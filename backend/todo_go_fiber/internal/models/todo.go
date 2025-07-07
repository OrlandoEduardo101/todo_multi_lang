package models

import "time"

type Todo struct {
	ID        uint      `gorm:"primaryKey"`
	UserID    uint      `gorm:"not null"` // chave estrangeira
	Title     string    `gorm:"not null"`
	Completed bool      `gorm:"default:false"`
	CreatedAt time.Time `gorm:"autoCreateTime"`
}
