package fleetmap

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"

	"backend/internal/session"

	"github.com/gin-gonic/gin"
)

const yandexMapDriversPointsURL = "https://fleet.yandex.ru/api/fleet/map/v2/drivers/points"
const yandexMapDriversListURL = "https://fleet.yandex.ru/api/fleet/map/v1/drivers/list"

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

// ─── proxyToYandex ───────────────────────────────────────────────────────────

func proxyToYandex(c *gin.Context, targetURL string, method string) {
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

// ─── Хендлеры ────────────────────────────────────────────────────────────────

func driverPointsProxy(c *gin.Context) {
	s := getSession(c)

	var bodyBytes []byte
	if c.Request.Body != nil {
		bodyBytes, _ = io.ReadAll(c.Request.Body)
	}

	var body map[string]interface{}
	if len(bodyBytes) > 0 {
		json.Unmarshal(bodyBytes, &body)
	}
	if body == nil {
		body = make(map[string]interface{})
	}

	body["park_id"] = s.ParkID
	if _, ok := body["car"]; !ok {
		body["car"] = map[string]interface{}{}
	}
	if _, ok := body["sort"]; !ok {
		body["sort"] = map[string]interface{}{
			"field":     "status_duration",
			"direction": "desc",
		}
	}

	jsonBody, _ := json.Marshal(body)
	log.Printf("[driverPointsProxy] payload: %s", string(jsonBody))

	c.Request.Body = io.NopCloser(bytes.NewBuffer(jsonBody))
	proxyToYandex(c, yandexMapDriversPointsURL, http.MethodPost)
}

func driverListProxy(c *gin.Context) {
	s := getSession(c)

	var bodyBytes []byte
	if c.Request.Body != nil {
		bodyBytes, _ = io.ReadAll(c.Request.Body)
	}

	var body map[string]interface{}
	if len(bodyBytes) > 0 {
		json.Unmarshal(bodyBytes, &body)
	}
	if body == nil {
		body = make(map[string]interface{})
	}

	body["park_id"] = s.ParkID

	if _, ok := body["sort"]; !ok {
		body["sort"] = map[string]interface{}{
			"field":     "status_duration",
			"direction": "desc",
		}
	}

	jsonBody, _ := json.Marshal(body)
	c.Request.Body = io.NopCloser(bytes.NewBuffer(jsonBody))

	proxyToYandex(c, yandexMapDriversListURL, http.MethodPost)
}

func driverItemProxy(c *gin.Context) {
	driverID := c.Query("driver_id")
	showBlocked := c.DefaultQuery("show_blocked", "false")
	url := fmt.Sprintf("https://fleet.yandex.ru/api/fleet/map/v1/drivers/item?driver_id=%s&show_blocked=%s", driverID, showBlocked)
	proxyToYandex(c, url, http.MethodGet)
}

func driverStatusHistoryProxy(c *gin.Context) {
	driverID := c.Query("driver_id")
	url := fmt.Sprintf("https://fleet.yandex.ru/api/fleet/map/v1/drivers/status-history?driver_id=%s", driverID)
	proxyToYandex(c, url, http.MethodGet)
}

func surgeProxy(c *gin.Context) {
	proxyToYandex(c, "https://fleet.yandex.ru/api/fleet/map/v1/surge", http.MethodPost)
}

func workRulesProxy(c *gin.Context) {
	proxyToYandex(c, "https://fleet.yandex.ru/api/fleet/driver-work-rules/v1/work-rules/light-list", http.MethodPost)
}

func driverGpsProxy(c *gin.Context) {
	proxyToYandex(c, "https://fleet.yandex.ru/api/fleet/map/v1/driver/gps", http.MethodPost)
}

// ─── Роутинг ─────────────────────────────────────────────────────────────────

func RegisterRoutes(r *gin.Engine) {
	g := r.Group("/api/map", authMiddleware)
	{
		g.POST("/drivers/points", driverPointsProxy)
		g.POST("/drivers/list", driverListProxy)
		g.GET("/driver/item", driverItemProxy)
		g.GET("/driver/status-history", driverStatusHistoryProxy)
		g.POST("/driver/gps", driverGpsProxy)
		g.POST("/surge", surgeProxy)
		g.POST("/work-rules", workRulesProxy)
	}
}
