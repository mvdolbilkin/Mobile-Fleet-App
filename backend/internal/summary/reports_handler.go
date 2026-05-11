package summary

import (
	"net/http"

	"backend/internal/shared/proxy"

	"github.com/gin-gonic/gin"
)

// GetDriversSummaryList proxies the drivers summary report list.
func (h *Handler) GetDriversSummaryList(c *gin.Context) {
	proxy.ToYandex(c, urlDriversSummaryList, http.MethodPost, proxy.WithJSONContentType())
}

// GetCarsSummaryList proxies the cars summary report list.
func (h *Handler) GetCarsSummaryList(c *gin.Context) {
	proxy.ToYandex(c, urlCarsSummaryList, http.MethodPost, proxy.WithJSONContentType())
}

// GetParksSummaryList proxies the parks summary report list.
func (h *Handler) GetParksSummaryList(c *gin.Context) {
	proxy.ToYandex(c, urlParksSummaryList, http.MethodPost, proxy.WithJSONContentType())
}
