package controllers

import (
	"errors"
	"net/http"
	"strconv"
	"strings"

	"github.com/Athlon64/blogging_site/helpers"
	"github.com/Athlon64/blogging_site/models"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// 用户注册
func UserRegister(c *gin.Context) {
	var input models.UserRegisterForm
	err := c.ShouldBind(&input)
	if err != nil {
		c.Error(helpers.ErrorsFromValidator(err))
		return
	}

	encryptedPassword, err := helpers.EncryptPassword(input.User.Password)
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	user := &models.User{
		Username: input.User.Username,
		Email:    input.User.Email,
		Password: encryptedPassword,
	}
	err = models.DB.Create(&user).Error
	if err != nil {
		errMsg := err.Error()
		if strings.Contains(errMsg, "UNIQUE") && strings.Contains(errMsg, "username") {
			c.Error(helpers.NewError(http.StatusUnprocessableEntity, "username", "此用户名已注册，请换一个"))
			return
		}

		if strings.Contains(errMsg, "UNIQUE") && strings.Contains(errMsg, "email") {
			c.Error(helpers.NewError(http.StatusUnprocessableEntity, "email", "此邮箱已注册，请换一个"))
			return
		}

		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	token, err := helpers.NewToken(user.ID)
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	output := models.UserRegisterResponse{
		Username: user.Username,
		Email:    user.Email,
		Token:    token,
		Bio:      user.Bio,
		Avatar:   user.Avatar,
		Image:    user.Image,
	}
	c.JSON(http.StatusOK, gin.H{"user": output})
}

// 用户登录
func UserLogin(c *gin.Context) {
	var input models.UserLoginForm
	err := c.ShouldBind(&input)
	if err != nil {
		c.Error(helpers.ErrorsFromValidator(err))
		return
	}

	var user models.User
	err = models.DB.Where("email = ?", input.User.Email).First(&user).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.Error(helpers.NewError(http.StatusUnprocessableEntity, "email", "电子邮箱地址有误"))
			return
		}

		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	err = helpers.CheckPassword(input.User.Password, user.Password)
	if err != nil {
		c.Error(helpers.NewError(http.StatusUnprocessableEntity, "password", "密码有误"))
		return
	}

	token, err := helpers.NewToken(user.ID)
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	output := models.UserRegisterResponse{
		Username: user.Username,
		Email:    user.Email,
		Token:    token,
		Bio:      user.Bio,
		Avatar:   user.Avatar,
		Image:    user.Image,
	}
	c.JSON(http.StatusOK, gin.H{"user": output})
}

// 返回用户信息
func GetUser(c *gin.Context) {
	userID, _ := c.Get("userID")
	if userID == uint(0) {
		c.Error(helpers.ErrAuthorizationFailed)
		return
	}

	var user models.User
	err := models.DB.First(&user, userID).Error
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	output := struct {
		Username string `json:"username"`
		Email    string `json:"email"`
		Bio      string `json:"bio"`
		Avatar   string `json:"avatar"`
		Image    string `json:"image"`
	}{user.Username, user.Email, user.Bio, user.Avatar, user.Image}
	c.JSON(http.StatusOK, gin.H{"user": output})
}

// 更新用户信息
func UpdateUser(c *gin.Context) {
	userID, _ := c.Get("userID")
	if userID == uint(0) {
		c.Error(helpers.ErrAuthorizationFailed)
		return
	}

	input := models.UserSettingsForm{}
	c.ShouldBind(&input)

	var user models.User
	err := models.DB.First(&user, userID).Error
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	user.Avatar = input.User.Avatar
	user.Image = input.User.Image
	user.Bio = input.User.Bio

	err = models.DB.Save(&user).Error
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	output := struct {
		Username string `json:"username"`
		Email    string `json:"email"`
		Avatar   string `json:"avatar"`
		Image    string `json:"image"`
		Bio      string `json:"bio"`
		Token    string `json:"token"`
	}{user.Username, user.Email, user.Avatar, user.Image, user.Bio, helpers.GetTokenString(c)}
	c.JSON(http.StatusOK, gin.H{"user": output})
}

func getUserAssociations(c *gin.Context, association string) {
	l := c.DefaultQuery("limit", "10")
	o := c.DefaultQuery("offset", "0")
	limit, _ := strconv.Atoi(l)
	offset, _ := strconv.Atoi(o)
	username := c.Param("username")
	userID, _ := c.Get("userID")

	var user models.User
	err := models.DB.Where("username = ?", username).First(&user).Error
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	var users []models.User
	var count int64
	db := models.DB.Offset(offset).Limit(limit).Order("updated_at desc")
	count = models.DB.Model(&user).Association(association).Count()
	err = db.Model(&user).Association(association).Find(&users)
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	output := prepareUsersResponse(users, userID.(uint), false)

	c.JSON(http.StatusOK, gin.H{"users": output, "count": count})
}

// 获取用户关注列表
func GetUserFollowings(c *gin.Context) {
	getUserAssociations(c, "Followings")
}

func prepareUsersResponse(users []models.User, userID uint, checkFollowings bool) []models.UserResponse {
	usersResponse := make([]models.UserResponse, len(users))
	for i := range users {
		usersResponse[i] = prepareUserResponse(users[i], userID, false)
	}

	return usersResponse
}

// 获取用户粉丝列表
func GetUserFollowers(c *gin.Context) {
	getUserAssociations(c, "Followers")
}

// 获取用户资料
func GetProfile(c *gin.Context) {
	username := c.Param("username")
	userID, _ := c.Get("userID")

	var user models.User
	err := models.DB.Preload("Followers").Where("username = ?", username).First(&user).Error
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	output := prepareUserResponse(user, userID.(uint), true)

	c.JSON(http.StatusOK, gin.H{"profile": output})
}

func prepareUserResponse(user models.User, userID uint, checkFollowing bool) models.UserResponse {
	userResponse := models.UserResponse{
		Username:  user.Username,
		Bio:       user.Bio,
		Avatar:    user.Avatar,
		Image:     user.Image,
		Following: false,
	}

	if checkFollowing {
		if userID != 0 {
			for i := range user.Followers {
				if user.Followers[i].ID == userID {
					userResponse.Following = true
				}
			}
		}
	}

	return userResponse
}

func toggleUserFollowing(c *gin.Context, toFollow bool) {
	userID, _ := c.Get("userID")
	if userID == uint(0) {
		c.Error(helpers.ErrAuthorizationFailed)
		return
	}

	var su, du models.User
	err := models.DB.First(&su, userID).Error
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	username := c.Param("username")
	err = models.DB.Where("username = ?", username).First(&du).Error
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	if toFollow {
		err = models.DB.Model(&su).Association("Followings").Append(&du)
		if err != nil {
			c.Error(helpers.InternalServerError(err.Error()))
			return
		}

		err = models.DB.Model(&du).Association("Followers").Append(&su)
		if err != nil {
			c.Error(helpers.InternalServerError(err.Error()))
			return
		}
	} else {
		err = models.DB.Model(&su).Association("Followings").Delete(&du)
		if err != nil {
			c.Error(helpers.InternalServerError(err.Error()))
			return
		}

		err = models.DB.Model(&du).Association("Followers").Delete(&su)
		if err != nil {
			c.Error(helpers.InternalServerError(err.Error()))
			return
		}
	}

	output := models.UserResponse{
		Username: du.Username,
		Bio:      du.Bio,
		Avatar:   du.Avatar,
		Image:    du.Image,
		// Following: true/false,
		Following: isFollowing(su.ID, du.ID),
	}

	c.JSON(http.StatusOK, gin.H{"profile": output})
}

// 关注用户
func FollowUser(c *gin.Context) {
	toggleUserFollowing(c, true)
}

// 取关用户
func UnfollowUser(c *gin.Context) {
	toggleUserFollowing(c, false)
}

func toggleArticleFavoriting(c *gin.Context, toFavorite bool) {
	userID, _ := c.Get("userID")
	if userID == uint(0) {
		c.Error(helpers.ErrAuthorizationFailed)
		return
	}

	article, err := findArticle(c)
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	var user models.User
	err = models.DB.First(&user, userID).Error
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	if toFavorite {
		err = models.DB.Model(&user).Association("Favorites").Append(&article)
		if err != nil {
			c.Error(helpers.InternalServerError(err.Error()))
			return
		}
	} else {
		err = models.DB.Model(&user).Association("Favorites").Delete(&article)
		if err != nil {
			c.Error(helpers.InternalServerError(err.Error()))
			return
		}
	}

	output := prepareArticleResponse(article, userID.(uint))
	c.JSON(http.StatusOK, gin.H{"article": output})
}

// 收藏文章
func Favorite(c *gin.Context) {
	toggleArticleFavoriting(c, true)
}

// 取消收藏文章
func Unfavorite(c *gin.Context) {
	toggleArticleFavoriting(c, false)
}
