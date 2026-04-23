package auth

type LoginRequest struct {
	Clid   string `json:"clid" binding:"required"`
	ApiKey string `json:"api_key" binding:"required"`
	ParkID string `json:"park_id" binding:"required"`
}

type LoginResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message,omitempty"`
}

// WebViewSessionRequest запрос для сохранения сессии из WebView
type WebViewSessionRequest struct {
	SessionID  string `json:"session_id" binding:"required"`
	SessionID2 string `json:"session_id2" binding:"required"`
	LoginToken string `json:"login_token"`
	ParkID     string `json:"park_id" binding:"required"`
	Login      string `json:"login"`
	UID        string `json:"uid"`
}
