package routers

import (
	"time"

	"github.com/Athlon64/blogging_site/controllers"
	"github.com/Athlon64/blogging_site/helpers"
	"github.com/Athlon64/blogging_site/middlewares"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func Home(ctx *gin.Context) {
	ctx.HTML(200, "index.html", nil)
}

func Run() {
	g := gin.Default()

	for k, v := range helpers.GetFileList() {
		g.StaticFile(k, v)
	}

	g.LoadHTMLFiles("./public/index.html")
	g.GET("/", Home)
	g.NoRoute(Home)

	g.Use(cors.New(cors.Config{
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS"},
		AllowHeaders:     []string{"Authorization", "Origin", "Content-Length", "Content-Type"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
		AllowAllOrigins:  true,
	}))

	auth := g.Group("/api", middlewares.ErrorHandler(), middlewares.Authorize())
	{
		// user
		auth.POST("/users/login", controllers.UserLogin)
		auth.POST("/users", controllers.UserRegister)
		auth.GET("/user", controllers.GetUser)
		auth.PUT("/user", controllers.UpdateUser)
		auth.GET("/profiles/:username", controllers.GetProfile)
		auth.GET("/profiles/:username/followings", controllers.GetUserFollowings)
		auth.GET("/profiles/:username/followers", controllers.GetUserFollowers)
		auth.POST("/profiles/:username/follow", controllers.FollowUser)
		auth.DELETE("/profiles/:username/follow", controllers.UnfollowUser)

		// article
		auth.GET("/articles", controllers.GetArticles)
		auth.GET("/articles/:slug", controllers.GetArticle)
		auth.POST("/articles", controllers.NewArticle)
		auth.PUT("/articles/:slug", controllers.UpdateArticle)
		auth.DELETE("/articles/:slug", controllers.DeleteArticle)
		auth.POST("/articles/:slug/comments", controllers.NewComment)
		auth.GET("/articles/:slug/comments", controllers.GetComments)
		auth.DELETE("/articles/:slug/comments/:id", controllers.DeleteComment)
		auth.POST("/articles/:slug/favorite", controllers.Favorite)
		auth.DELETE("/articles/:slug/favorite", controllers.Unfavorite)

		auth.GET("/tags", controllers.GetTags)
	}

	g.Run(":5000")
}
