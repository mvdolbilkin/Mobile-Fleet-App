package summary

import (
	"bytes"
	"io"
	"net/http"

	"backend/internal/shared/proxy"

	"github.com/gin-gonic/gin"
)

// GetCarAvailableStatuses proxies the available car statuses list.
func (h *Handler) GetCarAvailableStatuses(c *gin.Context) {
	proxy.ToYandex(c, urlCarAvailableStatuses, http.MethodGet)
}

// GetCarCategories fetches car categories from the Yandex references API.
func (h *Handler) GetCarCategories(c *gin.Context) {
	s := proxy.GetSession(c)

	body := []byte(`{"references":["car_categories"]}`)
	req, err := http.NewRequest(http.MethodPost, urlCarCategoriesReferences, bytes.NewReader(body))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept-Language", "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7")
	req.Header.Set("x-park-id", s.ParkID)
	req.Header.Set("Cookie", proxy.BuildCookieValue(s))

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		c.JSON(http.StatusBadGateway, gin.H{"error": "Failed to reach Yandex Fleet API"})
		return
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read response"})
		return
	}

	c.Data(resp.StatusCode, resp.Header.Get("Content-Type"), respBody)
}
