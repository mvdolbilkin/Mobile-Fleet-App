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

func (s *Service) GetDrivers(limit int, offset int, cookieHeader string, parkID string) (interface{}, error) {
	if cookieHeader == "" && parkID == "" {
		return nil, fmt.Errorf("отсутствуют необходимые учетные данные")
	}

	url := "https://fleet.yandex.ru/api/fleet/contractor-profiles-manager/v2/contractors/list"

	reqBody := ContractorsListRequest{
		Filter: map[string]interface{}{},
		Limit:  limit,
		Projection: []string{
			"full_name", "avatar_url", "name", "status", "id", "phone", "orders_count", "groups", "violations",
			"attestation_issues", "balance", "balance_limit", "unblock_date", "photocheck_restrictions",
		},
	}

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

	// Используем Cookie для авторизации
	if cookieHeader != "" {
		req.Header.Set("Cookie", cookieHeader)
	}
	if parkID != "" {
		req.Header.Set("X-Park-Id", parkID)
	}
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

func (s *Service) GetDriverProfile(cookieHeader string, parkID string, contractorProfileID string) (interface{}, error) {
	if cookieHeader == "" || parkID == "" || contractorProfileID == "" {
		return nil, fmt.Errorf("отсутствуют необходимые параметры")
	}

	url := fmt.Sprintf("https://fleet.yandex.ru/api/fleet/parks/contractors/driver-profile?contractor_profile_id=%s", contractorProfileID) // Changed to fleet.yandex.ru, may need adjustment depending on correct internal Endpoint

	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()

	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		return nil, fmt.Errorf("ошибка создания запроса: %w", err)
	}

	req.Header.Set("Cookie", cookieHeader)
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

func (s *Service) GetDriverOrders(cookieHeader string, parkID string, driverID string, from string, to string) (interface{}, error) {
	if cookieHeader == "" || parkID == "" || driverID == "" || from == "" || to == "" {
		return nil, fmt.Errorf("отсутствуют необходимые параметры")
	}

	url := "https://fleet.yandex.ru/api/fleet/parks/orders/list" // Changed to fleet.yandex.ru guessing the route

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

	req.Header.Set("Cookie", cookieHeader)
	req.Header.Set("X-Park-Id", parkID)
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

func (s *Service) GetCar(cookieHeader string, parkID string, carID string) (interface{}, error) {
	if cookieHeader == "" || parkID == "" || carID == "" {
		return nil, fmt.Errorf("отсутствуют необходимые параметры")
	}

	url := "https://fleet.yandex.ru/api/fleet/parks/cars/list"

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

	req.Header.Set("Cookie", cookieHeader)
	req.Header.Set("X-Park-Id", parkID)
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
