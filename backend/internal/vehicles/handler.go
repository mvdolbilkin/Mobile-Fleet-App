package vehicles

import (
	"bytes"
	"crypto/rand"
	"encoding/hex"
	"io"
	"net/http"

	"backend/internal/session"

	"github.com/gin-gonic/gin"
)

const yandexFleetVehiclesListURL = "https://fleet.yandex.ru/api/fleet/vehicles-manager/v1/vehicles/list"
const yandexFleetVehicleDetailsURL = "https://fleet.yandex.ru/api/fleet/vehicles-manager/v2/vehicles/details"
const yandexFleetCreateVehicleURL = "https://fleet.yandex.ru/api/fleet/vehicles-manager/v1/vehicles"
const yandexFleetVehicleStatusURL = "https://fleet.yandex.ru/api/fleet/fleet-operations/v1/vehicles-manager/vehicle-status"
const yandexFleetBrandsURL = "https://fleet.yandex.ru/api/fleet/cars-catalog/v1/vehicles/brands/list"
const yandexFleetModelsURL = "https://fleet.yandex.ru/api/fleet/cars-catalog/v1/vehicles/models/list"
const yandexFleetCategoriesURL = "https://fleet.yandex.ru/api/fleet/vehicles-manager/v1/vehicles/categories"
const yandexFleetReferencesURL = "https://fleet.yandex.ru/api/fleet/router/v1/references/list"
const yandexFleetVehiclesByDaysURL = "https://fleet.yandex.ru/api/fleet/rent/v1/vehicles/by-days"
const yandexFleetAvailableStatusesURL = "https://fleet.yandex.ru/api/fleet/vehicles-manager/v1/cars/available-statuses"
const yandexFleetVehicleStatusSingleURL = "https://fleet.yandex.ru/api/fleet/vehicles-manager/v1/vehicle-status"
const yandexFleetRegularChargesListURL = "https://fleet.yandex.ru/api/api/v1/regular-charges/list"
const yandexFleetOsagoCompensationURL = "https://fleet.yandex.ru/api/fleet/fleet-operations/v1/fleet-vehicles-rent/policy/park-compensation"
const yandexFleetOfficeAddressesURL = "https://fleet.yandex.ru/api/fleet/hiring-taxiparks-gambling/v1/office-address/list"

// ─── Middleware: проверка auth + получение сессии ────────────────────────────

func authMiddleware(c *gin.Context) {
	userID := c.GetHeader("X-Park-ID")
	if userID == "" {
		userID = c.GetHeader("x-park-id")
	}
	if userID == "" {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "X-Park-ID header is required"})
		return
	}

	store := session.GetStore()
	userSession, exists := store.Get(userID)
	if !exists {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Session not found. Please login again."})
		return
	}

	c.Set("session", userSession)
	c.Next()
}

// Получить сессию из контекста (ставится middleware)
func getSession(c *gin.Context) *session.UserSession {
	s, _ := c.Get("session")
	return s.(*session.UserSession)
}

// ─── proxyOption: опции проксирования ───────────────────────────────────────

type proxyOption func(*http.Request)

// withIdempotencyToken добавляет X-Idempotency-Token к запросу
func withIdempotencyToken() proxyOption {
	return func(req *http.Request) {
		tokenBytes := make([]byte, 16)
		rand.Read(tokenBytes)
		tokenHex := hex.EncodeToString(tokenBytes)
		token := tokenHex[:8] + "-" + tokenHex[8:12] + "-" + tokenHex[12:16] + "-" + tokenHex[16:20] + "-" + tokenHex[20:]
		req.Header.Set("X-Idempotency-Token", token)
	}
}

// withJSONContentType добавляет Content-Type: application/json
func withJSONContentType() proxyOption {
	return func(req *http.Request) {
		req.Header.Set("Content-Type", "application/json")
	}
}

// ─── proxyToYandex: универсальный прокси ────────────────────────────────────

func proxyToYandex(c *gin.Context, targetURL string, method string, opts ...proxyOption) {
	s := getSession(c)

	// Читаем body (может быть пустым для GET)
	var bodyBytes []byte
	if c.Request.Body != nil {
		bodyBytes, _ = io.ReadAll(c.Request.Body)
	}

	var bodyReader *bytes.Buffer
	if len(bodyBytes) > 0 {
		bodyReader = bytes.NewBuffer(bodyBytes)
	} else {
		bodyReader = bytes.NewBuffer(nil)
	}

	req, err := http.NewRequest(method, targetURL, bodyReader)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Accept-Language", "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7")
	req.Header.Set("x-park-id", s.ParkID)

	// Cookie из сессии
	cookieValue := "Session_id=" + s.SessionID + "; sessionid2=" + s.SessionID2
	if s.LoginToken != "" {
		cookieValue += "; L=" + s.LoginToken
	}
	if s.Login != "" {
		cookieValue += "; yandex_login=" + s.Login
	}
	if s.UID != "" {
		cookieValue += "; yandexuid=" + s.UID
	}
	req.Header.Set("Cookie", cookieValue)

	// Применяем опции
	for _, opt := range opts {
		opt(req)
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		c.JSON(http.StatusBadGateway, gin.H{"error": "Failed to reach Yandex Fleet API"})
		return
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read response from Yandex API"})
		return
	}

	c.Data(resp.StatusCode, resp.Header.Get("Content-Type"), respBody)
}

// ─── Хендлеры ───────────────────────────────────────────────────────────────

func listVehiclesProxy(c *gin.Context) {
	proxyToYandex(c, yandexFleetVehiclesListURL, http.MethodPost, withJSONContentType())
}

func getVehicleProxy(c *gin.Context) {
	vehicleID := c.Query("vehicle_id")
	if vehicleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing vehicle_id query parameter"})
		return
	}
	proxyToYandex(c, yandexFleetVehicleDetailsURL+"?vehicle_id="+vehicleID, http.MethodGet)
}

func createVehicleProxy(c *gin.Context) {
	proxyToYandex(c, yandexFleetCreateVehicleURL, http.MethodPost, withJSONContentType(), withIdempotencyToken())
}

func updateVehicleProxy(c *gin.Context) {
	vehicleID := c.Query("vehicle_id")
	if vehicleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing vehicle_id query parameter"})
		return
	}
	proxyToYandex(c, yandexFleetVehicleDetailsURL+"?vehicle_id="+vehicleID, http.MethodPut, withJSONContentType())
}

func updateVehiclesStatusProxy(c *gin.Context) {
	proxyToYandex(c, yandexFleetVehicleStatusURL, http.MethodPost, withJSONContentType(), withIdempotencyToken())
}

func listBrandsProxy(c *gin.Context) {
	proxyToYandex(c, yandexFleetBrandsURL, http.MethodGet)
}

func listModelsProxy(c *gin.Context) {
	brand := c.Query("brand")
	if brand == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing brand query parameter"})
		return
	}
	proxyToYandex(c, yandexFleetModelsURL+"?brand="+brand, http.MethodGet)
}

func listCategoriesProxy(c *gin.Context) {
	vehicleID := c.Query("vehicle_id")
	if vehicleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing vehicle_id query parameter"})
		return
	}
	proxyToYandex(c, yandexFleetCategoriesURL+"?vehicle_id="+vehicleID, http.MethodGet)
}

func updateCategoriesProxy(c *gin.Context) {
	vehicleID := c.Query("vehicle_id")
	if vehicleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing vehicle_id query parameter"})
		return
	}
	proxyToYandex(c, yandexFleetCategoriesURL+"?vehicle_id="+vehicleID, http.MethodPost, withJSONContentType(), withIdempotencyToken())
}

func listReferencesProxy(c *gin.Context) {
	proxyToYandex(c, yandexFleetReferencesURL, http.MethodPost, withJSONContentType())
}

func getVehiclesByDaysProxy(c *gin.Context) {
	proxyToYandex(c, yandexFleetVehiclesByDaysURL, http.MethodPost, withJSONContentType())
}

func getAvailableStatusesProxy(c *gin.Context) {
	proxyToYandex(c, yandexFleetAvailableStatusesURL, http.MethodGet)
}

func updateVehicleStatusSingleProxy(c *gin.Context) {
	vehicleID := c.Query("vehicle_id")
	if vehicleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing vehicle_id query parameter"})
		return
	}
	proxyToYandex(c, yandexFleetVehicleStatusSingleURL+"?vehicle_id="+vehicleID, http.MethodPost, withJSONContentType())
}

func listRegularChargesProxy(c *gin.Context) {
	proxyToYandex(c, yandexFleetRegularChargesListURL, http.MethodPost, withJSONContentType())
}

func updateOsagoCompensationProxy(c *gin.Context) {
	proxyToYandex(c, yandexFleetOsagoCompensationURL, http.MethodPost, withJSONContentType(), withIdempotencyToken())
}

func listOfficeAddressesProxy(c *gin.Context) {
	proxyToYandex(c, yandexFleetOfficeAddressesURL, http.MethodPost, withJSONContentType())
}

// ─── Роутинг ────────────────────────────────────────────────────────────────

// RegisterRoutes registers the vehicle routes onto the provided gin.Engine
func RegisterRoutes(r *gin.Engine) {
	g := r.Group("/api/vehicles", authMiddleware)
	{
		g.POST("/list", listVehiclesProxy)
		g.GET("/car", getVehicleProxy)
		g.POST("/create", createVehicleProxy)
		g.PUT("/car", updateVehicleProxy)
		g.POST("/status", updateVehiclesStatusProxy)
		g.GET("/brands", listBrandsProxy)
		g.GET("/models", listModelsProxy)
		g.GET("/categories", listCategoriesProxy)
		g.POST("/categories", updateCategoriesProxy)
		g.POST("/references", listReferencesProxy)
		g.POST("/by-days", getVehiclesByDaysProxy)
		g.GET("/available-statuses", getAvailableStatusesProxy)
		g.POST("/vehicle-status", updateVehicleStatusSingleProxy)
		g.POST("/regular-charges", listRegularChargesProxy)
		g.POST("/osago-compensation", updateOsagoCompensationProxy)
		g.POST("/office-addresses", listOfficeAddressesProxy)
	}
}
