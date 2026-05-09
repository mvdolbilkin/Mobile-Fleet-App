package garage

import (
	"net/http"

	"backend/internal/shared/middleware"
	"backend/internal/shared/proxy"

	"github.com/gin-gonic/gin"
)

const (
	urlPostingsList     = "https://fleet.yandex.ru/api/fleet/fleet-vehicles-rent/v2/posting/list"
	urlOfficeAddresses  = "https://fleet.yandex.ru/api/fleet/hiring-taxiparks-gambling/v1/office-address/list"
	urlGarageCarsSuggest = "https://fleet.yandex.ru/api/fleet/vehicles-manager/v1/cars/suggest?is_active=true&is_rental=true"
)

// Handlers

func getPostingsList(c *gin.Context) {
	proxy.ToYandex(c, urlPostingsList, http.MethodPost, proxy.WithJSONContentType())
}

func getOfficeAddressList(c *gin.Context) {
	proxy.ToYandex(c, urlOfficeAddresses, http.MethodPost, proxy.WithJSONContentType())
}

func getCarsSuggest(c *gin.Context) {
	proxy.ToYandex(c, urlGarageCarsSuggest, http.MethodGet)
}

// Routes

func RegisterRoutes(r *gin.Engine) {
	g := r.Group("/api/garage", middleware.Auth)
	{
		g.POST("/postings/list", getPostingsList)
		g.POST("/offices/list", getOfficeAddressList)
		g.GET("/cars/suggest", getCarsSuggest)
	}
}
