#include "WiFi.h"
#include "time.h"
#include "Wire.h"
#include "RTClib.h"
#include "HTTPClient.h"
#include "ArduinoJson.h"

const char *ssid = "Airtel_9762463995";
const char *password = "air41573";

RTC_DS1307 rtc;
StaticJsonDocument<200> doc;

void setup() {
  Serial.begin(115200);

  if (!rtc.begin()) {
    Serial.println("Couldn't find RTC");
    return;
  }
  if (!rtc.isrunning()) {
    Serial.println("RTC is not running!");
    getTime();
  }
}

void loop() {
  DateTime now = rtc.now();

  
  char buf1[] = "hh:mm:ss";
  Serial.println(now.toString(buf1));

  if(now.toString(buf1) == "17:55:00" || now.toString(buf1) == "17:55:01"){
    getTime();
  }
  
  char buf2[] = "YYMMDD-hh:mm:ss";
  Serial.println(now.toString(buf2));

  char buf3[] = "Today is DDD, MMM DD YYYY";
  Serial.println(now.toString(buf3));

  char buf4[] = "MM-DD-YYYY";
  Serial.println(now.toString(buf4));

  delay(1000);
}

void getTime() {

  // Connect to Wi-Fi
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected.");

  HTTPClient http;
  http.begin("http://worldtimeapi.org/api/timezone/Asia/Kolkata"); //HTTP
  int httpCode = http.GET();

  if (httpCode > 0) {
    if (httpCode == HTTP_CODE_OK) {
      String payload = http.getString();
      Serial.println(payload);

      StaticJsonDocument<16> filter;
      filter["datetime"] = true;
      DeserializationError error = deserializeJson(doc, payload, DeserializationOption::Filter(filter));
      if (!error) {
        const char* datetime = doc["datetime"]; // "2022-04-04T16:04:00.008773+05:30"

        int year, month, date, hour, minute, second;
        sscanf(datetime, "%d-%d-%dT%d:%d:%d.", &year, &month, &date, &hour, &minute, &second);
        rtc.adjust(DateTime(year, month, date, hour, minute, second));
        Serial.println("new time saved");

        Serial.println(datetime);
      } else {
        Serial.print("deserializeJson() failed: ");
        Serial.println(error.c_str());
        return;
      }
    }
  } else {
    Serial.printf("[HTTP] GET... failed, error: %s\n", http.errorToString(httpCode).c_str());
  }

  http.end();

  // disconnect WiFi as it's no longer needed
  WiFi.disconnect(true);
  WiFi.mode(WIFI_OFF);
}
