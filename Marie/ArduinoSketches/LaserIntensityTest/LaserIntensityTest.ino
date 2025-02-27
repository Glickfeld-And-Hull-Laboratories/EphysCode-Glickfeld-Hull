
// this constant won't change:
const int ledPin = 10;       // the pin that the LED is attached to
const int M = 133;

void setup() {
  // initialize the LED as an output:
  pinMode(ledPin, OUTPUT);
  // initialize serial communication:
   Serial.begin(9600);
}

void setup() {
 delay(10000);
    digitalWrite(ledPin, LOW);   // turn the LED on (HIGH is the voltage level)
 for (int m = 1; m < M+1; m ++) {
digitalWrite(ledPin, LOW);   // turn the LED on (HIGH is the voltage level)
  delay(10);                       // wait for a second
  digitalWrite(ledPin, LOW);    // turn the LED off by making the voltage LOW
  delay(20);
      }
        exit(0);
}


//
//// the loop function runs over and over again forever
//void loop() {
//   delay(10000);
//    digitalWrite(ledPin, LOW);   // turn the LED on (HIGH is the voltage level)
// for (int m = 1; m < M+1; m ++) {
//digitalWrite(ledPin, LOW);   // turn the LED on (HIGH is the voltage level)
//  delay(10);                       // wait for a second
//  digitalWrite(ledPin, LOW);    // turn the LED off by making the voltage LOW
//  delay(20);
//      }
//    }
