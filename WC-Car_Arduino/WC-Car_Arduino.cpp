// Do not remove the include below
#include "WC-Car_Arduino.h"

/*
 *
 * Audio max Frequency: ~22kHz
 *
 * Motor Control Signal:
 * 	200Hz PWM
 *
 * AUDIO Control Signal:
 * 	xx100 - xx400 Hz backward
 * 	xx600 - xx900 Hz forward
 * 	00xxx - 10xxx Hz left
 * 	11xxx - 20xxx Hz right
 * 	10500 Hz Standby
 *
 *	Tolerance: +/- 50Hz
 *
 *
 * OUT:
 *	EN_RC	enables radio control
 *	BWD		drive backward
 *	FWD		drive forward
 *	RGHT	drive right
 *	LFT		drive left
 *
 * IN:
 *	AUDIO	Uss 1.7V
 *
 */


//The setup function is called once at startup of the sketch
void setup()
{
// Add your initialization code here
}

// The loop function is called in an endless loop
void loop()
{
//Add your repeated code here
}
