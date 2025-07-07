package database

import (
	"fmt"
	"log"
	"os"
	"todo_go_fiber/internal/models"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func Connect() {
	err := godotenv.Load(".env")
	if err != nil {
		log.Fatal("Erro ao carregar o arquivo .env")
	}

	host := os.Getenv("DB_HOST")
	port := os.Getenv("DB_PORT")
	user := os.Getenv("DB_USER")
	password := os.Getenv("DB_PASSWORD")
	dbname := os.Getenv("DB_NAME")

	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable",
		host, user, password, dbname, port,
	)

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Erro ao conectar no banco: ", err)
	}

	DB = db
	fmt.Println("✅ Conectado ao banco com sucesso")

	DB = db

	// Migração automática (verifica se a tabela já existe)
	db.AutoMigrate(&models.User{})
	db.AutoMigrate(&models.User{}, &models.Todo{})

	fmt.Println("✅ Conectado ao banco e tabela User pronta")
}
