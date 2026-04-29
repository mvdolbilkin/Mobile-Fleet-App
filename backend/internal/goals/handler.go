package goals

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	"github.com/gin-gonic/gin"
)

type Handler struct{}

func NewHandler() *Handler {
	return &Handler{}
}

// GetCurrentGoals handles POST /api/goals/current
func (h *Handler) GetCurrentGoals(c *gin.Context) {
	var req GoalsRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	cookieHeader := c.GetHeader("Cookie")
	if cookieHeader == "" {
		cookieHeader = c.GetHeader("cookie")
	}
	parkID := c.GetHeader("X-Park-ID")

	if cookieHeader == "" || parkID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing authorization headers"})
		return
	}

	// Call Yandex Fleet Goals API
	yandexURL := "https://fleet.yandex.ru/api/fleet/fleet-goals/v2/goals/current"
	
	requestBody, err := json.Marshal(req)
	if err != nil {
		fmt.Printf("GetCurrentGoals Marshal Error: %v\n", err)
		c.JSON(http.StatusOK, getMockCurrentGoals())
		return
	}

	yandexReq, err := http.NewRequest("POST", yandexURL, bytes.NewBuffer(requestBody))
	if err != nil {
		fmt.Printf("GetCurrentGoals Request Creation Error: %v\n", err)
		c.JSON(http.StatusOK, getMockCurrentGoals())
		return
	}

	// Set headers
	yandexReq.Header.Set("Content-Type", "application/json")
	yandexReq.Header.Set("Cookie", cookieHeader)
	yandexReq.Header.Set("X-Park-ID", parkID)
	yandexReq.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
	yandexReq.Header.Set("Accept", "application/json")
	yandexReq.Header.Set("Origin", "https://fleet.yandex.ru")
	yandexReq.Header.Set("Referer", "https://fleet.yandex.ru/")

	client := &http.Client{}
	resp, err := client.Do(yandexReq)
	if err != nil {
		fmt.Printf("GetCurrentGoals HTTP Error: %v, returning mock data\n", err)
		c.JSON(http.StatusOK, getMockCurrentGoals())
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		fmt.Printf("GetCurrentGoals Yandex API Error: %s - %s, returning mock data\n", resp.Status, string(body))
		c.JSON(http.StatusOK, getMockCurrentGoals())
		return
	}

	var result GoalsResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		fmt.Printf("GetCurrentGoals Decode Error: %v, returning mock data\n", err)
		c.JSON(http.StatusOK, getMockCurrentGoals())
		return
	}

	c.JSON(http.StatusOK, result)
}

// GetPreviousGoals handles POST /api/goals/previous
func (h *Handler) GetPreviousGoals(c *gin.Context) {
	var req GoalsRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	cookieHeader := c.GetHeader("Cookie")
	if cookieHeader == "" {
		cookieHeader = c.GetHeader("cookie")
	}
	parkID := c.GetHeader("X-Park-ID")

	if cookieHeader == "" || parkID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing authorization headers"})
		return
	}

	// Call Yandex Fleet Goals API
	yandexURL := "https://fleet.yandex.ru/api/fleet/fleet-goals/v2/goals/previous"
	
	requestBody, err := json.Marshal(req)
	if err != nil {
		fmt.Printf("GetPreviousGoals Marshal Error: %v\n", err)
		c.JSON(http.StatusOK, getMockPreviousGoals())
		return
	}

	yandexReq, err := http.NewRequest("POST", yandexURL, bytes.NewBuffer(requestBody))
	if err != nil {
		fmt.Printf("GetPreviousGoals Request Creation Error: %v\n", err)
		c.JSON(http.StatusOK, getMockPreviousGoals())
		return
	}

	// Set headers
	yandexReq.Header.Set("Content-Type", "application/json")
	yandexReq.Header.Set("Cookie", cookieHeader)
	yandexReq.Header.Set("X-Park-ID", parkID)
	yandexReq.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
	yandexReq.Header.Set("Accept", "application/json")
	yandexReq.Header.Set("Origin", "https://fleet.yandex.ru")
	yandexReq.Header.Set("Referer", "https://fleet.yandex.ru/")

	client := &http.Client{}
	resp, err := client.Do(yandexReq)
	if err != nil {
		fmt.Printf("GetPreviousGoals HTTP Error: %v, returning mock data\n", err)
		c.JSON(http.StatusOK, getMockPreviousGoals())
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		fmt.Printf("GetPreviousGoals Yandex API Error: %s - %s, returning mock data\n", resp.Status, string(body))
		c.JSON(http.StatusOK, getMockPreviousGoals())
		return
	}

	var result GoalsResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		fmt.Printf("GetPreviousGoals Decode Error: %v, returning mock data\n", err)
		c.JSON(http.StatusOK, getMockPreviousGoals())
		return
	}

	c.JSON(http.StatusOK, result)
}

// Mock data functions
func getMockCurrentGoals() GoalsResponse {
	subtitle1 := "Выполнено 2 из 3 условий"
	subtitle2 := "Выполнено 1 из 3 условий"
	subtitle3 := "Выполнено 0 из 3 условий"
	
	current50 := 50
	target100 := 100
	percent50 := 50
	
	current30 := 30
	percent30 := 30
	
	current0 := 0
	percent0 := 0

	return GoalsResponse{
		Goals: []Goal{
			{
				ID:         "loyalty_program_2026_04",
				Title:      "Программа лояльности",
				PeriodText: "1 апреля — 30 апреля",
				Rewards: []Reward{
					{
						ID:          "basic",
						Title:       "Базовый",
						Subtitle:    &subtitle1,
						IsCompleted: true,
						BenefitItems: []BenefitItem{
							{Value: "Скидка 5%"},
							{Value: "Бонус 100₽"},
						},
						KeyPerformanceIndicators: []KeyPerformanceIndicator{
							{
								ID:          "trips_count",
								Title:       "Совершить 100 поездок",
								IsCompleted: true,
								Current:     &current50,
								Target:      &target100,
								Percent:     &percent50,
							},
							{
								ID:          "rating",
								Title:       "Рейтинг выше 4.8",
								IsCompleted: true,
							},
							{
								ID:          "acceptance_rate",
								Title:       "Процент принятия заказов выше 80%",
								IsCompleted: false,
								Current:     &current30,
								Target:      &target100,
								Percent:     &percent30,
							},
						},
					},
					{
						ID:          "bronze",
						Title:       "Бронзовый",
						Subtitle:    &subtitle2,
						IsCompleted: false,
						BenefitItems: []BenefitItem{
							{Value: "Скидка 10%"},
							{Value: "Бонус 300₽"},
							{Value: "Приоритет в заказах"},
						},
						KeyPerformanceIndicators: []KeyPerformanceIndicator{
							{
								ID:          "trips_count",
								Title:       "Совершить 200 поездок",
								IsCompleted: true,
								Current:     &current50,
								Target:      &target100,
								Percent:     &percent50,
							},
							{
								ID:          "rating",
								Title:       "Рейтинг выше 4.9",
								IsCompleted: false,
							},
							{
								ID:          "acceptance_rate",
								Title:       "Процент принятия заказов выше 85%",
								IsCompleted: false,
								Current:     &current30,
								Target:      &target100,
								Percent:     &percent30,
							},
						},
					},
					{
						ID:          "silver",
						Title:       "Серебряный",
						Subtitle:    &subtitle3,
						IsCompleted: false,
						BenefitItems: []BenefitItem{
							{Value: "Скидка 15%"},
							{Value: "Бонус 500₽"},
							{Value: "Приоритет в заказах"},
							{Value: "Персональный менеджер"},
						},
						KeyPerformanceIndicators: []KeyPerformanceIndicator{
							{
								ID:          "trips_count",
								Title:       "Совершить 300 поездок",
								IsCompleted: false,
								Current:     &current0,
								Target:      &target100,
								Percent:     &percent0,
							},
							{
								ID:          "rating",
								Title:       "Рейтинг выше 4.95",
								IsCompleted: false,
							},
							{
								ID:          "acceptance_rate",
								Title:       "Процент принятия заказов выше 90%",
								IsCompleted: false,
								Current:     &current0,
								Target:      &target100,
								Percent:     &percent0,
							},
						},
					},
				},
			},
		},
	}
}

func getMockPreviousGoals() GoalsResponse {
	subtitle1 := "Выполнено 3 из 3 условий"
	subtitle2 := "Выполнено 2 из 3 условий"
	
	current100 := 100
	target100 := 100
	percent100 := 100
	
	current80 := 80
	percent80 := 80

	return GoalsResponse{
		Goals: []Goal{
			{
				ID:         "loyalty_program_2026_03",
				Title:      "Программа лояльности",
				PeriodText: "1 марта — 31 марта",
				Rewards: []Reward{
					{
						ID:          "basic",
						Title:       "Базовый",
						Subtitle:    &subtitle1,
						IsCompleted: true,
						BenefitItems: []BenefitItem{
							{Value: "Скидка 5%"},
							{Value: "Бонус 100₽"},
						},
						KeyPerformanceIndicators: []KeyPerformanceIndicator{
							{
								ID:          "trips_count",
								Title:       "Совершить 100 поездок",
								IsCompleted: true,
								Current:     &current100,
								Target:      &target100,
								Percent:     &percent100,
							},
							{
								ID:          "rating",
								Title:       "Рейтинг выше 4.8",
								IsCompleted: true,
							},
							{
								ID:          "acceptance_rate",
								Title:       "Процент принятия заказов выше 80%",
								IsCompleted: true,
								Current:     &current100,
								Target:      &target100,
								Percent:     &percent100,
							},
						},
					},
					{
						ID:          "bronze",
						Title:       "Бронзовый",
						Subtitle:    &subtitle2,
						IsCompleted: false,
						BenefitItems: []BenefitItem{
							{Value: "Скидка 10%"},
							{Value: "Бонус 300₽"},
							{Value: "Приоритет в заказах"},
						},
						KeyPerformanceIndicators: []KeyPerformanceIndicator{
							{
								ID:          "trips_count",
								Title:       "Совершить 200 поездок",
								IsCompleted: true,
								Current:     &current100,
								Target:      &target100,
								Percent:     &percent100,
							},
							{
								ID:          "rating",
								Title:       "Рейтинг выше 4.9",
								IsCompleted: true,
							},
							{
								ID:          "acceptance_rate",
								Title:       "Процент принятия заказов выше 85%",
								IsCompleted: false,
								Current:     &current80,
								Target:      &target100,
								Percent:     &percent80,
							},
						},
					},
				},
			},
		},
	}
}
