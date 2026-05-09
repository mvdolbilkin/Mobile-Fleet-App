package summary

func getMockActiveDrivers(dateFrom, dateTo string) interface{} {
	return map[string]interface{}{
		"series": []map[string]interface{}{
			{
				"id": "common",
				"requested": map[string]interface{}{
					"values": []map[string]interface{}{
						{"x": dateFrom + "T00:00:00+03:00", "y": 3},
						{"x": dateFrom + "T00:00:00+03:00", "y": 5},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 5},
						{"x": dateFrom + "T00:00:00+03:00", "y": 2},
						{"x": dateTo + "T00:00:00+03:00", "y": 7},
					},
					"summary": 22,
				},
				"previous": map[string]interface{}{
					"values": []map[string]interface{}{
						{"x": "2026-04-16T00:00:00+03:00", "y": 1},
						{"x": "2026-04-17T00:00:00+03:00", "y": 3},
						{"x": "2026-04-18T00:00:00+03:00", "y": 0},
						{"x": "2026-04-19T00:00:00+03:00", "y": 0},
						{"x": "2026-04-20T00:00:00+03:00", "y": 3},
						{"x": "2026-04-21T00:00:00+03:00", "y": 4},
						{"x": "2026-04-22T00:00:00+03:00", "y": 4},
					},
					"summary": 15,
				},
				"summary_diff_percent": 0.3636,
			},
			{
				"id":   "car",
				"name": "Автомобиль",
				"requested": map[string]interface{}{
					"values": []map[string]interface{}{
						{"x": dateFrom + "T00:00:00+03:00", "y": 3},
						{"x": dateFrom + "T00:00:00+03:00", "y": 5},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 5},
						{"x": dateFrom + "T00:00:00+03:00", "y": 2},
						{"x": dateTo + "T00:00:00+03:00", "y": 7},
					},
					"summary": 22,
				},
				"previous": map[string]interface{}{
					"values": []map[string]interface{}{
						{"x": "2026-04-16T00:00:00+03:00", "y": 1},
						{"x": "2026-04-17T00:00:00+03:00", "y": 3},
						{"x": "2026-04-18T00:00:00+03:00", "y": 0},
						{"x": "2026-04-19T00:00:00+03:00", "y": 0},
						{"x": "2026-04-20T00:00:00+03:00", "y": 3},
						{"x": "2026-04-21T00:00:00+03:00", "y": 4},
						{"x": "2026-04-22T00:00:00+03:00", "y": 4},
					},
					"summary": 15,
				},
				"summary_diff_percent": 0.3636,
			},
			{
				"id":   "bike",
				"name": "Мотоцикл",
				"requested": map[string]interface{}{
					"values": []map[string]interface{}{
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateTo + "T00:00:00+03:00", "y": 0},
					},
					"summary": 0,
				},
				"previous": map[string]interface{}{
					"values": []map[string]interface{}{
						{"x": "2026-04-16T00:00:00+03:00", "y": 0},
						{"x": "2026-04-17T00:00:00+03:00", "y": 0},
						{"x": "2026-04-18T00:00:00+03:00", "y": 0},
						{"x": "2026-04-19T00:00:00+03:00", "y": 0},
						{"x": "2026-04-20T00:00:00+03:00", "y": 0},
						{"x": "2026-04-21T00:00:00+03:00", "y": 0},
						{"x": "2026-04-22T00:00:00+03:00", "y": 0},
					},
					"summary": 0,
				},
			},
			{
				"id":   "rickshaw",
				"name": "Рикша",
				"requested": map[string]interface{}{
					"values": []map[string]interface{}{
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateFrom + "T00:00:00+03:00", "y": 0},
						{"x": dateTo + "T00:00:00+03:00", "y": 0},
					},
					"summary": 0,
				},
				"previous": map[string]interface{}{
					"values": []map[string]interface{}{
						{"x": "2026-04-16T00:00:00+03:00", "y": 0},
						{"x": "2026-04-17T00:00:00+03:00", "y": 0},
						{"x": "2026-04-18T00:00:00+03:00", "y": 0},
						{"x": "2026-04-19T00:00:00+03:00", "y": 0},
						{"x": "2026-04-20T00:00:00+03:00", "y": 0},
						{"x": "2026-04-21T00:00:00+03:00", "y": 0},
						{"x": "2026-04-22T00:00:00+03:00", "y": 0},
					},
					"summary": 0,
				},
			},
		},
	}
}
