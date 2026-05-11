package auth_test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"backend/internal/auth"
	"backend/internal/session"

	"github.com/gin-gonic/gin"
)

func init() {
	gin.SetMode(gin.TestMode)
}

// TestMain инициализирует Redis store перед запуском всех тестов пакета.
func TestMain(m *testing.M) {
	addr := os.Getenv("REDIS_ADDR")
	if addr == "" {
		addr = "localhost:6379"
	}
	session.InitStore(addr, "", 0)
	os.Exit(m.Run())
}

func setupRouter() *gin.Engine {
	r := gin.New()
	auth.RegisterRoutes(r)
	return r
}

func postJSON(r *gin.Engine, path string, body interface{}) *httptest.ResponseRecorder {
	jsonBody, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, path, bytes.NewBuffer(jsonBody))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	return w
}

// ─── POST /api/auth/login ─────────────────────────────────────────────────────

func TestLogin_MissingClid_Returns400(t *testing.T) {
	r := setupRouter()
	w := postJSON(r, "/api/auth/login", map[string]string{
		"api_key": "key",
		"park_id": "park-1",
	})
	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d; body: %s", w.Code, w.Body.String())
	}
	assertHasErrorKey(t, w)
}

func TestLogin_MissingApiKey_Returns400(t *testing.T) {
	r := setupRouter()
	w := postJSON(r, "/api/auth/login", map[string]string{
		"clid":    "clid-1",
		"park_id": "park-1",
	})
	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d; body: %s", w.Code, w.Body.String())
	}
	assertHasErrorKey(t, w)
}

func TestLogin_MissingParkID_Returns400(t *testing.T) {
	r := setupRouter()
	w := postJSON(r, "/api/auth/login", map[string]string{
		"clid":    "clid-1",
		"api_key": "key",
	})
	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d; body: %s", w.Code, w.Body.String())
	}
	assertHasErrorKey(t, w)
}

func TestLogin_EmptyBody_Returns400(t *testing.T) {
	r := setupRouter()
	req := httptest.NewRequest(http.MethodPost, "/api/auth/login", bytes.NewBuffer(nil))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d; body: %s", w.Code, w.Body.String())
	}
}

func TestLogin_InvalidJSON_Returns400(t *testing.T) {
	r := setupRouter()
	req := httptest.NewRequest(http.MethodPost, "/api/auth/login",
		bytes.NewBufferString("{invalid json}"))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d; body: %s", w.Code, w.Body.String())
	}
}

// TestLogin_InvalidCredentials_DoesNotReturn200 проверяет что мусорные
// учётные данные никогда не дают 200 — либо 401 (Yandex отверг), либо 503
// (Yandex недоступен). Тест не зависит от наличия сети.
func TestLogin_InvalidCredentials_DoesNotReturn200(t *testing.T) {
	r := setupRouter()
	w := postJSON(r, "/api/auth/login", map[string]string{
		"clid":    "fake-clid",
		"api_key": "fake-api-key",
		"park_id": "fake-park-id",
	})
	if w.Code == http.StatusOK {
		t.Errorf("fake credentials must not return 200; body: %s", w.Body.String())
	}
}

// ─── POST /api/auth/webview-session ──────────────────────────────────────────

func TestSaveWebViewSession_MissingSessionID_Returns400(t *testing.T) {
	r := setupRouter()
	w := postJSON(r, "/api/auth/webview-session", map[string]string{
		"session_id2": "sid2",
		"park_id":     "park-1",
	})
	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d; body: %s", w.Code, w.Body.String())
	}
	assertHasErrorKey(t, w)
}

func TestSaveWebViewSession_MissingSessionID2_Returns400(t *testing.T) {
	r := setupRouter()
	w := postJSON(r, "/api/auth/webview-session", map[string]string{
		"session_id": "sid1",
		"park_id":    "park-1",
	})
	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d; body: %s", w.Code, w.Body.String())
	}
	assertHasErrorKey(t, w)
}

func TestSaveWebViewSession_MissingParkID_Returns400(t *testing.T) {
	r := setupRouter()
	w := postJSON(r, "/api/auth/webview-session", map[string]string{
		"session_id":  "sid1",
		"session_id2": "sid2",
	})
	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d; body: %s", w.Code, w.Body.String())
	}
	assertHasErrorKey(t, w)
}

func TestSaveWebViewSession_InvalidJSON_Returns400(t *testing.T) {
	r := setupRouter()
	req := httptest.NewRequest(http.MethodPost, "/api/auth/webview-session",
		bytes.NewBufferString("{invalid json}"))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d; body: %s", w.Code, w.Body.String())
	}
}

// TestSaveWebViewSession_ValidRequest_SavesSession — happy path:
// сессия сохраняется в Redis и читается обратно с правильными полями.
func TestSaveWebViewSession_ValidRequest_SavesSession(t *testing.T) {
	store := session.GetStore()
	if store == nil {
		t.Skip("Redis store not initialized — пропускаем")
	}

	r := setupRouter()
	parkID := "test-park-webview-" + t.Name()

	w := postJSON(r, "/api/auth/webview-session", map[string]string{
		"session_id":  "sid-1",
		"session_id2": "sid-2",
		"login_token": "token-abc",
		"park_id":     parkID,
		"login":       "driver@yandex.ru",
		"uid":         "uid-999",
	})

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d; body: %s", w.Code, w.Body.String())
	}

	var resp map[string]interface{}
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("response is not JSON: %s", w.Body.String())
	}
	if resp["success"] != true {
		t.Errorf("expected success=true, got: %v", resp)
	}

	// Проверяем что сессия реально попала в Redis
	saved, ok := store.Get(parkID)
	if !ok {
		t.Fatal("session was not saved to Redis")
	}
	if saved.SessionID != "sid-1" {
		t.Errorf("session_id: want sid-1, got %s", saved.SessionID)
	}
	if saved.SessionID2 != "sid-2" {
		t.Errorf("session_id2: want sid-2, got %s", saved.SessionID2)
	}
	if saved.LoginToken != "token-abc" {
		t.Errorf("login_token: want token-abc, got %s", saved.LoginToken)
	}
	if saved.ParkID != parkID {
		t.Errorf("park_id: want %s, got %s", parkID, saved.ParkID)
	}
	// UserID должен совпадать с ParkID (так устроен handler)
	if saved.UserID != parkID {
		t.Errorf("user_id: want %s (same as park_id), got %s", parkID, saved.UserID)
	}
}

// TestSaveWebViewSession_OverwritesExistingSession проверяет что повторный
// вызов обновляет сессию, а не создаёт дубликат.
func TestSaveWebViewSession_OverwritesExistingSession(t *testing.T) {
	store := session.GetStore()
	if store == nil {
		t.Skip("Redis store not initialized — пропускаем")
	}

	r := setupRouter()
	parkID := "test-park-overwrite-" + t.Name()

	postJSON(r, "/api/auth/webview-session", map[string]string{
		"session_id":  "old-sid",
		"session_id2": "old-sid2",
		"park_id":     parkID,
	})

	w := postJSON(r, "/api/auth/webview-session", map[string]string{
		"session_id":  "new-sid",
		"session_id2": "new-sid2",
		"park_id":     parkID,
	})

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200 on overwrite, got %d", w.Code)
	}

	saved, ok := store.Get(parkID)
	if !ok {
		t.Fatal("session not found after overwrite")
	}
	if saved.SessionID != "new-sid" {
		t.Errorf("expected new-sid after overwrite, got: %s", saved.SessionID)
	}
}

// ─── helpers ─────────────────────────────────────────────────────────────────

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
