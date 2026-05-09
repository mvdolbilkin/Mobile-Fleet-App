package staff

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/google/uuid"
)

type Service struct {
	httpClient *http.Client
}

func NewService() *Service {
	return &Service{
		httpClient: &http.Client{
			Timeout: 25 * time.Second,
			Transport: &http.Transport{
				MaxIdleConns:       10,
				IdleConnTimeout:    90 * time.Second,
				DisableCompression: false,
			},
		},
	}
}

// setHeaders sets common Yandex Fleet request headers.
func setHeaders(req *http.Request, cookieHeader, parkID string) {
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept-Language", "ru")
	if cookieHeader != "" {
		req.Header.Set("Cookie", cookieHeader)
	}
	if parkID != "" {
		req.Header.Set("X-Park-ID", parkID)
		req.Header.Set("X-Idempotency-Token", uuid.New().String())
	}
}

// doJSON executes req and unmarshals JSON response into interface{}.
func (s *Service) doJSON(req *http.Request) (interface{}, error) {
	resp, err := s.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("ошибка выполнения запроса: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("ошибка чтения ответа: %w", err)
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("ошибка Yandex API: %s - %s", resp.Status, string(body))
	}

	var result interface{}
	if err := json.Unmarshal(body, &result); err != nil {
		return nil, fmt.Errorf("ошибка десериализации ответа: %w", err)
	}
	return result, nil
}

func (s *Service) GetDrivers(limit int, offset int, cookieHeader string, parkID string) (interface{}, error) {
	if cookieHeader == "" && parkID == "" {
		return nil, fmt.Errorf("отсутствуют необходимые учетные данные")
	}

	reqBody := ContractorsListRequest{
		Filter: map[string]interface{}{},
		Limit:  limit,
		Offset: offset,
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

	req, err := http.NewRequestWithContext(ctx, "POST",
		"https://fleet.yandex.ru/api/fleet/contractor-profiles-manager/v2/contractors/list",
		bytes.NewBuffer(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("ошибка создания запроса: %w", err)
	}
	setHeaders(req, cookieHeader, parkID)
	return s.doJSON(req)
}

func (s *Service) GetDriverProfile(cookieHeader string, parkID string, contractorProfileID string) (interface{}, error) {
	if cookieHeader == "" || contractorProfileID == "" {
		return nil, fmt.Errorf("отсутствуют необходимые параметры")
	}

	url := fmt.Sprintf(
		"https://fleet.yandex.ru/api/fleet/contractor-profiles-manager/v1/contractor-profile/contractor-data?contractor_profile_id=%s",
		contractorProfileID,
	)

	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()

	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		return nil, fmt.Errorf("ошибка создания запроса: %w", err)
	}
	setHeaders(req, cookieHeader, parkID)
	return s.doJSON(req)
}

func (s *Service) GetDriverOrders(cookieHeader string, parkID string, driverID string, from string, to string) (interface{}, error) {
	reqBody := map[string]interface{}{
		"contractor_id": driverID,
		"period":        map[string]string{"from": from, "to": to},
	}
	jsonBody, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("ошибка сериализации json: %w", err)
	}

	req, err := http.NewRequest("POST",
		"https://fleet.yandex.ru/api/fleet/contractor-profiles-manager/v1/contractor-profile/period-data",
		bytes.NewBuffer(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("ошибка создания запроса: %w", err)
	}
	setHeaders(req, cookieHeader, parkID)
	return s.doJSON(req)
}

func (s *Service) GetCar(cookieHeader string, parkID string, carID string) (interface{}, error) {
	reqBody := map[string]interface{}{"car_id": carID}
	jsonBody, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("ошибка сериализации json: %w", err)
	}

	req, err := http.NewRequest("POST",
		"https://fleet.yandex.ru/api/api/v1/cards/car/details",
		bytes.NewBuffer(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("ошибка создания запроса: %w", err)
	}
	setHeaders(req, cookieHeader, parkID)
	return s.doJSON(req)
}

func (s *Service) GetVehicleSuggestions(cookieHeader string, parkID string, limit int) (interface{}, error) {
	url := fmt.Sprintf("https://fleet.yandex.ru/api/fleet/vehicles-manager/v1/cars/suggest?is_rental=true&limit=%d", limit)

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, fmt.Errorf("ошибка создания запроса: %w", err)
	}
	setHeaders(req, cookieHeader, parkID)
	return s.doJSON(req)
}

func (s *Service) CreateTransaction(cookieHeader string, parkID string, transaction TransactionRequest) (interface{}, error) {
	jsonBody, err := json.Marshal(transaction)
	if err != nil {
		return nil, fmt.Errorf("ошибка сериализации json: %w", err)
	}

	println("Sending to Yandex API:")
	println("  URL:", "https://fleet.yandex.ru/api/fleet/fleet-external-business-events/v2/parks/driver-profiles/transactions")
	println("  Body:", string(jsonBody))

	req, err := http.NewRequest("POST",
		"https://fleet.yandex.ru/api/fleet/fleet-external-business-events/v2/parks/driver-profiles/transactions",
		bytes.NewBuffer(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("ошибка создания запроса: %w", err)
	}

	idempotencyToken := uuid.New().String()
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Cookie", cookieHeader)
	req.Header.Set("Accept-Language", "ru")
	req.Header.Set("X-Park-ID", parkID)
	req.Header.Set("X-Idempotency-Token", idempotencyToken)

	println("  X-Idempotency-Token:", idempotencyToken)

	resp, err := s.httpClient.Do(req)
	if err != nil {
		println("HTTP request error:", err.Error())
		return nil, fmt.Errorf("ошибка выполнения запроса: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("ошибка чтения ответа: %w", err)
	}

	println("Yandex API response:")
	println("  Status:", resp.StatusCode)
	println("  Body:", string(body))

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		return nil, fmt.Errorf("ошибка Yandex API: %s - %s", resp.Status, string(body))
	}

	var result interface{}
	if err := json.Unmarshal(body, &result); err != nil {
		return nil, fmt.Errorf("ошибка десериализации ответа: %w", err)
	}
	return result, nil
}

func (s *Service) GetDriverDetails(cookieHeader string, parkID string, driverID string) (interface{}, error) {
	requestBody := DriverDetailsRequest{DriverID: driverID}
	jsonData, err := json.Marshal(requestBody)
	if err != nil {
		return nil, fmt.Errorf("ошибка сериализации json: %w", err)
	}

	req, err := http.NewRequest("POST",
		"https://fleet.yandex.ru/api/fleet/router/v1/cards/driver/details",
		bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("ошибка создания запроса: %w", err)
	}
	setHeaders(req, cookieHeader, parkID)
	return s.doJSON(req)
}

func (s *Service) GetDriverStatuses(cookieHeader string, parkID string) (interface{}, error) {
	reqBody := map[string]interface{}{"references": []string{"driver_statuses"}}
	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("ошибка сериализации json: %w", err)
	}

	req, err := http.NewRequest("POST",
		"https://fleet.yandex.ru/api/fleet/router/v1/references/list",
		bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("ошибка создания запроса: %w", err)
	}
	setHeaders(req, cookieHeader, parkID)
	return s.doJSON(req)
}

func (s *Service) ApplyWorkRule(cookieHeader string, parkID string, contractorIDs []string, workRuleID string) (interface{}, error) {
	reqBody := map[string]interface{}{
		"filters": map[string]interface{}{
			"contractor_ids": contractorIDs,
			"profile_exists": true,
		},
		"action": map[string]interface{}{
			"work_rule_id": workRuleID,
		},
	}
	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("ошибка сериализации json: %w", err)
	}

	req, err := http.NewRequest("POST",
		"https://fleet.yandex.ru/api/fleet/fleet-operations/v1/contractor-profiles-manager/work-rule",
		bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("ошибка создания запроса: %w", err)
	}
	setHeaders(req, cookieHeader, parkID)
	return s.doJSON(req)
}

func (s *Service) ApplyWorkStatus(cookieHeader string, parkID string, contractorIDs []string, workStatus string) (interface{}, error) {
	reqBody := map[string]interface{}{
		"filters": map[string]interface{}{
			"contractor_ids": contractorIDs,
			"profile_exists": true,
		},
		"action": map[string]interface{}{
			"work_status": workStatus,
		},
	}
	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("ошибка сериализации json: %w", err)
	}

	fmt.Println("Sending ApplyWorkStatus to Yandex API:")
	fmt.Println("  URL:", "https://fleet.yandex.ru/api/fleet/fleet-operations/v1/contractor-profiles-manager/work-status")
	fmt.Println("  Body:", string(jsonData))

	req, err := http.NewRequest("POST",
		"https://fleet.yandex.ru/api/fleet/fleet-operations/v1/contractor-profiles-manager/work-status",
		bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("ошибка создания запроса: %w", err)
	}
	setHeaders(req, cookieHeader, parkID)

	resp, err := s.httpClient.Do(req)
	if err != nil {
		fmt.Println("HTTP request error:", err.Error())
		return nil, fmt.Errorf("ошибка выполнения запроса: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("ошибка чтения ответа: %w", err)
	}

	fmt.Println("Yandex API response (ApplyWorkStatus):")
	fmt.Println("  Status:", resp.StatusCode)
	fmt.Println("  Body:", string(body))

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("ошибка Yandex API: %s - %s", resp.Status, string(body))
	}

	var result interface{}
	if err := json.Unmarshal(body, &result); err != nil {
		return nil, fmt.Errorf("ошибка десериализации ответа: %w", err)
	}
	return result, nil
}
