#!/usr/bin/env python3
import argparse
import json
import math
import statistics
import time
import uuid
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def percentile(values: List[float], p: float) -> float:
    if not values:
        return 0.0
    if len(values) == 1:
        return values[0]
    sorted_values = sorted(values)
    k = (len(sorted_values) - 1) * (p / 100.0)
    f = math.floor(k)
    c = math.ceil(k)
    if f == c:
        return sorted_values[int(k)]
    d0 = sorted_values[f] * (c - k)
    d1 = sorted_values[c] * (k - f)
    return d0 + d1


def json_dumps(data: Dict[str, Any]) -> bytes:
    return json.dumps(data, ensure_ascii=False).encode("utf-8")


def http_call(
    method: str,
    url: str,
    payload: Optional[Dict[str, Any]] = None,
    headers: Optional[Dict[str, str]] = None,
    timeout: int = 15,
) -> Dict[str, Any]:
    req_headers = {"Accept": "application/json"}
    if headers:
        req_headers.update(headers)

    body = None
    if payload is not None:
        body = json_dumps(payload)
        req_headers.setdefault("Content-Type", "application/json")

    req = Request(url=url, data=body, headers=req_headers, method=method.upper())
    started = time.perf_counter()
    status = 0
    raw_text = ""
    parsed: Any = None
    error: Optional[str] = None

    try:
        with urlopen(req, timeout=timeout) as resp:
            status = resp.getcode() or 0
            raw = resp.read()
            raw_text = raw.decode("utf-8", errors="replace")
    except HTTPError as e:
        status = e.code
        raw_text = e.read().decode("utf-8", errors="replace")
    except URLError as e:
        error = f"URLError: {e}"
    except Exception as e:
        error = f"Exception: {e}"

    ended = time.perf_counter()
    duration_ms = (ended - started) * 1000.0

    if raw_text:
        try:
            parsed = json.loads(raw_text)
        except Exception:
            parsed = None

    return {
        "status": status,
        "ok": error is None and 200 <= status < 300,
        "duration_ms": round(duration_ms, 3),
        "response_size": len(raw_text.encode("utf-8", errors="ignore")),
        "json": parsed,
        "text": raw_text,
        "error": error,
    }


@dataclass
class BackendConfig:
    name: str
    base_url: str


def endpoint_url(base_url: str, path: str) -> str:
    return f"{base_url.rstrip('/')}/{path.lstrip('/')}"


def extract_token(payload: Any) -> str:
    if isinstance(payload, dict):
        token = payload.get("token") or payload.get("access_token")
        if isinstance(token, str):
            return token
    return ""


def extract_todo_id(payload: Any) -> str:
    if isinstance(payload, dict):
        for key in ("id", "ID"):
            value = payload.get(key)
            if isinstance(value, str):
                return value
    return ""


def record_call(
    records: List[Dict[str, Any]],
    backend: str,
    endpoint: str,
    method: str,
    path: str,
    result: Dict[str, Any],
    expected_statuses: Tuple[int, ...] = (200, 201),
    meta: Optional[Dict[str, Any]] = None,
) -> Dict[str, Any]:
    expected_ok = result["status"] in expected_statuses and result["error"] is None
    rec = {
        "timestamp": now_iso(),
        "backend": backend,
        "endpoint": endpoint,
        "method": method,
        "path": path,
        "status": result["status"],
        "ok": expected_ok,
        "duration_ms": result["duration_ms"],
        "response_size": result["response_size"],
        "error": result["error"],
    }
    if meta:
        rec.update(meta)
    records.append(rec)
    return rec


def wait_for_backend(base_url: str, timeout_seconds: int = 45) -> bool:
    deadline = time.time() + timeout_seconds
    health_paths = ["/health", "/"]

    while time.time() < deadline:
        for path in health_paths:
            try:
                req = Request(url=endpoint_url(base_url, path), method="GET")
                with urlopen(req, timeout=3):
                    return True
            except HTTPError:
                return True
            except Exception:
                pass
        time.sleep(1)
    return False


def benchmark_repeats(
    records: List[Dict[str, Any]],
    backend: str,
    endpoint: str,
    method: str,
    url: str,
    path: str,
    repeats: int,
    warmup: int = 0,
    headers: Optional[Dict[str, str]] = None,
) -> None:
    for _ in range(max(0, warmup)):
        http_call(method, url, headers=headers)

    for i in range(1, repeats + 1):
        result = http_call(method, url, headers=headers)
        record_call(
            records,
            backend=backend,
            endpoint=f"{endpoint} [bench]",
            method=method,
            path=path,
            result=result,
            expected_statuses=(200,),
            meta={"repeat": i},
        )


def try_login(
    config: BackendConfig,
    records: List[Dict[str, Any]],
    login_path: str,
    email: str,
    password: str,
    seed_email: Optional[str],
    seed_password: Optional[str],
) -> str:
    login_payload = {"email": email, "password": password}
    login_res = http_call("POST", endpoint_url(config.base_url, login_path), payload=login_payload)
    record_call(records, config.name, "login", "POST", login_path, login_res, expected_statuses=(200,))
    token = extract_token(login_res.get("json"))
    if token:
        return token

    if seed_email and seed_password:
        seed_payload = {"email": seed_email, "password": seed_password}
        seed_login = http_call("POST", endpoint_url(config.base_url, login_path), payload=seed_payload)
        record_call(
            records,
            config.name,
            "login_seed_fallback",
            "POST",
            login_path,
            seed_login,
            expected_statuses=(200,),
        )
        return extract_token(seed_login.get("json"))

    return ""


def run_java(
    config: BackendConfig,
    records: List[Dict[str, Any]],
    repeats: int,
    warmup: int,
    seed_email: Optional[str],
    seed_password: Optional[str],
) -> None:
    suffix = uuid.uuid4().hex[:8]
    email = f"bench_java_{suffix}@test.com"
    password = "123456"

    register_path = "/auth/register"
    register_payload = {"email": email, "password": password, "name": "Bench Java"}
    register_res = http_call("POST", endpoint_url(config.base_url, register_path), payload=register_payload)
    record_call(records, config.name, "register", "POST", register_path, register_res, expected_statuses=(201, 400))

    login_path = "/auth/login"
    token = try_login(config, records, login_path, email, password, seed_email, seed_password)
    auth_headers = {"Authorization": f"Bearer {token}"} if token else {}

    list_path = "/api/todos"
    list_res = http_call("GET", endpoint_url(config.base_url, list_path), headers=auth_headers)
    record_call(records, config.name, "list_todos", "GET", list_path, list_res, expected_statuses=(200,))

    create_path = "/api/todos"
    create_payload = {"title": "Bench Java Todo", "description": "created by benchmark", "completed": False}
    create_res = http_call("POST", endpoint_url(config.base_url, create_path), payload=create_payload, headers=auth_headers)
    record_call(records, config.name, "create_todo", "POST", create_path, create_res, expected_statuses=(201, 200))

    todo_id = extract_todo_id(create_res.get("json"))

    if todo_id:
        get_path = f"/api/todos/{todo_id}"
        get_res = http_call("GET", endpoint_url(config.base_url, get_path), headers=auth_headers)
        record_call(records, config.name, "get_todo", "GET", get_path, get_res, expected_statuses=(200,))

        update_path = f"/api/todos/{todo_id}"
        update_payload = {"title": "Bench Java Todo Updated", "description": "updated", "completed": True}
        update_res = http_call("PUT", endpoint_url(config.base_url, update_path), payload=update_payload, headers=auth_headers)
        record_call(records, config.name, "update_todo", "PUT", update_path, update_res, expected_statuses=(200,))

        delete_path = f"/api/todos/{todo_id}"
        delete_res = http_call("DELETE", endpoint_url(config.base_url, delete_path), headers=auth_headers)
        record_call(records, config.name, "delete_todo", "DELETE", delete_path, delete_res, expected_statuses=(200,))

    benchmark_repeats(
        records,
        backend=config.name,
        endpoint="list_todos",
        method="GET",
        url=endpoint_url(config.base_url, list_path),
        path=list_path,
        repeats=repeats,
        warmup=warmup,
        headers=auth_headers,
    )


def run_go(
    config: BackendConfig,
    records: List[Dict[str, Any]],
    repeats: int,
    warmup: int,
    seed_email: Optional[str],
    seed_password: Optional[str],
) -> None:
    suffix = uuid.uuid4().hex[:8]
    email = f"bench_go_{suffix}@test.com"
    password = "123456"

    register_path = "/auth/register"
    register_payload = {"name": "Bench Go", "email": email, "password": password}
    register_res = http_call("POST", endpoint_url(config.base_url, register_path), payload=register_payload)
    record_call(records, config.name, "register", "POST", register_path, register_res, expected_statuses=(201, 400))

    login_path = "/auth/login"
    token = try_login(config, records, login_path, email, password, seed_email, seed_password)
    auth_headers = {"Authorization": f"Bearer {token}"} if token else {}

    me_path = "/api/me"
    me_res = http_call("GET", endpoint_url(config.base_url, me_path), headers=auth_headers)
    record_call(records, config.name, "me", "GET", me_path, me_res, expected_statuses=(200,))

    list_path = "/api/todos"
    list_res = http_call("GET", endpoint_url(config.base_url, list_path), headers=auth_headers)
    record_call(records, config.name, "list_todos", "GET", list_path, list_res, expected_statuses=(200,))

    create_path = "/api/todos"
    create_payload = {"title": "Bench Go Todo", "description": "created by benchmark", "completed": False}
    create_res = http_call("POST", endpoint_url(config.base_url, create_path), payload=create_payload, headers=auth_headers)
    record_call(records, config.name, "create_todo", "POST", create_path, create_res, expected_statuses=(200, 201))

    todo_id = extract_todo_id(create_res.get("json"))
    if todo_id:
        update_path = f"/api/todos/{todo_id}"
        update_payload = {"title": "Bench Go Todo Updated", "description": "updated", "completed": True}
        update_res = http_call("PUT", endpoint_url(config.base_url, update_path), payload=update_payload, headers=auth_headers)
        record_call(records, config.name, "update_todo", "PUT", update_path, update_res, expected_statuses=(200,))

        delete_path = f"/api/todos/{todo_id}"
        delete_res = http_call("DELETE", endpoint_url(config.base_url, delete_path), headers=auth_headers)
        record_call(records, config.name, "delete_todo", "DELETE", delete_path, delete_res, expected_statuses=(200,))

    benchmark_repeats(
        records,
        backend=config.name,
        endpoint="list_todos",
        method="GET",
        url=endpoint_url(config.base_url, list_path),
        path=list_path,
        repeats=repeats,
        warmup=warmup,
        headers=auth_headers,
    )


def run_dart(
    config: BackendConfig,
    records: List[Dict[str, Any]],
    repeats: int,
    warmup: int,
    seed_email: Optional[str],
    seed_password: Optional[str],
) -> None:
    suffix = uuid.uuid4().hex[:8]
    email = f"bench_dart_{suffix}@test.com"
    password = "123456"

    register_path = "/auth/register"
    register_payload = {
        "firstName": "Bench",
        "lastName": "Dart",
        "email": email,
        "password": password,
    }
    register_res = http_call("POST", endpoint_url(config.base_url, register_path), payload=register_payload)
    record_call(records, config.name, "register", "POST", register_path, register_res, expected_statuses=(200, 201, 409))

    login_path = "/auth/login"
    token = try_login(config, records, login_path, email, password, seed_email, seed_password)
    auth_headers = {"Authorization": f"Bearer {token}"} if token else {}

    list_path = "/api/todos"
    list_res = http_call("GET", endpoint_url(config.base_url, list_path), headers=auth_headers)
    record_call(records, config.name, "list_todos", "GET", list_path, list_res, expected_statuses=(200,))

    create_path = "/api/todos"
    create_payload = {"title": "Bench Dart Todo", "description": "created by benchmark"}
    create_res = http_call("POST", endpoint_url(config.base_url, create_path), payload=create_payload, headers=auth_headers)
    record_call(records, config.name, "create_todo", "POST", create_path, create_res, expected_statuses=(200, 201))

    todo_id = extract_todo_id(create_res.get("json"))

    if todo_id:
        get_path = f"/api/todos/{todo_id}"
        get_res = http_call("GET", endpoint_url(config.base_url, get_path), headers=auth_headers)
        record_call(records, config.name, "get_todo", "GET", get_path, get_res, expected_statuses=(200,))

        update_path = f"/api/todos/{todo_id}"
        update_payload = {"title": "Bench Dart Todo Updated", "description": "updated", "completed": True}
        update_res = http_call("PUT", endpoint_url(config.base_url, update_path), payload=update_payload, headers=auth_headers)
        record_call(records, config.name, "update_todo", "PUT", update_path, update_res, expected_statuses=(200,))

        delete_path = f"/api/todos/{todo_id}"
        delete_res = http_call("DELETE", endpoint_url(config.base_url, delete_path), headers=auth_headers)
        record_call(records, config.name, "delete_todo", "DELETE", delete_path, delete_res, expected_statuses=(200,))

    benchmark_repeats(
        records,
        backend=config.name,
        endpoint="list_todos",
        method="GET",
        url=endpoint_url(config.base_url, list_path),
        path=list_path,
        repeats=repeats,
        warmup=warmup,
        headers=auth_headers,
    )


def summarize(records: List[Dict[str, Any]]) -> Dict[str, Any]:
    def endpoint_suite(endpoint_name: str) -> str:
        auth_prefixes = ("register", "login", "login_seed_fallback", "me")
        if endpoint_name.startswith(auth_prefixes):
            return "AUTH"
        return "CRUD"

    backend_names = sorted({r["backend"] for r in records})

    backend_summary: Dict[str, Dict[str, Any]] = {}
    for backend in backend_names:
        subset = [r for r in records if r["backend"] == backend]
        latencies = [r["duration_ms"] for r in subset]
        passed = sum(1 for r in subset if r["ok"])
        total = len(subset)
        backend_summary[backend] = {
            "total": total,
            "passed": passed,
            "failed": total - passed,
            "pass_rate": round((passed / total) * 100.0, 2) if total else 0.0,
            "avg_ms": round(statistics.mean(latencies), 3) if latencies else 0.0,
            "p95_ms": round(percentile(latencies, 95), 3) if latencies else 0.0,
        }

    suite_summary: Dict[str, Dict[str, Dict[str, Any]]] = {}
    for backend in backend_names:
        suite_summary[backend] = {
            "AUTH": {"total": 0, "passed": 0, "latencies": []},
            "CRUD": {"total": 0, "passed": 0, "latencies": []},
        }

    for r in records:
        backend = r["backend"]
        suite = endpoint_suite(r["endpoint"])
        suite_summary[backend][suite]["total"] += 1
        suite_summary[backend][suite]["passed"] += 1 if r["ok"] else 0
        suite_summary[backend][suite]["latencies"].append(r["duration_ms"])

    suite_summary_rows: List[Dict[str, Any]] = []
    for backend in backend_names:
        for suite in ("AUTH", "CRUD"):
            item = suite_summary[backend][suite]
            total = item["total"]
            passed = item["passed"]
            latencies = item["latencies"]
            suite_summary_rows.append(
                {
                    "backend": backend,
                    "suite": suite,
                    "total": total,
                    "passed": passed,
                    "failed": total - passed,
                    "pass_rate": round((passed / total) * 100.0, 2) if total else 0.0,
                    "avg_ms": round(statistics.mean(latencies), 3) if latencies else 0.0,
                    "p95_ms": round(percentile(latencies, 95), 3) if latencies else 0.0,
                }
            )

    endpoint_summary: Dict[str, Dict[str, Any]] = {}
    for r in records:
        key = f"{r['backend']}::{r['method']}::{r['path']}::{r['endpoint']}"
        endpoint_summary.setdefault(key, {
            "backend": r["backend"],
            "endpoint": r["endpoint"],
            "method": r["method"],
            "path": r["path"],
            "count": 0,
            "passed": 0,
            "latencies": [],
            "statuses": [],
        })
        endpoint_summary[key]["count"] += 1
        endpoint_summary[key]["passed"] += 1 if r["ok"] else 0
        endpoint_summary[key]["latencies"].append(r["duration_ms"])
        endpoint_summary[key]["statuses"].append(r["status"])

    endpoint_rows: List[Dict[str, Any]] = []
    for _, item in endpoint_summary.items():
        endpoint_rows.append({
            "backend": item["backend"],
            "endpoint": item["endpoint"],
            "method": item["method"],
            "path": item["path"],
            "count": item["count"],
            "passed": item["passed"],
            "pass_rate": round((item["passed"] / item["count"]) * 100.0, 2) if item["count"] else 0.0,
            "avg_ms": round(statistics.mean(item["latencies"]), 3) if item["latencies"] else 0.0,
            "p95_ms": round(percentile(item["latencies"], 95), 3) if item["latencies"] else 0.0,
            "last_status": item["statuses"][-1] if item["statuses"] else 0,
        })

    endpoint_rows.sort(key=lambda x: (x["backend"], x["endpoint"], x["path"]))
    suite_summary_rows.sort(key=lambda x: (x["backend"], x["suite"]))

    return {
        "by_backend": backend_summary,
        "by_suite_backend": suite_summary_rows,
        "by_endpoint": endpoint_rows,
    }


def mermaid_avg_latency(summary: Dict[str, Any]) -> str:
    items = sorted(summary["by_backend"].items(), key=lambda x: x[0])
    labels = [name for name, _ in items]
    values = [data["avg_ms"] for _, data in items]
    top = max(values) if values else 10.0
    y_max = max(10, int(math.ceil(top / 10.0) * 10 + 10))
    return "\n".join([
        "```mermaid",
        "xychart-beta",
        '  title "Average latency by backend (ms)"',
        f"  x-axis [{', '.join([json.dumps(l) for l in labels])}]",
        f'  y-axis "ms" 0 --> {y_max}',
        f"  bar [{', '.join([str(v) for v in values])}]",
        "```",
    ])


def mermaid_pass_rate(summary: Dict[str, Any]) -> str:
    items = sorted(summary["by_backend"].items(), key=lambda x: x[0])
    blocks = []
    for name, data in items:
        blocks.extend([
            "```mermaid",
            "pie showData",
            f'  title "Pass vs Fail - {name}"',
            f'  "Pass" : {data["passed"]}',
            f'  "Fail" : {data["failed"]}',
            "```",
            "",
        ])
    return "\n".join(blocks).strip()


def generate_markdown(
    started_at: str,
    finished_at: str,
    output_json_path: Path,
    summary: Dict[str, Any],
) -> str:
    lines: List[str] = []
    lines.append("# Backend Benchmark Report")
    lines.append("")
    lines.append(f"- Started (UTC): {started_at}")
    lines.append(f"- Finished (UTC): {finished_at}")
    lines.append(f"- Raw data: {output_json_path.as_posix()}")
    lines.append("")

    lines.append("## Backend Summary")
    lines.append("")
    lines.append("| Backend | Total | Passed | Failed | Pass Rate (%) | Avg (ms) | P95 (ms) |")
    lines.append("|---|---:|---:|---:|---:|---:|---:|")
    for backend, data in sorted(summary["by_backend"].items(), key=lambda x: x[0]):
        lines.append(
            f"| {backend} | {data['total']} | {data['passed']} | {data['failed']} | {data['pass_rate']} | {data['avg_ms']} | {data['p95_ms']} |"
        )

    lines.append("")
    lines.append("## Legend")
    lines.append("")
    lines.append("- **Total**: number of recorded HTTP attempts in that grouping (not unique endpoints).")
    lines.append("- **Passed**: attempts that matched expected statuses for each endpoint.")
    lines.append("- **Failed**: attempts with unexpected status or transport/runtime error.")
    lines.append("- **Pass Rate (%)**: `Passed / Total * 100`.")
    lines.append("- **Runs** (Endpoint Results): attempts executed for that specific endpoint row.")
    lines.append("- **Warmup** calls are not recorded in totals; they are only used to stabilize measurements.")
    lines.append("- **AUTH** suite includes `register`, `login`, `login_seed_fallback`, and `me`.")
    lines.append("- **CRUD** suite includes todo read/write endpoints and benchmark list calls.")
    lines.append("")

    lines.append("")
    lines.append("## Suite Summary (AUTH vs CRUD)")
    lines.append("")
    lines.append("| Backend | Suite | Total | Passed | Failed | Pass Rate (%) | Avg (ms) | P95 (ms) |")
    lines.append("|---|---|---:|---:|---:|---:|---:|---:|")
    for row in summary["by_suite_backend"]:
        lines.append(
            f"| {row['backend']} | {row['suite']} | {row['total']} | {row['passed']} | {row['failed']} | {row['pass_rate']} | {row['avg_ms']} | {row['p95_ms']} |"
        )

    lines.append("")
    lines.append("## Charts")
    lines.append("")
    lines.append(mermaid_avg_latency(summary))
    lines.append("")
    lines.append(mermaid_pass_rate(summary))
    lines.append("")

    lines.append("## Endpoint Results")
    lines.append("")
    lines.append("| Backend | Endpoint | Method | Path | Runs | Passed | Pass Rate (%) | Avg (ms) | P95 (ms) | Last Status |")
    lines.append("|---|---|---|---|---:|---:|---:|---:|---:|---:|")
    for row in summary["by_endpoint"]:
        lines.append(
            f"| {row['backend']} | {row['endpoint']} | {row['method']} | {row['path']} | {row['count']} | {row['passed']} | {row['pass_rate']} | {row['avg_ms']} | {row['p95_ms']} | {row['last_status']} |"
        )

    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description="Benchmark and validate Java/Go/Dart backends")
    parser.add_argument("--java-url", default="http://localhost:8081", help="Java backend base URL")
    parser.add_argument("--go-url", default="http://localhost:3000", help="Go backend base URL")
    parser.add_argument("--dart-url", default="http://localhost:8080", help="Dart backend base URL")
    parser.add_argument("--repeats", type=int, default=5, help="Benchmark repeats for read endpoints")
    parser.add_argument("--warmup", type=int, default=0, help="Warmup runs before collecting benchmark timings")
    parser.add_argument("--strict", action="store_true", help="Exit with non-zero status if any check fails")
    parser.add_argument("--seed-email", default="cross@test.com", help="Fallback email if fresh login fails")
    parser.add_argument("--seed-password", default="123456", help="Fallback password if fresh login fails")
    parser.add_argument("--output-dir", default="reports/benchmark", help="Output directory for benchmark artifacts")
    args = parser.parse_args()

    started_at = now_iso()
    records: List[Dict[str, Any]] = []

    java = BackendConfig(name="java", base_url=args.java_url)
    go = BackendConfig(name="go", base_url=args.go_url)
    dart = BackendConfig(name="dart", base_url=args.dart_url)

    backend_readiness = {
        "java": wait_for_backend(java.base_url),
        "go": wait_for_backend(go.base_url),
        "dart": wait_for_backend(dart.base_url),
    }

    for backend_name, ready in backend_readiness.items():
        if not ready:
            records.append(
                {
                    "timestamp": now_iso(),
                    "backend": backend_name,
                    "endpoint": "backend_readiness",
                    "method": "GET",
                    "path": "/health",
                    "status": 0,
                    "ok": False,
                    "duration_ms": 0.0,
                    "response_size": 0,
                    "error": f"Backend {backend_name} not ready within timeout",
                }
            )

    if backend_readiness["java"]:
        run_java(java, records, args.repeats, args.warmup, args.seed_email, args.seed_password)
    if backend_readiness["go"]:
        run_go(go, records, args.repeats, args.warmup, args.seed_email, args.seed_password)
    if backend_readiness["dart"]:
        run_dart(dart, records, args.repeats, args.warmup, args.seed_email, args.seed_password)

    summary = summarize(records)
    finished_at = now_iso()

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
    json_path = output_dir / f"benchmark_{timestamp}.json"
    latest_json_path = output_dir / "benchmark_latest.json"
    report_path = output_dir / f"benchmark_report_{timestamp}.md"
    latest_report_path = output_dir / "benchmark_report_latest.md"

    payload = {
        "started_at": started_at,
        "finished_at": finished_at,
        "config": {
            "java_url": args.java_url,
            "go_url": args.go_url,
            "dart_url": args.dart_url,
            "repeats": args.repeats,
            "warmup": args.warmup,
            "strict": args.strict,
            "seed_email": args.seed_email,
        },
        "summary": summary,
        "records": records,
    }

    json_text = json.dumps(payload, indent=2, ensure_ascii=False)
    json_path.write_text(json_text, encoding="utf-8")
    latest_json_path.write_text(json_text, encoding="utf-8")

    md_text = generate_markdown(started_at, finished_at, latest_json_path, summary)
    report_path.write_text(md_text, encoding="utf-8")
    latest_report_path.write_text(md_text, encoding="utf-8")

    print(f"Benchmark JSON: {json_path.as_posix()}")
    print(f"Benchmark JSON (latest): {latest_json_path.as_posix()}")
    print(f"Benchmark report: {report_path.as_posix()}")
    print(f"Benchmark report (latest): {latest_report_path.as_posix()}")

    total_failed = sum(data.get("failed", 0) for data in summary.get("by_backend", {}).values())
    if args.strict and total_failed > 0:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
