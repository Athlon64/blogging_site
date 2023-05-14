package models

import "time"

type User struct {
	ID        uint `gorm:"primarykey"`
	CreatedAt time.Time
	UpdatedAt time.Time

	Username string `gorm:"unique"`
	Email    string `gorm:"unique"`
	Password string
	Avatar   string `gorm:"default:http://localhost:5000/default_avatar.png"`
	Image    string `gorm:"default:http://localhost:5000/default_background_image.png"`
	Bio      string `gorm:"default:这位用户很懒，没有留下任何言语..."`

	Followings []User `gorm:"many2many:user_followings"`
	Followers  []User `gorm:"many2many:user_followers"`

	Owns      []Article `gorm:"foreignKey:AuthorID"`
	Favorites []Article `gorm:"many2many:user_favorites"`
}
