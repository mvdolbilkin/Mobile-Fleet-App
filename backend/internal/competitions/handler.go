package competitions

import (
	"net/http"

	"backend/internal/shared/middleware"
	"backend/internal/shared/proxy"

	"github.com/gin-gonic/gin"
)

const (
	urlCompetitionList    = "https://fleet.yandex.ru/api/fleet/fleet-contractor-motivation/v1/competition/list"
	urlCompetitionDetails = "https://fleet.yandex.ru/api/fleet/fleet-contractor-motivation/v1/competition/details"
)

func RegisterRoutes(r *gin.Engine) {
	competitionsGroup := r.Group("/api/competitions", middleware.Auth)
	{
		competitionsGroup.POST("/list", getCompetitionsListProxy)
		competitionsGroup.POST("/details", getCompetitionDetailsProxy)
	}
}

func getCompetitionsListProxy(c *gin.Context) {
	proxy.ToYandex(c, urlCompetitionList, http.MethodPost, proxy.WithJSONContentType())
}

func getCompetitionDetailsProxy(c *gin.Context) {
	proxy.ToYandex(c, urlCompetitionDetails, http.MethodPost, proxy.WithJSONContentType())
}
