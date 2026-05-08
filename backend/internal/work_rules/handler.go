package work_rules

import (
	"fmt"
	"net/http"

	"backend/internal/shared/middleware"
	"backend/internal/shared/proxy"

	"github.com/gin-gonic/gin"
)

const (
	urlWorkRulesList   = "https://fleet.yandex.ru/api/fleet/driver-work-rules/v1/work-rules"
	urlWorkRulesDetail = "https://fleet.yandex.ru/api/fleet/driver-work-rules/v1/work-rules/by-id"
)

func RegisterRoutes(r *gin.Engine) {
	workRulesGroup := r.Group("/api/work-rules", middleware.Auth)
	{
		workRulesGroup.GET("/list", getWorkRulesProxy)
		workRulesGroup.GET("/details", getWorkRuleDetailsProxy)
	}
}

func getWorkRulesProxy(c *gin.Context) {
	isArchived := c.DefaultQuery("is_archived", "false")
	url := fmt.Sprintf("%s?is_archived=%s", urlWorkRulesList, isArchived)
	proxy.ToYandex(c, url, http.MethodGet)
}

func getWorkRuleDetailsProxy(c *gin.Context) {
	workRuleID := c.Query("work_rule_id")
	if workRuleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing work_rule_id parameter"})
		return
	}
	url := fmt.Sprintf("%s?work_rule_id=%s", urlWorkRulesDetail, workRuleID)
	proxy.ToYandex(c, url, http.MethodGet)
}
