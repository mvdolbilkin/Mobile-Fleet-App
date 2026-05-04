package garage

import (
	"bytes"
	"io"
	"net/http"

	"backend/internal/session"

	"github.com/gin-gonic/gin"
)

const yandexFleetAPIBase = "https://fleet.yandex.ru/api/fleet"

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

	c.Data(resp.StatusCode, resp.Header.Get("Content-Type"), respBody)
}

// ─── Handlers ────────────────────────────────────────────────────────────────

func getPostingsList(c *gin.Context) {
	proxyToYandex(c, yandexFleetAPIBase+"/fleet-vehicles-rent/v2/posting/list", http.MethodPost)
}

func getOfficeAddressList(c *gin.Context) {
	proxyToYandex(c, yandexFleetAPIBase+"/hiring-taxiparks-gambling/v1/office-address/list", http.MethodPost)
}

func getCarsSuggest(c *gin.Context) {
	proxyToYandex(c, yandexFleetAPIBase+"/vehicles-manager/v1/cars/suggest?is_active=true&is_rental=true", http.MethodGet)
}

// ─── Routes ──────────────────────────────────────────────────────────────────

func RegisterRoutes(r *gin.Engine) {
	g := r.Group("/api/garage", authMiddleware)
	{
		g.POST("/postings/list", getPostingsList)
		g.POST("/offices/list", getOfficeAddressList)
		g.GET("/cars/suggest", getCarsSuggest)
	}
}
