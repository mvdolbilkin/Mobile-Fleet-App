package vehicles

// CarsListRequest represents the payload for the Yandex Fleet API cars list request.
type CarsListRequest struct {
	Limit  int            `json:"limit,omitempty"`
	Offset int            `json:"offset,omitempty"`
	Query  *CarsListQuery `json:"query,omitempty"`
	Fields *CarsListFields `json:"fields,omitempty"`
}

type CarsListQuery struct {
	Park *CarsListQueryPark `json:"park,omitempty"`
	Text string             `json:"text,omitempty"`
}

type CarsListQueryPark struct {
	ID  string                `json:"id"`
	Car *CarsListQueryParkCar `json:"car,omitempty"`
}

type CarsListQueryParkCar struct {
	Amenities  []string `json:"amenities,omitempty"`
	Categories []string `json:"categories,omitempty"`
	ID         []string `json:"id,omitempty"`
	IsRental   *bool    `json:"is_rental,omitempty"`
	Status     []string `json:"status,omitempty"`
}

type CarsListFields struct {
	Car []string `json:"car,omitempty"`
}

// CarsListResponse represents the response from the Yandex Fleet API.
type CarsListResponse struct {
	Cars   []Vehicle `json:"cars"`
	Limit  int       `json:"limit"`
	Offset int       `json:"offset"`
	Total  int       `json:"total"`
}

// Vehicle represents the structural data of a car returned by the API.
type Vehicle struct {
	ID               string   `json:"id"`
	Amenities        []string `json:"amenities,omitempty"`
	Brand            string   `json:"brand,omitempty"`
	Callsign         string   `json:"callsign,omitempty"`
	Category         []string `json:"category,omitempty"`
	Color            string   `json:"color,omitempty"`
	Model            string   `json:"model,omitempty"`
	Number           string   `json:"number,omitempty"`
	RegistrationCert string   `json:"registration_cert,omitempty"`
	Status           string   `json:"status,omitempty"`
	VIN              string   `json:"vin,omitempty"`
	Year             int      `json:"year,omitempty"`
}

// CreateVehicleRequest represents the payload for creating a vehicle
type CreateVehicleRequest struct {
	ParkProfile           *ParkProfile           `json:"park_profile,omitempty"`
	VehicleLicenses       *VehicleLicenses       `json:"vehicle_licenses,omitempty"`
	VehicleSpecifications *VehicleSpecifications `json:"vehicle_specifications,omitempty"`
	Cargo                 *Cargo                 `json:"cargo,omitempty"`
	ChildSafety           *ChildSafety           `json:"child_safety,omitempty"`
}

type ParkProfile struct {
	Callsign          string             `json:"callsign,omitempty"`
	Status            string             `json:"status,omitempty"`
	FuelType          string             `json:"fuel_type,omitempty"`
	Amenities         []string           `json:"amenities,omitempty"`
	Categories        []string           `json:"categories,omitempty"`
	Comment           string             `json:"comment,omitempty"`
	IsParkProperty    bool               `json:"is_park_property,omitempty"`
	LeasingConditions *LeasingConditions `json:"leasing_conditions,omitempty"`
	LicenseOwnerID    string             `json:"license_owner_id,omitempty"`
	OwnershipType     string             `json:"ownership_type,omitempty"`
	Tariffs           []string           `json:"tariffs,omitempty"`
}

type LeasingConditions struct {
	Company        string `json:"company,omitempty"`
	InterestRate   string `json:"interest_rate,omitempty"`
	MonthlyPayment int    `json:"monthly_payment,omitempty"`
	StartDate      string `json:"start_date,omitempty"`
	Term           int    `json:"term,omitempty"`
}

type VehicleLicenses struct {
	LicencePlateNumber      string `json:"licence_plate_number,omitempty"`
	LicenceNumber           string `json:"licence_number,omitempty"`
	RegistrationCertificate string `json:"registration_certificate,omitempty"`
}

type VehicleSpecifications struct {
	Brand        string `json:"brand,omitempty"`
	Model        string `json:"model,omitempty"`
	Color        string `json:"color,omitempty"`
	Year         int    `json:"year,omitempty"`
	Transmission string `json:"transmission,omitempty"`
	VIN          string `json:"vin,omitempty"`
	BodyNumber   string `json:"body_number,omitempty"`
	Mileage      int    `json:"mileage,omitempty"`
}

type Cargo struct {
	CargoHoldDimensions *Dimensions `json:"cargo_hold_dimensions,omitempty"`
	CargoLoaders        int         `json:"cargo_loaders,omitempty"`
	CarryingCapacity    int         `json:"carrying_capacity,omitempty"`
}

type Dimensions struct {
	Height int `json:"height,omitempty"`
	Length int `json:"length,omitempty"`
	Width  int `json:"width,omitempty"`
}

type ChildSafety struct {
	BoosterCount int `json:"booster_count,omitempty"`
}

// CreateVehicleResponse represents the response from creating a vehicle
type CreateVehicleResponse struct {
	VehicleID string `json:"vehicle_id"`
}

// ErrorResponse represents an error from the Yandex Fleet API.
type ErrorResponse struct {
	Message string `json:"message"`
	Code    string `json:"code"`
}
