package models

import "time"

type Article struct {
	ID        uint `gorm:"primarykey"`
	CreatedAt time.Time
	UpdatedAt time.Time

	Slug     string `gorm:"unique"`
	Title    string
	Abstract string
	Body     string

	AuthorID uint
	Author   User `gorm:"foreignKey:AuthorID"`

	Tags []Tag `gorm:"many2many:article_tags"`

	FavoritedBy []User `gorm:"many2many:user_favorites"`

	Comments []Comment
}

type Comment struct {
	ID        uint `gorm:"primarykey"`
	CreatedAt time.Time
	UpdatedAt time.Time

	Body string

	AuthorID uint
	Author   User `gorm:"foreignKey:AuthorID"`

	ArticleID uint
}
