package vehicles

import (
	"bytes"
	"io"
	"net/http"

	"github.com/gin-gonic/gin"
)

const yandexFleetAPIURL = "https://fleet-api.taxi.yandex.net/v1/parks/cars/list"

// RegisterRoutes registers the vehicle routes onto the provided gin.Engine
func RegisterRoutes(r *gin.Engine) {
	vehiclesGroup := r.Group("/api/vehicles")
	{
		vehiclesGroup.POST("/list", listVehiclesProxy)
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
