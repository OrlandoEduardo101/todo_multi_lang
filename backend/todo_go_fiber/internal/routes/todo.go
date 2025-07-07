package routes

import (
	"todo_go_fiber/internal/handlers"

	"github.com/gofiber/fiber/v2"
)

// SetupTodoRoutes configura as rotas relacionadas aos todos
func SetupTodoRoutes(protected fiber.Router) {
	// Grupo de rotas protegidas para todos
	// todoGroup := app.Group("/api/todos", middlewares.Protected())

	// CRUD de todos
	protected.Post("/", handlers.CreateTodo)
	protected.Get("/", handlers.GetTodos)
	protected.Put("/:id", handlers.UpdateTodo)
	protected.Delete("/:id", handlers.DeleteTodo)
}
