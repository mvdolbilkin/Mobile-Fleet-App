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

// ErrorResponse represents an error from the Yandex Fleet API.
type ErrorResponse struct {
	Message string `json:"message"`
	Code    string `json:"code"`
}
