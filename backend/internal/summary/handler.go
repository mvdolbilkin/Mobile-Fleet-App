package summary

import (
	"net/http"

	"backend/internal/shared/proxy"

	"github.com/gin-gonic/gin"
)

// Handler aggregates summary HTTP handlers.
type Handler struct{}

// NewHandler returns a Handler instance.
func NewHandler() *Handler {
	return &Handler{}
}

// GetProfile proxies the user profile request to Yandex Fleet API.
func (h *Handler) GetProfile(c *gin.Context) {
	proxy.ToYandex(c, urlProfile, http.MethodGet)
}

// GetActiveDrivers proxies the active drivers dashboard widget.
func (h *Handler) GetActiveDrivers(c *gin.Context) {
	proxy.ToYandex(c, urlActiveDrivers, http.MethodPost, proxy.WithJSONContentType())
}

// GetOrders proxies the orders dashboard widget.
func (h *Handler) GetOrders(c *gin.Context) {
	proxy.ToYandex(c, urlOrders, http.MethodPost, proxy.WithJSONContentType())
}

// GetSupplyHours proxies the supply hours dashboard widget.
func (h *Handler) GetSupplyHours(c *gin.Context) {
	proxy.ToYandex(c, urlSupplyHours, http.MethodPost, proxy.WithJSONContentType())
}

// GetProfit proxies the profit dashboard widget.
func (h *Handler) GetProfit(c *gin.Context) {
	proxy.ToYandex(c, urlProfit, http.MethodPost, proxy.WithJSONContentType())
}

// GetOrdersSum proxies the orders sum dashboard widget.
func (h *Handler) GetOrdersSum(c *gin.Context) {
	proxy.ToYandex(c, urlOrdersSum, http.MethodPost, proxy.WithJSONContentType())
}

// GetCertification proxies the certification dashboard widget.
func (h *Handler) GetCertification(c *gin.Context) {
	proxy.ToYandex(c, urlCertification, http.MethodGet)
}
