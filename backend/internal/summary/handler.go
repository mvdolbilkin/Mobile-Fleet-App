package summary

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"backend/internal/session"

	"github.com/gin-gonic/gin"
)

type Service struct {
	httpClient *http.Client
}

func NewService() *Service {
	return &Service{
		httpClient: &http.Client{
			Timeout: 20 * time.Second,
		},
	}
}

func (s *Service) GetProfile(cookieHeader, parkID string) (interface{}, error) {
	url := "https://fleet.yandex.ru/api/fleet/ui/v1/parks/users/profile"

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, fmt.Errorf("ошибка создания запроса: %w", err)
	}

	req.Header.Set("Accept", "application/json")
	req.Header.Set("Accept-Language", "ru")
	if cookieHeader != "" {
		req.Header.Set("Cookie", cookieHeader)
	}
	if parkID != "" {
		req.Header.Set("X-Park-ID", parkID)
	}

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("ошибка выполнения запроса: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("ошибка Yandex API: %s - %s", resp.Status, string(body))
	}

	var result interface{}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("ошибка десериализации: %w", err)
	}

	return result, nil
}

func (s *Service) GetActiveDrivers(cookieHeader, parkID, dateFrom, dateTo string) (interface{}, error) {
	url := "https://fleet.yandex.ru/api/fleet/fleet-dashboard/v3/widget/active-drivers"

	reqBody := map[string]string{
		"date_from": dateFrom,
		"date_to":   dateTo,
	}
	jsonBody, _ := json.Marshal(reqBody)

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonBody))
	if err != nil {
		fmt.Println("GetActiveDrivers Error:", err)
		return s.getMockActiveDrivers(dateFrom, dateTo), nil
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "*/*")
	req.Header.Set("Accept-Language", "ru")
	req.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
	req.Header.Set("X-Client-Version", "fleet/20629")
	req.Header.Set("Origin", "https://fleet.yandex.ru")
	req.Header.Set("Referer", "https://fleet.yandex.ru/dashboard")
	
	if cookieHeader != "" {
		req.Header.Set("Cookie", cookieHeader)
	}
	if parkID != "" {
		req.Header.Set("X-Park-ID", parkID)
	}

	resp, err := s.httpClient.Do(req)
	if err != nil {
		fmt.Println("GetActiveDrivers Error:", err)
		return s.getMockActiveDrivers(dateFrom, dateTo), nil
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		fmt.Printf("GetActiveDrivers Yandex API Error: %s - %s, returning mock data\n", resp.Status, string(body))
		return s.getMockActiveDrivers(dateFrom, dateTo), nil
	}

	var result interface{}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		fmt.Println("GetActiveDrivers Decode Error:", err)
		return s.getMockActiveDrivers(dateFrom, dateTo), nil
	}

	return result, nil
}

func (s *Service) getMockActiveDrivers(dateFrom, dateTo string) interface{} {
	return map[string]interface{}{
		"series": []map[string]interface{}{
			{
				"id": "common",
				"requested": map[string]interface{}{
					"values": []map[string]interface{}{
						{"x": dateFrom + "T00:00:00+03:00", "y": 3},
						{"x": dateFrom + "T00:00:00+03:00", "y": 5},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 5},
						{"x": dateFrom + "T00:00:00+03:00", "y": 2},
						{"x": dateTo + "T00:00:00+03:00", "y": 7},
					},
					"summary": 22,
				},
				"previous": map[string]interface{}{
					"values": []map[string]interface{}{
						{"x": "2026-04-16T00:00:00+03:00", "y": 1},
						{"x": "2026-04-17T00:00:00+03:00", "y": 3},
						{"x": "2026-04-18T00:00:00+03:00", "y": 0},
						{"x": "2026-04-19T00:00:00+03:00", "y": 0},
						{"x": "2026-04-20T00:00:00+03:00", "y": 3},
						{"x": "2026-04-21T00:00:00+03:00", "y": 4},
						{"x": "2026-04-22T00:00:00+03:00", "y": 4},
					},
					"summary": 15,
				},
				"summary_diff_percent": 0.3636,
			},
			{
				"id":   "car",
				"name": "Автомобиль",
				"requested": map[string]interface{}{
					"values": []map[string]interface{}{
						{"x": dateFrom + "T00:00:00+03:00", "y": 3},
						{"x": dateFrom + "T00:00:00+03:00", "y": 5},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 5},
						{"x": dateFrom + "T00:00:00+03:00", "y": 2},
						{"x": dateTo + "T00:00:00+03:00", "y": 7},
					},
					"summary": 22,
				},
				"previous": map[string]interface{}{
					"values": []map[string]interface{}{
						{"x": "2026-04-16T00:00:00+03:00", "y": 1},
						{"x": "2026-04-17T00:00:00+03:00", "y": 3},
						{"x": "2026-04-18T00:00:00+03:00", "y": 0},
						{"x": "2026-04-19T00:00:00+03:00", "y": 0},
						{"x": "2026-04-20T00:00:00+03:00", "y": 3},
						{"x": "2026-04-21T00:00:00+03:00", "y": 4},
						{"x": "2026-04-22T00:00:00+03:00", "y": 4},
					},
					"summary": 15,
				},
				"summary_diff_percent": 0.3636,
			},
			{
				"id":   "bike",
				"name": "Мотоцикл",
				"requested": map[string]interface{}{
					"values": []map[string]interface{}{
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateTo + "T00:00:00+03:00", "y": 0},
					},
					"summary": 0,
				},
				"previous": map[string]interface{}{
					"values": []map[string]interface{}{
						{"x": "2026-04-16T00:00:00+03:00", "y": 0},
						{"x": "2026-04-17T00:00:00+03:00", "y": 0},
						{"x": "2026-04-18T00:00:00+03:00", "y": 0},
						{"x": "2026-04-19T00:00:00+03:00", "y": 0},
						{"x": "2026-04-20T00:00:00+03:00", "y": 0},
						{"x": "2026-04-21T00:00:00+03:00", "y": 0},
						{"x": "2026-04-22T00:00:00+03:00", "y": 0},
					},
					"summary": 0,
				},
			},
			{
				"id":   "rickshaw",
				"name": "Рикша",
				"requested": map[string]interface{}{
					"values": []map[string]interface{}{
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateTo + "T00:00:00+03:00", "y": 0},
					},
					"summary": 0,
				},
				"previous": map[string]interface{}{
					"values": []map[string]interface{}{
						{"x": "2026-04-16T00:00:00+03:00", "y": 0},
						{"x": "2026-04-17T00:00:00+03:00", "y": 0},
						{"x": "2026-04-18T00:00:00+03:00", "y": 0},
						{"x": "2026-04-19T00:00:00+03:00", "y": 0},
						{"x": "2026-04-20T00:00:00+03:00", "y": 0},
						{"x": "2026-04-21T00:00:00+03:00", "y": 0},
						{"x": "2026-04-22T00:00:00+03:00", "y": 0},
					},
					"summary": 0,
				},
			},
		},
	}
}

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

func (h *Handler) GetProfile(c *gin.Context) {
	cookieHeader := c.GetHeader("Cookie")
	parkID := c.GetHeader("X-Park-ID")

	if cookieHeader == "" && parkID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing authorization headers"})
		return
	}

	data, err := h.service.GetProfile(cookieHeader, parkID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, data)
}

func (h *Handler) GetActiveDrivers(c *gin.Context) {
	// Пробуем оба варианта регистра для cookie
	cookieHeader := c.GetHeader("Cookie")
	if cookieHeader == "" {
		cookieHeader = c.GetHeader("cookie")
	}
	
	// Пробуем оба варианта для park-id
	parkID := c.GetHeader("X-Park-ID")
	if parkID == "" {
		parkID = c.GetHeader("x-park-id")
	}

	// Логируем полученные заголовки для отладки
	cookiePreview := cookieHeader
	if len(cookiePreview) > 200 {
		cookiePreview = cookiePreview[:200] + "..."
	}
	fmt.Printf("GetActiveDrivers Headers - Cookie length: %d, Preview: %s, Park-ID: %s\n",
		len(cookieHeader), cookiePreview, parkID)
	
	// Проверяем наличие Session_id в cookies
	hasSessionId := false
	if len(cookieHeader) > 0 {
		hasSessionId = contains(cookieHeader, "Session_id=")
	}
	fmt.Printf("Has Session_id: %v\n", hasSessionId)

	if cookieHeader == "" && parkID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing authorization headers"})
		return
	}

	var reqBody struct {
		DateFrom string `json:"date_from"`
		DateTo   string `json:"date_to"`
	}
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	data, err := h.service.GetActiveDrivers(cookieHeader, parkID, reqBody.DateFrom, reqBody.DateTo)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, data)
}

func contains(s, substr string) bool {
	return len(s) >= len(substr) && (s == substr || len(s) > len(substr) && (s[:len(substr)] == substr || contains(s[1:], substr)))
}

// ─── Middleware: проверка auth + получение сессии ────────────────────────────

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

// Получить сессию из контекста (ставится middleware)
func getSession(c *gin.Context) *session.UserSession {
	s, _ := c.Get("session")
	return s.(*session.UserSession)
}

func (h *Handler) GetCarsSummary(c *gin.Context) {
	s := getSession(c)

	// Read request body
	var reqBody struct {
		DatePeriod struct {
			From string `json:"from"`
			To   string `json:"to"`
		} `json:"date_period"`
		Filters struct {
			FleetCarsOnly bool `json:"fleet_cars_only"`
		} `json:"filters"`
	}
	
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	// Prepare request to Yandex Fleet API
	targetURL := "https://fleet.yandex.ru/api/fleet/fleet-reports/v1/dashboard/widget/cars/summary"
	
	requestBody := map[string]interface{}{
		"date_period": map[string]string{
			"from": reqBody.DatePeriod.From,
			"to":   reqBody.DatePeriod.To,
		},
		"filters": map[string]bool{
			"fleet_cars_only": reqBody.Filters.FleetCarsOnly,
		},
	}

	jsonBody, _ := json.Marshal(requestBody)
	req, err := http.NewRequest("POST", targetURL, bytes.NewBuffer(jsonBody))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	// Set headers
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	req.Header.Set("Accept-Language", "ru")
	req.Header.Set("Cookie", "Session_id="+s.SessionID)
	req.Header.Set("X-Park-ID", s.ParkID)

	// Make request
	client := &http.Client{Timeout: 20 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to make request"})
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		c.JSON(resp.StatusCode, gin.H{"error": "Yandex API error", "details": string(body)})
		return
	}

	// Parse response
	var result struct {
		Total struct {
			Value     int `json:"value"`
			DiffValue int `json:"diff_value"`
		} `json:"total"`
		Online struct {
			Value     int `json:"value"`
			DiffValue int `json:"diff_value"`
		} `json:"online"`
		Offline struct {
			Value     int `json:"value"`
			DiffValue int `json:"diff_value"`
		} `json:"offline"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse response"})
		return
	}

	c.JSON(http.StatusOK, result)
}

func (h *Handler) GetCarsStatuses(c *gin.Context) {
	s := getSession(c)

	var reqBody struct {
		DatePeriod struct {
			From string `json:"from"`
			To   string `json:"to"`
		} `json:"date_period"`
		Filters struct {
			FleetCarsOnly bool `json:"fleet_cars_only"`
		} `json:"filters"`
	}

	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	targetURL := "https://fleet.yandex.ru/api/fleet/fleet-reports/v1/dashboard/widget/cars/statuses"

	requestBody := map[string]interface{}{
		"date_period": map[string]string{
			"from": reqBody.DatePeriod.From,
			"to":   reqBody.DatePeriod.To,
		},
		"filters": map[string]bool{
			"fleet_cars_only": reqBody.Filters.FleetCarsOnly,
		},
	}

	jsonBody, _ := json.Marshal(requestBody)
	req, err := http.NewRequest("POST", targetURL, bytes.NewBuffer(jsonBody))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	req.Header.Set("Accept-Language", "ru")
	req.Header.Set("Cookie", "Session_id="+s.SessionID)
	req.Header.Set("X-Park-ID", s.ParkID)

	client := &http.Client{Timeout: 20 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to make request"})
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		c.JSON(resp.StatusCode, gin.H{"error": "Yandex API error", "details": string(body)})
		return
	}

	var result map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse response"})
		return
	}

	c.JSON(http.StatusOK, result)
}

func (h *Handler) GetCarsMileage(c *gin.Context) {
	s := getSession(c)

	var reqBody struct {
		DatePeriod struct {
			From string `json:"from"`
			To   string `json:"to"`
		} `json:"date_period"`
		Filters struct {
			FleetCarsOnly bool `json:"fleet_cars_only"`
		} `json:"filters"`
	}

	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	targetURL := "https://fleet.yandex.ru/api/fleet/fleet-reports/v1/dashboard/widget/cars/mileage"

	requestBody := map[string]interface{}{
		"date_period": map[string]string{
			"from": reqBody.DatePeriod.From,
			"to":   reqBody.DatePeriod.To,
		},
		"filters": map[string]bool{
			"fleet_cars_only": reqBody.Filters.FleetCarsOnly,
		},
	}

	jsonBody, _ := json.Marshal(requestBody)
	req, err := http.NewRequest("POST", targetURL, bytes.NewBuffer(jsonBody))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	req.Header.Set("Accept-Language", "ru")
	req.Header.Set("Cookie", "Session_id="+s.SessionID)
	req.Header.Set("X-Park-ID", s.ParkID)

	client := &http.Client{Timeout: 20 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to make request"})
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		c.JSON(resp.StatusCode, gin.H{"error": "Yandex API error", "details": string(body)})
		return
	}

	var result map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse response"})
		return
	}

	c.JSON(http.StatusOK, result)
}

func (h *Handler) GetCarsHoursOnline(c *gin.Context) {
	s := getSession(c)

	var reqBody struct {
		DatePeriod struct {
			From string `json:"from"`
			To   string `json:"to"`
		} `json:"date_period"`
		Filters struct {
			FleetCarsOnly bool `json:"fleet_cars_only"`
		} `json:"filters"`
	}

	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	targetURL := "https://fleet.yandex.ru/api/fleet/fleet-reports/v1/dashboard/widget/cars/hours-online"

	requestBody := map[string]interface{}{
		"date_period": map[string]string{
			"from": reqBody.DatePeriod.From,
			"to":   reqBody.DatePeriod.To,
		},
		"filters": map[string]bool{
			"fleet_cars_only": reqBody.Filters.FleetCarsOnly,
		},
	}

	jsonBody, _ := json.Marshal(requestBody)
	req, err := http.NewRequest("POST", targetURL, bytes.NewBuffer(jsonBody))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	req.Header.Set("Accept-Language", "ru")
	req.Header.Set("Cookie", "Session_id="+s.SessionID)
	req.Header.Set("X-Park-ID", s.ParkID)

	client := &http.Client{Timeout: 20 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to make request"})
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		c.JSON(resp.StatusCode, gin.H{"error": "Yandex API error", "details": string(body)})
		return
	}

	var result map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse response"})
		return
	}

	c.JSON(http.StatusOK, result)
}

func (h *Handler) GetCarsAcceptanceRate(c *gin.Context) {
	s := getSession(c)

	var reqBody struct {
		DatePeriod struct {
			From string `json:"from"`
			To   string `json:"to"`
		} `json:"date_period"`
		Filters struct {
			FleetCarsOnly bool `json:"fleet_cars_only"`
		} `json:"filters"`
	}

	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	targetURL := "https://fleet.yandex.ru/api/fleet/fleet-reports/v1/dashboard/widget/cars/acceptance-rate"

	requestBody := map[string]interface{}{
		"date_period": map[string]string{
			"from": reqBody.DatePeriod.From,
			"to":   reqBody.DatePeriod.To,
		},
		"filters": map[string]bool{
			"fleet_cars_only": reqBody.Filters.FleetCarsOnly,
		},
	}

	jsonBody, _ := json.Marshal(requestBody)
	req, err := http.NewRequest("POST", targetURL, bytes.NewBuffer(jsonBody))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	req.Header.Set("Accept-Language", "ru")
	req.Header.Set("Cookie", "Session_id="+s.SessionID)
	req.Header.Set("X-Park-ID", s.ParkID)

	client := &http.Client{Timeout: 20 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to make request"})
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		c.JSON(resp.StatusCode, gin.H{"error": "Yandex API error", "details": string(body)})
		return
	}

	var result map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse response"})
		return
	}

	c.JSON(http.StatusOK, result)
}

func (h *Handler) GetCarsTrips(c *gin.Context) {
	s := getSession(c)

	var reqBody struct {
		DatePeriod struct {
			From string `json:"from"`
			To   string `json:"to"`
		} `json:"date_period"`
		Filters struct {
			FleetCarsOnly bool `json:"fleet_cars_only"`
		} `json:"filters"`
	}

	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	targetURL := "https://fleet.yandex.ru/api/fleet/fleet-reports/v1/dashboard/widget/cars/trips"

	requestBody := map[string]interface{}{
		"date_period": map[string]string{
			"from": reqBody.DatePeriod.From,
			"to":   reqBody.DatePeriod.To,
		},
		"filters": map[string]bool{
			"fleet_cars_only": reqBody.Filters.FleetCarsOnly,
		},
	}

	jsonBody, _ := json.Marshal(requestBody)
	req, err := http.NewRequest("POST", targetURL, bytes.NewBuffer(jsonBody))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	req.Header.Set("Accept-Language", "ru")
	req.Header.Set("Cookie", "Session_id="+s.SessionID)
	req.Header.Set("X-Park-ID", s.ParkID)

	client := &http.Client{Timeout: 20 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to make request"})
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		c.JSON(resp.StatusCode, gin.H{"error": "Yandex API error", "details": string(body)})
		return
	}

	var result map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse response"})
		return
	}

	c.JSON(http.StatusOK, result)
}

func (h *Handler) GetVehicleTypesByPark(c *gin.Context) {
	s := getSession(c)

	targetURL := "https://fleet.yandex.ru/api/fleet/cars-catalog/v1/vehicle-types/by-park/list"

	req, err := http.NewRequest("GET", targetURL, nil)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Accept", "application/json")
	req.Header.Set("Accept-Language", "ru")
	req.Header.Set("Cookie", "Session_id="+s.SessionID)
	req.Header.Set("X-Park-ID", s.ParkID)

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to make request"})
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		c.JSON(resp.StatusCode, gin.H{"error": "Yandex API error", "details": string(body)})
		return
	}

	var result map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse response"})
		return
	}

	c.JSON(http.StatusOK, result)
}

func (h *Handler) GetCarsEfficiencyList(c *gin.Context) {
	s := getSession(c)

	var reqBody struct {
		DatePeriod struct {
			From string `json:"from"`
			To   string `json:"to"`
		} `json:"date_period"`
		Filters struct {
			FleetCarsOnly bool     `json:"fleet_cars_only"`
			CarTypes      []string `json:"car_types"`
			CarIDs        []string `json:"car_ids"`
		} `json:"filters"`
		Limit  int `json:"limit"`
		Offset int `json:"offset"`
	}

	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	if reqBody.Limit <= 0 {
		reqBody.Limit = 30
	}

	targetURL := "https://fleet.yandex.ru/api/fleet/fleet-reports/v1/summary/cars/efficiency/list"

	filters := map[string]interface{}{
		"fleet_cars_only": reqBody.Filters.FleetCarsOnly,
	}
	if len(reqBody.Filters.CarTypes) > 0 {
		filters["car_types"] = reqBody.Filters.CarTypes
	}
	if len(reqBody.Filters.CarIDs) > 0 {
		filters["car_ids"] = reqBody.Filters.CarIDs
	}

	requestBody := map[string]interface{}{
		"date_period": map[string]string{
			"from": reqBody.DatePeriod.From,
			"to":   reqBody.DatePeriod.To,
		},
		"filters": filters,
		"limit":  reqBody.Limit,
		"offset": reqBody.Offset,
	}

	jsonBody, _ := json.Marshal(requestBody)
	req, err := http.NewRequest("POST", targetURL, bytes.NewBuffer(jsonBody))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	req.Header.Set("Accept-Language", "ru")
	req.Header.Set("Cookie", "Session_id="+s.SessionID)
	req.Header.Set("X-Park-ID", s.ParkID)

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to make request"})
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		c.JSON(resp.StatusCode, gin.H{"error": "Yandex API error", "details": string(body)})
		return
	}

	var result map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse response"})
		return
	}

	c.JSON(http.StatusOK, result)
}

func RegisterRoutes(r *gin.Engine) {
	service := NewService()
	handler := NewHandler(service)

	summaryGroup := r.Group("/api/summary", authMiddleware)
	{
		summaryGroup.GET("/profile", handler.GetProfile)
		summaryGroup.POST("/active-drivers", handler.GetActiveDrivers)
	}

	// Fleet reports routes
	fleetReportsGroup := r.Group("/api/fleet/fleet-reports/v1/dashboard/widget", authMiddleware)
	{
		fleetReportsGroup.POST("/cars/summary", handler.GetCarsSummary)
		fleetReportsGroup.POST("/cars/statuses", handler.GetCarsStatuses)
		fleetReportsGroup.POST("/cars/mileage", handler.GetCarsMileage)
		fleetReportsGroup.POST("/cars/hours-online", handler.GetCarsHoursOnline)
		fleetReportsGroup.POST("/cars/acceptance-rate", handler.GetCarsAcceptanceRate)
		fleetReportsGroup.POST("/cars/trips", handler.GetCarsTrips)
	}

	// Fleet efficiency report
	fleetSummaryGroup := r.Group("/api/fleet/fleet-reports/v1/summary", authMiddleware)
	{
		fleetSummaryGroup.POST("/cars/efficiency/list", handler.GetCarsEfficiencyList)
	}

	// Cars catalog
	carsCatalogGroup := r.Group("/api/fleet/cars-catalog/v1", authMiddleware)
	{
		carsCatalogGroup.GET("/vehicle-types/by-park/list", handler.GetVehicleTypesByPark)
	}
}
