package main

import (
	"backend/internal/auth"
	"backend/internal/competitions"
	"backend/internal/expenses"
	"backend/internal/fines"
	"backend/internal/fleetmap"
	"backend/internal/garage"
	"backend/internal/goals"
	"backend/internal/mailings"
	"backend/internal/menu"
	"backend/internal/session"
	"backend/internal/staff"
	"backend/internal/summary"
	"backend/internal/vehicles"
	workrules "backend/internal/work_rules"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	godotenv.Load()

	// Initialize Redis session store
	session.InitStore(os.Getenv("REDIS_ADDR"), "", 0)

	r := gin.Default()

	// Register auth routes
	auth.RegisterRoutes(r)

	// Register staff routes
	staff.RegisterRoutes(r)

	// Register vehicle routes
	vehicles.RegisterRoutes(r)

	// Register expenses routes
	expenses.RegisterRoutes(r)

	// Register menu routes
	menu.RegisterRoutes(r)

	// Register summary routes
	summary.RegisterRoutes(r)

	// Register garage routes
	garage.RegisterRoutes(r)

	// Register goals routes
	goals.RegisterRoutes(r)

	// Register fines routes
	fines.RegisterRoutes(r)

	// Register map routes
	fleetmap.RegisterRoutes(r)

	// Register mailings routes
	mailings.RegisterRoutes(r)

	// Register competitions routes
	competitions.RegisterRoutes(r)

	// Register work rules routes
	workrules.RegisterRoutes(r)

	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "Hello, world!",
		})
	})
	r.Run(":8080")
}
