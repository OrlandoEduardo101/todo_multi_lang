package models

import "time"

type User struct {
	ID        uint      `gorm:"primaryKey"`
	Name      string    `gorm:"not null"`
	Email     string    `gorm:"uniqueIndex;not null"`
	Password  string    `gorm:"not null"` // aqui vai o hash da senha
	CreatedAt time.Time `gorm:"autoCreateTime"`
}
