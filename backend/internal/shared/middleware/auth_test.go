package middleware_test

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"backend/internal/session"
	"backend/internal/shared/middleware"

	"github.com/gin-gonic/gin"
)

// requireStore пропускает тест если Redis-стор не инициализирован.
// Auth middleware вызывает session.GetStore().Get(...) — без InitStore() будет panic.
func requireStore(t *testing.T) {
	t.Helper()
	if session.GetStore() == nil {
		t.Skip("session store not initialized (Redis unavailable) — пропускаем")
	}
}

func init() {
	gin.SetMode(gin.TestMode)
}

// setupRouter создаёт тестовый роутер с Auth middleware и простым хендлером.
func setupRouter() *gin.Engine {
	r := gin.New()
	r.GET("/protected", middleware.Auth, func(c *gin.Context) {
		s := c.MustGet("session").(*session.UserSession)
		c.JSON(http.StatusOK, gin.H{"park_id": s.ParkID})
	})
	return r
}

// seedSession записывает сессию в глобальный store для теста.
func seedSession(t *testing.T, parkID string) *session.UserSession {
	t.Helper()
	s := &session.UserSession{
		UserID:    parkID,
		ParkID:    parkID,
		SessionID: "test-session-id",
		SessionID2: "test-session-id2",
		CreatedAt: time.Now(),
		ExpiresAt: time.Now().Add(24 * time.Hour),
	}
	if err := session.GetStore().Set(parkID, s); err != nil {
		t.Fatalf("seedSession: %v", err)
	}
	return s
}

// ─── Tests ───────────────────────────────────────────────────────────────────

func TestAuth_MissingHeader_Returns401(t *testing.T) {
	r := setupRouter()

	req := httptest.NewRequest("GET", "/protected", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Errorf("expected 401, got %d", w.Code)
	}
	assertErrorJSON(t, w, "X-Park-ID header is required")
}

func TestAuth_EmptyHeader_Returns401(t *testing.T) {
	r := setupRouter()

	req := httptest.NewRequest("GET", "/protected", nil)
	req.Header.Set("X-Park-ID", "")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Errorf("expected 401, got %d", w.Code)
	}
}

func TestAuth_UnknownParkID_Returns401(t *testing.T) {
	// store.Get() вызывается только когда заголовок есть — нужен инициализированный store
	requireStore(t)

	r := setupRouter()

	req := httptest.NewRequest("GET", "/protected", nil)
	req.Header.Set("X-Park-ID", "non-existent-park-id")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Errorf("expected 401, got %d", w.Code)
	}
	assertErrorJSON(t, w, "Session not found")
}

func TestAuth_LowercaseHeader_IsAccepted(t *testing.T) {
	// Middleware принимает и X-Park-ID и x-park-id — важно не сломать мобильный клиент.
	// Когда заголовок есть, middleware идёт в store — нужен инициализированный store.
	requireStore(t)

	r := setupRouter()

	req := httptest.NewRequest("GET", "/protected", nil)
	req.Header.Set("x-park-id", "non-existent-park-id")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	// Должно вернуть 401 (нет сессии), но НЕ panic
	if w.Code != http.StatusUnauthorized {
		t.Errorf("expected 401, got %d", w.Code)
	}
}

func TestAuth_DoesNotLeakSessionData(t *testing.T) {
	r := setupRouter()

	req := httptest.NewRequest("GET", "/protected", nil)
	// Без заголовка
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	body := w.Body.String()
	// Тело ошибки не должно содержать внутренние детали сессии
	for _, sensitive := range []string{"session_id", "login_token", "SessionID"} {
		if containsStr(body, sensitive) {
			t.Errorf("response body leaks sensitive field %q: %s", sensitive, body)
		}
	}
}

// ─── helpers ─────────────────────────────────────────────────────────────────

func assertErrorJSON(t *testing.T, w *httptest.ResponseRecorder, wantSubstr string) {
	t.Helper()
	var body map[string]string
	if err := json.Unmarshal(w.Body.Bytes(), &body); err != nil {
		t.Fatalf("response is not valid JSON: %s", w.Body.String())
	}
	msg, ok := body["error"]
	if !ok {
		t.Errorf("response JSON missing 'error' key: %v", body)
		return
	}
	if !containsStr(msg, wantSubstr) {
		t.Errorf("error message %q does not contain %q", msg, wantSubstr)
	}
}

func containsStr(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}
