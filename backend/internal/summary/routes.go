package summary

import (
	"backend/internal/shared/middleware"

	"github.com/gin-gonic/gin"
)

// RegisterRoutes sets up summary API endpoints.
func RegisterRoutes(r *gin.Engine) {
	handler := NewHandler()

	// Dashboard summary endpoints
	summaryGroup := r.Group("/api/summary", middleware.Auth)
	{
		summaryGroup.GET("/profile", handler.GetProfile)
		summaryGroup.POST("/active-drivers", handler.GetActiveDrivers)
		summaryGroup.POST("/orders", handler.GetOrders)
		summaryGroup.POST("/supply-hours", handler.GetSupplyHours)
		summaryGroup.POST("/profit", handler.GetProfit)
		summaryGroup.POST("/orders-sum", handler.GetOrdersSum)
		summaryGroup.GET("/certification", handler.GetCertification)
	}

	// Fleet reports routes
	fleetReportsGroup := r.Group("/api/fleet/fleet-reports/v1/dashboard/widget", middleware.Auth)
	{
		fleetReportsGroup.POST("/cars/summary", handler.GetCarsSummary)
		fleetReportsGroup.POST("/cars/statuses", handler.GetCarsStatuses)
		fleetReportsGroup.POST("/cars/mileage", handler.GetCarsMileage)
		fleetReportsGroup.POST("/cars/hours-online", handler.GetCarsHoursOnline)
		fleetReportsGroup.POST("/cars/acceptance-rate", handler.GetCarsAcceptanceRate)
		fleetReportsGroup.POST("/cars/trips", handler.GetCarsTrips)
	}

	// Reports API routes
	reportsGroup := r.Group("/api/reports", middleware.Auth)
	{
		reportsGroup.POST("/summary/drivers/list", handler.GetDriversSummaryList)
		reportsGroup.POST("/summary/cars/list", handler.GetCarsSummaryList)
		reportsGroup.POST("/summary/parks/list", handler.GetParksSummaryList)
	}

	// Payments routes
	paymentsGroup := r.Group("/api/payments", middleware.Auth)
	{
		paymentsGroup.POST("/dashboard/transactions/summary", handler.GetPaymentTransactionsSummary)
		paymentsGroup.POST("/dashboard/fees/summary", handler.GetPaymentFeesSummary)
		paymentsGroup.POST("/dashboard/transactions/drivers", handler.GetPaymentTransactionsDrivers)
		paymentsGroup.POST("/dashboard/transactions/count", handler.GetPaymentTransactionsCount)
		paymentsGroup.POST("/dashboard/transactions/statuses", handler.GetPaymentTransactionsStatuses)
		paymentsGroup.POST("/transactions/list", handler.GetPaymentTransactionsList)
		paymentsGroup.GET("/transactions/by-id", handler.GetPaymentTransactionByID)
	}
}
