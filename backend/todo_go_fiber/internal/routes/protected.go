package routes

import (
	"todo_go_fiber/internal/middlewares"

	"github.com/gofiber/fiber/v2"
)

// SetupProtectedRoutes configura rotas protegidas gerais
func SetupProtectedRoutes(app *fiber.App) {
	// Grupo de rotas protegidas
	protected := app.Group("/api", middlewares.Protected())

	// Rota para obter informações do usuário autenticado
	// @Summary      Informações do Usuário
	// @Description  Retorna informações do usuário autenticado
	// @Tags         Users
	// @Produce      json
	// @Success      200   {object}  models.MeResponse
	// @Router       /api/me [get]
	// @Security     BearerAuth
	protected.Get("/me", func(c *fiber.Ctx) error {
		userID := c.Locals("user_id")
		return c.JSON(fiber.Map{
			"message": "Área protegida",
			"user_id": userID,
		})
	})

	// Configurar rotas de todos
	SetupTodoRoutes(protected)

	// Aqui você pode adicionar outras rotas protegidas gerais
	// que não se encaixam em categorias específicas como todos
}
