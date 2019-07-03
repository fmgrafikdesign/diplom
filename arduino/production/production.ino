int mode = 3; // 0 for production, 1 for analog read, 2 for digital read, 3 for mass analog read

// A beam structure. pin is the assigned pin, hit wether the pin is hit by a laser or not.
typedef struct {
  int pin;
  bool hit = 0;
} beam;

// Quick implementation to get the size of an array
#define ARRAYSIZE(x)  (sizeof(x) / sizeof(x[0]))

// The pins we can use to check for lasers
// Taking 20 and 21 out for now because they're the SDA and SCL pins and I haven't found out how to tame them yet.
// Taking out 13 as well because it's the LED pin and it appears to always be HIGH except when programatically set to LOW...
int sensorPins[] = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12,/*13,*/14, 15, 16, 17, 18, 19,/*20,21,*/22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53};

// A construct of pin value pairs.
beam sensors[ ARRAYSIZE(sensorPins)];

int sensorValue = 0; // variable to store the value coming from the sensor
int previousValue = 0; // variable to store the value

// Intensity is a measurement of how many beams are interrupted over a set of time. It increases as beams get interrupted and normalizes to 0 over time.
// THIS IS CURRENTLY HANDLED IN PROCESSING AND NOT USED HERE
int intensity = 0;
int increasePerInterrupt = 128;
int decreasePerLoop = 1;

void setup() {
  Serial.begin(19200); //sets serial port for communication
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(13, LOW);

  String debug;
  /*
    String debug = "byte-size of sensorPins: ";
    debug += sizeof (sensorPins);
    Serial.println(debug);

    debug = "byte-size of a single beam struct: ";
    debug += sizeof(beam);
    Serial.println(debug);
  */

  /*
    debug = "Amount of pins used for lasers: ";
    debug += ARRAYSIZE(sensorPins);
    Serial.println(debug);
  */

  // Initialize our sensor array with the used pins.
  int i = 0;
  for (i = 0; i < ARRAYSIZE(sensors); i++) {
    sensors[i].pin = sensorPins[i];
  }
}


void loop() {

  if (mode == 1) {
    sensorValue = analogRead(A3);
    Serial.println(sensorValue);

  } else if (mode == 2) {
    sensorValue = digitalRead(3);
  }
  else if (mode == 0) {

    // Loop through our sensor array
    int i = 0;
    for (i = 0; i < ARRAYSIZE(sensors); i++) {

      // Store the previous hit value of the sensor
      previousValue = sensors[i].hit;

      // Read the current value of the pin. 1 means hit, 0 means not hit by laser.
      sensorValue = digitalRead(sensors[i].pin);

      // Store the current value of the pin in the hit property.
      sensors[i].hit = sensorValue;

      // Debug String variable
      String debug;

      // If the beam is interruped and was not interrupted before, do something.
      if (sensorValue == 0 && previousValue != sensorValue) {

        //DEBUG
        //String debug = String("Value on pin ") + sensors[i].pin + " changed from " + previousValue  + " to " + sensorValue;
        //Serial.println(debug);

        Serial.println(sensors[i].pin);

      }
    }
  }
  else if (mode == 3) {
    // Loop through our sensor array

    //String value = String(analogRead(0)) + "," + String(analogRead(1)) + "," + String(analogRead(2)) + "," + String(analogRead(3)) + "," + String(analogRead(4)) + "," + String(analogRead(5)) + "," + String(analogRead(6)) + "," + String(analogRead(7)) + "," + String(analogRead(8)) + "," + String(analogRead(9)) + "," + String(analogRead(10)) + "," + String(analogRead(11)) + "," + String(analogRead(12)) + "," + String(analogRead(13)) + "," + String(analogRead(14)) + "," + String(analogRead(15));
    String value2 = String(analogRead(0)) + "," + String(analogRead(1)) + "," + String(analogRead(2)) + "," + String(analogRead(3)) + "," + String(analogRead(4)) + "," + String(analogRead(5)) + "," + String(analogRead(6)) + "," + String(analogRead(7)) + "," + String(analogRead(8)) + "," + String(analogRead(9)) + "," + String(analogRead(10)) + "," + String(analogRead(11)) + "," + String(analogRead(12)) + "," + String(analogRead(13)) + "," + String(analogRead(14)) + "," + String(analogRead(15));
    Serial.println(value2);

  }
  delay(50);

}
