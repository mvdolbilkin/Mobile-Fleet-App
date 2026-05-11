package proxy_test

import (
	"net/http"
	"regexp"
	"testing"

	"backend/internal/session"
	"backend/internal/shared/proxy"
)

// BuildCookieValue

func TestBuildCookieValue_RequiredFields(t *testing.T) {
	s := &session.UserSession{
		SessionID:  "session-abc",
		SessionID2: "session2-xyz",
	}
	got := proxy.BuildCookieValue(s)

	if want := "Session_id=session-abc"; !contains(got, want) {
		t.Errorf("cookie missing %q, got: %q", want, got)
	}
	if want := "sessionid2=session2-xyz"; !contains(got, want) {
		t.Errorf("cookie missing %q, got: %q", want, got)
	}
}

func TestBuildCookieValue_OptionalLoginToken(t *testing.T) {
	withToken := &session.UserSession{
		SessionID:  "sid",
		SessionID2: "sid2",
		LoginToken: "token123",
	}
	withoutToken := &session.UserSession{
		SessionID:  "sid",
		SessionID2: "sid2",
	}

	if !contains(proxy.BuildCookieValue(withToken), "L=token123") {
		t.Error("expected L= cookie when LoginToken set")
	}
	if contains(proxy.BuildCookieValue(withoutToken), "L=") {
		t.Error("unexpected L= cookie when LoginToken empty")
	}
}

func TestBuildCookieValue_AllOptionalFields(t *testing.T) {
	s := &session.UserSession{
		SessionID:  "sid",
		SessionID2: "sid2",
		LoginToken: "tok",
		Login:      "user@yandex.ru",
		UID:        "uid999",
	}
	got := proxy.BuildCookieValue(s)

	for _, want := range []string{
		"Session_id=sid",
		"sessionid2=sid2",
		"L=tok",
		"yandex_login=user@yandex.ru",
		"yandexuid=uid999",
	} {
		if !contains(got, want) {
			t.Errorf("cookie missing %q, got: %q", want, got)
		}
	}
}

func TestBuildCookieValue_NoOptionalFields(t *testing.T) {
	s := &session.UserSession{
		SessionID:  "sid",
		SessionID2: "sid2",
	}
	got := proxy.BuildCookieValue(s)

	for _, unwanted := range []string{"yandex_login", "yandexuid", "L="} {
		if contains(got, unwanted) {
			t.Errorf("cookie should not contain %q when field is empty, got: %q", unwanted, got)
		}
	}
}

// WithIdempotencyToken

func TestWithIdempotencyToken_SetsHeader(t *testing.T) {
	req, _ := http.NewRequest("POST", "http://example.com", nil)
	opt := proxy.WithIdempotencyToken()
	opt(req)

	token := req.Header.Get("X-Idempotency-Token")
	if token == "" {
		t.Fatal("X-Idempotency-Token header not set")
	}
}

func TestWithIdempotencyToken_ValidUUIDFormat(t *testing.T) {
	req, _ := http.NewRequest("POST", "http://example.com", nil)
	proxy.WithIdempotencyToken()(req)

	token := req.Header.Get("X-Idempotency-Token")
	uuidRe := regexp.MustCompile(`^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`)
	if !uuidRe.MatchString(token) {
		t.Errorf("token %q does not match UUID format", token)
	}
}

func TestWithIdempotencyToken_UniquePerCall(t *testing.T) {
	req1, _ := http.NewRequest("POST", "http://example.com", nil)
	req2, _ := http.NewRequest("POST", "http://example.com", nil)

	proxy.WithIdempotencyToken()(req1)
	proxy.WithIdempotencyToken()(req2)

	t1 := req1.Header.Get("X-Idempotency-Token")
	t2 := req2.Header.Get("X-Idempotency-Token")
	if t1 == t2 {
		t.Error("idempotency tokens must be unique per call")
	}
}

// WithJSONContentType

func TestWithJSONContentType_SetsHeader(t *testing.T) {
	req, _ := http.NewRequest("POST", "http://example.com", nil)
	proxy.WithJSONContentType()(req)

	got := req.Header.Get("Content-Type")
	if got != "application/json" {
		t.Errorf("expected Content-Type application/json, got %q", got)
	}
}

// helpers

func contains(s, substr string) bool {
	return len(s) >= len(substr) && (s == substr ||
		len(s) > 0 && containsRune(s, substr))
}

func containsRune(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}
