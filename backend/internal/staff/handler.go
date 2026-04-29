package staff

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

func RegisterRoutes(r *gin.Engine) {
	service := NewService()
	handler := NewHandler(service)

	staffGroup := r.Group("/api/staff")
	{
		staffGroup.GET("/list", handler.GetStaffList)
		staffGroup.GET("/profile", handler.GetStaffProfile)
		staffGroup.GET("/orders", handler.GetDriverOrders)
		staffGroup.GET("/car", handler.GetCarInfo)
		staffGroup.GET("/categories", handler.GetTransactionCategories)
		staffGroup.POST("/transaction", handler.CreateTransaction)
		staffGroup.POST("/details", handler.GetDriverDetails)
		staffGroup.GET("/vehicles/suggest", handler.GetVehicleSuggestions)
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

	// Получаем куки или заголовки от мобилки
	cookieHeader := c.GetHeader("Cookie")
	parkID := c.GetHeader("X-Park-ID")

	if cookieHeader == "" {
		// Резервный вариант, если клиент все еще шлет старые заголовки
		apiKey := c.GetHeader("X-API-Key")
		clientID := c.GetHeader("X-Client-ID")

		if apiKey == "" || clientID == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing credentials"})
			return
		}
	}

	drivers, err := h.service.GetDrivers(limit, offset, cookieHeader, parkID)
	if err != nil {
		// Логируем ошибку для отладки
		println("Error in GetStaffList:", err.Error())
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

	cookieHeader := c.GetHeader("Cookie")
	parkID := c.GetHeader("X-Park-ID")

	if cookieHeader == "" && parkID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing authorization headers"})
		return
	}

	profile, err := h.service.GetDriverProfile(cookieHeader, parkID, contractorProfileID)
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

	cookieHeader := c.GetHeader("Cookie")
	parkID := c.GetHeader("X-Park-ID")

	if cookieHeader == "" && parkID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing authorization headers"})
		return
	}

	orders, err := h.service.GetDriverOrders(cookieHeader, parkID, driverID, from, to)
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

	cookieHeader := c.GetHeader("Cookie")
	parkID := c.GetHeader("X-Park-ID")

	if cookieHeader == "" && parkID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing authorization headers"})
		return
	}

	car, err := h.service.GetCar(cookieHeader, parkID, carID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, car)
}

func (h *Handler) GetTransactionCategories(c *gin.Context) {
	cookieHeader := c.GetHeader("Cookie")
	parkID := c.GetHeader("X-Park-ID")

	if cookieHeader == "" && parkID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing authorization headers"})
		return
	}

	categories, err := h.service.GetTransactionCategories(cookieHeader, parkID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, categories)
}

func (h *Handler) CreateTransaction(c *gin.Context) {
	var transaction TransactionRequest
	if err := c.ShouldBindJSON(&transaction); err != nil {
		println("Error binding JSON:", err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"error": "неверный формат запроса: " + err.Error()})
		return
	}

	println("Transaction request received:")
	println("  ContractorProfileID:", transaction.ContractorProfileID)
	println("  Amount:", transaction.Amount)
	println("  Kind:", transaction.Data.Kind)
	println("  FeeAmount:", transaction.Data.FeeAmount)

	cookieHeader := c.GetHeader("Cookie")
	parkID := c.GetHeader("X-Park-ID")

	println("  Cookie:", cookieHeader[:50], "...")
	println("  ParkID:", parkID)

	if cookieHeader == "" && parkID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing authorization headers"})
		return
	}

	result, err := h.service.CreateTransaction(cookieHeader, parkID, transaction)
	if err != nil {
		println("Error creating transaction:", err.Error())
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	println("Transaction created successfully")
	c.JSON(http.StatusOK, result)
}

func (h *Handler) GetDriverDetails(c *gin.Context) {
	var req DriverDetailsRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "неверный формат запроса: " + err.Error()})
		return
	}

	cookieHeader := c.GetHeader("Cookie")
	parkID := c.GetHeader("X-Park-ID")

	if cookieHeader == "" && parkID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing authorization headers"})
		return
	}

	result, err := h.service.GetDriverDetails(cookieHeader, parkID, req.DriverID)
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

	cookieHeader := c.GetHeader("Cookie")
	parkID := c.GetHeader("X-Park-ID")

	if cookieHeader == "" && parkID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing authorization headers"})
		return
	}

	result, err := h.service.GetVehicleSuggestions(cookieHeader, parkID, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, result)
}
