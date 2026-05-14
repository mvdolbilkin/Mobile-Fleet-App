package middleware

import (
	"net/http"
	"strings"

	"backend/internal/session"

	"github.com/gin-gonic/gin"
)

// Auth is a Gin middleware that validates the user session via Authorization Bearer token header.
// On success, it stores the *session.UserSession in the gin context under "session" key.
func Auth(c *gin.Context) {
	var token string

	// Extract the Bearer token
	authHeader := c.GetHeader("Authorization")
	if strings.HasPrefix(authHeader, "Bearer ") {
		token = strings.TrimPrefix(authHeader, "Bearer ")
	}

	// Fallback to X-Park-ID for backward compatibility (if needed for older app versions)
	if token == "" {
		token = c.GetHeader("X-Park-ID")
		if token == "" {
			token = c.GetHeader("x-park-id")
		}
	}

	if token == "" {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Authorization header is required"})
		return
	}

	store := session.GetStore()
	userSession, exists := store.Get(token)
	if !exists {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Session not found. Please login again."})
		return
	}

	c.Set("session", userSession)
	c.Next()
}
