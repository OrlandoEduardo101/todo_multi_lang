package com.todo.dto.todo;

import java.util.List;

public class TodoListResponse {
    private int page;
    private int limit;
    private long total;
    private boolean hasMore;
    private List<TodoResponse> data;

    public TodoListResponse() {}

    public TodoListResponse(
            int page,
            int limit,
            long total,
            boolean hasMore,
            List<TodoResponse> data
    ) {
        this.page = page;
        this.limit = limit;
        this.total = total;
        this.hasMore = hasMore;
        this.data = data;
    }

    public int getPage() { return page; }
    public void setPage(int page) { this.page = page; }

    public int getLimit() { return limit; }
    public void setLimit(int limit) { this.limit = limit; }

    public long getTotal() { return total; }
    public void setTotal(long total) { this.total = total; }

    public boolean isHasMore() { return hasMore; }
    public void setHasMore(boolean hasMore) { this.hasMore = hasMore; }

    public List<TodoResponse> getData() { return data; }
    public void setData(List<TodoResponse> data) { this.data = data; }
}
