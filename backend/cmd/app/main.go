package main

import (
	"backend/internal/auth"
	"backend/internal/expenses"
	"backend/internal/staff"
	"backend/internal/vehicles"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	godotenv.Load()

	r := gin.Default()

	// Register auth routes
	auth.RegisterRoutes(r)
	
	// Register staff routes
	staff.RegisterRoutes(r)

	// Register vehicle routes
	vehicles.RegisterRoutes(r)

	// Register expenses routes
	expenses.RegisterRoutes(r)

	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "Hello, world!",
		})
	})
	r.Run(":8080")
}
