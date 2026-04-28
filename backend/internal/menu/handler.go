package menu

import (
	"encoding/json"
	"io/ioutil"
	"net/http"
)

type Handler struct{}

func NewHandler() *Handler {
	return &Handler{}
}

// GetContractorsWidget handles POST /api/menu/contractors
func (h *Handler) GetContractorsWidget(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Check for authentication headers
	cookieHeader := r.Header.Get("Cookie")
	parkID := r.Header.Get("X-Park-ID")

	if cookieHeader == "" && parkID == "" {
		http.Error(w, "Missing authorization headers", http.StatusUnauthorized)
		return
	}

	var req ContractorsRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// TODO: Replace with actual data from Yandex Fleet API
	response := ContractorsResponse{
		Indicator: Indicator{
			Total:   32,
			Free:    3,
			InOrder: 0,
			Busy:    29,
		},
		New: MetricWithDiff{
			Current: 30,
			Diff: Diff{
				Value:     -57.14285714285714,
				IsPercent: true,
			},
		},
		Churn: MetricWithDiff{
			Current: 6,
			Diff: Diff{
				Value:     -14.285714285714285,
				IsPercent: true,
			},
		},
		AvgTimeOnline: AvgTimeOnline{
			Current: 12117,
		},
		Conversion: Conversion{
			OneTrip: ConversionMetric{
				Trips:   1,
				Current: 0,
				Status:  "normal",
			},
			NTrips: ConversionMetric{
				Trips:   50,
				Current: 0,
				Status:  "normal",
			},
		},
		RatingInfo: RatingInfo{
			Rating: "4.82",
			RatingCategory: RatingCategory{
				CategoryCode: "not_ranked",
				Text:         "Рейтинг парка",
			},
		},
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// GetCarsWidget handles POST /api/menu/cars
func (h *Handler) GetCarsWidget(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	cookieHeader := r.Header.Get("Cookie")
	parkID := r.Header.Get("X-Park-ID")

	if cookieHeader == "" && parkID == "" {
		http.Error(w, "Missing authorization headers", http.StatusUnauthorized)
		return
	}

	var req CarsRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	response := CarsResponse{
		Indicator: CarsIndicator{
			Total: 2744,
			Unknown: CarStatusDetail{
				Name:  "Другое",
				Count: 1,
			},
			Working: CarStatusDetail{
				Name:  "Работает",
				Count: 2643,
			},
			Repairing: CarStatusDetail{
				Name:  "Сервис",
				Count: 3,
			},
			NoDriver: CarStatusDetail{
				Name:  "Нет водителя",
				Count: 71,
			},
			Pending: CarStatusDetail{
				Name:  "Подготовка",
				Count: 1,
			},
		},
		RentalRevenue: MetricWithDiff{
			Current: 1004553,
			Diff: Diff{
				Value:     -1,
				IsPercent: true,
			},
		},
		Expenses: SimpleMetric{
			Current: 0,
		},
		Profit: MetricWithDiff{
			Current: 1004553,
			Diff: Diff{
				Value:     -1,
				IsPercent: true,
			},
		},
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// GetLoyaltyProgram handles POST /api/menu/loyalty
func (h *Handler) GetLoyaltyProgram(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	cookieHeader := r.Header.Get("Cookie")
	parkID := r.Header.Get("X-Park-ID")

	if cookieHeader == "" && parkID == "" {
		http.Error(w, "Missing authorization headers", http.StatusUnauthorized)
		return
	}

	// Read and discard body
	ioutil.ReadAll(r.Body)

	// TODO: Replace with actual data from Yandex Fleet API
	response := LoyaltyProgramResponse{
		Goals: []Goal{
			{
				ID:     "84dd1db2-8b9d-43ee-9a04-212755c3ffa2",
				Type:   "taxi_certification",
				Title:  "Программа лояльности",
				Status: "completed",
				Period: Period{
					Start:  "2026-02-28T21:00:00+00:00",
					Finish: "2026-03-31T21:00:00+00:00",
					Type:   "monthly",
				},
				Rewards: []Reward{
					{
						Title:          "Базовый",
						Subtitle:       "Необходимо выполнить 1 из 2 показателей",
						IsCompleted:    true,
						LoyaltyStatus:  "basic",
						KpisToComplete: 1,
						Items: []Item{
							{Type: "loyalty_status", Value: "basic"},
						},
						KeyPerformanceIndicators: []KPI{
							{
								Type:   "newbie_period_completed",
								Title:  "Прошло 3 месяца с момента регистрации",
								Status: "completed",
								Value: KPIValue{
									Type:    "binary",
									Current: true,
									Target:  true,
									Order:   "ascending",
								},
							},
							{
								Type:   "praktikum",
								Title:  "60% в тесте Практикума",
								Status: "completed",
								Value: KPIValue{
									Type:    "percent",
									Current: 73.83,
									Target:  60.0,
									Order:   "ascending",
								},
							},
						},
					},
					{
						Title:          "Бронзовый",
						IsCompleted:    false,
						LoyaltyStatus:  "bronze",
						KpisToComplete: 5,
						Items: []Item{
							{Type: "loyalty_status", Value: "bronze"},
							{Type: "text", Value: "Галочка в Про"},
							{Type: "text", Value: "Обратный звонок"},
						},
						KeyPerformanceIndicators: []KPI{
							{
								Type:   "monthly_success_orders_count",
								Title:  "2000 поездок в месяц",
								Status: "not_completed",
								Value: KPIValue{
									Type:    "numeric",
									Current: 15.0,
									Target:  2000.0,
									Order:   "ascending",
								},
							},
							{
								Type:   "park_profile_filled",
								Title:  "Заполнен профиль партнёра",
								Status: "completed",
								Value: KPIValue{
									Type:    "binary",
									Current: true,
									Target:  true,
									Order:   "ascending",
								},
							},
							{
								Type:   "legalization",
								Title:  "Исполнители подтвердили занятость",
								Status: "completed",
								Value: KPIValue{
									Type:    "binary",
									Current: true,
									Target:  true,
									Order:   "ascending",
								},
							},
						},
					},
					{
						Title:          "Серебряный",
						Subtitle:       "Необходимо выполнить 1 из 2 показателей",
						IsCompleted:    false,
						LoyaltyStatus:  "silver",
						KpisToComplete: 1,
						Items: []Item{
							{Type: "loyalty_status", Value: "silver"},
							{Type: "text", Value: "Скидка на Диспетчерскую"},
						},
						KeyPerformanceIndicators: []KPI{
							{
								Type:   "monthly_new_drivers_with_50_orders",
								Title:  "20 новых водителей с 50 заказами",
								Status: "not_completed",
								Value: KPIValue{
									Type:    "numeric",
									Current: 0.0,
									Target:  20.0,
									Order:   "ascending",
								},
							},
							{
								Type:   "supply_hours_per_park_car",
								Title:  "100 часов на линии с подтверждённым авто",
								Status: "not_completed",
								Value: KPIValue{
									Type:    "numeric",
									Current: 9.0,
									Target:  100.0,
									Order:   "ascending",
								},
							},
						},
					},
					{
						Title:          "Золотой",
						Subtitle:       "Необходимо выполнить 1 из 2 показателей",
						IsCompleted:    false,
						LoyaltyStatus:  "gold",
						KpisToComplete: 1,
						Items: []Item{
							{Type: "loyalty_status", Value: "gold"},
							{Type: "text", Value: "Скидка на Диспетчерскую"},
						},
						KeyPerformanceIndicators: []KPI{
							{
								Type:   "monthly_new_drivers_with_50_orders",
								Title:  "40 новых водителей с 50 заказами",
								Status: "not_completed",
								Value: KPIValue{
									Type:    "numeric",
									Current: 0.0,
									Target:  40.0,
									Order:   "ascending",
								},
							},
							{
								Type:   "supply_hours_per_park_car",
								Title:  "140 часов на линии с подтверждённым авто",
								Status: "not_completed",
								Value: KPIValue{
									Type:    "numeric",
									Current: 9.0,
									Target:  140.0,
									Order:   "ascending",
								},
							},
						},
					},
				},
			},
		},
		ParkInfo: ParkInfo{
			LoyaltyStatus: "basic",
		},
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// GetProblems handles POST /api/menu/problems
func (h *Handler) GetProblems(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	cookieHeader := r.Header.Get("Cookie")
	parkID := r.Header.Get("X-Park-ID")

	if cookieHeader == "" && parkID == "" {
		http.Error(w, "Missing authorization headers", http.StatusUnauthorized)
		return
	}

	// Read and discard body
	ioutil.ReadAll(r.Body)

	// TODO: Replace with actual data from Yandex Fleet API
	value1 := 1
	value3 := 3
	value42 := 42
	value103 := 103
	value19 := 19
	value1_2 := 1

	response := ProblemsResponse{
		Total: 8,
		Badges: []ProblemBadge{
			{
				ID: "has_contract_issue_depriority",
				Icon: ProblemIcon{
					Value: &value1,
				},
				Text: "Проблема с контрактом",
				Action: ProblemAction{
					ActionType:    "url",
					URL:           "/contractors?segment=active&group=has_contract_issue_depriority",
					IsURLExternal: false,
				},
			},
			{
				ID: "has_violation_warning",
				Icon: ProblemIcon{
					Value: &value3,
				},
				Text: "С нарушениями",
				Action: ProblemAction{
					ActionType:    "url",
					URL:           "/contractors?segment=active&group=has_violation_warning",
					IsURLExternal: false,
				},
			},
			{
				ID: "contractors_one_trip_conversion",
				Icon: ProblemIcon{
					Picture: "ArrowDownRoundFill",
				},
				Text: "Низкая конверсия в 1 поездку",
				Action: ProblemAction{
					ActionType:   "scenario_popup",
					ScenarioID:   "activation_conversion",
					OpenScenario: false,
				},
			},
			{
				ID: "contractors_n_trips_conversion",
				Icon: ProblemIcon{
					Picture: "ArrowDownRoundFill",
				},
				Text: "Низкая конверсия в 50 поездок",
				Action: ProblemAction{
					ActionType:    "url",
					URL:           "contractors-segments-dashboard?dateType=period&from=2026-03-29&to=2026-04-28",
					IsURLExternal: false,
				},
			},
			{
				ID: "has_thermobag_photocheck_not_passed",
				Icon: ProblemIcon{
					Value: &value42,
				},
				Text: "Проверки фото термосумки не пройдены",
				Action: ProblemAction{
					ActionType:    "url",
					URL:           "/contractors?segment=active&group=has_thermobag_photocheck_not_passed",
					IsURLExternal: false,
				},
			},
			{
				ID: "has_photocheck_restrictions",
				Icon: ProblemIcon{
					Value: &value103,
				},
				Text: "Имеют проблемы с фотоконтролем",
				Action: ProblemAction{
					ActionType:    "url",
					URL:           "/contractors?segment=active&group=has_photocheck_restrictions",
					IsURLExternal: false,
				},
			},
			{
				ID: "attestation_depriority_status",
				Icon: ProblemIcon{
					Value: &value19,
				},
				Text: "Не прошли аттестацию",
				Action: ProblemAction{
					ActionType:    "url",
					URL:           "/contractors?segment=active&group=attestation_depriority_status",
					IsURLExternal: false,
				},
			},
			{
				ID: "has_osago_restriction",
				Icon: ProblemIcon{
					Value: &value1_2,
				},
				Text: "Нет ОСАГО для такси",
				Action: ProblemAction{
					ActionType:    "url",
					URL:           "/contractors?segment=active&group=has_osago_restriction",
					IsURLExternal: false,
				},
			},
		},
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
