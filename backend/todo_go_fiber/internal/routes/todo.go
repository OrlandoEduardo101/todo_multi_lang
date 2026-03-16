package routes

import (
	"todo_go_fiber/internal/handlers"

	"github.com/gofiber/fiber/v2"
)

// SetupTodoRoutes configura as rotas relacionadas aos todos
func SetupTodoRoutes(protected fiber.Router) {
	// Grupo de rotas protegidas para todos em /api/todos
	todos := protected.Group("/todos")

	// CRUD de todos
	todos.Post("/", handlers.CreateTodo)
	todos.Get("/", handlers.GetTodos)
	todos.Put("/:id", handlers.UpdateTodo)
	todos.Delete("/:id", handlers.DeleteTodo)
}
