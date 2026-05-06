package fines

import (
	"bytes"
	"io"
	"log"
	"net/http"

	"backend/internal/session"

	"github.com/gin-gonic/gin"
)

const yandexFinesRetrieveURL = "https://fleet.yandex.ru/api/fleet/traffic-fines/v2/fines/retrieve"
const yandexFinesTotalURL = "https://fleet.yandex.ru/api/fleet/traffic-fines/v2/fines/total"
const yandexFinesDetailURL = "https://fleet.yandex.ru/api/fleet/traffic-fines/v1/fines"
const yandexFinesDriversSuggestURL = "https://fleet.yandex.ru/api/api/v1/suggestions/drivers"
const yandexFinesCarsSuggestURL = "https://fleet.yandex.ru/api/fleet/vehicles-manager/v1/cars/suggest"

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

// ─── Proxy helper ───────────────────────────────────────────────────────────

func proxyToYandex(c *gin.Context, targetURL string, method string) {
	s := getSession(c)

	var bodyBytes []byte
	if c.Request.Body != nil {
		bodyBytes, _ = io.ReadAll(c.Request.Body)
	}

	log.Printf("[FINES PROXY] Incoming %s %s | parkID=%s | body=%s", method, c.Request.URL.Path, s.ParkID, string(bodyBytes))

	var bodyReader *bytes.Buffer
	if len(bodyBytes) > 0 {
		bodyReader = bytes.NewBuffer(bodyBytes)
	} else {
		bodyReader = bytes.NewBuffer(nil)
	}

	req, err := http.NewRequest(method, targetURL, bodyReader)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "*/*")
	req.Header.Set("Accept-Language", "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7")
	req.Header.Set("x-park-id", s.ParkID)
	req.Header.Set("x-client-version", "fleet/20653")
	req.Header.Set("x-retpath-y", "https://fleet.yandex.ru/challenge-done")
	req.Header.Set("origin", "https://fleet.yandex.ru")
	req.Header.Set("referer", "https://fleet.yandex.ru/fines")
	req.Header.Set("language", "ru")

	cookieValue := "Session_id=" + s.SessionID + "; sessionid2=" + s.SessionID2
	if s.ParkID != "" {
		cookieValue += "; park_id=" + s.ParkID
	}
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
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read response from Yandex API"})
		return
	}

	log.Printf("[FINES PROXY] Yandex response: status=%d | body=%s", resp.StatusCode, string(respBody))
	c.Data(resp.StatusCode, resp.Header.Get("Content-Type"), respBody)
}

// ─── Handlers ───────────────────────────────────────────────────────────────

func retrieveFinesProxy(c *gin.Context) {
	proxyToYandex(c, yandexFinesRetrieveURL, http.MethodPost)
}

func totalFinesProxy(c *gin.Context) {
	proxyToYandex(c, yandexFinesTotalURL, http.MethodPost)
}

func getFineDetailProxy(c *gin.Context) {
	uin := c.Query("uin")
	if uin == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing uin query parameter"})
		return
	}
	proxyToYandex(c, yandexFinesDetailURL+"?uin="+uin, http.MethodGet)
}

func suggestDriversProxy(c *gin.Context) {
	proxyToYandex(c, yandexFinesDriversSuggestURL, http.MethodPost)
}

func suggestCarsProxy(c *gin.Context) {
	proxyToYandex(c, yandexFinesCarsSuggestURL, http.MethodGet)
}

// ─── Routes ─────────────────────────────────────────────────────────────────

func RegisterRoutes(r *gin.Engine) {
	g := r.Group("/api/fines", authMiddleware)
	{
		g.POST("/retrieve", retrieveFinesProxy)
		g.POST("/total", totalFinesProxy)
		g.GET("/detail", getFineDetailProxy)
		g.POST("/drivers/suggest", suggestDriversProxy)
		g.GET("/cars/suggest", suggestCarsProxy)
	}
}
