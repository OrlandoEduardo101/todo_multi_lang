package handlers

import (
	"fmt"
	"todo_go_fiber/internal/database"
	"todo_go_fiber/internal/models"

	"github.com/gofiber/fiber/v2"
)

// GetTodos retorna uma lista de tarefas do usuário com suporte a paginação, filtros e ordenação
// @Summary      Listar Tarefas
// @Description  Retorna uma lista de tarefas do usuário com suporte a paginação, filtros e ordenação
// @Tags         Todos
// @Produce      json
// @Param        page     query     int    false  "Número da página"  default(1)
// @Param        limit    query     int    false  "Número de itens por página"  default(10) minimum(1) maximum(100)
// @Param        search   query	string false  "Filtro de pesquisa pelo título da tarefa"
// @Param        completed query    string false  "Filtro de tarefas concluídas (true, false ou vazio)"
// @Param        sort     query     string false  "Campo para ordenação (created_at, title, completed)" default(created_at) enum(created_at,title,completed)
// @Param        order	query     string false  "Direção da ordenação (asc, desc)" default(desc)
// @Success      200   {object}  models.TodoListResponse
// @Failure      500   {object}  models.ErrorResponse
// @Router       /api/todos [get]
// @Security     BearerAuth
func GetTodos(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(uint)

	// Paginação
	page := c.QueryInt("page", 1)
	limit := c.QueryInt("limit", 10)
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 10
	}
	offset := (page - 1) * limit

	// Filtros
	search := c.Query("search", "")
	completed := c.Query("completed") // "true", "false", ou vazio

	// Ordenação

	sortField := c.Query("sort", "created_at")
	sortOrder := c.Query("order", "desc") // asc ou desc

	// Validações de ordenação
	// Permite apenas campos específicos para evitar SQL Injection
	// e define valores padrão se necessário
	// Aqui, "created_at", "title", e "completed" são os únicos campos
	// permitidos para ordenação.
	// Se o campo não for permitido, usa "created_at" como padrão.
	// E se a ordem não for "asc" ou "desc", usa "desc"
	// como padrão.
	allowedSorts := map[string]bool{
		"created_at": true,
		"title":      true,
		"completed":  true,
	}
	if !allowedSorts[sortField] {
		sortField = "created_at"
	}

	if sortOrder != "asc" && sortOrder != "desc" {
		sortOrder = "desc"
	}

	// Monta a query base
	query := database.DB.
		Where("user_id = ?", userID)

	if search != "" {
		query = query.Where("LOWER(title) LIKE LOWER(?)", "%"+search+"%")
	}

	if completed != "" {
		if completed == "true" {
			query = query.Where("completed = ?", true)
		} else if completed == "false" {
			query = query.Where("completed = ?", false)
		}
	}

	// Executa consulta com paginação e ordenação
	var todos []models.Todo
	err := query.
		Order(fmt.Sprintf("%s %s", sortField, sortOrder)).
		Offset(offset).
		Limit(limit).
		Find(&todos).Error

	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Erro ao buscar tarefas"})
	}

	return c.JSON(fiber.Map{
		"page":  page,
		"limit": limit,
		"filters": fiber.Map{
			"search":    search,
			"completed": completed,
			"sort":      sortField,
			"order":     sortOrder,
		},
		"results": todos,
	})
}

type CreateTodoInput struct {
	Title string `json:"title"`
}

// CreateTodo cria uma nova tarefa para o usuário autenticado
// @Summary      Criar Tarefa
// @Description  Cria uma nova tarefa para o usuário autenticado
// @Tags         Todos
// @Accept       json
// @Produce      json
// @Param        todo  body      CreateTodoInput  true  "Dados da tarefa"
// @Success      201   {object}  models.Todo
// @Failure      400   {object}  models.ErrorResponse
// @Failure      500   {object}  models.ErrorResponse
// @Router       /api/todos [post]
// @Security     BearerAuth
func CreateTodo(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(uint)

	var input CreateTodoInput
	if err := c.BodyParser(&input); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "Dados inválidos"})
	}

	if input.Title == "" {
		return c.Status(400).JSON(fiber.Map{"error": "O título é obrigatório"})
	}

	todo := models.Todo{
		UserID: userID,
		Title:  input.Title,
	}

	if err := database.DB.Create(&todo).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Erro ao criar tarefa"})
	}

	return c.Status(201).JSON(todo)
}

type UpdateTodoInput struct {
	Title     *string `json:"title"`
	Completed *bool   `json:"completed"`
}

// UpdateTodo atualiza uma tarefa existente do usuário autenticado
// @Summary      Atualizar Tarefa
// @Description  Atualiza uma tarefa existente do usuário autenticado
// @Tags         Todos
// @Accept       json
// @Produce      json
// @Param        id    path      int                true  "ID da tarefa"
// @Param        todo  body      UpdateTodoInput    true  "Dados da tarefa"
// @Success      200   {object}  models.Todo
// @Failure      400   {object}  models.ErrorResponse
// @Failure      404   {object}  models.ErrorResponse
// @Failure      500   {object}  models.ErrorResponse
// @Router       /api/todos/{id} [put]
// @Security     BearerAuth
func UpdateTodo(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(uint)
	todoID := c.Params("id")

	var todo models.Todo
	if err := database.DB.
		Where("id = ? AND user_id = ?", todoID, userID).
		First(&todo).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"error": "Tarefa não encontrada"})
	}

	var input UpdateTodoInput
	if err := c.BodyParser(&input); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "Dados inválidos"})
	}

	if input.Title != nil {
		todo.Title = *input.Title
	}
	if input.Completed != nil {
		todo.Completed = *input.Completed
	}

	if err := database.DB.Save(&todo).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Erro ao atualizar tarefa"})
	}

	return c.JSON(todo)
}

// UpdateTodo atualiza uma tarefa existente do usuário autenticado
// @Summary      Atualizar Tarefa
// @Description  Atualiza uma tarefa existente do usuário autenticado
// @Tags         Todos
// @Accept       json
// @Produce      json
// @Param        id    path      int                true  "ID da tarefa"
// @Success      200   {object}  models.DeleteTodoResponse
// @Failure      400   {object}  models.ErrorResponse
// @Failure      404   {object}  models.ErrorResponse
// @Failure      500   {object}  models.ErrorResponse
// @Router       /api/todos/{id} [delete]
// @Security     BearerAuth
func DeleteTodo(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(uint)
	todoID := c.Params("id")

	var todo models.Todo
	if err := database.DB.
		Where("id = ? AND user_id = ?", todoID, userID).
		First(&todo).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"error": "Tarefa não encontrada"})
	}

	if err := database.DB.Delete(&todo).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Erro ao deletar tarefa"})
	}

	return c.JSON(fiber.Map{
		"message": "Tarefa deletada com sucesso",
	})
}
