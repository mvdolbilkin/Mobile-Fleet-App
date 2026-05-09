package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"net/http"
)

func main() {
	url := "https://fleet.yandex.ru/api/fleet/fleet-leads-crm/v1/reports/life-time-value/source/side-card"
	payload := []byte(`{"date_period":{"from":"2026-04-07","to":"2026-05-06"},"source_id":"partners_driver_selfreg"}`)
	req, _ := http.NewRequest("POST", url, bytes.NewBuffer(payload))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept-Language", "ru")
	req.Header.Set("X-Park-ID", "db43edfb8d0246aab01a4e21a37c050a")
	req.Header.Set("Cookie", "Session_id=3:1740683050.5.0.1738743126839:rZgUww:cd.1.2:1|358988582.0.2.3:1738743126|3:10332857.917173.K7B4R_X-eRj5lQ1FzBvPjB0k82g")
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	defer resp.Body.Close()
	body, _ := ioutil.ReadAll(resp.Body)
	fmt.Println("Status:", resp.Status)
	fmt.Println("Body:", string(body))
}
