package proxy

import (
	"bytes"
	"crypto/rand"
	"encoding/hex"
	"io"
	"net/http"

	"backend/internal/session"

	"github.com/gin-gonic/gin"
)

// Option is a function that modifies an outgoing HTTP request before it is sent.
type Option func(*http.Request)

// WithJSONContentType sets Content-Type: application/json on the request.
func WithJSONContentType() Option {
	return func(req *http.Request) {
		req.Header.Set("Content-Type", "application/json")
	}
}

// WithIdempotencyToken generates and sets a unique X-Idempotency-Token header.
func WithIdempotencyToken() Option {
	return func(req *http.Request) {
		tokenBytes := make([]byte, 16)
		rand.Read(tokenBytes)
		tokenHex := hex.EncodeToString(tokenBytes)
		token := tokenHex[:8] + "-" + tokenHex[8:12] + "-" + tokenHex[12:16] + "-" + tokenHex[16:20] + "-" + tokenHex[20:]
		req.Header.Set("X-Idempotency-Token", token)
	}
}

// GetSession extracts the *session.UserSession from the gin context.
// Must be called after AuthMiddleware has been applied.
func GetSession(c *gin.Context) *session.UserSession {
	s, _ := c.Get("session")
	return s.(*session.UserSession)
}

// BuildCookieValue constructs the Yandex session cookie string from a UserSession.
func BuildCookieValue(s *session.UserSession) string {
	cookieValue := "Session_id=" + s.SessionID + "; sessionid2=" + s.SessionID2
	if s.LoginToken != "" {
		cookieValue += "; L=" + s.LoginToken
	}
	if s.Login != "" {
		cookieValue += "; yandex_login=" + s.Login
	}
	if s.UID != "" {
		cookieValue += "; yandexuid=" + s.UID
	}
	return cookieValue
}

// ToYandex is a universal proxy function that forwards the incoming request
// to the specified Yandex Fleet API URL using session-based authentication.
func ToYandex(c *gin.Context, targetURL string, method string, opts ...Option) {
	s := GetSession(c)

	var bodyBytes []byte
	if c.Request.Body != nil {
		bodyBytes, _ = io.ReadAll(c.Request.Body)
	}

	var bodyReader *bytes.Buffer
	if len(bodyBytes) > 0 {
		bodyReader = bytes.NewBuffer(bodyBytes)
	} else {
		bodyReader = bytes.NewBuffer(nil)
	}

	req, err := http.NewRequest(method, targetURL, bodyReader)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Accept-Language", "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7")
	req.Header.Set("x-park-id", s.ParkID)
	req.Header.Set("Cookie", BuildCookieValue(s))

	for _, opt := range opts {
		opt(req)
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		c.JSON(http.StatusBadGateway, gin.H{"error": "Failed to reach Yandex Fleet API"})
		return
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read response from Yandex API"})
		return
	}

	c.Data(resp.StatusCode, resp.Header.Get("Content-Type"), respBody)
}
