package staff

import (
	"fmt"
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

	// Получаем ключи из заголовков, отправленных мобильным приложением
	apiKey := c.GetHeader("X-API-Key")
	clientID := c.GetHeader("X-Client-ID")
	parkID := c.GetHeader("X-Park-ID")

	// Детальное логирование для отладки
	fmt.Printf("[STAFF] Headers received: X-API-Key=%q, X-Client-ID=%q, X-Park-ID=%q\n", apiKey, clientID, parkID)
	
	if apiKey == "" {
		fmt.Println("[STAFF] ERROR: Missing X-API-Key header")
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing X-API-Key header"})
		return
	}
	if clientID == "" {
		fmt.Println("[STAFF] ERROR: Missing X-Client-ID header")
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing X-Client-ID header"})
		return
	}
	if parkID == "" {
		fmt.Println("[STAFF] ERROR: Missing X-Park-ID header")
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing X-Park-ID header"})
		return
	}
	
	fmt.Println("[STAFF] All headers present, proceeding with request")

	drivers, err := h.service.GetDrivers(limit, offset, apiKey, clientID, parkID)
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

	apiKey := c.GetHeader("X-API-Key")
	clientID := c.GetHeader("X-Client-ID")
	parkID := c.GetHeader("X-Park-ID")

	if apiKey == "" || clientID == "" || parkID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing authorization headers"})
		return
	}

	profile, err := h.service.GetDriverProfile(apiKey, clientID, parkID, contractorProfileID)
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

	apiKey := c.GetHeader("X-API-Key")
	clientID := c.GetHeader("X-Client-ID")
	parkID := c.GetHeader("X-Park-ID")

	if apiKey == "" || clientID == "" || parkID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing authorization headers"})
		return
	}

	orders, err := h.service.GetDriverOrders(apiKey, clientID, parkID, driverID, from, to)
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

	apiKey := c.GetHeader("X-API-Key")
	clientID := c.GetHeader("X-Client-ID")
	parkID := c.GetHeader("X-Park-ID")

	if apiKey == "" || clientID == "" || parkID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing authorization headers"})
		return
	}

	car, err := h.service.GetCar(apiKey, clientID, parkID, carID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, car)
}
