package main

import (
	"todo_go_fiber/internal/database"
	"todo_go_fiber/internal/routes"

	"github.com/gofiber/fiber/v2"
)

// @title           Todo API em Go
// @version         1.0
// @description     API REST para gerenciamento de tarefas.
// @host            0.0.0.0:3000
// @BasePath        /
func main() {
	app := fiber.New()

	// Conectar ao banco
	database.Connect()

	// Configurar todas as rotas
	routes.SetupRoutes(app)

	app.Listen("0.0.0.0:3000")
}
