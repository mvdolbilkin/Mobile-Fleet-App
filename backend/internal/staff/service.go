package staff

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

type Service struct {
	httpClient *http.Client
}

func NewService() *Service {
	return &Service{
		httpClient: &http.Client{
			Timeout: 25 * time.Second,
			Transport: &http.Transport{
				MaxIdleConns:        10,
				IdleConnTimeout:     90 * time.Second,
				DisableCompression:  false,
			},
		},
	}
}

func (s *Service) GetDrivers(apiKey, clientID, parkID string, limit int, offset int) (interface{}, error) {

	url := "https://fleet-api.taxi.yandex.net/v1/parks/driver-profiles/list"

	reqBody := YandexAPIRequest{
		Limit:  limit,
		Offset: offset,
	}
	reqBody.Query.Park.ID = parkID
	reqBody.Fields.DriverProfile = []string{"id", "first_name", "last_name", "middle_name", "phones", "work_status"}
	reqBody.Fields.Car = []string{}
	reqBody.Fields.Account = []string{"id", "balance_limit", "balance"}
	reqBody.Fields.CurrentStatus = []string{"status"}

	jsonBody, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("ошибка сериализации json: %w", err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()

	req, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewBuffer(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("ошибка создания запроса: %w", err)
	}

	// Используем ключи, переданные из мобильного приложения
	req.Header.Set("X-Client-ID", clientID)
	req.Header.Set("X-API-Key", apiKey)
	req.Header.Set("Accept-Language", "ru")
	req.Header.Set("Content-Type", "application/json")

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("ошибка выполнения запроса: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("ошибка апи яндекса (код %d): %s", resp.StatusCode, string(bodyBytes))
	}

	var yandexResp map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&yandexResp); err != nil {
		return nil, fmt.Errorf("ошибка декодирования ответа: %w", err)
	}

	return yandexResp, nil
}
