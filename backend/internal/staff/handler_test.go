package staff_test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
	"time"

	"backend/internal/session"
	"backend/internal/shared/middleware"
	"backend/internal/staff"

	"github.com/gin-gonic/gin"
)

func init() {
	gin.SetMode(gin.TestMode)
}

func TestMain(m *testing.M) {
	addr := os.Getenv("REDIS_ADDR")
	if addr == "" {
		addr = "localhost:6379"
	}
	session.InitStore(addr, "", 0)
	os.Exit(m.Run())
}

func setupTestRouter(t *testing.T) (*gin.Engine, string) {
	t.Helper()

	parkID := "test-park-" + t.Name()
	s := &session.UserSession{
		UserID:     parkID,
		ParkID:     parkID,
		SessionID:  "test-sid",
		SessionID2: "test-sid2",
		CreatedAt:  time.Now(),
		ExpiresAt:  time.Now().Add(24 * time.Hour),
	}

	store := session.GetStore()
	if store == nil {
		t.Skip("Redis store not initialized — пропускаем тесты требующие сессию")
	}
	if err := store.Set(parkID, s); err != nil {
		t.Skipf("cannot seed session (Redis unavailable): %v", err)
	}

	r := gin.New()
	svc := staff.NewService()
	h := staff.NewHandler(svc)

	g := r.Group("/api/staff", middleware.Auth)
	g.GET("/list", h.GetStaffList)
	g.GET("/profile", h.GetStaffProfile)
	g.GET("/orders", h.GetDriverOrders)
	g.GET("/car", h.GetCarInfo)
	g.POST("/transaction", h.CreateTransaction)
	g.POST("/details", h.GetDriverDetails)
	g.POST("/bulk/update-work-conditions", h.BulkUpdateWorkConditions)
	g.POST("/bulk/update-work-status", h.BulkUpdateWorkStatus)
	g.POST("/bulk/mailing", h.BulkMailing)

	return r, parkID
}

// authHeader возвращает заголовок с X-Park-ID для тестовых запросов.
func authHeader(parkID string) func(*http.Request) {
	return func(req *http.Request) {
		req.Header.Set("X-Park-ID", parkID)
	}
}

// ─── /api/staff/profile ──────────────────────────────────────────────────────

func TestGetStaffProfile_MissingContractorID_Returns400(t *testing.T) {
	r, parkID := setupTestRouter(t)

	req := httptest.NewRequest("GET", "/api/staff/profile", nil)
	authHeader(parkID)(req)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d; body: %s", w.Code, w.Body.String())
	}
	assertHasErrorKey(t, w)
}

// ─── /api/staff/orders ───────────────────────────────────────────────────────

func TestGetDriverOrders_MissingParams_Returns400(t *testing.T) {
	r, parkID := setupTestRouter(t)

	cases := []struct {
		name  string
		query string
	}{
		{"no params", ""},
		{"only driver_id", "?contractor_profile_id=abc"},
		{"only from", "?from=2024-01-01"},
		{"driver+from no to", "?contractor_profile_id=abc&from=2024-01-01"},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			req := httptest.NewRequest("GET", "/api/staff/orders"+tc.query, nil)
			authHeader(parkID)(req)
			w := httptest.NewRecorder()
			r.ServeHTTP(w, req)

			if w.Code != http.StatusBadRequest {
				t.Errorf("expected 400, got %d", w.Code)
			}
		})
	}
}

// ─── /api/staff/car ──────────────────────────────────────────────────────────

func TestGetCarInfo_MissingCarID_Returns400(t *testing.T) {
	r, parkID := setupTestRouter(t)

	req := httptest.NewRequest("GET", "/api/staff/car", nil)
	authHeader(parkID)(req)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d; body: %s", w.Code, w.Body.String())
	}
}

// ─── /api/staff/transaction ──────────────────────────────────────────────────

func TestCreateTransaction_InvalidJSON_Returns400(t *testing.T) {
	r, parkID := setupTestRouter(t)

	req := httptest.NewRequest("POST", "/api/staff/transaction",
		strings.NewReader("{invalid json}"))
	req.Header.Set("Content-Type", "application/json")
	authHeader(parkID)(req)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d", w.Code)
	}
}

func TestCreateTransaction_EmptyBody_Returns400(t *testing.T) {
	r, parkID := setupTestRouter(t)

	req := httptest.NewRequest("POST", "/api/staff/transaction",
		bytes.NewBuffer(nil))
	req.Header.Set("Content-Type", "application/json")
	authHeader(parkID)(req)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d", w.Code)
	}
}

// ─── /api/staff/bulk/* ───────────────────────────────────────────────────────

func TestBulkUpdateWorkConditions_NoContractors_Returns400(t *testing.T) {
	r, parkID := setupTestRouter(t)

	body := map[string]interface{}{
		"contractor_ids": []string{},
		"condition":      "some-rule-id",
	}
	testBulkReturns400(t, r, parkID, "/api/staff/bulk/update-work-conditions", body)
}

func TestBulkUpdateWorkConditions_NoCondition_Returns400(t *testing.T) {
	r, parkID := setupTestRouter(t)

	body := map[string]interface{}{
		"contractor_ids": []string{"driver-1"},
		"condition":      "",
	}
	testBulkReturns400(t, r, parkID, "/api/staff/bulk/update-work-conditions", body)
}

func TestBulkUpdateWorkStatus_NoContractors_Returns400(t *testing.T) {
	r, parkID := setupTestRouter(t)

	body := map[string]interface{}{
		"contractor_ids": []string{},
		"status":         "working",
	}
	testBulkReturns400(t, r, parkID, "/api/staff/bulk/update-work-status", body)
}

func TestBulkMailing_NoMessage_Returns400(t *testing.T) {
	r, parkID := setupTestRouter(t)

	body := map[string]interface{}{
		"contractor_ids": []string{"driver-1"},
		"message_type":   "sms",
		"message":        "",
	}
	testBulkReturns400(t, r, parkID, "/api/staff/bulk/mailing", body)
}

func TestBulkMailing_NoContractors_Returns400(t *testing.T) {
	r, parkID := setupTestRouter(t)

	body := map[string]interface{}{
		"contractor_ids": []string{},
		"message":        "Hello",
	}
	testBulkReturns400(t, r, parkID, "/api/staff/bulk/mailing", body)
}

// BulkMailing с валидными данными должен вернуть 200 (это TODO-заглушка)
func TestBulkMailing_ValidData_Returns200(t *testing.T) {
	r, parkID := setupTestRouter(t)

	body := map[string]interface{}{
		"contractor_ids": []string{"driver-1", "driver-2"},
		"message_type":   "push",
		"message":        "Тестовое сообщение",
	}
	jsonBody, _ := json.Marshal(body)

	req := httptest.NewRequest("POST", "/api/staff/bulk/mailing",
		bytes.NewBuffer(jsonBody))
	req.Header.Set("Content-Type", "application/json")
	authHeader(parkID)(req)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("expected 200, got %d; body: %s", w.Code, w.Body.String())
	}

	var resp map[string]interface{}
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("response is not JSON: %s", w.Body.String())
	}
	if resp["success"] != true {
		t.Errorf("expected success=true, got: %v", resp)
	}
	if resp["sent_count"].(float64) != 2 {
		t.Errorf("expected sent_count=2, got: %v", resp["sent_count"])
	}
}

// ─── /api/staff/list — query param parsing ──────────────────────────────────

func TestGetStaffList_InvalidLimitParam_Returns400(t *testing.T) {
	r, parkID := setupTestRouter(t)

	req := httptest.NewRequest("GET", "/api/staff/list?limit=notanumber", nil)
	authHeader(parkID)(req)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400 for invalid limit, got %d", w.Code)
	}
}

// ─── helpers ─────────────────────────────────────────────────────────────────

func testBulkReturns400(t *testing.T, r *gin.Engine, parkID, path string, body interface{}) {
	t.Helper()
	jsonBody, _ := json.Marshal(body)

	req := httptest.NewRequest("POST", path, bytes.NewBuffer(jsonBody))
	req.Header.Set("Content-Type", "application/json")
	authHeader(parkID)(req)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d; body: %s", w.Code, w.Body.String())
	}
	assertHasErrorKey(t, w)
}

func assertHasErrorKey(t *testing.T, w *httptest.ResponseRecorder) {
	t.Helper()
	var body map[string]interface{}
	if err := json.Unmarshal(w.Body.Bytes(), &body); err != nil {
		t.Fatalf("response is not JSON: %s", w.Body.String())
	}
	if _, ok := body["error"]; !ok {
		t.Errorf("response JSON missing 'error' key: %v", body)
	}
}
