package routes

import (
	_ "todo_go_fiber/docs" // Importa a documentação gerada pelo swag

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/swagger"
)

// SetupRoutes configura todas as rotas da aplicação
func SetupRoutes(app *fiber.App) {
	// Rota raiz
	app.Get("/", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"message": "API TODO em Go!",
		})
	})

	// Documentação Swagger
	app.Get("/docs/*", swagger.HandlerDefault) // acessível em /docs/index.html

	// Configurar rotas de autenticação
	SetupAuthRoutes(app)

	// Configurar rotas protegidas (exemplo do /me)
	SetupProtectedRoutes(app)
}
