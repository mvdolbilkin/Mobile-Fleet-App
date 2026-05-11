package staff

type ContractorsListRequest struct {
	Filter     map[string]interface{} `json:"filter"`
	Limit      int                    `json:"limit"`
	Offset     int                    `json:"offset,omitempty"`
	Projection []string               `json:"projection,omitempty"`
}

type BulkUpdateSourceRequest struct {
	ContractorIDs []string `json:"contractor_ids"`
	Source        string   `json:"source"`
}

type BulkUpdateWorkConditionsRequest struct {
	ContractorIDs []string `json:"contractor_ids"`
	Condition     string   `json:"condition"`
}

type BulkUpdateWorkStatusRequest struct {
	ContractorIDs []string `json:"contractor_ids"`
	Status        string   `json:"status"`
}

type BulkMailingRequest struct {
	ContractorIDs []string `json:"contractor_ids"`
	MessageType   string   `json:"message_type"` // sms, push, email
	Message       string   `json:"message"`
}

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

type TransactionRequest struct {
	ContractorProfileID string                 `json:"contractor_profile_id"`
	Amount              string                 `json:"amount"`
	Condition           map[string]interface{} `json:"condition,omitempty"`
	Data                TransactionData        `json:"data"`
	Description         string                 `json:"description,omitempty"`
}

type TransactionData struct {
	Kind             string                 `json:"kind,omitempty"`
	CategoryID       string                 `json:"category_id,omitempty"`
	FeeAmount        string                 `json:"fee_amount,omitempty"`
	ReceiptCondition string                 `json:"receipt_condition,omitempty"`
	ChildDriverID    string                 `json:"child_driver_id,omitempty"`
	Object           map[string]interface{} `json:"object,omitempty"`
	ParkFee          string                 `json:"park_fee,omitempty"`
	Value            string                 `json:"value,omitempty"`
	Units            string                 `json:"units,omitempty"`
	Reason           string                 `json:"reason,omitempty"`
}

type DriverDetailsRequest struct {
	DriverID string `json:"driver_id"`
}

type FleetTransactionsRequest struct {
	Query struct {
		Transaction struct {
			EventAt struct {
				From string `json:"from"`
				To   string `json:"to"`
			} `json:"event_at"`
			WithoutCash bool `json:"without_cash"`
		} `json:"transaction"`
		DriverID string `json:"driver_id"`
	} `json:"query"`
	Limit int `json:"limit"`
}
