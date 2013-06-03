// Only modify this file to include
// - function definitions (prototypes)
// - include files
// - extern variable definitions
// In the appropriate section

#ifndef WebCar_H_
#define WebCar_H_
#define WEBCAR
#include "Arduino.h"
//add your includes for the project WebCar here


//end of add your includes here
#ifdef __cplusplus
extern "C" {
#endif
void loop();
void setup();
#ifdef __cplusplus
} // extern "C"
#endif



// Pin Numbers
#define PIN_EN_RIGHT A3  //  green high --> disable, low --> enable
#define PIN_EN_LEFT  A2  //  yellow
#define PIN_EN_FWD   A1  //  red
#define PIN_EN_BWD   A0  //  orange
#define PIN_PWM_RL   2
#define PIN_PWM_FB   3

// Macros for enabling(=LOW)/disabling(=HIGH) Pins
#define EN_RIGHT 	digitalWrite(PIN_EN_RIGHT, LOW)
#define DIS_RIGHT 	digitalWrite(PIN_EN_RIGHT, HIGH)
#define EN_LEFT 	digitalWrite(PIN_EN_LEFT, LOW)
#define DIS_LEFT 	digitalWrite(PIN_EN_LEFT, HIGH)
#define EN_FWD 		digitalWrite(PIN_EN_FWD, LOW)
#define DIS_FWD 	digitalWrite(PIN_EN_FWD, HIGH)
#define EN_BWD 		digitalWrite(PIN_EN_BWD, LOW)
#define DIS_BWD 	digitalWrite(PIN_EN_BWD, HIGH)

// Macros for PWMs
#define PWM_RL(val)		analogWrite(PIN_PWM_RL, val)
#define PWM_FB(val)		analogWrite(PIN_PWM_FB, val)

//Do not add code below this line
#endif /* WebCar_H_ */
