#define DEBUG

#ifdef DEBUG
#include "HardwareSerial.h"
#endif

#include "WebCar.h"
#include "FreqCount/FreqCount.h"


/*
 *                  r/l fwd/bwd
 * min Frequency:    01   100 (left, backward)
 * max Frequency:    20   900 (right, forward)
 * stop Frequency:   10   500
 *
 * Attention: Cause Timer0 is overwritten, a lot Arduino features (Serial Interface,
 * millis, ...) can't be used!!!
 */




/* Variables for frequency calculation */
unsigned long risingEdges = 0;
int frequency   = 0;
int fwdbwd = 0;
int rightleft = 0;
double fb_divisor = (double)( (FWD_FREQVAL-BWD_FREQVAL)/2 );
double rl_divisor = (double)( (R_FREQVAL-L_FREQVAL)/2 );
int stopVal = (BWD_FREQVAL+(FWD_FREQVAL-BWD_FREQVAL)/2);
static int countGate = 20; //ms


/* PWM & Interrupt stuff */
bool RL_OFF = true;
bool FB_OFF = true;



void setup()
{
#ifndef DEBUG
	/* set Pins to OUTPUT */
	pinMode(PIN_EN_RIGHT, OUTPUT);
	pinMode(PIN_EN_LEFT, OUTPUT);
	pinMode(PIN_EN_FWD, OUTPUT);
	pinMode(PIN_EN_BWD, OUTPUT);

	pinMode(PIN_PWM_RL, OUTPUT);
	pinMode(PIN_PWM_FB, OUTPUT);


	/* disable all Pins */
	steer( 0 );
	move( 0 );

	/* enable Frequency Counter */
	initPWM();
	uint8_t status = SREG;
	cli();
	startPWM();
	SREG = status;

#endif

#ifdef DEBUG
	Serial.begin(115200);
	Serial.println("Hallo!");
#endif


	FreqCount.begin(countGate);
}


void loop()
{

	if ( FreqCount.available()) {
		risingEdges = FreqCount.read();

		frequency = (double) (risingEdges / ( (double) countGate/1000));

		if (frequency == 0) {
			steer(0);
			move(0);
			return;
		}

#ifdef DEBUG
		Serial.print("Freq: ");
		Serial.println(frequency);
		//Serial.println(risingEdges);
		//Serial.println(countGate);
#endif
		// frequency = xxyyy Hz
		rightleft = frequency / 1000; // get first 2 digits xx
		fwdbwd    = frequency % 1000; // get last 3 digits  yyy

#ifdef DEBUG
		Serial.print("r2l: ");
		Serial.print(rightleft);
		Serial.print(" f2b: ");
		Serial.println(fwdbwd);
#endif

		// keep everything in boundaries
		if ( rightleft > R_FREQVAL || rightleft < L_FREQVAL )
			rightleft = 10;

		if ( fwdbwd > FWD_FREQVAL+50 || fwdbwd < BWD_FREQVAL-50 )
			fwdbwd = 500;

		if ( fwdbwd > FWD_FREQVAL )
			fwdbwd = FWD_FREQVAL;
		else if ( fwdbwd < BWD_FREQVAL )
			fwdbwd = BWD_FREQVAL;

		if ( stopVal+50 > fwdbwd && fwdbwd > stopVal-50 )
			fwdbwd = stopVal;


#ifdef DEBUG
		Serial.print("After: r2l: ");
		Serial.print(rightleft);
		Serial.print(" f2b: ");
		Serial.println(fwdbwd);
#endif

		if (fwdbwd == 10)
			move(0);
		else
			move(-1+ (double)( (fwdbwd-BWD_FREQVAL)/(fb_divisor) ));

		if (rightleft == 500)
			steer(0);
		else
			steer(-1+ (double)( (rightleft-L_FREQVAL)/(rl_divisor) ));

	}

  	/*
  	 r -> l takes 4x, --> 0.1+4*0.05 = 0.3
  	 	 --> means, that between -0.3 and 0.3
  	 	 	 the steering is in the middle

	 f -> b takes 3x, --> 0.0+3x0.05 = 0.15
		--> means, that between -0.15 and 0.15 it stops
  	*/

}


void steer( float val ) {
#ifdef DEBUG
	Serial.print("steerVal: ");
	Serial.println(val);
#endif
	if ( val==0 ){
		steerRL(true,0);
	}else if ( val<0 ) {
#ifdef DEBUG
	Serial.print("steer: ");
	Serial.println(RL_BOUNDARY(-1*val));
#endif
		steerRL(false, RL_BOUNDARY(-1*val));
	} else {
#ifdef DEBUG
	Serial.print("steer: ");
	Serial.println(RL_BOUNDARY(val));
#endif
		steerRL(true, RL_BOUNDARY(val));
	}
}

void move( float val ) {
#ifdef DEBUG
	Serial.print("moveVal: ");
	Serial.println(val);
#endif
	if ( val==0 ) {
		moveFB(true,0);
	} else if ( val<0 ) {
#ifdef DEBUG
	Serial.print("move: ");
	Serial.println(FB_BOUNDARY(-1*val));
#endif
		moveFB(false, FB_BOUNDARY(-1*val));
	} else {
#ifdef DEBUG
	Serial.print("move: ");
	Serial.println(FB_BOUNDARY(val));
#endif
		moveFB(true, FB_BOUNDARY(val));
	}
}

void steerRL( bool right, int val ) {

	if ( val > RL_MAX )
		val = RL_MAX;
	else if ( val < RL_MIN ) {
		val = 0;
		middle();
		return;
	}

	if (right)
		enableRight();
	else
		enableLeft();

#ifdef DEBUG
	Serial.print("r2l Val: ");
	Serial.println(val);
#endif

#ifndef DEBUG
	setPWM( true, val );
#endif
}

void moveFB( bool forward, int val ) {
	if ( val > FB_MAX )
		val = FB_MAX;
	else if ( val < (FB_MIN/2) ){
		val = 0;
		stop();
		return;
	}

	if (forward)
		enableFwd();
	else
		enableBwd();

#ifdef DEBUG
	Serial.print("f2b Val: ");
	Serial.println(val);
#endif
#ifndef DEBUG
	setPWM( false, val );
#endif
}

void enableRight() {
	DIS_LEFT;
	EN_RIGHT;
}
void enableLeft() {
	DIS_RIGHT;
	EN_LEFT;
}
void enableFwd() {
	DIS_BWD;
	EN_FWD;
}
void enableBwd() {
	DIS_FWD;
	EN_BWD;
}
void middle() {
	DIS_RIGHT;
	DIS_LEFT;
	setPWM( true, 0 );
}
void stop() {
	DIS_FWD;
	DIS_BWD;
	setPWM( false, 0 );
}

void initPWM() {
	sei();
	TCCR0A = 0b00000000;
	TCCR0B = 0b00000100; // Prescaler 256 --> 31250 Hz --> overflow 122Hz

	TCNT0  = 0b00000000; // Reset Counter Register
	TIFR0  = 0b00000111; // Clear Interrupt flags
}

void startPWM() {
	TIMSK0 = 0b00000111; // Enable A,B,Overflow Interrupts
}

void stopPWM() {
	TCCR0B = 0;
	TIMSK0 = 0;
}

void setPWM( bool r2l, float val ) {

	if (r2l) {
		if ( val >= RL_MAX ) {
			RL_OFF = false;
			OCR0A = RL_MAX;
		} else if ( val <= RL_MIN ) {
			RL_OFF = true;
			digitalWrite( PIN_PWM_RL, LOW );
		} else {
			RL_OFF = false;
			OCR0A = val;
		}
	}
	else {
		if ( val >= FB_MAX ) {
			FB_OFF = false;
			OCR0B = FB_MAX;
		} else if ( val <= FB_MIN ) {
			FB_OFF = true;
			digitalWrite( PIN_PWM_RL, LOW );
		} else {
			FB_OFF = false;
			OCR0B = val;
		}
	}
	TCNT0 = 0;
}

#ifndef DEBUG
ISR(TIMER0_COMPA_vect) {
	if (!RL_OFF)
		digitalWrite( PIN_PWM_RL, LOW);
}

ISR(TIMER0_COMPB_vect) {
	if (!FB_OFF)
		digitalWrite( PIN_PWM_FB, LOW);
}

ISR(TIMER0_OVF_vect) {
	if (!RL_OFF)
		digitalWrite( PIN_PWM_RL, HIGH);

	if (!FB_OFF)
		digitalWrite( PIN_PWM_FB, HIGH);

}
#endif
