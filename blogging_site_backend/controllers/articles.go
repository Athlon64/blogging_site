package controllers

import (
	"net/http"
	"strconv"

	"github.com/Athlon64/blogging_site/helpers"
	"github.com/Athlon64/blogging_site/models"
	"github.com/gin-gonic/gin"
	"github.com/gosimple/slug"
	"gorm.io/gorm/clause"
)

// 返回文章列表
func GetArticles(c *gin.Context) {
	l := c.DefaultQuery("limit", "10")
	o := c.DefaultQuery("offset", "0")
	limit, _ := strconv.Atoi(l)
	offset, _ := strconv.Atoi(o)
	tagQueryString := c.DefaultQuery("tag", "")
	authorQueryString := c.DefaultQuery("author", "")
	favoritedQueryString := c.DefaultQuery("favorited", "")

	var articles []models.Article
	var count int64
	var err error
	db := models.DB.Preload("Author").Preload("Tags").Offset(offset).Limit(limit).Order("updated_at desc")
	if tagQueryString != "" {
		var tag models.Tag
		err = models.DB.Where("tag = ?", tagQueryString).First(&tag).Error
		err = db.Model(&tag).Association("Articles").Find(&articles)
		count = models.DB.Model(&tag).Association("Articles").Count()
	} else if authorQueryString != "" {
		var user models.User
		err = models.DB.Where("username = ?", authorQueryString).First(&user).Error
		err = db.Model(&user).Association("Owns").Find(&articles)
		count = models.DB.Model(&user).Association("Owns").Count()
	} else if favoritedQueryString != "" {
		var user models.User
		err = models.DB.Where("username = ?", favoritedQueryString).First(&user).Error
		err = db.Model(&user).Association("Favorites").Find(&articles)
		count = models.DB.Model(&user).Association("Favorites").Count()
	} else {
		err = db.Find(&articles).Error
		models.DB.Model(&articles).Count(&count)
	}

	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	userID, _ := c.Get("userID")
	output := prepareArticlesResponse(articles, userID.(uint))
	c.JSON(http.StatusOK, gin.H{"articles": output, "count": count})
}

func prepareArticlesResponse(articles []models.Article, userID uint) []models.ArticleResponse {
	articlesResponse := make([]models.ArticleResponse, len(articles))
	for i := range articles {
		articlesResponse[i] = prepareArticleResponse(articles[i], userID)
	}

	return articlesResponse
}

func isFavorited(article models.Article, userID uint) bool {
	if userID == uint(0) {
		return false
	}

	var user models.User
	err := models.DB.Preload("Favorites").First(&user, userID).Error
	if err == nil {
		for i := range user.Favorites {
			if article.ID == user.Favorites[i].ID {
				return true
			}
		}
	}

	return false
}

func prepareTagsResponse(tags []models.Tag) []string {
	tagList := make([]string, len(tags))
	for i := range tags {
		tagList[i] = tags[i].Tag
	}

	return tagList
}

// 找到指定文章
func findArticle(c *gin.Context) (models.Article, error) {
	var article models.Article
	article.Slug = c.Param("slug")
	err := models.DB.Preload("Author").Preload("Tags").Where(&article).First(&article).Error

	return article, err
}

// 返回指定文章
func GetArticle(c *gin.Context) {
	userID, _ := c.Get("userID")
	article, err := findArticle(c)
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	output := prepareArticleResponse(article, userID.(uint))
	c.JSON(http.StatusOK, gin.H{"article": output})
}

// 创建文章
func NewArticle(c *gin.Context) {
	userID, _ := c.Get("userID")
	if userID == uint(0) {
		c.Error(helpers.ErrAuthorizationFailed)
		return
	}

	var articleForm models.ArticleForm
	err := c.ShouldBind(&articleForm)
	if err != nil {
		c.Error(helpers.ErrorsFromValidator(err))
		return
	}

	var author models.User
	err = models.DB.First(&author, userID).Error
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	article := models.Article{
		Title:    articleForm.Article.Title,
		Abstract: articleForm.Article.Abstract,
		Body:     articleForm.Article.Body,
		Tags:     tagListToModel(articleForm.Article.Tags),
		Slug:     slug.Make(articleForm.Article.Title),
		Author:   author,
	}
	err = models.DB.Create(&article).Error
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	output := prepareArticleResponse(article, userID.(uint))
	c.JSON(http.StatusOK, gin.H{"article": output})
}

func tagListToModel(tags []string) []models.Tag {
	tagList := make([]models.Tag, len(tags))
	for i := range tags {
		models.DB.FirstOrInit(&tagList[i], models.Tag{Tag: tags[i]})
	}

	return tagList
}

func prepareArticleResponse(article models.Article, userID uint) models.ArticleResponse {
	articleResponse := models.ArticleResponse{}

	articleResponse.Slug = article.Slug
	articleResponse.Title = article.Title
	articleResponse.Abstract = article.Abstract
	articleResponse.Body = article.Body
	articleResponse.CreatedAt = article.CreatedAt
	articleResponse.UpdatedAt = article.UpdatedAt
	articleResponse.FavoritesCount = getFavoritesCount(article)

	articleResponse.Author.Username = article.Author.Username
	articleResponse.Author.Bio = article.Author.Bio
	articleResponse.Author.Avatar = article.Author.Avatar
	articleResponse.Author.Image = article.Author.Image
	articleResponse.Author.Following = isFollowing(userID, article.Author.ID)

	articleResponse.Favorited = isFavorited(article, userID)
	articleResponse.Tags = prepareTagsResponse(article.Tags)

	return articleResponse
}

func getFavoritesCount(article models.Article) uint {
	return uint(models.DB.Model(&article).Association("FavoritedBy").Count())
}

func isFollowing(userID uint, authorID uint) bool {
	if userID == uint(0) {
		return false
	}

	var user models.User
	err := models.DB.Preload("Followings").First(&user, userID).Error
	if err != nil {
		return false
	}

	for i := range user.Followings {
		if authorID == user.Followings[i].ID {
			return true
		}
	}

	return false
}

// 更新文章
func UpdateArticle(c *gin.Context) {
	userID, _ := c.Get("userID")
	if userID == uint(0) {
		c.Error(helpers.ErrAuthorizationFailed)
		return
	}

	var articleForm models.ArticleForm
	err := c.ShouldBind(&articleForm)
	if err != nil {
		c.Error(helpers.ErrorsFromValidator(err))
		return
	}

	oldArticle, err := findArticle(c)
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	newArticle := oldArticle
	newArticle.Title = articleForm.Article.Title
	newArticle.Abstract = articleForm.Article.Abstract
	newArticle.Body = articleForm.Article.Body
	err = unlinkAndDeleteOrphanedTags(oldArticle)
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	newArticle.Tags = tagListToModel(articleForm.Article.Tags)
	newArticle.Slug = slug.Make(articleForm.Article.Title)

	err = models.DB.Save(&newArticle).Error
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	output := prepareArticleResponse(newArticle, userID.(uint))
	c.JSON(http.StatusOK, gin.H{"article": output})
}

func unlinkAndDeleteOrphanedTags(article models.Article) error {
	err := models.DB.Model(&article).Association("Tags").Clear()
	if err != nil {
		return err
	}

	var tags []models.Tag
	err = models.DB.Preload("Articles").Find(&tags).Error
	if err != nil {
		return err
	}

	for i := range tags {
		if len(tags[i].Articles) == 0 {
			err = models.DB.Unscoped().Delete(&tags[i]).Error
			if err != nil {
				return err
			}
		}
	}

	return nil
}

// 删除文章
func DeleteArticle(c *gin.Context) {
	userID, _ := c.Get("userID")
	if userID == uint(0) {
		c.Error(helpers.ErrAuthorizationFailed)
		return
	}

	var article models.Article
	article.Slug = c.Param("slug")
	err := models.DB.Where(&article).First(&article).Error
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	err = unlinkAndDeleteOrphanedTags(article)
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	err = deleteComments(article)
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	err = models.DB.Select(clause.Associations).Delete(&article).Error
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "成功"})
}

func deleteComments(article models.Article) error {
	var comments []models.Comment
	err := models.DB.Model(&article).Association("Comments").Find(&comments)
	if err != nil {
		return err
	}

	err = models.DB.Delete(&comments).Error
	if err != nil {
		return err
	}

	return nil
}

// 创建评论
func NewComment(c *gin.Context) {
	userID, _ := c.Get("userID")
	if userID == uint(0) {
		c.Error(helpers.ErrAuthorizationFailed)
		return
	}

	var commentForm models.CommentForm
	err := c.ShouldBind(&commentForm)
	if err != nil {
		c.Error(helpers.ErrorsFromValidator(err))
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

	comment := models.Comment{
		Body:   commentForm.Comment.Body,
		Author: user,
	}
	article.Comments = append(article.Comments, comment)
	err = models.DB.Save(&article).Error
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	output := prepareCommentResponse(comment, userID.(uint))
	c.JSON(http.StatusOK, gin.H{"comment": output})
}

func prepareCommentResponse(comment models.Comment, userID uint) models.CommentResponse {
	commentResponse := models.CommentResponse{}

	commentResponse.ID = comment.ID
	commentResponse.CreatedAt = comment.CreatedAt
	commentResponse.UpdatedAt = comment.UpdatedAt
	commentResponse.Body = comment.Body

	commentResponse.Author.Username = comment.Author.Username
	commentResponse.Author.Bio = comment.Author.Bio
	commentResponse.Author.Avatar = comment.Author.Avatar
	commentResponse.Author.Image = comment.Author.Image
	commentResponse.Author.Following = isFollowing(userID, comment.Author.ID)

	return commentResponse
}

// 获取评论
func GetComments(c *gin.Context) {
	userID, _ := c.Get("userID")
	var article models.Article
	article.Slug = c.Param("slug")
	err := models.DB.Preload("Comments").Preload("Comments.Author").Where(&article).First(&article).Error
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	output := prepareCommentsResponse(article.Comments, userID.(uint))
	c.JSON(http.StatusOK, gin.H{"comments": output})
}

func prepareCommentsResponse(comments []models.Comment, userID uint) []models.CommentResponse {
	commentsResponse := make([]models.CommentResponse, len(comments))

	for i := range comments {
		commentsResponse[i] = prepareCommentResponse(comments[i], userID)
	}

	return commentsResponse
}

// 删除评论
func DeleteComment(c *gin.Context) {
	userID, _ := c.Get("userID")
	if userID == uint(0) {
		c.Error(helpers.ErrAuthorizationFailed)
		return
	}

	id, _ := strconv.Atoi(c.Param("id"))
	var article models.Article
	article.Slug = c.Param("slug")
	err := models.DB.Preload("Comments").Preload("Comments.Author").Where(&article).First(&article).Error
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	err = unlinkAndDeleteComment(article, uint(id), userID.(uint))
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
	}

	c.JSON(http.StatusOK, gin.H{"message": "成功"})
}

func unlinkAndDeleteComment(article models.Article, id, userID uint) error {
	for i := range article.Comments {
		if article.Comments[i].ID == id && article.Comments[i].Author.ID == userID {
			err := models.DB.Model(&models.Comment{}).Unscoped().Delete(&article.Comments[i]).Error
			if err != nil {
				return err
			}
		}
	}

	return nil
}
