package session

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"
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

// SessionStore хранит сессии в Redis
type SessionStore struct {
	client *redis.Client
	ctx    context.Context
}

var store *SessionStore

func InitStore(addr string, password string, db int) {
	store = &SessionStore{
		client: redis.NewClient(&redis.Options{
			Addr:     addr,
			Password: password,
			DB:       db,
		}),
		ctx: context.Background(),
	}
}

// GetStore возвращает глобальное хранилище сессий
func GetStore() *SessionStore {
	return store
}

// Set сохраняет сессию с TTL
func (s *SessionStore) Set(userID string, session *UserSession) error {
	data, err := json.Marshal(session)
	if err != nil {
		return fmt.Errorf("failed to marshal session: %w", err)
	}
	key := fmt.Sprintf("session:%s", userID)
	return s.client.Set(s.ctx, key, data, 24*time.Hour).Err()
}

// Get получает сессию по userID
func (s *SessionStore) Get(userID string) (*UserSession, bool) {
	key := fmt.Sprintf("session:%s", userID)
	data, err := s.client.Get(s.ctx, key).Result()
	if err != nil {
		return nil, false
	}
	var session UserSession
	if err := json.Unmarshal([]byte(data), &session); err != nil {
		return nil, false
	}
	return &session, true
}

// Delete удаляет сессию
func (s *SessionStore) Delete(userID string) error {
	key := fmt.Sprintf("session:%s", userID)
	return s.client.Del(s.ctx, key).Err()
}
