package session

import (
	"sync"
	"time"
)

// UserSession хранит данные сессии пользователя
type UserSession struct {
	UserID     string    `json:"user_id"`
	SessionID  string    `json:"session_id"`
	SessionID2 string    `json:"session_id2"`
	LoginToken string    `json:"login_token"`
	ParkID     string    `json:"park_id"`
	Login      string    `json:"login"`
	UID        string    `json:"uid"`
	CreatedAt  time.Time `json:"created_at"`
	ExpiresAt  time.Time `json:"expires_at"`
}

// SessionStore хранит сессии в памяти
type SessionStore struct {
	sessions map[string]*UserSession
	mu       sync.RWMutex
}

var store *SessionStore

func init() {
	store = &SessionStore{
		sessions: make(map[string]*UserSession),
	}
}

// GetStore возвращает глобальное хранилище сессий
func GetStore() *SessionStore {
	return store
}

// Set сохраняет сессию
func (s *SessionStore) Set(userID string, session *UserSession) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.sessions[userID] = session
}

// Get получает сессию по userID
func (s *SessionStore) Get(userID string) (*UserSession, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	session, exists := s.sessions[userID]
	if !exists {
		return nil, false
	}
	// Проверяем не истекла ли сессия
	if time.Now().After(session.ExpiresAt) {
		return nil, false
	}
	return session, true
}

// Delete удаляет сессию
func (s *SessionStore) Delete(userID string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	delete(s.sessions, userID)
}

// CleanExpired удаляет истекшие сессии
func (s *SessionStore) CleanExpired() {
	s.mu.Lock()
	defer s.mu.Unlock()
	now := time.Now()
	for userID, session := range s.sessions {
		if now.After(session.ExpiresAt) {
			delete(s.sessions, userID)
		}
	}
}
