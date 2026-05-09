package summary

// Yandex Fleet API URLs.

// Dashboard widgets
const (
	urlActiveDrivers = "https://fleet.yandex.ru/api/fleet/fleet-dashboard/v3/widget/active-drivers"
	urlOrders        = "https://fleet.yandex.ru/api/fleet/fleet-dashboard/v3/widget/orders"
	urlSupplyHours   = "https://fleet.yandex.ru/api/fleet/fleet-dashboard/v3/widget/supply-hours"
	urlProfit        = "https://fleet.yandex.ru/api/fleet/fleet-dashboard/v3/widget/profit"
	urlOrdersSum     = "https://fleet.yandex.ru/api/fleet/fleet-dashboard/v3/widget/orders-sum"
	urlCertification = "https://fleet.yandex.ru/api/fleet/fleet-dashboard/v1/widget/certification"
	urlProfile       = "https://fleet.yandex.ru/api/fleet/ui/v1/parks/users/profile"
)

// Fleet reports
const (
	urlCarsSummary        = "https://fleet.yandex.ru/api/fleet/fleet-reports/v1/dashboard/widget/cars/summary"
	urlCarsStatuses       = "https://fleet.yandex.ru/api/fleet/fleet-reports/v1/dashboard/widget/cars/statuses"
	urlCarsMileage        = "https://fleet.yandex.ru/api/fleet/fleet-reports/v1/dashboard/widget/cars/mileage"
	urlCarsHoursOnline    = "https://fleet.yandex.ru/api/fleet/fleet-reports/v1/dashboard/widget/cars/hours-online"
	urlCarsAcceptanceRate = "https://fleet.yandex.ru/api/fleet/fleet-reports/v1/dashboard/widget/cars/acceptance-rate"
	urlCarsTrips          = "https://fleet.yandex.ru/api/fleet/fleet-reports/v1/dashboard/widget/cars/trips"
)

// Reports API
const (
	urlDriversSummaryList = "https://fleet.yandex.ru/api/reports-api/v2/summary/drivers/list"
	urlCarsSummaryList    = "https://fleet.yandex.ru/api/reports-api/v1/summary/cars/list"
	urlParksSummaryList   = "https://fleet.yandex.ru/api/reports-api/v2/summary/parks/list"
)

// Payments
const (
	urlPaymentTransactionsSummary  = "https://fleet.yandex.ru/api/fleet/fleet-payment-systems/v1/dashboard/widget/transactions/summary"
	urlPaymentFeesSummary          = "https://fleet.yandex.ru/api/fleet/fleet-payment-systems/v1/dashboard/widget/fees/summary"
	urlPaymentTransactionsDrivers  = "https://fleet.yandex.ru/api/fleet/fleet-payment-systems/v1/dashboard/widget/transactions/drivers"
	urlPaymentTransactionsCount    = "https://fleet.yandex.ru/api/fleet/fleet-payment-systems/v1/dashboard/widget/transactions/completed/count"
	urlPaymentTransactionsStatuses = "https://fleet.yandex.ru/api/fleet/fleet-payment-systems/v1/dashboard/widget/transactions/statuses"
	urlPaymentTransactionsList     = "https://fleet.yandex.ru/api/fleet/fleet-payment-systems/v3/transactions/list"
	urlPaymentTransactionByID      = "https://fleet.yandex.ru/api/fleet/fleet-payment-systems/v2/transactions/by-id"
)
