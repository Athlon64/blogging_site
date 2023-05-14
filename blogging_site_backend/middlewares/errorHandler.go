package middlewares

import (
	"net/http"

	"github.com/Athlon64/blogging_site/helpers"
	"github.com/gin-gonic/gin"
)

func ErrorHandler() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Next()

		for _, err := range c.Errors {
			if errs, ok := err.Err.(*helpers.Errors); ok {
				c.JSON(errs.Status, gin.H{"errors": errs.ErrMap})
			} else {
				c.JSON(http.StatusInternalServerError, gin.H{"errors": err.Err.Error()})
			}
		}
	}
}
