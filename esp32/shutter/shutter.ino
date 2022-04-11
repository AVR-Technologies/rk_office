//#include "ArduinoJson.h"
#include "BluetoothSerial.h"

BluetoothSerial SerialBT;
//StaticJsonDocument<200> doc;

const byte relay1 = 12;
const byte relay2 = 14;

//https://techtutorialsx.com/2018/12/10/esp32-arduino-serial-over-bluetooth-client-disconnection-event/
void callback(esp_spp_cb_event_t event, esp_spp_cb_param_t *param) {
  if (event == ESP_SPP_CLOSE_EVT ) {
    digitalWrite(relay1, LOW);
    digitalWrite(relay2, LOW);
    Serial.println("bluetooth disconnected: stop shutter");
  }
}
void setup() {
  Serial.begin(115200);
  SerialBT.begin("RKDevice:shutter"); //Bluetooth device name
  SerialBT.register_callback(callback);
  Serial.println("The device started, now you can pair it with bluetooth!");

  pinMode(relay1, OUTPUT);
  pinMode(relay2, OUTPUT);
}

void loop() {
  readData();
}
void readData() {
  if (int length = SerialBT.available()) {
    char buff[length];
    SerialBT.readBytes(buff, length);
    Serial.write(buff, length);
    if (length == 1) {
      switch (buff[0]) {
        case 'u':
          digitalWrite(relay1, HIGH);
          digitalWrite(relay2, LOW);
          Serial.println("up");
          break;
        case 'd':
          digitalWrite(relay1, LOW);
          digitalWrite(relay2, HIGH);
          Serial.println("down");
          break;
        default:
          digitalWrite(relay1, LOW);
          digitalWrite(relay2, LOW);
          Serial.println("stop");
      }
    } else {
      digitalWrite(relay1, LOW);
      digitalWrite(relay2, LOW);
      Serial.println("unknown data: stop shutter");
    }

    /*
        String data = SerialBT.readString();
        Serial.println(data);
        doc.clear();
        deserializeJson(doc, data);
        Serial.println("data parsing");
        if (doc["data"] == 3) {
          if (doc["status"] == "up") {
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
          } else if (doc["status"] == "down") {
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
          else if (doc["status"] == "stop") {
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
    */
  }
}
