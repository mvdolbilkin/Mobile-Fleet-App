package expenses

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"

	"backend/internal/session"

	"github.com/gin-gonic/gin"
)

const yandexFleetAPIBase = "https://fleet.yandex.ru/api/fleet"

func RegisterRoutes(r *gin.Engine) {
	r.POST("/api/expenses/costs/list", GetCostsList)
}

// GetCostsList проксирует запрос к Yandex Fleet API для получения списка расходов
func GetCostsList(c *gin.Context) {
	var req CostsListRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Получаем userID из заголовка (park_id используется как userID)
	userID := c.GetHeader("X-Park-ID")
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

	// Подготавливаем запрос к Yandex API
	requestBody, err := json.Marshal(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to marshal request"})
		return
	}

	yandexReq, err := http.NewRequest(
		"POST",
		yandexFleetAPIBase+"/fleet-vehicles-economy/v1/costs/list",
		bytes.NewBuffer(requestBody),
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	// Устанавливаем заголовки с cookies из сессии
	yandexReq.Header.Set("Content-Type", "application/json")
	yandexReq.Header.Set("Accept-Language", "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7")
	yandexReq.Header.Set("x-park-id", userSession.ParkID)
	
	// Формируем cookie header
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
	yandexReq.Header.Set("Cookie", cookieValue)

	// Выполняем запрос
	client := &http.Client{}
	resp, err := client.Do(yandexReq)
	if err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"error": "Failed to connect to Yandex API"})
		return
	}
	defer resp.Body.Close()

	// Читаем ответ
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read response"})
		return
	}

	// Проверяем статус ответа
	if resp.StatusCode != http.StatusOK {
		c.JSON(resp.StatusCode, gin.H{
			"error":  "Yandex API error",
			"status": resp.StatusCode,
			"body":   string(body),
		})
		return
	}

	// Парсим и возвращаем ответ
	var costsResponse interface{}
	if err := json.Unmarshal(body, &costsResponse); err != nil {
		// Если не удалось распарсить, возвращаем как есть
		c.Data(resp.StatusCode, "application/json", body)
		return
	}

	c.JSON(http.StatusOK, costsResponse)
}
