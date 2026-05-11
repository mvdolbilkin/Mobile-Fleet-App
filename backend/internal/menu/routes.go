package menu

import (
	"backend/internal/shared/middleware"

	"github.com/gin-gonic/gin"
)

func RegisterRoutes(r *gin.Engine) {
	g := r.Group("/api/menu", middleware.Auth)
	{
		g.POST("/contractors", getContractorsProxy)
		g.POST("/cars", getCarsProxy)
		g.POST("/loyalty", getLoyaltyProgramProxy)
		g.POST("/problems", getProblemsProxy)
	}
}
