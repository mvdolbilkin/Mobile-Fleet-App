package summary

import (
	"net/http"

	"backend/internal/shared/proxy"

	"github.com/gin-gonic/gin"
)

// GetCarsSummary proxies the cars summary fleet report widget.
func (h *Handler) GetCarsSummary(c *gin.Context) {
	proxy.ToYandex(c, urlCarsSummary, http.MethodPost, proxy.WithJSONContentType())
}

// GetCarsStatuses proxies the cars statuses fleet report widget.
func (h *Handler) GetCarsStatuses(c *gin.Context) {
	proxy.ToYandex(c, urlCarsStatuses, http.MethodPost, proxy.WithJSONContentType())
}

// GetCarsMileage proxies the cars mileage fleet report widget.
func (h *Handler) GetCarsMileage(c *gin.Context) {
	proxy.ToYandex(c, urlCarsMileage, http.MethodPost, proxy.WithJSONContentType())
}

// GetCarsHoursOnline proxies the cars hours-online fleet report widget.
func (h *Handler) GetCarsHoursOnline(c *gin.Context) {
	proxy.ToYandex(c, urlCarsHoursOnline, http.MethodPost, proxy.WithJSONContentType())
}

// GetCarsAcceptanceRate proxies the cars acceptance-rate fleet report widget.
func (h *Handler) GetCarsAcceptanceRate(c *gin.Context) {
	proxy.ToYandex(c, urlCarsAcceptanceRate, http.MethodPost, proxy.WithJSONContentType())
}

// GetCarsTrips proxies the cars trips fleet report widget.
func (h *Handler) GetCarsTrips(c *gin.Context) {
	proxy.ToYandex(c, urlCarsTrips, http.MethodPost, proxy.WithJSONContentType())
}
