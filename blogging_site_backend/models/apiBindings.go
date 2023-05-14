package models

import "time"

type UserRegisterForm struct {
	User struct {
		Username string `json:"username" binding:"required"`
		Email    string `json:"email" binding:"required,email"`
		Password string `json:"password" binding:"required"`
	} `json:"user"`
}

type UserRegisterResponse struct {
	Username string `json:"username"`
	Email    string `json:"email"`
	Token    string `json:"token"`
	Bio      string `json:"bio"`
	Avatar   string `json:"avatar"`
	Image    string `json:"image"`
}

type UserLoginForm struct {
	User struct {
		Email    string `json:"email" binding:"required,email"`
		Password string `json:"password" binding:"required"`
	} `json:"user"`
}

type UserSettingsForm struct {
	User struct {
		Avatar string `json:"avatar"`
		Image  string `json:"image"`
		Bio    string `json:"bio"`
	} `json:"user"`
}

type ArticleForm struct {
	Article struct {
		Title    string   `json:"title" binding:"required"`
		Abstract string   `json:"abstract"`
		Body     string   `json:"body" binding:"required"`
		Tags     []string `json:"tags"`
	} `json:"article"`
}

type UserResponse struct {
	Username  string `json:"username"`
	Bio       string `json:"bio"`
	Avatar    string `json:"avatar"`
	Image     string `json:"image"`
	Following bool   `json:"following"`
}

type ArticleResponse struct {
	Slug           string    `json:"slug"`
	Title          string    `json:"title"`
	Abstract       string    `json:"abstract"`
	Body           string    `json:"body"`
	CreatedAt      time.Time `json:"createdAt"`
	UpdatedAt      time.Time `json:"updatedAt"`
	Favorited      bool      `json:"favorited"`
	FavoritesCount uint      `json:"favoritesCount"`
	Tags           []string  `json:"tags"`

	Author UserResponse `json:"author"`
}

type CommentForm struct {
	Comment struct {
		Body string `json:"body" binding:"required"`
	} `json:"comment"`
}

type CommentResponse struct {
	ID        uint         `json:"id"`
	CreatedAt time.Time    `json:"createdAt"`
	UpdatedAt time.Time    `json:"updatedAt"`
	Body      string       `json:"body"`
	Author    UserResponse `json:"author"`
}
