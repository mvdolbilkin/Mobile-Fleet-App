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
