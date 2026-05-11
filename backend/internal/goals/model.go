package goals

// GoalsRequest represents the request body for goals endpoints
type GoalsRequest struct {
	DateFrom string `json:"date_from"`
	DateTo   string `json:"date_to"`
}

// GoalsResponse represents the response from Yandex Fleet Goals API
type GoalsResponse struct {
	Goals []Goal `json:"goals"`
}

// Goal represents a single goal/loyalty program
type Goal struct {
	ID                       string                    `json:"id"`
	Title                    string                    `json:"title"`
	Period                   *Period                   `json:"period,omitempty"`
	PeriodText               string                    `json:"period_text"`
	Rewards                  []Reward                  `json:"rewards"`
	KeyPerformanceIndicators []KeyPerformanceIndicator `json:"key_performance_indicators"`
}

// Period represents the goal period
type Period struct {
	Start  string `json:"start"`
	Finish string `json:"finish"`
	Type   string `json:"type"`
}

// Reward represents a reward level (basic, bronze, silver, gold)
type Reward struct {
	ID                       string                    `json:"id"`
	Title                    string                    `json:"title"`
	Subtitle                 *string                   `json:"subtitle,omitempty"`
	IsCompleted              bool                      `json:"is_completed"`
	BenefitItems             []BenefitItem             `json:"benefit_items"`
	KeyPerformanceIndicators []KeyPerformanceIndicator `json:"key_performance_indicators"`
}

// BenefitItem represents a benefit badge
type BenefitItem struct {
	Value string `json:"value"`
}

// KeyPerformanceIndicator represents a KPI requirement
type KeyPerformanceIndicator struct {
	ID          string `json:"id"`
	Title       string `json:"title"`
	IsCompleted bool   `json:"is_completed"`
	Current     *int   `json:"current,omitempty"`
	Target      *int   `json:"target,omitempty"`
	Percent     *int   `json:"percent,omitempty"`
}
