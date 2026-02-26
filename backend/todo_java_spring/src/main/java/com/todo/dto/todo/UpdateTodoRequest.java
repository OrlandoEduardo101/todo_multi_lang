package com.todo.dto.todo;

import jakarta.validation.constraints.Size;

public class UpdateTodoRequest {

    @Size(min = 3, max = 255, message = "Título deve ter entre 3 e 255 caracteres")
    private String title;

    @Size(max = 2000, message = "Descrição não pode ter mais de 2000 caracteres")
    private String description;

    private Boolean completed;

    public UpdateTodoRequest() {}

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Boolean getCompleted() { return completed; }
    public void setCompleted(Boolean completed) { this.completed = completed; }
}
