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

	apiKey := c.GetHeader("X-API-Key")
	clientID := c.GetHeader("X-Client-ID")
	parkID := c.GetHeader("X-Park-ID")

	if apiKey == "" || clientID == "" || parkID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing required authentication headers (X-API-Key, X-Client-ID, X-Park-ID)"})
		return
	}

	drivers, err := h.service.GetDrivers(limit, offset, apiKey, clientID, parkID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, drivers)
}
