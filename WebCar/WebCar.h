// Only modify this file to include
// - function definitions (prototypes)
// - include files
// - extern variable definitions
// In the appropriate section

#ifndef WebCar_H_
#define WebCar_H_
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
#define PIN_PWM_RL   7
#define PIN_PWM_FB   8


/* Boundaries Input Frequency */
#define BWD_FREQVAL 100
#define FWD_FREQVAL 900
#define R_FREQVAL 19
#define L_FREQVAL 2


/* Boundaries Arduino PWM*/
#define FB_MIN 0
#define FB_MAX 50	//120
#define RL_MIN 0
#define RL_MAX 255 //255

#define RL_BOUNDARY(val) (double)(RL_MIN+val*(RL_MAX-RL_MIN))
#define FB_BOUNDARY(val) (double)(FB_MIN+val*(FB_MAX-FB_MIN))


// Macros for enabling(=LOW)/disabling(=HIGH) Pins
#define EN_RIGHT 	digitalWrite(PIN_EN_RIGHT, LOW)
#define DIS_RIGHT 	digitalWrite(PIN_EN_RIGHT, HIGH)
#define EN_LEFT 	digitalWrite(PIN_EN_LEFT, LOW)
#define DIS_LEFT 	digitalWrite(PIN_EN_LEFT, HIGH)
#define EN_FWD 		digitalWrite(PIN_EN_FWD, LOW)
#define DIS_FWD 	digitalWrite(PIN_EN_FWD, HIGH)
#define EN_BWD 		digitalWrite(PIN_EN_BWD, LOW)
#define DIS_BWD 	digitalWrite(PIN_EN_BWD, HIGH)


void steer( float val );
void move( float val );

void steerRL( bool right, int val ); 	// -1 left 0 right 1
void moveFB( bool forward, int val );	// -1 bwd  0  fwd  1

void enableRight();
void enableLeft();
void enableFwd();
void enableBwd();
void middle();
void stop();


void initPWM();
void startPWM();
void setPWM( bool r2l, float val );

//Do not add code below this line
#endif /* WebCar_H_ */
