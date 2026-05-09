package expenses

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"

	"backend/internal/shared/middleware"
	"backend/internal/shared/proxy"

	"github.com/gin-gonic/gin"
)

const fleetAPIBase = "https://fleet.yandex.ru/api/fleet"

const (
	urlCostsList           = fleetAPIBase + "/fleet-vehicles-economy/v1/costs/list"
	urlCostsAvailableTypes = fleetAPIBase + "/fleet-vehicles-economy/v1/costs/available-types"
	urlCarsSuggest         = fleetAPIBase + "/vehicles-manager/v1/cars/suggest?is_rental=true"
	urlCosts               = fleetAPIBase + "/fleet-vehicles-economy/v1/costs"
	urlDriverBalanceHist   = "https://fleet.yandex.ru/api/api/v1/cards/driver/balances/history"
	urlReportsStatus       = "https://fleet.yandex.ru/api/fleet/reports-storage/v1/operations/status"
	urlReportsDownload     = "https://fleet.yandex.ru/api/fleet/reports-storage/v1/operations/download"
	urlRegularCharges      = "https://fleet.yandex.ru/api/reports-api/v1/regular-charges/download-async"
)

// Handlers

func getCostsList(c *gin.Context) {
	proxy.ToYandex(c, urlCostsList, http.MethodPost, proxy.WithJSONContentType())
}

func getAvailableCostTypes(c *gin.Context) {
	proxy.ToYandex(c, urlCostsAvailableTypes, http.MethodGet)
}

func getCarsSuggest(c *gin.Context) {
	proxy.ToYandex(c, urlCarsSuggest, http.MethodGet)
}

func getCostDetail(c *gin.Context) {
	id := c.Param("id")
	proxy.ToYandex(c, urlCosts+"?id="+id, http.MethodGet)
}

func updateCost(c *gin.Context) {
	proxy.ToYandex(c, urlCosts, http.MethodPut, proxy.WithJSONContentType())
}

func createCost(c *gin.Context) {
	proxy.ToYandex(c, urlCosts, http.MethodPost, proxy.WithJSONContentType())
}

func getDriverBalanceHistory(c *gin.Context) {
	proxy.ToYandex(c, urlDriverBalanceHist, http.MethodPost, proxy.WithJSONContentType())
}

// Report generation

func initiateReportGeneration(c *gin.Context) {
	var body map[string]interface{}
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	operationID, ok := body["operation_id"].(string)
	if !ok || operationID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "operation_id is required"})
		return
	}

	delete(body, "operation_id")
	delete(body, "report_type")

	requestBody := map[string]interface{}{
		"filters":     body["filters"],
		"date_period": body["date_period"],
	}
	bodyJSON, _ := json.Marshal(requestBody)

	targetURL := fleetAPIBase + "/reports-builder/report/costs?operation_id=" + operationID
	c.Request.Body = io.NopCloser(bytes.NewBuffer(bodyJSON))
	proxy.ToYandex(c, targetURL, http.MethodPost, proxy.WithJSONContentType())
}

func checkReportStatus(c *gin.Context) {
	operationID := c.Query("operation_id")
	if operationID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "operation_id is required"})
		return
	}
	targetURL := urlReportsStatus + "?operation_id=" + operationID
	proxy.ToYandex(c, targetURL, http.MethodGet)
}

func getReportDownloadLink(c *gin.Context) {
	operationID := c.Query("operation_id")
	if operationID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "operation_id is required"})
		return
	}
	targetURL := urlReportsDownload + "?operation_id=" + operationID
	proxy.ToYandex(c, targetURL, http.MethodGet)
}

func initiateRegularChargesReport(c *gin.Context) {
	var body map[string]interface{}
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	operationID, ok := body["operation_id"].(string)
	if !ok || operationID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "operation_id is required"})
		return
	}

	requestBody := map[string]interface{}{
		"charset":     "utf-8-sig",
		"date_type":   body["date_type"],
		"date_period": body["date_period"],
	}
	bodyJSON, _ := json.Marshal(requestBody)

	targetURL := urlRegularCharges + "?operation_id=" + operationID
	c.Request.Body = io.NopCloser(bytes.NewBuffer(bodyJSON))
	proxy.ToYandex(c, targetURL, http.MethodPost, proxy.WithJSONContentType())
}

// Routes

func RegisterRoutes(r *gin.Engine) {
	g := r.Group("/api/expenses", middleware.Auth)
	{
		g.POST("/costs/list", getCostsList)
		g.GET("/costs/:id", getCostDetail)
		g.PUT("/costs", updateCost)
		g.POST("/costs", createCost)
		g.GET("/cost-types", getAvailableCostTypes)
		g.GET("/cars/suggest", getCarsSuggest)

		g.POST("/driver/balance-history", getDriverBalanceHistory)

		g.POST("/reports/initiate", initiateReportGeneration)
		g.POST("/reports/regular-charges/initiate", initiateRegularChargesReport)
		g.GET("/reports/status", checkReportStatus)
		g.GET("/reports/download", getReportDownloadLink)
	}
}
