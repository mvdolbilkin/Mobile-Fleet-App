package vehicles

import (
	"bytes"
	"fmt"
	"io"
	"math/rand"
	"net/http"
	"time"

	"backend/internal/session"

	"github.com/gin-gonic/gin"
)

const yandexFleetVehiclesListURL = "https://fleet.yandex.ru/api/fleet/vehicles-manager/v1/vehicles/list"
const yandexFleetCarAPIURL = "https://fleet-api.taxi.yandex.net/v2/parks/vehicles/car"
const yandexFleetCreateCarAPIURL = "https://fleet-api.taxi.yandex.net/v2/parks/vehicles/car"

// RegisterRoutes registers the vehicle routes onto the provided gin.Engine
func RegisterRoutes(r *gin.Engine) {
	vehiclesGroup := r.Group("/api/vehicles")
	{
		vehiclesGroup.POST("/list", listVehiclesProxy)
		vehiclesGroup.GET("/car", getVehicleProxy)
		vehiclesGroup.POST("/create", createVehicleProxy)
		vehiclesGroup.PUT("/car", updateVehicleProxy)
	}
}

func listVehiclesProxy(c *gin.Context) {
	// Получаем userID из заголовка (park_id используется как userID)
	userID := c.GetHeader("X-Park-ID")
	if userID == "" {
		userID = c.GetHeader("x-park-id")
	}
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "X-Park-ID header is required"})
		return
	}

	// Получаем сессию пользователя
	store := session.GetStore()
	userSession, exists := store.Get(userID)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Session not found. Please login again."})
		return
	}

	// Read the incoming request body
	body, err := io.ReadAll(c.Request.Body)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to read request body"})
		return
	}

	// Create a new HTTP request to Yandex API
	req, err := http.NewRequest(http.MethodPost, yandexFleetVehiclesListURL, bytes.NewBuffer(body))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept-Language", "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7")
	req.Header.Set("x-park-id", userSession.ParkID)

	// Формируем cookie header из сессии
	cookieValue := "Session_id=" + userSession.SessionID + "; sessionid2=" + userSession.SessionID2
	if userSession.LoginToken != "" {
		cookieValue += "; L=" + userSession.LoginToken
	}
	if userSession.Login != "" {
		cookieValue += "; yandex_login=" + userSession.Login
	}
	if userSession.UID != "" {
		cookieValue += "; yandexuid=" + userSession.UID
	}
	req.Header.Set("Cookie", cookieValue)

	// Initialize HTTP client and execute the request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusBadGateway, gin.H{"error": "Failed to reach Yandex Fleet API"})
		return
	}
	defer resp.Body.Close()

	// Read the response from Yandex API
	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read response from Yandex API"})
		return
	}

	// forward the exact status code and response body back to the client
	c.Data(resp.StatusCode, resp.Header.Get("Content-Type"), respBody)
}

func getVehicleProxy(c *gin.Context) {
	vehicleID := c.Query("vehicle_id")
	if vehicleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing vehicle_id query parameter"})
		return
	}

	requestURL := yandexFleetCarAPIURL + "?vehicle_id=" + vehicleID

	req, err := http.NewRequest(http.MethodGet, requestURL, nil)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	apiKey := c.GetHeader("X-API-Key")
	clientID := c.GetHeader("X-Client-ID")
	parkID := c.GetHeader("X-Park-ID")

	if apiKey == "" || clientID == "" || parkID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing required authentication headers"})
		return
	}

	req.Header.Set("X-API-Key", apiKey)
	req.Header.Set("X-Client-ID", clientID)
	req.Header.Set("X-Park-ID", parkID)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusBadGateway, gin.H{"error": "Failed to reach Yandex Fleet API"})
		return
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read response from Yandex API"})
		return
	}

	c.Data(resp.StatusCode, resp.Header.Get("Content-Type"), respBody)
}

func createVehicleProxy(c *gin.Context) {
	// Read the incoming request body
	body, err := io.ReadAll(c.Request.Body)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to read request body"})
		return
	}

	// Create a new HTTP request to Yandex API
	req, err := http.NewRequest(http.MethodPost, yandexFleetCreateCarAPIURL, bytes.NewBuffer(body))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	// Set headers
	req.Header.Set("Content-Type", "application/json")
	
	// Retrieving API keys from headers sent by the mobile app
	apiKey := c.GetHeader("X-API-Key")
	clientID := c.GetHeader("X-Client-ID")
	parkID := c.GetHeader("X-Park-ID")

	if apiKey == "" || clientID == "" || parkID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing required authentication headers"})
		return
	}

	req.Header.Set("X-API-Key", apiKey)
	req.Header.Set("X-Client-ID", clientID)
	req.Header.Set("X-Park-ID", parkID)

	// Generate idempotency token (using a simple approach)
	idempotencyToken := generateIdempotencyToken()
	req.Header.Set("X-Idempotency-Token", idempotencyToken)

	// Initialize HTTP client and execute the request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusBadGateway, gin.H{"error": "Failed to reach Yandex Fleet API"})
		return
	}
	defer resp.Body.Close()

	// Read the response from Yandex API
	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read response from Yandex API"})
		return
	}

	// Forward the exact status code and response body back to the client
	c.Data(resp.StatusCode, resp.Header.Get("Content-Type"), respBody)
}

// generateIdempotencyToken generates a simple idempotency token
// In production, you might want to use a more sophisticated approach
func generateIdempotencyToken() string {
	// Simple implementation using timestamp and random component
	// This should be at least 16 characters as per API requirements
	return fmt.Sprintf("%d%016x", time.Now().Unix(), rand.Int63())
}

func updateVehicleProxy(c *gin.Context) {
	vehicleID := c.Query("vehicle_id")
	if vehicleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing vehicle_id query parameter"})
		return
	}

	// Read the incoming request body
	body, err := io.ReadAll(c.Request.Body)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to read request body"})
		return
	}

	requestURL := yandexFleetCarAPIURL + "?vehicle_id=" + vehicleID

	// Create a new HTTP request to Yandex API
	req, err := http.NewRequest(http.MethodPut, requestURL, bytes.NewBuffer(body))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	// Set headers
	req.Header.Set("Content-Type", "application/json")
	
	// Retrieving API keys from headers sent by the mobile app
	apiKey := c.GetHeader("X-API-Key")
	clientID := c.GetHeader("X-Client-ID")
	parkID := c.GetHeader("X-Park-ID")

	if apiKey == "" || clientID == "" || parkID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing required authentication headers"})
		return
	}

	req.Header.Set("X-API-Key", apiKey)
	req.Header.Set("X-Client-ID", clientID)
	req.Header.Set("X-Park-ID", parkID)

	// Initialize HTTP client and execute the request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusBadGateway, gin.H{"error": "Failed to reach Yandex Fleet API"})
		return
	}
	defer resp.Body.Close()

	// Read the response from Yandex API
	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read response from Yandex API"})
		return
	}

	// Forward the exact status code and response body back to the client
	c.Data(resp.StatusCode, resp.Header.Get("Content-Type"), respBody)
}
