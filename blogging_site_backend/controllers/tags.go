package controllers

import (
	"math"
	"sort"

	"github.com/Athlon64/blogging_site/helpers"
	"github.com/Athlon64/blogging_site/models"
	"github.com/gin-gonic/gin"
)

// 返回标签列表
func GetTags(c *gin.Context) {
	var tags []models.Tag
	err := models.DB.Preload("Articles").Find(&tags).Error
	if err != nil {
		c.Error(helpers.InternalServerError(err.Error()))
		return
	}

	sort.Slice(tags, func(i, j int) bool {
		return len(tags[i].Articles) > len(tags[j].Articles)
	})
	top10 := int(math.Min(float64(len(tags)), 10))
	output := prepareTagsResponse(tags[:top10])
	c.JSON(200, gin.H{"tags": output})
}
