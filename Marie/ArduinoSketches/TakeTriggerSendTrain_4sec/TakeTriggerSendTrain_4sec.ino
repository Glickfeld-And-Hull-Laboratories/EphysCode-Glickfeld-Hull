
// this constant won't change:
const int  buttonPin = 2;    // the pin that the pushbutton is attached to
const int ledPin = 10;       // the pin that the LED is attached to
const int M = 133;

// Variables will change:
// int buttonPushCounter = 0;   // counter for the number of button presses
int buttonState = 0;         // current state of the button
int lastButtonState = 0;     // previous state of the button

void setup() {
  // initialize the button pin as a input:
  pinMode(buttonPin, INPUT);
  // initialize the LED as an output:
  pinMode(ledPin, OUTPUT);
  // initialize serial communication:
   Serial.begin(9600);
}

// the loop function runs over and over again forever
void loop() {
  // read the pushbutton input pin:
  if (digitalRead(buttonPin)) {
    digitalWrite(ledPin, HIGH);   // turn the LED on (HIGH is the voltage level)
 for (int m = 1; m < M+1; m ++) {
digitalWrite(ledPin, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(10);                       // wait for a second
  digitalWrite(ledPin, LOW);    // turn the LED off by making the voltage LOW
  delay(20);
      }
          // Delay a little bit to avoid bouncing
    delay(10);
    }
//exit(0);
}
