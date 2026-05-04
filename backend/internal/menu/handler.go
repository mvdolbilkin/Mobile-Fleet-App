package menu

import (
	"bytes"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
)

type Handler struct{}

func NewHandler() *Handler {
	return &Handler{}
}

const yandexFleetContractorsWidgetURL = "https://fleet.yandex.ru/api/fleet/fleet-dashboard/v1/widget/contractors"
const yandexFleetCarsWidgetURL = "https://fleet.yandex.ru/api/fleet/fleet-dashboard/v1/widget/cars"
const yandexFleetProblemsWidgetURL = "https://fleet.yandex.ru/api/fleet/fleet-dashboard/v3/widget/problems"
const yandexFleetLoyaltyProgramURL = "https://fleet.yandex.ru/api/fleet/fleet-goals/v2/goals/current"

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

	log.Printf("[CONTRACTORS] Request received: date_from=%s, date_to=%s", req.DateFrom, req.DateTo)

	// Prepare request to Yandex Fleet API
	requestBody, err := json.Marshal(req)
	if err != nil {
		http.Error(w, "Failed to prepare request", http.StatusInternalServerError)
		return
	}

	log.Printf("[CONTRACTORS] Sending to Yandex Fleet: %s", string(requestBody))

	yandexReq, err := http.NewRequest("POST", yandexFleetContractorsWidgetURL, bytes.NewBuffer(requestBody))
	if err != nil {
		http.Error(w, "Failed to create request", http.StatusInternalServerError)
		return
	}

	// Set headers
	yandexReq.Header.Set("Content-Type", "application/json")
	yandexReq.Header.Set("Accept", "*/*")
	yandexReq.Header.Set("Accept-Language", "ru")
	yandexReq.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
	yandexReq.Header.Set("X-Client-Version", "fleet/20629")
	yandexReq.Header.Set("Origin", "https://fleet.yandex.ru")
	yandexReq.Header.Set("Referer", "https://fleet.yandex.ru/dashboard")

	if cookieHeader != "" {
		yandexReq.Header.Set("Cookie", cookieHeader)
	}
	if parkID != "" {
		yandexReq.Header.Set("X-Park-ID", parkID)
	}

	// Make request to Yandex Fleet API
	client := &http.Client{}
	yandexResp, err := client.Do(yandexReq)
	if err != nil {
		log.Printf("Error calling Yandex Fleet API: %v", err)
		http.Error(w, "Failed to fetch data from Yandex Fleet", http.StatusBadGateway)
		return
	}
	defer yandexResp.Body.Close()

	// Read response body
	body, err := ioutil.ReadAll(yandexResp.Body)
	if err != nil {
		log.Printf("Error reading response: %v", err)
		http.Error(w, "Failed to read response", http.StatusInternalServerError)
		return
	}

	// Check if request was successful
	if yandexResp.StatusCode != http.StatusOK {
		log.Printf("Yandex Fleet API returned status %d: %s", yandexResp.StatusCode, string(body))
		http.Error(w, "Failed to fetch data from Yandex Fleet", yandexResp.StatusCode)
		return
	}

	// Parse and validate response
	var response ContractorsResponse
	if err := json.Unmarshal(body, &response); err != nil {
		log.Printf("Error parsing response: %v", err)
		http.Error(w, "Invalid response from Yandex Fleet", http.StatusInternalServerError)
		return
	}

	// Return response
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

	log.Printf("[CARS] Request received: date_from=%s, date_to=%s", req.DateFrom, req.DateTo)

	// Prepare request to Yandex Fleet API
	requestBody, err := json.Marshal(req)
	if err != nil {
		http.Error(w, "Failed to prepare request", http.StatusInternalServerError)
		return
	}

	log.Printf("[CARS] Sending to Yandex Fleet: %s", string(requestBody))

	yandexReq, err := http.NewRequest("POST", yandexFleetCarsWidgetURL, bytes.NewBuffer(requestBody))
	if err != nil {
		http.Error(w, "Failed to create request", http.StatusInternalServerError)
		return
	}

	// Set headers
	yandexReq.Header.Set("Content-Type", "application/json")
	yandexReq.Header.Set("Accept", "*/*")
	yandexReq.Header.Set("Accept-Language", "ru")
	yandexReq.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
	yandexReq.Header.Set("X-Client-Version", "fleet/20629")
	yandexReq.Header.Set("Origin", "https://fleet.yandex.ru")
	yandexReq.Header.Set("Referer", "https://fleet.yandex.ru/dashboard")

	if cookieHeader != "" {
		yandexReq.Header.Set("Cookie", cookieHeader)
	}
	if parkID != "" {
		yandexReq.Header.Set("X-Park-ID", parkID)
	}

	// Make request to Yandex Fleet API
	client := &http.Client{}
	yandexResp, err := client.Do(yandexReq)
	if err != nil {
		log.Printf("Error calling Yandex Fleet API: %v", err)
		http.Error(w, "Failed to fetch data from Yandex Fleet", http.StatusBadGateway)
		return
	}
	defer yandexResp.Body.Close()

	// Read response body
	body, err := ioutil.ReadAll(yandexResp.Body)
	if err != nil {
		log.Printf("Error reading response: %v", err)
		http.Error(w, "Failed to read response", http.StatusInternalServerError)
		return
	}

	// Check if request was successful
	if yandexResp.StatusCode != http.StatusOK {
		log.Printf("Yandex Fleet API returned status %d: %s", yandexResp.StatusCode, string(body))
		http.Error(w, "Failed to fetch data from Yandex Fleet", yandexResp.StatusCode)
		return
	}

	// Parse and validate response
	var response CarsResponse
	if err := json.Unmarshal(body, &response); err != nil {
		log.Printf("Error parsing response: %v", err)
		http.Error(w, "Invalid response from Yandex Fleet", http.StatusInternalServerError)
		return
	}

	// Return response
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

	// Read request body
	bodyBytes, err := ioutil.ReadAll(r.Body)
	if err != nil {
		log.Printf("Error reading request body: %v", err)
		http.Error(w, "Failed to read request body", http.StatusBadRequest)
		return
	}

	// Create request to Yandex Fleet API
	yandexReq, err := http.NewRequest("POST", yandexFleetLoyaltyProgramURL, bytes.NewBuffer(bodyBytes))
	if err != nil {
		log.Printf("Error creating request to Yandex Fleet API: %v", err)
		http.Error(w, "Failed to create request", http.StatusInternalServerError)
		return
	}

	// Copy headers
	yandexReq.Header.Set("Cookie", cookieHeader)
	yandexReq.Header.Set("X-Park-ID", parkID)
	yandexReq.Header.Set("Content-Type", "application/json")
	yandexReq.Header.Set("Accept", "*/*")
	yandexReq.Header.Set("Accept-Language", "ru")
	yandexReq.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")

	// Make request
	client := &http.Client{}
	resp, err := client.Do(yandexReq)
	if err != nil {
		log.Printf("Error making request to Yandex Fleet API: %v", err)
		http.Error(w, "Failed to fetch data from Yandex Fleet API", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	// Read response
	respBody, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Printf("Error reading response from Yandex Fleet API: %v", err)
		http.Error(w, "Failed to read response", http.StatusInternalServerError)
		return
	}

	// Log response for debugging
	log.Printf("Yandex Fleet Loyalty Program API response status: %d", resp.StatusCode)
	log.Printf("Yandex Fleet Loyalty Program API response body: %s", string(respBody))

	// Check status code
	if resp.StatusCode != http.StatusOK {
		log.Printf("Yandex Fleet API returned non-200 status: %d, body: %s", resp.StatusCode, string(respBody))
		http.Error(w, string(respBody), resp.StatusCode)
		return
	}

	// Parse response
	var response LoyaltyProgramResponse
	if err := json.Unmarshal(respBody, &response); err != nil {
		log.Printf("Error parsing response from Yandex Fleet API: %v", err)
		http.Error(w, "Failed to parse response", http.StatusInternalServerError)
		return
	}

	// Return response
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

	// Read request body
	bodyBytes, err := ioutil.ReadAll(r.Body)
	if err != nil {
		log.Printf("Error reading request body: %v", err)
		http.Error(w, "Failed to read request body", http.StatusBadRequest)
		return
	}

	// Create request to Yandex Fleet API
	yandexReq, err := http.NewRequest("POST", yandexFleetProblemsWidgetURL, bytes.NewBuffer(bodyBytes))
	if err != nil {
		log.Printf("Error creating request to Yandex Fleet API: %v", err)
		http.Error(w, "Failed to create request", http.StatusInternalServerError)
		return
	}

	// Copy headers
	yandexReq.Header.Set("Cookie", cookieHeader)
	yandexReq.Header.Set("X-Park-ID", parkID)
	yandexReq.Header.Set("Content-Type", "application/json")
	yandexReq.Header.Set("Accept", "*/*")
	yandexReq.Header.Set("Accept-Language", "ru")
	yandexReq.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")

	// Make request
	client := &http.Client{}
	resp, err := client.Do(yandexReq)
	if err != nil {
		log.Printf("Error making request to Yandex Fleet API: %v", err)
		http.Error(w, "Failed to fetch data from Yandex Fleet API", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	// Read response
	respBody, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Printf("Error reading response from Yandex Fleet API: %v", err)
		http.Error(w, "Failed to read response", http.StatusInternalServerError)
		return
	}

	// Log response for debugging
	log.Printf("Yandex Fleet Problems API response status: %d", resp.StatusCode)
	log.Printf("Yandex Fleet Problems API response body: %s", string(respBody))

	// Check status code
	if resp.StatusCode != http.StatusOK {
		log.Printf("Yandex Fleet API returned non-200 status: %d, body: %s", resp.StatusCode, string(respBody))
		http.Error(w, string(respBody), resp.StatusCode)
		return
	}

	// Parse response
	var response ProblemsResponse
	if err := json.Unmarshal(respBody, &response); err != nil {
		log.Printf("Error parsing response from Yandex Fleet API: %v", err)
		http.Error(w, "Failed to parse response", http.StatusInternalServerError)
		return
	}

	// Return response
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
