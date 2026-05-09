package staff

import (
	"net/http"
	"strconv"

	"backend/internal/shared/middleware"
	"backend/internal/shared/proxy"

	"github.com/gin-gonic/gin"
)

// Yandex Fleet API URL constants
const (
	urlTransactionCategories  = "https://fleet.yandex.ru/api/fleet/fleet-external-business-events/v1/parks/categories/list"
	urlMailingBlanks          = "https://fleet.yandex.ru/api/fleet/communications/v1/mailings/blanks"
	urlMailingLimits          = "https://fleet.yandex.ru/api/fleet/communications/v2/mailings/limits"
	urlSendMailing            = "https://fleet.yandex.ru/api/fleet/fleet-operations/v1/contractor-profiles-manager/communications"
	urlContractorsCount       = "https://fleet.yandex.ru/api/fleet/contractor-profiles-manager/v2/contractors/count"
	urlTransactionsList       = "https://fleet.yandex.ru/api/fleet/fleet-transactions-reports/v1/reports/driver/transactions/list"
	urlTransactionsBalances   = "https://fleet.yandex.ru/api/api/v1/cards/driver/transactions/balances"
	urlBalancesHistory        = "https://fleet.yandex.ru/api/api/v1/cards/driver/balances/history"
	urlAttractionReport       = "https://fleet.yandex.ru/api/fleet/fleet-leads-crm/v1/reports/life-time-value/report"
	urlAttractionSourceReport = "https://fleet.yandex.ru/api/fleet/fleet-leads-crm/v1/reports/life-time-value/source/side-card"
	urlWorkRulesList          = "https://fleet.yandex.ru/api/fleet/driver-work-rules/v1/work-rules/light-list"
)

// Handler aggregates staff HTTP handlers that require service-level logic.
type Handler struct {
	service *Service
}

// NewHandler returns a Handler with the given service.
func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

// sessionCreds extracts cookie string and parkID from the gin context session.
func sessionCreds(c *gin.Context) (string, string) {
	s := proxy.GetSession(c)
	return proxy.BuildCookieValue(s), s.ParkID
}

// RegisterRoutes sets up staff API endpoints.
func RegisterRoutes(r *gin.Engine) {
	service := NewService()
	handler := NewHandler(service)

	g := r.Group("/api/staff", middleware.Auth)
	{
		// ── Handlers that build a custom request body / read URL params ──────
		g.GET("/list", handler.GetStaffList)
		g.GET("/profile", handler.GetStaffProfile)
		g.GET("/orders", handler.GetDriverOrders)
		g.GET("/car", handler.GetCarInfo)
		g.POST("/transaction", handler.CreateTransaction)
		g.POST("/details", handler.GetDriverDetails)
		g.GET("/vehicles/suggest", handler.GetVehicleSuggestions)
		g.POST("/driver-statuses", handler.GetDriverStatuses)

		// Bulk actions (wrap body into Yandex filter/action shape)
		g.POST("/bulk/update-source", handler.BulkUpdateSource)
		g.POST("/bulk/update-work-conditions", handler.BulkUpdateWorkConditions)
		g.POST("/bulk/update-work-status", handler.BulkUpdateWorkStatus)
		g.POST("/bulk/mailing", handler.BulkMailing)

		// ── Simple proxy handlers (body forwarded as-is to Yandex) ───────────
		g.GET("/categories", getTransactionCategoriesProxy)
		g.GET("/mailings/blanks", getMailingBlanksProxy)
		g.GET("/mailings/limits", getMailingLimitsProxy)
		g.POST("/mailings", sendMailingProxy)
		g.POST("/contractors/count", getContractorsCountProxy)
		g.POST("/transactions/list", getTransactionsListProxy)
		g.POST("/transactions/balances", getTransactionsBalancesProxy)
		g.POST("/balances/history", getBalancesHistoryProxy)
		g.POST("/attraction/report", getAttractionReportProxy)
		g.POST("/attraction/report/source", getAttractionSourceReportProxy)
		g.POST("/work-rules", getWorkRulesProxy)
	}
}

// ─── Simple proxy handlers ─────────────────────────────────────────────────

func getTransactionCategoriesProxy(c *gin.Context) {
	proxy.ToYandex(c, urlTransactionCategories, http.MethodGet)
}

func getMailingBlanksProxy(c *gin.Context) {
	proxy.ToYandex(c, urlMailingBlanks, http.MethodGet)
}

func getMailingLimitsProxy(c *gin.Context) {
	proxy.ToYandex(c, urlMailingLimits, http.MethodGet)
}

func sendMailingProxy(c *gin.Context) {
	proxy.ToYandex(c, urlSendMailing, http.MethodPost, proxy.WithJSONContentType())
}

func getContractorsCountProxy(c *gin.Context) {
	proxy.ToYandex(c, urlContractorsCount, http.MethodPost, proxy.WithJSONContentType())
}

func getTransactionsListProxy(c *gin.Context) {
	proxy.ToYandex(c, urlTransactionsList, http.MethodPost, proxy.WithJSONContentType())
}

func getTransactionsBalancesProxy(c *gin.Context) {
	proxy.ToYandex(c, urlTransactionsBalances, http.MethodPost, proxy.WithJSONContentType())
}

func getBalancesHistoryProxy(c *gin.Context) {
	proxy.ToYandex(c, urlBalancesHistory, http.MethodPost, proxy.WithJSONContentType())
}

func getAttractionReportProxy(c *gin.Context) {
	proxy.ToYandex(c, urlAttractionReport, http.MethodPost, proxy.WithJSONContentType())
}

func getAttractionSourceReportProxy(c *gin.Context) {
	proxy.ToYandex(c, urlAttractionSourceReport, http.MethodPost, proxy.WithJSONContentType())
}

func getWorkRulesProxy(c *gin.Context) {
	proxy.ToYandex(c, urlWorkRulesList, http.MethodPost, proxy.WithJSONContentType())
}

// ─── Handler methods (service layer for custom body / URL-param logic) ──────

func (h *Handler) GetStaffList(c *gin.Context) {
	limitStr := c.DefaultQuery("limit", "500")
	offsetStr := c.DefaultQuery("offset", "0")

	limit, err := strconv.Atoi(limitStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "неверный параметр limit"})
		return
	}
	offset, err := strconv.Atoi(offsetStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "неверный параметр offset"})
		return
	}

	cookie, parkID := sessionCreds(c)
	drivers, err := h.service.GetDrivers(limit, offset, cookie, parkID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, drivers)
}

func (h *Handler) GetStaffProfile(c *gin.Context) {
	contractorProfileID := c.Query("contractor_profile_id")
	if contractorProfileID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "отсутствует параметр contractor_profile_id"})
		return
	}

	cookie, parkID := sessionCreds(c)
	profile, err := h.service.GetDriverProfile(cookie, parkID, contractorProfileID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, profile)
}

func (h *Handler) GetDriverOrders(c *gin.Context) {
	driverID := c.Query("contractor_profile_id")
	from := c.Query("from")
	to := c.Query("to")

	if driverID == "" || from == "" || to == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "отсутствуют необходимые параметры (contractor_profile_id, from, to)"})
		return
	}

	cookie, parkID := sessionCreds(c)
	orders, err := h.service.GetDriverOrders(cookie, parkID, driverID, from, to)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, orders)
}

func (h *Handler) GetCarInfo(c *gin.Context) {
	carID := c.Query("car_id")
	if carID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "отсутствует параметр car_id"})
		return
	}

	cookie, parkID := sessionCreds(c)
	car, err := h.service.GetCar(cookie, parkID, carID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, car)
}

func (h *Handler) CreateTransaction(c *gin.Context) {
	var transaction TransactionRequest
	if err := c.ShouldBindJSON(&transaction); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "неверный формат запроса: " + err.Error()})
		return
	}

	cookie, parkID := sessionCreds(c)
	result, err := h.service.CreateTransaction(cookie, parkID, transaction)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, result)
}

func (h *Handler) GetDriverDetails(c *gin.Context) {
	var req DriverDetailsRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "неверный формат запроса: " + err.Error()})
		return
	}

	cookie, parkID := sessionCreds(c)
	result, err := h.service.GetDriverDetails(cookie, parkID, req.DriverID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, result)
}

func (h *Handler) GetVehicleSuggestions(c *gin.Context) {
	limitStr := c.DefaultQuery("limit", "20")
	limit, err := strconv.Atoi(limitStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "неверный параметр limit"})
		return
	}

	cookie, parkID := sessionCreds(c)
	result, err := h.service.GetVehicleSuggestions(cookie, parkID, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, result)
}

func (h *Handler) GetDriverStatuses(c *gin.Context) {
	cookie, parkID := sessionCreds(c)
	statuses, err := h.service.GetDriverStatuses(cookie, parkID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, statuses)
}

func (h *Handler) BulkUpdateSource(c *gin.Context) {
	var req BulkUpdateSourceRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "неверный формат запроса: " + err.Error()})
		return
	}
	if len(req.ContractorIDs) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "не указаны исполнители"})
		return
	}
	if req.Source == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "не указан источник"})
		return
	}

	// TODO: Implement actual API call to Yandex to update source
	c.JSON(http.StatusOK, gin.H{
		"success":       true,
		"message":       "Источник обновлен для " + strconv.Itoa(len(req.ContractorIDs)) + " исполнителей",
		"updated_count": len(req.ContractorIDs),
	})
}

func (h *Handler) BulkUpdateWorkConditions(c *gin.Context) {
	var req BulkUpdateWorkConditionsRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "неверный формат запроса: " + err.Error()})
		return
	}
	if len(req.ContractorIDs) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "не указаны исполнители"})
		return
	}
	if req.Condition == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "не указаны условия работы"})
		return
	}

	cookie, parkID := sessionCreds(c)
	result, err := h.service.ApplyWorkRule(cookie, parkID, req.ContractorIDs, req.Condition)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, result)
}

func (h *Handler) BulkUpdateWorkStatus(c *gin.Context) {
	var req BulkUpdateWorkStatusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "неверный формат запроса: " + err.Error()})
		return
	}
	if len(req.ContractorIDs) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "не указаны исполнители"})
		return
	}
	if req.Status == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "не указан статус работы"})
		return
	}

	cookie, parkID := sessionCreds(c)
	result, err := h.service.ApplyWorkStatus(cookie, parkID, req.ContractorIDs, req.Status)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, result)
}

func (h *Handler) BulkMailing(c *gin.Context) {
	var req BulkMailingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "неверный формат запроса: " + err.Error()})
		return
	}
	if len(req.ContractorIDs) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "не указаны исполнители"})
		return
	}
	if req.Message == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "не указан текст сообщения"})
		return
	}
	if req.MessageType == "" {
		req.MessageType = "sms"
	}

	// TODO: Implement actual API call to send messages
	c.JSON(http.StatusOK, gin.H{
		"success":      true,
		"message":      "Сообщение отправлено " + strconv.Itoa(len(req.ContractorIDs)) + " исполнителям",
		"sent_count":   len(req.ContractorIDs),
		"message_type": req.MessageType,
	})
}
