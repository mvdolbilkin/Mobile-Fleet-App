package expenses

import "time"

// CostsListRequest запрос на получение списка расходов
type CostsListRequest struct {
	Filters    map[string]interface{} `json:"filters"`
	DatePeriod DatePeriod             `json:"date_period"`
}

// DatePeriod период дат
type DatePeriod struct {
	DateFrom string `json:"date_from"` // YYYY-MM-DD
	DateTo   string `json:"date_to"`   // YYYY-MM-DD
}

// CostsListResponse ответ со списком расходов
type CostsListResponse struct {
	Costs      []Cost     `json:"costs"`
	Summary    Summary    `json:"summary,omitempty"`
	Pagination Pagination `json:"pagination,omitempty"`
}

// Cost информация о расходе
type Cost struct {
	ID          string    `json:"id"`
	VehicleID   string    `json:"vehicle_id"`
	VehicleName string    `json:"vehicle_name,omitempty"`
	Category    string    `json:"category"`
	Amount      float64   `json:"amount"`
	Currency    string    `json:"currency"`
	Date        time.Time `json:"date"`
	Description string    `json:"description,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
}

// Summary сводная информация по расходам
type Summary struct {
	TotalAmount float64            `json:"total_amount"`
	Currency    string             `json:"currency"`
	ByCategory  map[string]float64 `json:"by_category,omitempty"`
}

// Pagination информация о пагинации
type Pagination struct {
	Total  int `json:"total"`
	Offset int `json:"offset"`
	Limit  int `json:"limit"`
}
