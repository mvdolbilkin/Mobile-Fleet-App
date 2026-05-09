package mailings

import (
	"fmt"
	"net/http"

	"backend/internal/shared/middleware"
	"backend/internal/shared/proxy"

	"github.com/gin-gonic/gin"
)

const (
	urlMailingsList   = "https://fleet.yandex.ru/api/fleet/communications/v1/mailings/list"
	urlMailingsItem   = "https://fleet.yandex.ru/api/fleet/communications/v1/mailings/item"
	urlMailingsDetail = "https://fleet.yandex.ru/api/fleet/communications/v2/mailings"
)

func RegisterRoutes(r *gin.Engine) {
	mailingsGroup := r.Group("/api/mailings", middleware.Auth)
	{
		mailingsGroup.POST("/list", getMailingsListProxy)
		mailingsGroup.POST("/item", getMailingItemProxy)
		mailingsGroup.GET("/details", getMailingDetailsProxy)
	}
}

func getMailingsListProxy(c *gin.Context) {
	proxy.ToYandex(c, urlMailingsList, http.MethodPost, proxy.WithJSONContentType())
}

func getMailingItemProxy(c *gin.Context) {
	proxy.ToYandex(c, urlMailingsItem, http.MethodPost, proxy.WithJSONContentType())
}

func getMailingDetailsProxy(c *gin.Context) {
	mailingID := c.Query("id")
	if mailingID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing mailing ID"})
		return
	}
	url := fmt.Sprintf("%s?id=%s", urlMailingsDetail, mailingID)
	proxy.ToYandex(c, url, http.MethodGet)
}
