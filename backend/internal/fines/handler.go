package fines

import (
	"net/http"

	"backend/internal/shared/middleware"
	"backend/internal/shared/proxy"

	"github.com/gin-gonic/gin"
)

const (
	urlFinesRetrieve    = "https://fleet.yandex.ru/api/fleet/traffic-fines/v2/fines/retrieve"
	urlFinesTotal       = "https://fleet.yandex.ru/api/fleet/traffic-fines/v2/fines/total"
	urlFinesDetail      = "https://fleet.yandex.ru/api/fleet/traffic-fines/v1/fines"
	urlDriversSuggest   = "https://fleet.yandex.ru/api/api/v1/suggestions/drivers"
	urlFinesCarsSuggest = "https://fleet.yandex.ru/api/fleet/vehicles-manager/v1/cars/suggest"
)

// withFinesHeaders adds fines-specific headers required by the Yandex Fines API.
func withFinesHeaders() proxy.Option {
	return func(req *http.Request) {
		req.Header.Set("Content-Type", "application/json")
		req.Header.Set("Accept", "*/*")
		req.Header.Set("x-client-version", "fleet/20653")
		req.Header.Set("x-retpath-y", "https://fleet.yandex.ru/challenge-done")
		req.Header.Set("origin", "https://fleet.yandex.ru")
		req.Header.Set("referer", "https://fleet.yandex.ru/fines")
		req.Header.Set("language", "ru")
	}
}

// Handlers

func retrieveFinesProxy(c *gin.Context) {
	proxy.ToYandex(c, urlFinesRetrieve, http.MethodPost, withFinesHeaders())
}

func totalFinesProxy(c *gin.Context) {
	proxy.ToYandex(c, urlFinesTotal, http.MethodPost, withFinesHeaders())
}

func getFineDetailProxy(c *gin.Context) {
	uin := c.Query("uin")
	if uin == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing uin query parameter"})
		return
	}
	proxy.ToYandex(c, urlFinesDetail+"?uin="+uin, http.MethodGet, withFinesHeaders())
}

func suggestDriversProxy(c *gin.Context) {
	proxy.ToYandex(c, urlDriversSuggest, http.MethodPost, proxy.WithJSONContentType())
}

func suggestCarsProxy(c *gin.Context) {
	proxy.ToYandex(c, urlFinesCarsSuggest, http.MethodGet)
}

// Routes

func RegisterRoutes(r *gin.Engine) {
	g := r.Group("/api/fines", middleware.Auth)
	{
		g.POST("/retrieve", retrieveFinesProxy)
		g.POST("/total", totalFinesProxy)
		g.GET("/detail", getFineDetailProxy)
		g.POST("/drivers/suggest", suggestDriversProxy)
		g.GET("/cars/suggest", suggestCarsProxy)
	}
}
