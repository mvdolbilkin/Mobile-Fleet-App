package competitions

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	"github.com/gin-gonic/gin"
)

type Handler struct{}

func NewHandler() *Handler {
	return &Handler{}
}

func RegisterRoutes(r *gin.Engine) {
	handler := NewHandler()

	competitionsGroup := r.Group("/api/competitions")
	{
		competitionsGroup.POST("/list", handler.GetCompetitionsList)
		competitionsGroup.POST("/details", handler.GetCompetitionDetails)
	}
}

func (h *Handler) GetCompetitionsList(c *gin.Context) {
	var requestBody map[string]interface{}
	if err := c.ShouldBindJSON(&requestBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	cookieHeader := c.GetHeader("Cookie")
	parkID := c.GetHeader("X-Park-ID")

	if cookieHeader == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing credentials"})
		return
	}

	// Прокси запрос к Yandex Fleet API
	yandexURL := "https://fleet.yandex.ru/api/fleet/fleet-contractor-motivation/v1/competition/list"

	jsonData, err := json.Marshal(requestBody)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to marshal request"})
		return
	}

	req, err := http.NewRequest("POST", yandexURL, bytes.NewBuffer(jsonData))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Cookie", cookieHeader)
	if parkID != "" {
		req.Header.Set("X-Park-ID", parkID)
	}

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to fetch competitions: %v", err)})
		return
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read response"})
		return
	}

	if resp.StatusCode != http.StatusOK {
		c.JSON(resp.StatusCode, gin.H{"error": string(body)})
		return
	}

	var result map[string]interface{}
	if err := json.Unmarshal(body, &result); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse response"})
		return
	}

	c.JSON(http.StatusOK, result)
}

func (h *Handler) GetCompetitionDetails(c *gin.Context) {
	var requestBody map[string]interface{}
	if err := c.ShouldBindJSON(&requestBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	cookieHeader := c.GetHeader("Cookie")
	parkID := c.GetHeader("X-Park-ID")

	if cookieHeader == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing credentials"})
		return
	}

	// Прокси запрос к Yandex Fleet API
	yandexURL := "https://fleet.yandex.ru/api/fleet/fleet-contractor-motivation/v1/competition/details"

	jsonData, err := json.Marshal(requestBody)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to marshal request"})
		return
	}

	req, err := http.NewRequest("POST", yandexURL, bytes.NewBuffer(jsonData))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Cookie", cookieHeader)
	if parkID != "" {
		req.Header.Set("X-Park-ID", parkID)
	}

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to fetch competition details: %v", err)})
		return
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read response"})
		return
	}

	if resp.StatusCode != http.StatusOK {
		c.JSON(resp.StatusCode, gin.H{"error": string(body)})
		return
	}

	var result map[string]interface{}
	if err := json.Unmarshal(body, &result); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse response"})
		return
	}

	c.JSON(http.StatusOK, result)
}
