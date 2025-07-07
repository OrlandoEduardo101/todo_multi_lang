package routes

import (
	"todo_go_fiber/internal/handlers"

	"github.com/gofiber/fiber/v2"
)

// SetupAuthRoutes configura as rotas de autenticação
func SetupAuthRoutes(app *fiber.App) {
	// Rotas públicas de autenticação
	app.Post("/register", handlers.Register)
	app.Post("/login", handlers.Login)
}
