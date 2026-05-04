package expenses

import (
	"bytes"
	"encoding/json"
	"io"
	"log"
	"net/http"

	"backend/internal/session"

	"github.com/gin-gonic/gin"
)

const yandexFleetAPIBase = "https://fleet.yandex.ru/api/fleet"
const yandexDriverBalanceHistoryURL = "https://fleet.yandex.ru/api/api/v1/cards/driver/balances/history"

// ─── Middleware ──────────────────────────────────────────────────────────────

func authMiddleware(c *gin.Context) {
	userID := c.GetHeader("X-Park-ID")
	if userID == "" {
		userID = c.GetHeader("x-park-id")
	}
	if userID == "" {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "X-Park-ID header is required"})
		return
	}
	store := session.GetStore()
	userSession, exists := store.Get(userID)
	if !exists {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Session not found. Please login again."})
		return
	}
	c.Set("session", userSession)
	c.Next()
}

func getSession(c *gin.Context) *session.UserSession {
	s, _ := c.Get("session")
	return s.(*session.UserSession)
}

// ─── Proxy helper ────────────────────────────────────────────────────────────

func proxyToYandex(c *gin.Context, targetURL string, method string) {
	s := getSession(c)

	var bodyBytes []byte
	if c.Request.Body != nil {
		bodyBytes, _ = io.ReadAll(c.Request.Body)
	}

	log.Printf("[PROXY] %s %s | body=%s", method, targetURL, string(bodyBytes))

	req, err := http.NewRequest(method, targetURL, bytes.NewBuffer(bodyBytes))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept-Language", "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7")
	req.Header.Set("x-park-id", s.ParkID)

	cookieValue := "Session_id=" + s.SessionID + "; sessionid2=" + s.SessionID2
	if s.LoginToken != "" {
		cookieValue += "; L=" + s.LoginToken
	}
	if s.Login != "" {
		cookieValue += "; yandex_login=" + s.Login
	}
	if s.UID != "" {
		cookieValue += "; yandexuid=" + s.UID
	}
	req.Header.Set("Cookie", cookieValue)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		c.JSON(http.StatusBadGateway, gin.H{"error": "Failed to reach Yandex Fleet API"})
		return
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read response"})
		return
	}

	log.Printf("[PROXY] response status=%d body=%s", resp.StatusCode, string(respBody))

	c.Data(resp.StatusCode, resp.Header.Get("Content-Type"), respBody)
}

// ─── Handlers ────────────────────────────────────────────────────────────────

func getCostsList(c *gin.Context) {
	proxyToYandex(c, yandexFleetAPIBase+"/fleet-vehicles-economy/v1/costs/list", http.MethodPost)
}

func getAvailableCostTypes(c *gin.Context) {
	proxyToYandex(c, yandexFleetAPIBase+"/fleet-vehicles-economy/v1/costs/available-types", http.MethodGet)
}

func getCarsSuggest(c *gin.Context) {
	proxyToYandex(c, yandexFleetAPIBase+"/vehicles-manager/v1/cars/suggest?is_rental=true", http.MethodGet)
}

func getCostDetail(c *gin.Context) {
	id := c.Param("id")
	proxyToYandex(c, yandexFleetAPIBase+"/fleet-vehicles-economy/v1/costs?id="+id, http.MethodGet)
}

func updateCost(c *gin.Context) {
	proxyToYandex(c, yandexFleetAPIBase+"/fleet-vehicles-economy/v1/costs", http.MethodPut)
}

func createCost(c *gin.Context) {
	proxyToYandex(c, yandexFleetAPIBase+"/fleet-vehicles-economy/v1/costs", http.MethodPost)
}

func getDriverBalanceHistory(c *gin.Context) {
	proxyToYandex(c, yandexDriverBalanceHistoryURL, http.MethodPost)
}

// ─── Report Generation Handlers ──────────────────────────────────────────────

func initiateReportGeneration(c *gin.Context) {
	// Get operation_id from request body
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

	// Remove operation_id from body as it goes in query params
	delete(body, "operation_id")
	delete(body, "report_type")

	// Build request body with only filters and date_period
	requestBody := map[string]interface{}{
		"filters":     body["filters"],
		"date_period": body["date_period"],
	}

	// Rebuild body from our map
	bodyJSON, _ := json.Marshal(requestBody)

	// Proxy to Yandex Fleet API with operation_id as query param
	targetURL := yandexFleetAPIBase + "/reports-builder/report/costs?operation_id=" + operationID
	log.Printf("[REPORT] Initiating report generation: %s with body: %s", targetURL, string(bodyJSON))

	s := getSession(c)

	req, err := http.NewRequest(http.MethodPost, targetURL, bytes.NewBuffer(bodyJSON))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept-Language", "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7")
	req.Header.Set("x-park-id", s.ParkID)

	cookieValue := "Session_id=" + s.SessionID + "; sessionid2=" + s.SessionID2
	if s.LoginToken != "" {
		cookieValue += "; L=" + s.LoginToken
	}
	if s.Login != "" {
		cookieValue += "; yandex_login=" + s.Login
	}
	if s.UID != "" {
		cookieValue += "; yandexuid=" + s.UID
	}
	req.Header.Set("Cookie", cookieValue)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		c.JSON(http.StatusBadGateway, gin.H{"error": "Failed to reach Yandex Fleet API"})
		return
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	log.Printf("[REPORT] Initiate response: status=%d body=%s", resp.StatusCode, string(respBody))

	c.Data(resp.StatusCode, resp.Header.Get("Content-Type"), respBody)
}

func checkReportStatus(c *gin.Context) {
	operationID := c.Query("operation_id")
	if operationID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "operation_id is required"})
		return
	}

	// Correct URL: https://fleet.yandex.ru/api/fleet/reports-storage/v1/operations/status?operation_id=...
	targetURL := "https://fleet.yandex.ru/api/fleet/reports-storage/v1/operations/status?operation_id=" + operationID
	log.Printf("[REPORT] Checking status: %s", targetURL)

	s := getSession(c)
	req, err := http.NewRequest(http.MethodGet, targetURL, nil)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Accept-Language", "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7")
	req.Header.Set("x-park-id", s.ParkID)

	cookieValue := "Session_id=" + s.SessionID + "; sessionid2=" + s.SessionID2
	if s.LoginToken != "" {
		cookieValue += "; L=" + s.LoginToken
	}
	if s.Login != "" {
		cookieValue += "; yandex_login=" + s.Login
	}
	if s.UID != "" {
		cookieValue += "; yandexuid=" + s.UID
	}
	req.Header.Set("Cookie", cookieValue)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		c.JSON(http.StatusBadGateway, gin.H{"error": "Failed to reach Yandex Fleet API"})
		return
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	log.Printf("[REPORT] Status response: status=%d body=%s", resp.StatusCode, string(respBody))

	c.Data(resp.StatusCode, resp.Header.Get("Content-Type"), respBody)
}

func getReportDownloadLink(c *gin.Context) {
	operationID := c.Query("operation_id")
	if operationID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "operation_id is required"})
		return
	}

	// Correct URL: https://fleet.yandex.ru/api/fleet/reports-storage/v1/operations/download?operation_id=...
	targetURL := "https://fleet.yandex.ru/api/fleet/reports-storage/v1/operations/download?operation_id=" + operationID
	log.Printf("[REPORT] Getting download link: %s", targetURL)

	s := getSession(c)
	req, err := http.NewRequest(http.MethodGet, targetURL, nil)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Accept-Language", "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7")
	req.Header.Set("x-park-id", s.ParkID)

	cookieValue := "Session_id=" + s.SessionID + "; sessionid2=" + s.SessionID2
	if s.LoginToken != "" {
		cookieValue += "; L=" + s.LoginToken
	}
	if s.Login != "" {
		cookieValue += "; yandex_login=" + s.Login
	}
	if s.UID != "" {
		cookieValue += "; yandexuid=" + s.UID
	}
	req.Header.Set("Cookie", cookieValue)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		c.JSON(http.StatusBadGateway, gin.H{"error": "Failed to reach Yandex Fleet API"})
		return
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	log.Printf("[REPORT] Download link response: status=%d body=%s", resp.StatusCode, string(respBody))

	c.Data(resp.StatusCode, resp.Header.Get("Content-Type"), respBody)
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

	targetURL := "https://fleet.yandex.ru/api/reports-api/v1/regular-charges/download-async?operation_id=" + operationID
	log.Printf("[REPORT] Initiating regular charges report: %s with body: %s", targetURL, string(bodyJSON))

	s := getSession(c)

	req, err := http.NewRequest(http.MethodPost, targetURL, bytes.NewBuffer(bodyJSON))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept-Language", "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7")
	req.Header.Set("x-park-id", s.ParkID)

	cookieValue := "Session_id=" + s.SessionID + "; sessionid2=" + s.SessionID2
	if s.LoginToken != "" {
		cookieValue += "; L=" + s.LoginToken
	}
	if s.Login != "" {
		cookieValue += "; yandex_login=" + s.Login
	}
	if s.UID != "" {
		cookieValue += "; yandexuid=" + s.UID
	}
	req.Header.Set("Cookie", cookieValue)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		c.JSON(http.StatusBadGateway, gin.H{"error": "Failed to reach Yandex Fleet API"})
		return
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	log.Printf("[REPORT] Regular charges report response: status=%d body=%s", resp.StatusCode, string(respBody))

	c.Data(resp.StatusCode, resp.Header.Get("Content-Type"), respBody)
}

func RegisterRoutes(r *gin.Engine) {
	g := r.Group("/api/expenses", authMiddleware)
	{
		g.POST("/costs/list", getCostsList)
		g.GET("/costs/:id", getCostDetail)
		g.PUT("/costs", updateCost)
		g.POST("/costs", createCost)
		g.GET("/cost-types", getAvailableCostTypes)
		g.GET("/cars/suggest", getCarsSuggest)

		g.POST("/driver/balance-history", getDriverBalanceHistory)

		// Report generation endpoints
		g.POST("/reports/initiate", initiateReportGeneration)
		g.POST("/reports/regular-charges/initiate", initiateRegularChargesReport)
		g.GET("/reports/status", checkReportStatus)
		g.GET("/reports/download", getReportDownloadLink)
	}
}
