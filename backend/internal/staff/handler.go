package staff

import (
	"net/http"
	"strconv"

	"backend/internal/shared/middleware"
	"backend/internal/shared/proxy"

	"github.com/gin-gonic/gin"
)

// Handler aggregates staff HTTP handlers.
type Handler struct {
	service *Service
}

// NewHandler returns a Handler with the given service.
func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

// sessionCreds extracts cookie string and parkID from the session in gin context.
func sessionCreds(c *gin.Context) (string, string) {
	s := proxy.GetSession(c)
	return proxy.BuildCookieValue(s), s.ParkID
}

// RegisterRoutes sets up staff API endpoints.
func RegisterRoutes(r *gin.Engine) {
	service := NewService()
	handler := NewHandler(service)

	staffGroup := r.Group("/api/staff", middleware.Auth)
	{
		staffGroup.GET("/list", handler.GetStaffList)
		staffGroup.GET("/profile", handler.GetStaffProfile)
		staffGroup.GET("/orders", handler.GetDriverOrders)
		staffGroup.GET("/car", handler.GetCarInfo)
		staffGroup.GET("/categories", handler.GetTransactionCategories)
		staffGroup.POST("/transaction", handler.CreateTransaction)
		staffGroup.POST("/details", handler.GetDriverDetails)
		staffGroup.GET("/vehicles/suggest", handler.GetVehicleSuggestions)
		staffGroup.POST("/work-rules", handler.GetWorkRules)
		staffGroup.POST("/driver-statuses", handler.GetDriverStatuses)

		// Bulk actions
		staffGroup.POST("/bulk/update-source", handler.BulkUpdateSource)
		staffGroup.POST("/bulk/update-work-conditions", handler.BulkUpdateWorkConditions)
		staffGroup.POST("/bulk/update-work-status", handler.BulkUpdateWorkStatus)

		staffGroup.GET("/mailings/blanks", handler.GetMailingBlanks)
		staffGroup.GET("/mailings/limits", handler.GetMailingLimits)
		staffGroup.POST("/mailings", handler.SendMailing)
		staffGroup.POST("/contractors/count", handler.GetContractorsCount)
		staffGroup.POST("/bulk/mailing", handler.BulkMailing)

		staffGroup.POST("/transactions/list", handler.GetTransactionsList)
		staffGroup.POST("/transactions/balances", handler.GetTransactionsBalances)
		staffGroup.POST("/balances/history", handler.GetBalancesHistory)
		staffGroup.POST("/attraction/report", handler.GetAttractionReport)
		staffGroup.POST("/attraction/report/source", handler.GetAttractionSourceReport)
	}
}

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

func (h *Handler) GetTransactionCategories(c *gin.Context) {
	cookie, parkID := sessionCreds(c)
	categories, err := h.service.GetTransactionCategories(cookie, parkID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, categories)
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

func (h *Handler) GetWorkRules(c *gin.Context) {
	cookie, parkID := sessionCreds(c)
	rules, err := h.service.GetWorkRules(cookie, parkID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, rules)
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

func (h *Handler) GetDriverStatuses(c *gin.Context) {
	cookie, parkID := sessionCreds(c)
	statuses, err := h.service.GetDriverStatuses(cookie, parkID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, statuses)
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

func (h *Handler) GetMailingBlanks(c *gin.Context) {
	cookie, parkID := sessionCreds(c)
	result, err := h.service.GetMailingBlanks(cookie, parkID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, result)
}

func (h *Handler) GetMailingLimits(c *gin.Context) {
	cookie, parkID := sessionCreds(c)
	result, err := h.service.GetMailingLimits(cookie, parkID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, result)
}

func (h *Handler) GetContractorsCount(c *gin.Context) {
	var reqBody map[string]interface{}
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "неверное тело запроса: " + err.Error()})
		return
	}

	cookie, parkID := sessionCreds(c)
	result, err := h.service.GetContractorsCount(cookie, parkID, reqBody)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, result)
}

func (h *Handler) SendMailing(c *gin.Context) {
	var reqBody map[string]interface{}
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный формат запроса"})
		return
	}

	cookie, parkID := sessionCreds(c)
	result, err := h.service.SendMailing(cookie, parkID, reqBody)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, result)
}

func (h *Handler) GetTransactionsList(c *gin.Context) {
	var reqBody map[string]interface{}
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "неверное тело запроса: " + err.Error()})
		return
	}

	cookie, parkID := sessionCreds(c)
	result, err := h.service.GetTransactionsListRaw(cookie, parkID, reqBody)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, result)
}

func (h *Handler) GetTransactionsBalances(c *gin.Context) {
	var reqBody map[string]interface{}
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "неверное тело запроса: " + err.Error()})
		return
	}

	cookie, parkID := sessionCreds(c)
	result, err := h.service.GetTransactionsBalancesRaw(cookie, parkID, reqBody)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, result)
}

func (h *Handler) GetBalancesHistory(c *gin.Context) {
	var reqBody map[string]interface{}
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "неверное тело запроса: " + err.Error()})
		return
	}

	cookie, parkID := sessionCreds(c)
	result, err := h.service.GetBalancesHistoryRaw(cookie, parkID, reqBody)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, result)
}

func (h *Handler) GetAttractionReport(c *gin.Context) {
	var reqBody map[string]interface{}
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "неверное тело запроса: " + err.Error()})
		return
	}

	cookie, parkID := sessionCreds(c)
	result, err := h.service.GetAttractionReportRaw(cookie, parkID, reqBody)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, result)
}

func (h *Handler) GetAttractionSourceReport(c *gin.Context) {
	var reqBody map[string]interface{}
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "неверное тело запроса: " + err.Error()})
		return
	}

	cookie, parkID := sessionCreds(c)
	result, err := h.service.GetAttractionSourceReportRaw(cookie, parkID, reqBody)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, result)
}
