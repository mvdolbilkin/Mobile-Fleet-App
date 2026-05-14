package auth

import (
	"bytes"
	"encoding/json"
	"net/http"
	"time"

	"backend/internal/session"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func RegisterRoutes(r *gin.Engine) {
	r.POST("/api/auth/login", LoginHandler)
	r.POST("/api/auth/webview-session", SaveWebViewSessionHandler)
}

func LoginHandler(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	client := &http.Client{}

	// Request body for Yandex Fleet API
	type Park struct {
		ID string `json:"id"`
	}
	type Query struct {
		Park Park `json:"park"`
	}
	type RequestBody struct {
		Query Query `json:"query"`
		Limit int   `json:"limit"`
	}

	payload := RequestBody{
		Query: Query{
			Park: Park{
				ID: req.ParkID,
			},
		},
		Limit: 1,
	}

	requestBody, err := json.Marshal(payload)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to marshal request"})
		return
	}

	yandexReq, err := http.NewRequest("POST", "https://fleet-api.taxi.yandex.net/v1/parks/cars/list", bytes.NewBuffer(requestBody))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	yandexReq.Header.Set("Content-Type", "application/json")
	yandexReq.Header.Set("X-Client-ID", req.Clid)
	yandexReq.Header.Set("X-API-Key", req.ApiKey)

	resp, err := client.Do(yandexReq)
	if err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"error": "Failed to verify credentials"})
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials or park ID"})
		return
	}

	c.JSON(http.StatusOK, LoginResponse{
		Success: true,
		Message: "Login successful",
	})
}

// SaveWebViewSessionHandler сохраняет сессию из WebView авторизации
func SaveWebViewSessionHandler(c *gin.Context) {
	var req WebViewSessionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Получаем или генерируем уникальный ID для пользователя, но ключом сессии будет токен
	appToken := uuid.New().String()

	// Создаем сессию
	userSession := &session.UserSession{
		UserID:     req.UID,    // Используем яндексовый UID, а не ParkID
		SessionID:  req.SessionID,
		SessionID2: req.SessionID2,
		LoginToken: req.LoginToken,
		ParkID:     req.ParkID,
		Login:      req.Login,
		UID:        req.UID,
		CreatedAt:  time.Now(),
		ExpiresAt:  time.Now().Add(7 * 24 * time.Hour), // Сессия на 7 дней
	}

	// Сохраняем в store
	store := session.GetStore()
	if err := store.Set(appToken, userSession); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save session"})
		return
	}

	c.JSON(http.StatusOK, LoginResponse{
		Success: true,
		Message: "WebView session saved successfully",
		Token:   appToken,
	})
}
