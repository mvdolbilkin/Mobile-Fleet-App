package mailings

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

	mailingsGroup := r.Group("/api/mailings")
	{
		mailingsGroup.POST("/list", handler.GetMailingsList)
		mailingsGroup.POST("/item", handler.GetMailingItem)
		mailingsGroup.GET("/details", handler.GetMailingDetails)
	}
}

func (h *Handler) GetMailingsList(c *gin.Context) {
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
	yandexURL := "https://fleet.yandex.ru/api/fleet/communications/v1/mailings/list"

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
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to fetch mailings: %v", err)})
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

func (h *Handler) GetMailingItem(c *gin.Context) {
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
	yandexURL := "https://fleet.yandex.ru/api/fleet/communications/v1/mailings/item"

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
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to fetch mailing item: %v", err)})
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

func (h *Handler) GetMailingDetails(c *gin.Context) {
	mailingID := c.Query("id")
	if mailingID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing mailing ID"})
		return
	}

	cookieHeader := c.GetHeader("Cookie")
	parkID := c.GetHeader("X-Park-ID")

	if cookieHeader == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing credentials"})
		return
	}

	// Прокси запрос к Yandex Fleet API v2
	yandexURL := fmt.Sprintf("https://fleet.yandex.ru/api/fleet/communications/v2/mailings?id=%s", mailingID)

	req, err := http.NewRequest("GET", yandexURL, nil)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Cookie", cookieHeader)
	if parkID != "" {
		req.Header.Set("X-Park-ID", parkID)
	}

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to fetch mailing details: %v", err)})
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
