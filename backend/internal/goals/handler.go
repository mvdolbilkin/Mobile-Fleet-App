package goals

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"backend/internal/shared/proxy"

	"github.com/gin-gonic/gin"
)

const (
	urlGoalsCurrent  = "https://fleet.yandex.ru/api/fleet/fleet-goals/v2/goals/current"
	urlGoalsPrevious = "https://fleet.yandex.ru/api/fleet/fleet-goals/v2/goals/previous"
)

// fetchGoals proxies a goals request, formats period_text, falls back to mock on error.
func fetchGoals(c *gin.Context, targetURL string, mockFn func() GoalsResponse) {
	var req GoalsRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	s := proxy.GetSession(c)

	requestBody, err := json.Marshal(req)
	if err != nil {
		c.JSON(http.StatusOK, mockFn())
		return
	}

	yandexReq, err := http.NewRequest("POST", targetURL, bytes.NewBuffer(requestBody))
	if err != nil {
		c.JSON(http.StatusOK, mockFn())
		return
	}

	yandexReq.Header.Set("Content-Type", "application/json")
	yandexReq.Header.Set("Accept", "*/*")
	yandexReq.Header.Set("Accept-Language", "ru")
	yandexReq.Header.Set("X-Park-ID", s.ParkID)

	cookieValue := "Session_id=" + s.SessionID + "; sessionid2=" + s.SessionID2
	if s.LoginToken != "" {
		cookieValue += "; L=" + s.LoginToken
	}
	if s.Login != "" {
		cookieValue += "; yandex_login=" + s.Login
	}
	if s.UID != "" {
		cookieValue += "; yandexuid=" + s.UID
	}
	yandexReq.Header.Set("Cookie", cookieValue)

	resp, err := http.DefaultClient.Do(yandexReq)
	if err != nil {
		c.JSON(http.StatusOK, mockFn())
		return
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil || resp.StatusCode != http.StatusOK {
		c.JSON(http.StatusOK, mockFn())
		return
	}

	var result GoalsResponse
	if err := json.Unmarshal(body, &result); err != nil {
		c.JSON(http.StatusOK, mockFn())
		return
	}

	for i := range result.Goals {
		if result.Goals[i].Period != nil {
			result.Goals[i].PeriodText = formatPeriodText(result.Goals[i].Period)
		}
	}

	c.JSON(http.StatusOK, result)
}

// getCurrentGoals handles POST /api/goals/current.
func getCurrentGoals(c *gin.Context) {
	fetchGoals(c, urlGoalsCurrent, getMockCurrentGoals)
}

// getPreviousGoals handles POST /api/goals/previous.
func getPreviousGoals(c *gin.Context) {
	fetchGoals(c, urlGoalsPrevious, getMockPreviousGoals)
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

// formatPeriodText formats period dates into readable text
func formatPeriodText(period *Period) string {
	if period == nil {
		return ""
	}

	months := []string{
		"января", "февраля", "марта", "апреля", "мая", "июня",
		"июля", "августа", "сентября", "октября", "ноября", "декабря",
	}

	// Parse start date and add 3 hours to convert from UTC to local time (UTC+3)
	startTime, err := time.Parse(time.RFC3339, period.Start)
	if err != nil {
		return ""
	}
	// Add 3 hours to get local time
	startTime = startTime.Add(3 * time.Hour)

	// Parse finish date and add 3 hours
	finishTime, err := time.Parse(time.RFC3339, period.Finish)
	if err != nil {
		return ""
	}
	// Add 3 hours to get local time
	finishTime = finishTime.Add(3 * time.Hour)

	// Format as "1 мая — 31 мая"
	return fmt.Sprintf("%d %s — %d %s",
		startTime.Day(), months[startTime.Month()-1],
		finishTime.Day(), months[finishTime.Month()-1])
}
