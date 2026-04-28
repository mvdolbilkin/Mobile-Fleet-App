package menu

// ContractorsRequest represents the request payload for contractors widget
type ContractorsRequest struct {
	DateFrom string `json:"date_from"` // Format: YYYY-MM-DD
	DateTo   string `json:"date_to"`   // Format: YYYY-MM-DD
}

// ContractorsResponse represents the contractors widget data
type ContractorsResponse struct {
	Indicator      Indicator      `json:"indicator"`
	New            MetricWithDiff `json:"new"`
	Churn          MetricWithDiff `json:"churn"`
	AvgTimeOnline  AvgTimeOnline  `json:"avg_time_online"`
	Conversion     Conversion     `json:"conversion"`
	RatingInfo     RatingInfo     `json:"rating_info"`
}

// Indicator represents the current status of contractors
type Indicator struct {
	Total   int `json:"total"`
	Free    int `json:"free"`
	InOrder int `json:"in_order"`
	Busy    int `json:"busy"`
}

// MetricWithDiff represents a metric with its difference
type MetricWithDiff struct {
	Current int  `json:"current"`
	Diff    Diff `json:"diff"`
}

// Diff represents the difference value
type Diff struct {
	Value     float64 `json:"value"`
	IsPercent bool    `json:"is_percent"`
}

// AvgTimeOnline represents average time online in seconds
type AvgTimeOnline struct {
	Current int `json:"current"` // in seconds
}

// Conversion represents conversion metrics
type Conversion struct {
	OneTrip ConversionMetric `json:"one_trip"`
	NTrips  ConversionMetric `json:"n_trips"`
}

// ConversionMetric represents a single conversion metric
type ConversionMetric struct {
	Trips   int     `json:"trips"`
	Current float64 `json:"current"`
	Status  string  `json:"status"` // "normal", "warning", "critical"
}

// RatingInfo represents rating information
type RatingInfo struct {
	Rating         string         `json:"rating"`
	RatingCategory RatingCategory `json:"rating_category"`
}

// RatingCategory represents the rating category
type RatingCategory struct {
	CategoryCode string `json:"category_code"` // "not_ranked", "below_average", "average", "above_average"
	Text         string `json:"text"`
}

// CarsRequest represents the request payload for cars widget
type CarsRequest struct {
	DateFrom string `json:"date_from"` // Format: YYYY-MM-DD
	DateTo   string `json:"date_to"`   // Format: YYYY-MM-DD
}

// CarsResponse represents the cars widget data
type CarsResponse struct {
	Indicator      CarsIndicator  `json:"indicator"`
	RentalRevenue  MetricWithDiff `json:"rental_revenue"`
	Expenses       SimpleMetric   `json:"expenses"`
	Profit         MetricWithDiff `json:"profit"`
}

// CarsIndicator represents the current status of cars
type CarsIndicator struct {
	Total     int              `json:"total"`
	Unknown   CarStatusDetail  `json:"unknown"`
	Working   CarStatusDetail  `json:"working"`
	Repairing CarStatusDetail  `json:"repairing"`
	NoDriver  CarStatusDetail  `json:"no_driver"`
	Pending   CarStatusDetail  `json:"pending"`
}

// CarStatusDetail represents a car status with name and count
type CarStatusDetail struct {
	Name  string `json:"name"`
	Count int    `json:"count"`
}

// SimpleMetric represents a metric without diff
type SimpleMetric struct {
	Current int `json:"current"`
}

// LoyaltyProgramResponse represents the loyalty program data
type LoyaltyProgramResponse struct {
	Goals    []Goal   `json:"goals"`
	ParkInfo ParkInfo `json:"park_info"`
}

// Goal represents a loyalty program goal
type Goal struct {
	ID      string   `json:"id"`
	Type    string   `json:"type"`
	Title   string   `json:"title"`
	Period  Period   `json:"period"`
	Status  string   `json:"status"`
	Rewards []Reward `json:"rewards"`
}

// Period represents the goal period
type Period struct {
	Start  string `json:"start"`
	Finish string `json:"finish"`
	Type   string `json:"type"`
}

// Reward represents a loyalty level reward
type Reward struct {
	Title                    string `json:"title"`
	Subtitle                 string `json:"subtitle,omitempty"`
	IsCompleted              bool   `json:"is_completed"`
	LoyaltyStatus            string `json:"loyalty_status"`
	Items                    []Item `json:"items"`
	KpisToComplete           int    `json:"kpis_to_complete"`
	KeyPerformanceIndicators []KPI  `json:"key_performance_indicators"`
}

// Item represents a reward item
type Item struct {
	Type  string `json:"type"`
	Value string `json:"value"`
}

// KPI represents a key performance indicator
type KPI struct {
	Type         string        `json:"type"`
	Title        string        `json:"title"`
	Status       string        `json:"status"`
	Value        KPIValue      `json:"value"`
	Requirements []Requirement `json:"requirements"`
	Link         string        `json:"link,omitempty"`
	LinkID       string        `json:"link_id,omitempty"`
}

// KPIValue represents the value of a KPI
type KPIValue struct {
	Type    string      `json:"type"`
	Current interface{} `json:"current"`
	Target  interface{} `json:"target"`
	Order   string      `json:"order"`
}

// Requirement represents a KPI requirement
type Requirement struct {
	Text string `json:"text"`
}

// ParkInfo represents park information
type ParkInfo struct {
	LoyaltyStatus string `json:"loyalty_status"`
}

// ProblemsResponse represents the problems widget data
type ProblemsResponse struct {
	Total  int           `json:"total"`
	Badges []ProblemBadge `json:"badges"`
}

// ProblemBadge represents a single problem badge
type ProblemBadge struct {
	ID     string        `json:"id"`
	Icon   ProblemIcon   `json:"icon"`
	Text   string        `json:"text"`
	Action ProblemAction `json:"action"`
}

// ProblemIcon represents the icon for a problem
type ProblemIcon struct {
	Value   *int   `json:"value,omitempty"`
	Picture string `json:"picture,omitempty"`
}

// ProblemAction represents the action for a problem
type ProblemAction struct {
	ActionType    string `json:"action_type"`
	URL           string `json:"url,omitempty"`
	IsURLExternal bool   `json:"is_url_external,omitempty"`
	ScenarioID    string `json:"scenario_id,omitempty"`
	OpenScenario  bool   `json:"open_scenario,omitempty"`
}
