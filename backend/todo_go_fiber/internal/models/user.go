package models

import "time"

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type User struct {
	ID        uuid.UUID      `gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	Name      string         `gorm:"not null"`
	Email     string         `gorm:"uniqueIndex;not null"`
	Password  string         `gorm:"not null"` // aqui vai o hash da senha
	CreatedAt time.Time      `gorm:"autoCreateTime"`
	UpdatedAt time.Time      `gorm:"autoUpdateTime"`
	DeletedAt gorm.DeletedAt `gorm:"index"`
}
