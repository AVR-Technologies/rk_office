#include "ArduinoJson.h"
#include "BluetoothSerial.h"
#include "Wire.h"
#include "RTClib.h"
#include "Preferences.h"
#include "time_e.h"

RTC_DS1307 rtc;
BluetoothSerial SerialBT;
StaticJsonDocument<200> doc;
Preferences prefs;

const byte relay1 = 12;
const byte relay2 = 14;

TimeE currentTime, startAt, stopAt;

void setup() {
  Serial.begin(115200);
  SerialBT.begin("RKDevice"); //Bluetooth device name
  Serial.println("The device started, now you can pair it with bluetooth!");
  if (!rtc.begin()) {
    Serial.println("Couldn't find RTC");
    SerialBT.println("Couldn't find RTC");
    Serial.flush();
    return;
  }
  if (!rtc.isrunning()) {
    Serial.println("RTC is not running!");
    SerialBT.println("RTC is not running!");
    return;
  }

  pinMode(relay1, OUTPUT);
  pinMode(relay2, OUTPUT);
  
  prefs.begin("settings"); // use "schedule" namespace
  readPrefs();
}

void loop() {
  DateTime now = rtc.now();
  currentTime.from(now);

  printTimer();
  checkTimer();

  readData();
  delay(1000);
}
void readData() {
  if (SerialBT.available()) {
    String data = SerialBT.readString();
    Serial.println(data);
    doc.clear();
    deserializeJson(doc, data);
    Serial.println("new config  parsing");
    if (doc["data"] == 1) { //timer settings
      startAt.from(doc["at"].as<const char*>());
      stopAt.from(startAt);
      stopAt.add(TimeE(0, 1, 0));
      
      savePrefs();
      Serial.println("new config saved");
    }
  }
}
void printTimer() {
  currentTime.print();
  Serial.print('\t');
  startAt.print();
  Serial.print('\t');
  stopAt.print();
  Serial.print('\t');
}
void checkTimer() {
  if (currentTime.isCrossed(startAt) && !currentTime.isCrossed(stopAt) ) {
    Serial.println("started");
    digitalWrite(relay1, HIGH);
    digitalWrite(relay2, HIGH);
  } else {
    Serial.println("stopped");
    digitalWrite(relay1, LOW);
    digitalWrite(relay2, LOW);
  }
}
void savePrefs() {
  prefs.putBytes("startAt", &startAt, sizeof(TimeE));
  prefs.putBytes("stopAt", &stopAt, sizeof(TimeE));
}
void readPrefs() {
  prefs.getBytes("startAt", &startAt, sizeof(TimeE));
  prefs.getBytes("stopAt", &stopAt, sizeof(TimeE));
}
