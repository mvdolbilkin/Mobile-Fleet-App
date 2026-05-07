package menu

import (
	"github.com/gin-gonic/gin"
)

func RegisterRoutes(r *gin.Engine) {
	g := r.Group("/api/menu", authMiddleware)
	{
		g.POST("/contractors", getContractorsProxy)
		g.POST("/cars", getCarsProxy)
		g.POST("/loyalty", getLoyaltyProgramProxy)
		g.POST("/problems", getProblemsProxy)
	}
}
