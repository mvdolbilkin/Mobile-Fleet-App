package fleetmap

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	"backend/internal/shared/middleware"
	"backend/internal/shared/proxy"

	"github.com/gin-gonic/gin"
)

const (
	urlDriversPoints     = "https://fleet.yandex.ru/api/fleet/map/v2/drivers/points"
	urlDriversList       = "https://fleet.yandex.ru/api/fleet/map/v1/drivers/list"
	urlDriverItem        = "https://fleet.yandex.ru/api/fleet/map/v1/drivers/item"
	urlDriverStatusHist  = "https://fleet.yandex.ru/api/fleet/map/v1/drivers/status-history"
	urlSurge             = "https://fleet.yandex.ru/api/fleet/map/v1/surge"
	urlMapWorkRules      = "https://fleet.yandex.ru/api/fleet/driver-work-rules/v1/work-rules/light-list"
	urlDriverGps         = "https://fleet.yandex.ru/api/fleet/map/v1/driver/gps"
)

// Handlers

func driverPointsProxy(c *gin.Context) {
	s := proxy.GetSession(c)

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
	c.Request.Body = io.NopCloser(bytes.NewBuffer(jsonBody))
	proxy.ToYandex(c, urlDriversPoints, http.MethodPost, proxy.WithJSONContentType())
}

func driverListProxy(c *gin.Context) {
	s := proxy.GetSession(c)

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
	proxy.ToYandex(c, urlDriversList, http.MethodPost, proxy.WithJSONContentType())
}

func driverItemProxy(c *gin.Context) {
	driverID := c.Query("driver_id")
	showBlocked := c.DefaultQuery("show_blocked", "false")
	url := fmt.Sprintf("%s?driver_id=%s&show_blocked=%s", urlDriverItem, driverID, showBlocked)
	proxy.ToYandex(c, url, http.MethodGet)
}

func driverStatusHistoryProxy(c *gin.Context) {
	driverID := c.Query("driver_id")
	url := fmt.Sprintf("%s?driver_id=%s", urlDriverStatusHist, driverID)
	proxy.ToYandex(c, url, http.MethodGet)
}

func surgeProxy(c *gin.Context) {
	proxy.ToYandex(c, urlSurge, http.MethodPost, proxy.WithJSONContentType())
}

func workRulesProxy(c *gin.Context) {
	proxy.ToYandex(c, urlMapWorkRules, http.MethodPost, proxy.WithJSONContentType())
}

func driverGpsProxy(c *gin.Context) {
	proxy.ToYandex(c, urlDriverGps, http.MethodPost, proxy.WithJSONContentType())
}

// Routes

func RegisterRoutes(r *gin.Engine) {
	g := r.Group("/api/map", middleware.Auth)
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
