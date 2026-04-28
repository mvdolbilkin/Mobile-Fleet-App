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

type OrdersRequest struct {
	Limit int `json:"limit"`
	Query struct {
		Park struct {
			ID    string `json:"id"`
			Order struct {
				BookedAt struct {
					From string `json:"from"`
					To   string `json:"to"`
				} `json:"booked_at"`
			} `json:"order"`
		} `json:"park"`
	} `json:"query"`
}

type CarsRequest struct {
	Query struct {
		Park struct {
			ID  string `json:"id"`
			Car struct {
				ID []string `json:"id"`
			} `json:"car"`
		} `json:"park"`
	} `json:"query"`
}
