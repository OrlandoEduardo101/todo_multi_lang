package com.todo.dto.todo;

import java.util.List;

public class TodoListResponse {
    private int page;
    private int limit;
    private long total;
    private String search;
    private Boolean completed;
    private String sort;
    private String order;
    private List<TodoResponse> results;

    public TodoListResponse() {}

    public TodoListResponse(
            int page,
            int limit,
            long total,
            String search,
            Boolean completed,
            String sort,
            String order,
            List<TodoResponse> results
    ) {
        this.page = page;
        this.limit = limit;
        this.total = total;
        this.search = search;
        this.completed = completed;
        this.sort = sort;
        this.order = order;
        this.results = results;
    }

    public int getPage() { return page; }
    public void setPage(int page) { this.page = page; }

    public int getLimit() { return limit; }
    public void setLimit(int limit) { this.limit = limit; }

    public long getTotal() { return total; }
    public void setTotal(long total) { this.total = total; }

    public String getSearch() { return search; }
    public void setSearch(String search) { this.search = search; }

    public Boolean getCompleted() { return completed; }
    public void setCompleted(Boolean completed) { this.completed = completed; }

    public String getSort() { return sort; }
    public void setSort(String sort) { this.sort = sort; }

    public String getOrder() { return order; }
    public void setOrder(String order) { this.order = order; }

    public List<TodoResponse> getResults() { return results; }
    public void setResults(List<TodoResponse> results) { this.results = results; }
}
