package goals

import (
	"backend/internal/shared/middleware"

	"github.com/gin-gonic/gin"
)

func RegisterRoutes(r *gin.Engine) {
	api := r.Group("/api/goals", middleware.Auth)
	{
		api.POST("/current", getCurrentGoals)
		api.POST("/previous", getPreviousGoals)
	}
}
