package vehicles

import (
	"net/http"

	"backend/internal/shared/middleware"
	"backend/internal/shared/proxy"

	"github.com/gin-gonic/gin"
)

const (
	urlVehiclesList        = "https://fleet.yandex.ru/api/fleet/vehicles-manager/v1/vehicles/list"
	urlVehicleDetails      = "https://fleet.yandex.ru/api/fleet/vehicles-manager/v2/vehicles/details"
	urlCreateVehicle       = "https://fleet.yandex.ru/api/fleet/vehicles-manager/v1/vehicles"
	urlVehicleStatus       = "https://fleet.yandex.ru/api/fleet/fleet-operations/v1/vehicles-manager/vehicle-status"
	urlBrands              = "https://fleet.yandex.ru/api/fleet/cars-catalog/v1/vehicles/brands/list"
	urlModels              = "https://fleet.yandex.ru/api/fleet/cars-catalog/v1/vehicles/models/list"
	urlCategories          = "https://fleet.yandex.ru/api/fleet/vehicles-manager/v1/vehicles/categories"
	urlReferences          = "https://fleet.yandex.ru/api/fleet/router/v1/references/list"
	urlVehiclesByDays      = "https://fleet.yandex.ru/api/fleet/rent/v1/vehicles/by-days"
	urlAvailableStatuses   = "https://fleet.yandex.ru/api/fleet/vehicles-manager/v1/cars/available-statuses"
	urlVehicleStatusSingle = "https://fleet.yandex.ru/api/fleet/vehicles-manager/v1/vehicle-status"
	urlRegularChargesList  = "https://fleet.yandex.ru/api/api/v1/regular-charges/list"
	urlOsagoCompensation   = "https://fleet.yandex.ru/api/fleet/fleet-operations/v1/fleet-vehicles-rent/policy/park-compensation"
	urlOfficeAddresses     = "https://fleet.yandex.ru/api/fleet/hiring-taxiparks-gambling/v1/office-address/list"
	urlCarEfficiency       = "https://fleet.yandex.ru/api/fleet/fleet-reports/v1/summary/cars/efficiency"
	urlVehicleBranding     = "https://fleet.yandex.ru/api/fleet/vehicles-manager/v1/vehicles/branding"
	urlChildChairs         = "https://fleet.yandex.ru/api/fleet/contractor-options/v2/child-chairs"
	urlVehicleKeyInfo      = "https://fleet.yandex.ru/api/fleet/vehicles-manager/v1/vehicles/key-info"
	urlVehicleChangelog    = "https://fleet.yandex.ru/api/fleet/fleet-changelog/v1/vehicle/changes/list"
	urlOsagoProperties     = "https://fleet.yandex.ru/api/fleet/contractor-insurance/e-osago/v1/properties/by-car/fetch/bulk"
	urlSupplyLock          = "https://fleet.yandex.ru/api/fleet/fleet-vehicles-rent/v2/supply-lock"
)

// Handlers

func listVehiclesProxy(c *gin.Context) {
	proxy.ToYandex(c, urlVehiclesList, http.MethodPost, proxy.WithJSONContentType())
}

func getVehicleProxy(c *gin.Context) {
	vehicleID := c.Query("vehicle_id")
	if vehicleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing vehicle_id query parameter"})
		return
	}
	proxy.ToYandex(c, urlVehicleDetails+"?vehicle_id="+vehicleID, http.MethodGet)
}

func createVehicleProxy(c *gin.Context) {
	proxy.ToYandex(c, urlCreateVehicle, http.MethodPost, proxy.WithJSONContentType(), proxy.WithIdempotencyToken())
}

func updateVehicleProxy(c *gin.Context) {
	vehicleID := c.Query("vehicle_id")
	if vehicleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing vehicle_id query parameter"})
		return
	}
	proxy.ToYandex(c, urlVehicleDetails+"?vehicle_id="+vehicleID, http.MethodPut, proxy.WithJSONContentType())
}

func updateVehiclesStatusProxy(c *gin.Context) {
	proxy.ToYandex(c, urlVehicleStatus, http.MethodPost, proxy.WithJSONContentType(), proxy.WithIdempotencyToken())
}

func listBrandsProxy(c *gin.Context) {
	proxy.ToYandex(c, urlBrands, http.MethodGet)
}

func listModelsProxy(c *gin.Context) {
	brand := c.Query("brand")
	if brand == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing brand query parameter"})
		return
	}
	proxy.ToYandex(c, urlModels+"?brand="+brand, http.MethodGet)
}

func listCategoriesProxy(c *gin.Context) {
	vehicleID := c.Query("vehicle_id")
	if vehicleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing vehicle_id query parameter"})
		return
	}
	proxy.ToYandex(c, urlCategories+"?vehicle_id="+vehicleID, http.MethodGet)
}

func updateCategoriesProxy(c *gin.Context) {
	vehicleID := c.Query("vehicle_id")
	if vehicleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing vehicle_id query parameter"})
		return
	}
	proxy.ToYandex(c, urlCategories+"?vehicle_id="+vehicleID, http.MethodPost, proxy.WithJSONContentType(), proxy.WithIdempotencyToken())
}

func listReferencesProxy(c *gin.Context) {
	proxy.ToYandex(c, urlReferences, http.MethodPost, proxy.WithJSONContentType())
}

func getVehiclesByDaysProxy(c *gin.Context) {
	proxy.ToYandex(c, urlVehiclesByDays, http.MethodPost, proxy.WithJSONContentType())
}

func getAvailableStatusesProxy(c *gin.Context) {
	proxy.ToYandex(c, urlAvailableStatuses, http.MethodGet)
}

func updateVehicleStatusSingleProxy(c *gin.Context) {
	vehicleID := c.Query("vehicle_id")
	if vehicleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing vehicle_id query parameter"})
		return
	}
	proxy.ToYandex(c, urlVehicleStatusSingle+"?vehicle_id="+vehicleID, http.MethodPost, proxy.WithJSONContentType())
}

func listRegularChargesProxy(c *gin.Context) {
	proxy.ToYandex(c, urlRegularChargesList, http.MethodPost, proxy.WithJSONContentType())
}

func updateOsagoCompensationProxy(c *gin.Context) {
	proxy.ToYandex(c, urlOsagoCompensation, http.MethodPost, proxy.WithJSONContentType(), proxy.WithIdempotencyToken())
}

func listOfficeAddressesProxy(c *gin.Context) {
	proxy.ToYandex(c, urlOfficeAddresses, http.MethodPost, proxy.WithJSONContentType())
}

func getVehicleEfficiencyProxy(c *gin.Context) {
	vehicleID := c.Query("vehicle_id")
	if vehicleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing vehicle_id query parameter"})
		return
	}
	proxy.ToYandex(c, urlCarEfficiency+"?car_id="+vehicleID, http.MethodPost, proxy.WithJSONContentType())
}

func getVehicleBrandingProxy(c *gin.Context) {
	vehicleID := c.Query("vehicle_id")
	if vehicleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing vehicle_id query parameter"})
		return
	}
	proxy.ToYandex(c, urlVehicleBranding+"?vehicle_id="+vehicleID, http.MethodGet)
}

func updateVehicleBrandingProxy(c *gin.Context) {
	vehicleID := c.Query("vehicle_id")
	if vehicleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing vehicle_id query parameter"})
		return
	}
	proxy.ToYandex(c, urlVehicleBranding+"?vehicle_id="+vehicleID, http.MethodPost, proxy.WithJSONContentType())
}

func getChildChairsProxy(c *gin.Context) {
	vehicleID := c.Query("vehicle_id")
	if vehicleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing vehicle_id query parameter"})
		return
	}
	proxy.ToYandex(c, urlChildChairs+"?vehicle_id="+vehicleID, http.MethodGet)
}

func getVehicleKeyInfoProxy(c *gin.Context) {
	vehicleID := c.Query("vehicle_id")
	if vehicleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing vehicle_id query parameter"})
		return
	}
	proxy.ToYandex(c, urlVehicleKeyInfo+"?vehicle_id="+vehicleID, http.MethodGet)
}

func getVehicleChangelogProxy(c *gin.Context) {
	vehicleID := c.Query("vehicle_id")
	if vehicleID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing vehicle_id query parameter"})
		return
	}
	proxy.ToYandex(c, urlVehicleChangelog+"?object_id="+vehicleID, http.MethodPost, proxy.WithJSONContentType())
}

func getOsagoPropertiesProxy(c *gin.Context) {
	proxy.ToYandex(c, urlOsagoProperties, http.MethodPost, proxy.WithJSONContentType())
}

func getSupplyLockProxy(c *gin.Context) {
	carID := c.Query("car_id")
	if carID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing car_id query parameter"})
		return
	}
	proxy.ToYandex(c, urlSupplyLock+"?car_id="+carID, http.MethodGet)
}

// RegisterRoutes sets up vehicle API endpoints.
func RegisterRoutes(r *gin.Engine) {
	g := r.Group("/api/vehicles", middleware.Auth)
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
		g.POST("/efficiency", getVehicleEfficiencyProxy)
		g.GET("/branding", getVehicleBrandingProxy)
		g.POST("/branding", updateVehicleBrandingProxy)
		g.GET("/child-chairs", getChildChairsProxy)
		g.GET("/key-info", getVehicleKeyInfoProxy)
		g.POST("/changelog", getVehicleChangelogProxy)
		g.POST("/osago-properties", getOsagoPropertiesProxy)
		g.GET("/supply-lock", getSupplyLockProxy)
	}
}
