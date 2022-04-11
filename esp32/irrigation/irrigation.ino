#include "ArduinoJson.h"
#include "BluetoothSerial.h"
#include "Wire.h"
#include "RTClib.h"
#include "Preferences.h"
#include "time_e.h"
#include "HTTPClient.h"

const char *ssid = "Airtel_9762463995";
const char *password = "air41573";

RTC_DS1307 rtc;
BluetoothSerial SerialBT;
StaticJsonDocument<200> doc;
Preferences prefs;

const byte relay1 = 12;
// const byte relay2 = 14;

TimeE currentTime, startAt, stopAt;
TimeE clockUpdateAt(17, 30, 0), clockUpdateBefore(17, 30, 5); // update clock between 5:30:00pm - 5:30:05pm

void setup() {
  Serial.begin(115200);
  SerialBT.begin("RKDevice"); // Bluetooth device name
  Serial.println("The device started, now you can pair it with bluetooth!");
  if (!rtc.begin())
  {
    Serial.println("Couldn't find RTC");
    SerialBT.println("Couldn't find RTC");
    Serial.flush();
    return;
  }
  if (!rtc.isrunning())
  {
    Serial.println("RTC is not running!");
    SerialBT.println("RTC is not running!");
    getTime();
    //    return;
  }

  pinMode(relay1, OUTPUT);
  // pinMode(relay2, OUTPUT);

  prefs.begin("settings"); // use "schedule" namespace
  readPrefs();
}

void loop()
{
  DateTime now = rtc.now();
  currentTime.from(now);

  printTimer();
  checkTimer();

  readData();
  delay(1000);
}

void readData()
{
  if (SerialBT.available())
  {
    String data = SerialBT.readString();
    Serial.println(data);
    doc.clear();
    deserializeJson(doc, data);
    Serial.println("new config parsing");
    if (doc["data"] == 1)
    { // save new timer settings
      startAt.from(doc["from"].as<const char *>());
      stopAt.from(doc["to"].as<const char *>());

      savePrefs();
      Serial.println("new config saved");

      doc.clear();
      doc["data"] = 1;
      doc["from"] = startAt.toString();
      doc["to"] = stopAt.toString();
      String output = "";
      serializeJson(doc, output);
      SerialBT.println(output);
      doc.clear();
    }
    else if (doc["data"] == 2)
    { // read timer settings
      doc.clear();
      doc["data"] = 2;
      doc["from"] = startAt.toString();
      doc["to"] = stopAt.toString();
      String output = "";
      serializeJson(doc, output);
      SerialBT.println(output);
      doc.clear();
    }
    else if (doc["data"] == 3) {
      int year, month, date, hour, minute, second;
      sscanf(doc["time"], "%d:%d:%d:%d:%d:%d", &year, &month, &date, &hour, &minute, &second);
      rtc.adjust(DateTime(year, month, date, hour, minute, second));
      Serial.println("new time saved");

      doc.clear();
      doc["data"] = 3;
      String output = "";
      serializeJson(doc, output);
      SerialBT.println(output);
      doc.clear();
    }
  }
}

void printTimer()
{
  currentTime.print();
  Serial.print('\t');
  startAt.print();
  Serial.print('\t');
  stopAt.print();
  Serial.print('\t');
}

void checkTimer() {
  if (currentTime.toString() == "00:00:00") {
    getTime();
  }
  if (currentTime.isCrossed(startAt) && !currentTime.isCrossed(stopAt))
  {
    Serial.println("started");
    digitalWrite(relay1, HIGH);
    // digitalWrite(relay2, LOW);
  }
  else
  {
    Serial.println("stopped");
    digitalWrite(relay1, LOW);
    // digitalWrite(relay2, HIGH);
  }

  if (currentTime.isCrossed(clockUpdateAt) && !currentTime.isCrossed(clockUpdateBefore)) {
    getTime();
  }
}

void savePrefs()
{
  prefs.putBytes("startAt", &startAt, sizeof(TimeE));
  prefs.putBytes("stopAt", &stopAt, sizeof(TimeE));
}

void readPrefs()
{
  prefs.getBytes("startAt", &startAt, sizeof(TimeE));
  prefs.getBytes("stopAt", &stopAt, sizeof(TimeE));
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
