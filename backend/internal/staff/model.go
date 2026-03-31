package staff

type YandexAPIRequest struct {
	Query struct {
		Park struct {
			ID string `json:"id"`
		} `json:"park"`
	} `json:"query"`
	Fields struct {
		DriverProfile []string `json:"driver_profile"`
		Car           []string `json:"car"`
		Account       []string `json:"account"`
		CurrentStatus []string `json:"current_status"`
	} `json:"fields"`
	Limit  int `json:"limit"`
	Offset int `json:"offset"`
}
