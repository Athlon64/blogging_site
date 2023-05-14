package middlewares

import (
	"github.com/Athlon64/blogging_site/helpers"
	"github.com/gin-gonic/gin"
)

func Authorize() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Set("userID", uint(0))

		tokenString := helpers.GetTokenString(c)
		if tokenString != "" {
			id, err := helpers.CheckToken(tokenString)
			if err == nil {
				c.Set("userID", uint(id))
			}
		}
	}
}
