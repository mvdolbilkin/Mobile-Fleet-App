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

func (s *Service) GetDrivers(limit int, offset int, apiKey string, clientID string, parkID string) (interface{}, error) {
	if apiKey == "" || clientID == "" || parkID == "" {
		return nil, fmt.Errorf("отсутствуют необходимые учетные данные в заголовках")
	}

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

func (s *Service) GetDriverProfile(apiKey string, clientID string, parkID string, contractorProfileID string) (interface{}, error) {
	if apiKey == "" || clientID == "" || parkID == "" || contractorProfileID == "" {
		return nil, fmt.Errorf("отсутствуют необходимые параметры")
	}

	url := fmt.Sprintf("https://fleet-api.taxi.yandex.net/v2/parks/contractors/driver-profile?contractor_profile_id=%s", contractorProfileID)

	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()

	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		return nil, fmt.Errorf("ошибка создания запроса: %w", err)
	}

	req.Header.Set("X-Client-ID", clientID)
	req.Header.Set("X-API-Key", apiKey)
	req.Header.Set("X-Park-ID", parkID)
	req.Header.Set("Accept-Language", "ru")

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

func (s *Service) GetDriverOrders(apiKey string, clientID string, parkID string, driverID string, from string, to string) (interface{}, error) {
	if apiKey == "" || clientID == "" || parkID == "" || driverID == "" || from == "" || to == "" {
		return nil, fmt.Errorf("отсутствуют необходимые параметры")
	}

	url := "https://fleet-api.taxi.yandex.net/v1/parks/orders/list"

	reqBody := OrdersRequest{
		Limit: 500, // или больше, если нужно
	}
	reqBody.Query.Park.ID = parkID
	reqBody.Query.Park.Order.BookedAt.From = from
	reqBody.Query.Park.Order.BookedAt.To = to
	// Removed contractor filtering here

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

	req.Header.Set("X-Client-ID", clientID)
	req.Header.Set("X-API-Key", apiKey)
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

func (s *Service) GetCar(apiKey string, clientID string, parkID string, carID string) (interface{}, error) {
	if apiKey == "" || clientID == "" || parkID == "" || carID == "" {
		return nil, fmt.Errorf("отсутствуют необходимые параметры")
	}

	url := "https://fleet-api.taxi.yandex.net/v1/parks/cars/list"

	reqBody := CarsRequest{}
	reqBody.Query.Park.ID = parkID
	reqBody.Query.Park.Car.ID = []string{carID}

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

	req.Header.Set("X-Client-ID", clientID)
	req.Header.Set("X-API-Key", apiKey)
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
