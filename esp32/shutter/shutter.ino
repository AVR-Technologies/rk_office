#include "ArduinoJson.h"
#include "BluetoothSerial.h"

BluetoothSerial SerialBT;
StaticJsonDocument<200> doc;

const byte relay1 = 12;
const byte relay2 = 14;

void setup() {
  Serial.begin(115200);
  SerialBT.begin("RKDevice:shutter"); //Bluetooth device name
  Serial.println("The device started, now you can pair it with bluetooth!");

  pinMode(relay1, OUTPUT);
  pinMode(relay2, OUTPUT);
}

void loop() {
  readData();
  delay(1000);
}
void readData() {
  if (SerialBT.available()) {
    String data = SerialBT.readString();
    Serial.println(data);
    doc.clear();
    deserializeJson(doc, data);
    Serial.println("data parsing");
    if (doc["data"] == 3) { 
      if (doc["status"]=="up") {
        digitalWrite(relay1, HIGH);
        digitalWrite(relay2, LOW);
        Serial.println("shutter is opening");
        
        doc.clear();
        doc["data"] = 1;
        doc["message"] = "shutter is opening";
        String output = "";
        serializeJson(doc, output);
        SerialBT.println(output);
        doc.clear();
      } else if (doc["status"]=="down") {
        digitalWrite(relay1, LOW);
        digitalWrite(relay2, HIGH);
        Serial.println("shutter is closing");
        
        doc.clear();
        doc["data"] = 1;
        doc["message"] = "shutter is closing";
        String output = "";
        serializeJson(doc, output);
        SerialBT.println(output);
        doc.clear();
      }
       else if (doc["status"]=="stop") {
        digitalWrite(relay1, LOW);
        digitalWrite(relay2, LOW);
        Serial.println("shutter Stoped");
        
        doc.clear();
        doc["data"] = 1;
        doc["message"] = "shutter Stoped";
        String output = "";
        serializeJson(doc, output);
        SerialBT.println(output);
        doc.clear();
      }
    }
  }
}
