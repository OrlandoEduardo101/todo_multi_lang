#!/usr/bin/env bash
set -euo pipefail

GO_URL="${GO_URL:-http://localhost:3000}"
JAVA_URL="${JAVA_URL:-http://localhost:8081}"
DART_URL="${DART_URL:-http://localhost:8080}"

EMAIL="cross_go_$(date +%s)@test.com"
PASSWORD="123456"
NAME="Cross Go User"

echo "==> 1) Register no GO"
GO_REG_STATUS=$(curl -s -o /tmp/go_reg.json -w "%{http_code}" \
  -X POST "$GO_URL/register" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"$NAME\",\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")
echo "GO register status: $GO_REG_STATUS"
[[ "$GO_REG_STATUS" == "201" || "$GO_REG_STATUS" == "200" ]] || { echo "FAIL: register GO"; cat /tmp/go_reg.json; exit 1; }

echo "==> 2) Login no GO (controle)"
GO_LOGIN_STATUS=$(curl -s -o /tmp/go_login.json -w "%{http_code}" \
  -X POST "$GO_URL/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")
echo "GO login status: $GO_LOGIN_STATUS"
[[ "$GO_LOGIN_STATUS" == "200" ]] || { echo "FAIL: login GO"; cat /tmp/go_login.json; exit 1; }

echo "==> 3) Login no JAVA com usuário criado no GO"
JAVA_LOGIN_STATUS=$(curl -s -o /tmp/java_login.json -w "%{http_code}" \
  -X POST "$JAVA_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")
echo "JAVA login status: $JAVA_LOGIN_STATUS"
[[ "$JAVA_LOGIN_STATUS" == "200" ]] || { echo "FAIL: login JAVA"; cat /tmp/java_login.json; exit 1; }

echo "==> 4) Login no DART com usuário criado no GO"
DART_LOGIN_STATUS=$(curl -s -o /tmp/dart_login.json -w "%{http_code}" \
  -X POST "$DART_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")
echo "DART login status: $DART_LOGIN_STATUS"
[[ "$DART_LOGIN_STATUS" == "200" ]] || { echo "FAIL: login DART"; cat /tmp/dart_login.json; exit 1; }

echo "✅ CONSTATAÇÃO: usuário criado no GO loga no JAVA e no DART."
