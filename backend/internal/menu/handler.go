package menu

import (
	"bytes"
	"io"
	"net/http"

	"backend/internal/session"

	"github.com/gin-gonic/gin"
)

const yandexFleetContractorsWidgetURL = "https://fleet.yandex.ru/api/fleet/fleet-dashboard/v1/widget/contractors"
const yandexFleetCarsWidgetURL = "https://fleet.yandex.ru/api/fleet/fleet-dashboard/v1/widget/cars"
const yandexFleetProblemsWidgetURL = "https://fleet.yandex.ru/api/fleet/fleet-dashboard/v3/widget/problems"
const yandexFleetLoyaltyProgramURL = "https://fleet.yandex.ru/api/fleet/fleet-goals/v2/goals/current"

// ─── Middleware ───────────────────────────────────────────────────────────────

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

// ─── proxyOption ──────────────────────────────────────────────────────────────

type proxyOption func(*http.Request)

func withJSONContentType() proxyOption {
	return func(req *http.Request) {
		req.Header.Set("Content-Type", "application/json")
	}
}

// ─── proxyToYandex ────────────────────────────────────────────────────────────

func proxyToYandex(c *gin.Context, targetURL string, method string, opts ...proxyOption) {
	s := getSession(c)

	var bodyBytes []byte
	if c.Request.Body != nil {
		bodyBytes, _ = io.ReadAll(c.Request.Body)
	}

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

	for _, opt := range opts {
		opt(req)
	}

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

	c.Data(resp.StatusCode, resp.Header.Get("Content-Type"), respBody)
}

// ─── Handlers ─────────────────────────────────────────────────────────────────

func getContractorsProxy(c *gin.Context) {
	proxyToYandex(c, yandexFleetContractorsWidgetURL, http.MethodPost, withJSONContentType())
}

func getCarsProxy(c *gin.Context) {
	proxyToYandex(c, yandexFleetCarsWidgetURL, http.MethodPost, withJSONContentType())
}

func getLoyaltyProgramProxy(c *gin.Context) {
	proxyToYandex(c, yandexFleetLoyaltyProgramURL, http.MethodPost, withJSONContentType())
}

func getProblemsProxy(c *gin.Context) {
	proxyToYandex(c, yandexFleetProblemsWidgetURL, http.MethodPost, withJSONContentType())
}

