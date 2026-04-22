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

	drivers, err := h.service.GetDrivers(apiKey, clientID, parkID, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, drivers)
}
