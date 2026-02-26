package models

import "time"

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Todo struct {
	ID          uuid.UUID      `gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	UserID      uuid.UUID      `gorm:"type:uuid;not null"` // chave estrangeira
	Title       string         `gorm:"not null"`
	Description *string        `gorm:"type:text"`
	Completed   bool           `gorm:"default:false"`
	CreatedAt   time.Time      `gorm:"autoCreateTime"`
	UpdatedAt   time.Time      `gorm:"autoUpdateTime"`
	DeletedAt   gorm.DeletedAt `gorm:"index"`
}
