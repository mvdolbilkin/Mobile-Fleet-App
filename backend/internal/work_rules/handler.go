package work_rules

import (
	"fmt"
	"io"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

type Handler struct{}

func NewHandler() *Handler {
	return &Handler{}
}

func RegisterRoutes(r *gin.Engine) {
	handler := NewHandler()

	workRulesGroup := r.Group("/api/work-rules")
	{
		workRulesGroup.GET("/list", handler.GetWorkRules)
		workRulesGroup.GET("/details", handler.GetWorkRuleDetails)
	}
}

func (h *Handler) GetWorkRules(c *gin.Context) {
	isArchived := c.Query("is_archived")
	if isArchived == "" {
		isArchived = "false"
	}

	cookieHeader := c.GetHeader("Cookie")
	parkID := c.GetHeader("X-Park-ID")

	log.Printf("[Work Rules] Request received - is_archived: %s", isArchived)
	log.Printf("[Work Rules] Cookie header length: %d", len(cookieHeader))
	log.Printf("[Work Rules] X-Park-ID: %s", parkID)

	if cookieHeader == "" {
		log.Printf("[Work Rules] ERROR: Missing credentials")
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing credentials"})
		return
	}

	yandexURL := fmt.Sprintf("https://fleet.yandex.ru/api/fleet/driver-work-rules/v1/work-rules?is_archived=%s", isArchived)
	log.Printf("[Work Rules] Requesting Yandex API: %s", yandexURL)

	req, err := http.NewRequest("GET", yandexURL, nil)
	if err != nil {
		log.Printf("[Work Rules] ERROR: Failed to create request: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Cookie", cookieHeader)
	req.Header.Set("Accept-Language", "ru")
	if parkID != "" {
		req.Header.Set("X-Park-ID", parkID)
	}

	log.Printf("[Work Rules] Request headers: Content-Type=%s, X-Park-ID=%s",
		req.Header.Get("Content-Type"), req.Header.Get("X-Park-ID"))

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Printf("[Work Rules] ERROR: Failed to fetch work rules: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to fetch work rules: %v", err)})
		return
	}
	defer resp.Body.Close()

	log.Printf("[Work Rules] Yandex API response status: %d", resp.StatusCode)

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Printf("[Work Rules] ERROR: Failed to read response: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read response"})
		return
	}

	log.Printf("[Work Rules] Response body length: %d bytes", len(body))

	if resp.StatusCode != http.StatusOK {
		log.Printf("[Work Rules] ERROR: Yandex API returned status %d: %s", resp.StatusCode, string(body))
		c.JSON(resp.StatusCode, gin.H{"error": fmt.Sprintf("Yandex API error: %s", string(body))})
		return
	}

	log.Printf("[Work Rules] SUCCESS: Returning work rules data")
	c.Data(resp.StatusCode, "application/json", body)
}

func (h *Handler) GetWorkRuleDetails(c *gin.Context) {
	workRuleID := c.Query("work_rule_id")
	if workRuleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing work_rule_id parameter"})
		return
	}

	cookieHeader := c.GetHeader("Cookie")
	parkID := c.GetHeader("X-Park-ID")

	if cookieHeader == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing credentials"})
		return
	}

	log.Printf("[Work Rule Details] Request received - work_rule_id: %s", workRuleID)

	yandexURL := fmt.Sprintf("https://fleet.yandex.ru/api/fleet/driver-work-rules/v1/work-rules/by-id?work_rule_id=%s", workRuleID)

	req, err := http.NewRequest("GET", yandexURL, nil)
	if err != nil {
		log.Printf("[Work Rule Details] ERROR: Failed to create request: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Cookie", cookieHeader)
	req.Header.Set("Accept-Language", "ru")
	if parkID != "" {
		req.Header.Set("X-Park-ID", parkID)
	}

	log.Printf("[Work Rule Details] Requesting Yandex API: %s", yandexURL)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Printf("[Work Rule Details] ERROR: Request failed: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to fetch work rule details: %v", err)})
		return
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Printf("[Work Rule Details] ERROR: Failed to read response body: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read response"})
		return
	}

	log.Printf("[Work Rule Details] Yandex API response status: %d", resp.StatusCode)
	log.Printf("[Work Rule Details] Response body length: %d bytes", len(body))

	if resp.StatusCode != http.StatusOK {
		log.Printf("[Work Rule Details] ERROR: Yandex API returned status %d: %s", resp.StatusCode, string(body))
		c.JSON(resp.StatusCode, gin.H{"error": string(body)})
		return
	}

	log.Printf("[Work Rule Details] SUCCESS: Returning work rule details")
	c.Data(resp.StatusCode, "application/json", body)
}
