package vehicles

import (
	"bytes"
	"fmt"
	"io"
	"math/rand"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

const yandexFleetAPIURL = "https://fleet-api.taxi.yandex.net/v1/parks/cars/list"
const yandexFleetCarAPIURL = "https://fleet-api.taxi.yandex.net/v2/parks/vehicles/car"
const yandexFleetCreateCarAPIURL = "https://fleet-api.taxi.yandex.net/v2/parks/vehicles/car"

// RegisterRoutes registers the vehicle routes onto the provided gin.Engine
func RegisterRoutes(r *gin.Engine) {
	vehiclesGroup := r.Group("/api/vehicles")
	{
		vehiclesGroup.POST("/list", listVehiclesProxy)
		vehiclesGroup.GET("/car", getVehicleProxy)
		vehiclesGroup.POST("/create", createVehicleProxy)
	}
}

func listVehiclesProxy(c *gin.Context) {
	// Read the incoming request body
	body, err := io.ReadAll(c.Request.Body)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to read request body"})
		return
	}

	// Create a new HTTP request to Yandex API
	req, err := http.NewRequest(http.MethodPost, yandexFleetAPIURL, bytes.NewBuffer(body))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	// Set headers
	req.Header.Set("Content-Type", "application/json")
	
	// Retrieving API keys from headers sent by the mobile app.
	apiKey := c.GetHeader("X-API-Key")
	clientID := c.GetHeader("X-Client-ID")

	if apiKey == "" || clientID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing X-API-Key or X-Client-ID headers"})
		return
	}

	req.Header.Set("X-API-Key", apiKey)
	req.Header.Set("X-Client-ID", clientID)

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
