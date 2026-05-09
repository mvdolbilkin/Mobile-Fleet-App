package menu

import (
	"net/http"

	"backend/internal/shared/proxy"

	"github.com/gin-gonic/gin"
)

const (
	urlContractorsWidget = "https://fleet.yandex.ru/api/fleet/fleet-dashboard/v1/widget/contractors"
	urlCarsWidget        = "https://fleet.yandex.ru/api/fleet/fleet-dashboard/v1/widget/cars"
	urlProblemsWidget    = "https://fleet.yandex.ru/api/fleet/fleet-dashboard/v3/widget/problems"
	urlLoyaltyProgram    = "https://fleet.yandex.ru/api/fleet/fleet-goals/v2/goals/current"
)

func getContractorsProxy(c *gin.Context) {
	proxy.ToYandex(c, urlContractorsWidget, http.MethodPost, proxy.WithJSONContentType())
}

func getCarsProxy(c *gin.Context) {
	proxy.ToYandex(c, urlCarsWidget, http.MethodPost, proxy.WithJSONContentType())
}

func getLoyaltyProgramProxy(c *gin.Context) {
	proxy.ToYandex(c, urlLoyaltyProgram, http.MethodPost, proxy.WithJSONContentType())
}

func getProblemsProxy(c *gin.Context) {
	proxy.ToYandex(c, urlProblemsWidget, http.MethodPost, proxy.WithJSONContentType())
}

