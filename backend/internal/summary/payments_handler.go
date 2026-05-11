package summary

import (
	"fmt"
	"net/http"

	"backend/internal/shared/proxy"

	"github.com/gin-gonic/gin"
)

// GetPaymentTransactionsSummary proxies the payment transactions summary widget.
func (h *Handler) GetPaymentTransactionsSummary(c *gin.Context) {
	proxy.ToYandex(c, urlPaymentTransactionsSummary, http.MethodPost, proxy.WithJSONContentType())
}

// GetPaymentFeesSummary proxies the payment fees summary widget.
func (h *Handler) GetPaymentFeesSummary(c *gin.Context) {
	proxy.ToYandex(c, urlPaymentFeesSummary, http.MethodPost, proxy.WithJSONContentType())
}

// GetPaymentTransactionsDrivers proxies the payment transactions drivers widget.
func (h *Handler) GetPaymentTransactionsDrivers(c *gin.Context) {
	proxy.ToYandex(c, urlPaymentTransactionsDrivers, http.MethodPost, proxy.WithJSONContentType())
}

// GetPaymentTransactionsCount proxies the payment transactions count widget.
func (h *Handler) GetPaymentTransactionsCount(c *gin.Context) {
	proxy.ToYandex(c, urlPaymentTransactionsCount, http.MethodPost, proxy.WithJSONContentType())
}

// GetPaymentTransactionsStatuses proxies the payment transactions statuses widget.
func (h *Handler) GetPaymentTransactionsStatuses(c *gin.Context) {
	proxy.ToYandex(c, urlPaymentTransactionsStatuses, http.MethodPost, proxy.WithJSONContentType())
}

// GetPaymentTransactionsList proxies the payment transactions list.
func (h *Handler) GetPaymentTransactionsList(c *gin.Context) {
	proxy.ToYandex(c, urlPaymentTransactionsList, http.MethodPost, proxy.WithJSONContentType())
}

// GetPaymentTransactionByID proxies a single payment transaction by id.
func (h *Handler) GetPaymentTransactionByID(c *gin.Context) {
	transactionType := c.Query("transaction_type")
	transactionID := c.Query("transaction_id")
	targetURL := fmt.Sprintf("%s?transaction_type=%s&transaction_id=%s",
		urlPaymentTransactionByID, transactionType, transactionID)
	proxy.ToYandex(c, targetURL, http.MethodGet)
}
