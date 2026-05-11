package session_test

import (
	"encoding/json"
	"testing"
	"time"

	"backend/internal/session"
)

// Эти тесты проверяют сериализацию UserSession — чистая логика, Redis не нужен.
// Если формат JSON изменится, Yandex перестанет принимать cookie / токены.

func TestUserSession_MarshalUnmarshal_PreservesAllFields(t *testing.T) {
	original := &session.UserSession{
		UserID:     "park-123",
		SessionID:  "sid-abc",
		SessionID2: "sid2-xyz",
		LoginToken: "token-999",
		ParkID:     "park-123",
		Login:      "user@yandex.ru",
		UID:        "uid-777",
		CreatedAt:  time.Date(2024, 1, 15, 10, 0, 0, 0, time.UTC),
		ExpiresAt:  time.Date(2024, 1, 16, 10, 0, 0, 0, time.UTC),
	}

	data, err := json.Marshal(original)
	if err != nil {
		t.Fatalf("marshal failed: %v", err)
	}

	var restored session.UserSession
	if err := json.Unmarshal(data, &restored); err != nil {
		t.Fatalf("unmarshal failed: %v", err)
	}

	if restored.UserID != original.UserID {
		t.Errorf("UserID: got %q, want %q", restored.UserID, original.UserID)
	}
	if restored.SessionID != original.SessionID {
		t.Errorf("SessionID: got %q, want %q", restored.SessionID, original.SessionID)
	}
	if restored.SessionID2 != original.SessionID2 {
		t.Errorf("SessionID2: got %q, want %q", restored.SessionID2, original.SessionID2)
	}
	if restored.LoginToken != original.LoginToken {
		t.Errorf("LoginToken: got %q, want %q", restored.LoginToken, original.LoginToken)
	}
	if restored.ParkID != original.ParkID {
		t.Errorf("ParkID: got %q, want %q", restored.ParkID, original.ParkID)
	}
	if restored.Login != original.Login {
		t.Errorf("Login: got %q, want %q", restored.Login, original.Login)
	}
	if restored.UID != original.UID {
		t.Errorf("UID: got %q, want %q", restored.UID, original.UID)
	}
}

func TestUserSession_JSONKeys_MatchExpected(t *testing.T) {
	// Проверяем что json-теги не изменились — от них зависит Redis-хранилище
	s := &session.UserSession{
		UserID:     "u",
		SessionID:  "s",
		SessionID2: "s2",
		ParkID:     "p",
	}

	data, _ := json.Marshal(s)
	var raw map[string]interface{}
	json.Unmarshal(data, &raw)

	expectedKeys := []string{
		"user_id", "session_id", "session_id2",
		"login_token", "park_id", "login", "uid",
		"created_at", "expires_at",
	}
	for _, key := range expectedKeys {
		if _, ok := raw[key]; !ok {
			t.Errorf("JSON missing expected key %q — json-тег изменился?", key)
		}
	}
}

func TestUserSession_EmptyOptionalFields_DoNotBreakMarshal(t *testing.T) {
	s := &session.UserSession{
		UserID:    "u",
		SessionID: "s",
	}

	data, err := json.Marshal(s)
	if err != nil {
		t.Fatalf("marshal of minimal session failed: %v", err)
	}
	if len(data) == 0 {
		t.Error("marshaled data is empty")
	}
}
