package menu

import (
	"github.com/gin-gonic/gin"
)

func RegisterRoutes(r *gin.Engine) {
	handler := NewHandler()

	menuGroup := r.Group("/api/menu")
	{
		menuGroup.POST("/contractors", func(c *gin.Context) {
			handler.GetContractorsWidget(c.Writer, c.Request)
		})
		menuGroup.POST("/cars", func(c *gin.Context) {
			handler.GetCarsWidget(c.Writer, c.Request)
		})
		menuGroup.POST("/loyalty", func(c *gin.Context) {
			handler.GetLoyaltyProgram(c.Writer, c.Request)
		})
		menuGroup.POST("/problems", func(c *gin.Context) {
			handler.GetProblems(c.Writer, c.Request)
		})
	}
}
