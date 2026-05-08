package middleware

import (
	"net/http"

	"backend/internal/session"

	"github.com/gin-gonic/gin"
)

// Auth is a Gin middleware that validates the user session via X-Park-ID header.
// On success, it stores the *session.UserSession in the gin context under "session" key.
func Auth(c *gin.Context) {
	userID := c.GetHeader("X-Park-ID")
	if userID == "" {
		userID = c.GetHeader("x-park-id")
	}
	if userID == "" {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "X-Park-ID header is required"})
		return
	}

	store := session.GetStore()
	userSession, exists := store.Get(userID)
	if !exists {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Session not found. Please login again."})
		return
	}

	c.Set("session", userSession)
	c.Next()
}
