package routes

import (
	"todo_go_fiber/internal/handlers"

	"github.com/gofiber/fiber/v2"
)

// SetupAuthRoutes configura as rotas de autenticação
func SetupAuthRoutes(app *fiber.App) {
	// Rotas públicas de autenticação (contrato padronizado)
	auth := app.Group("/auth")
	auth.Post("/register", handlers.Register)
	auth.Post("/login", handlers.Login)

	// Compatibilidade temporária com clientes legados.
	app.Post("/register", handlers.Register)
	app.Post("/login", handlers.Login)
}
