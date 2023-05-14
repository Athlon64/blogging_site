package models

import "time"

type Tag struct {
	ID        uint `gorm:"primarykey"`
	CreatedAt time.Time
	UpdatedAt time.Time

	Tag string `gorm:"unique"`

	Articles []Article `gorm:"many2many:article_tags"`
}
