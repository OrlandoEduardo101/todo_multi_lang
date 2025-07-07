package handlers

import (
	"os"
	"time"
	"todo_go_fiber/internal/database"
	"todo_go_fiber/internal/models"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v4"
	"golang.org/x/crypto/bcrypt"
)

type RegisterInput struct {
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

// Register é o handler para registrar um novo usuário
// @Summary      Registrar Usuário
// @Description  Registra um novo usuário com nome, email e senha
// @Tags         Users
// @Accept       json
// @Produce      json
// @Param        input body RegisterInput true "Dados do usuário"
// @Success      201 {object} models.UserResponse
// @Failure      400 {object} models.ErrorResponse
// @Failure      500 {object} models.ErrorResponse
// @Router       /register [post]
func Register(c *fiber.Ctx) error {
	var input RegisterInput

	if err := c.BodyParser(&input); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "Dados inválidos"})
	}

	// Verifica se o email já está em uso
	var existing models.User
	if err := database.DB.Where("email = ?", input.Email).First(&existing).Error; err == nil {
		return c.Status(400).JSON(fiber.Map{"error": "Email já registrado"})
	}

	// Criptografar a senha
	hash, err := bcrypt.GenerateFromPassword([]byte(input.Password), 14)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Erro ao gerar hash da senha"})
	}

	user := models.User{
		Name:     input.Name,
		Email:    input.Email,
		Password: string(hash),
	}

	// Salvar no banco
	if err := database.DB.Create(&user).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Erro ao salvar usuário"})
	}

	return c.Status(201).JSON(fiber.Map{
		"message": "Usuário registrado com sucesso",
		"user": fiber.Map{
			"id":    user.ID,
			"name":  user.Name,
			"email": user.Email,
		},
	})
}

// Login é o handler para autenticar um usuário
// @Summary      Login de Usuário
// @Description  Autentica um usuário com email e senha, retornando um token JWT
// @Tags         Users
// @Accept       json
// @Produce      json
// @Param        input body RegisterInput true "Dados do usuário"
// @Success      200 {object} models.LoginResponse
// @Failure      400 {object} models.ErrorResponse
// @Failure      401 {object} models.ErrorResponse
// @Failure      500 {object} models.ErrorResponse
// @Router       /login [post]
func Login(c *fiber.Ctx) error {
	var input RegisterInput

	if err := c.BodyParser(&input); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "Dados inválidos"})
	}

	var user models.User
	if err := database.DB.Where("email = ?", input.Email).First(&user).Error; err != nil {
		return c.Status(401).JSON(fiber.Map{"error": "Usuário ou senha inválidos"})
	}

	// Verifica a senha
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.Password)); err != nil {
		return c.Status(401).JSON(fiber.Map{"error": "Usuário ou senha inválidos"})
	}

	// Criar token JWT
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": user.ID,
		"exp":     time.Now().Add(time.Hour * 72).Unix(), // expira em 3 dias
	})

	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		return c.Status(500).JSON(fiber.Map{"error": "Chave secreta JWT não configurada"})
	}

	tokenString, err := token.SignedString([]byte(secret))
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Erro ao gerar token"})
	}

	return c.JSON(fiber.Map{
		"message": "Login realizado com sucesso",
		"token":   tokenString,
	})
}
