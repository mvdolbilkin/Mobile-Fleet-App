package goals

import (
	"github.com/gin-gonic/gin"
)

func RegisterRoutes(r *gin.Engine) {
	handler := NewHandler()
	
	api := r.Group("/api/goals")
	{
		api.POST("/current", handler.GetCurrentGoals)
		api.POST("/previous", handler.GetPreviousGoals)
	}
}
