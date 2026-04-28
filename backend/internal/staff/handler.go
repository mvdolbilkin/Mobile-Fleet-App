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
