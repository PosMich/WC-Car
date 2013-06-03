#include "WebCar2.h"
#include "FreqCount/FreqCount.h"


/*
 *                  r/l fwd/bwd
 * min Frequency:    01   100 (left, backward)
 * max Frequency:    20   900 (right, forward)
 * stop Frequency:   10   500
 *
 */

/* Boundaries Input Frequency */
#define BWD_FREQVAL 100
#define FWD_FREQVAL 900
#define R_FREQVAL 19
#define L_FREQVAL 2


/* Boundaries Arduino PWM*/
#define FB_MIN 0
#define FB_MAX 10	//120
#define RL_MIN 0
#define RL_MAX 100 //255


#define RL_BOUNDARY(val) (RL_MIN+val*(RL_MAX-RL_MIN))
#define FB_BOUNDARY(val) (FB_MIN+val*(FB_MAX-FB_MIN))


/* Variables for frequency calculation */
unsigned long risingEdges = 0;
int frequency   = 0;
int fwdbwd = 0;
int rightleft = 0;
int fb_divisor = (FWD_FREQVAL-BWD_FREQVAL)/2;
int rl_divisor = (R_FREQVAL-L_FREQVAL)/2;
static int countGate = 20; //ms

/* PWM & Interrupt stuff */
bool endOfPeriodIsrActive = false;
int valTimer = 0;
int valRL = 256;
int valFB = 256;
void initPWM();
void startPWM();
void setPWM( bool r2l, float val );


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


void setup()
{
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
//	initPWM();
//	uint8_t status = SREG;
//	cli();
//	startPWM();
//	SREG = status;

	enableRight();
	enableFwd();
	//FreqCount.begin(countGate);
}


void loop()
{

/*
	if ( FreqCount.available()) {
		risingEdges = FreqCount.read();

		frequency = (double) (risingEdges / ( (double) countGate/1000));

		// frequency = xxyyy Hz
		rightleft = frequency / 1000; // get first 2 digits xx
		fwdbwd    = frequency % 1000; // get last 3 digits  yyy

		// keep everything in boundaries
		if ( rightleft > R_FREQVAL )
			rightleft = R_FREQVAL;
		else if ( rightleft < L_FREQVAL)
			rightleft = L_FREQVAL;

		if ( fwdbwd > FWD_FREQVAL )
			fwdbwd = FWD_FREQVAL;
		else if ( fwdbwd < BWD_FREQVAL)
			fwdbwd = BWD_FREQVAL;

		steer(-1+ (fwdbwd-BWD_FREQVAL)/fb_divisor);
		move(-1+ (rightleft-L_FREQVAL)/rl_divisor);

	}
*/
	//steer(1);
	//move(1);
	digitalWrite(PIN_PWM_RL,HIGH);
	digitalWrite(PIN_PWM_FB,HIGH);
//
//	for (int i=0; i<200000; i++)
//		asm volatile("nop");
//
//	digitalWrite(PIN_PWM_RL,LOW);
//	digitalWrite(PIN_PWM_FB,LOW);
//
//	for (int i=0; i<20000; i++)
//		asm volatile("nop");
  	/*
  	 r -> l takes 4x, --> 0.1+4*0.05 = 0.3
  	 	 --> means, that between -0.3 and 0.3
  	 	 	 the steering is in the middle

	 f -> b takes 3x, --> 0.0+3x0.05 = 0.15
		--> means, that between -0.15 and 0.15 it stops
  	*/

}


void steer( float val ) {
	if ( val==0 )
		middle();

	else if ( val<0 )
		steerRL(false, RL_BOUNDARY(-1*val));
	else
		steerRL(true, RL_BOUNDARY(val));
}

void move( float val ) {
	if ( val==0 )
		stop();
	else if ( val<0 )
		moveFB(false, FB_BOUNDARY(-1*val));
	else
		moveFB(true, FB_BOUNDARY(val));
}

void steerRL( bool right, int val ) {
	if ( val > RL_MAX )
		val = RL_MAX;
	else if ( val < RL_MIN )
		val = RL_MIN;

	if (right)
		enableRight();
	else
		enableLeft();

	//delay(50);
	//PWM_RL(val);
	setPWM( true, val );
}

void moveFB( bool forward, int val ) {
	if ( val > FB_MAX )
		val = FB_MAX;
	else if ( val < FB_MIN )
		val = FB_MIN;

	if (forward)
		enableFwd();
	else
		enableBwd();

	//delay(50);
	//PWM_FB(val);
	setPWM( false, val );
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
}
void stop() {
	DIS_FWD;
	DIS_BWD;
}

void initPWM() {
	sei();
	TCCR0A = 0b00000000;
	TCCR0B = 0b00000000;
	OCR0A  = 1; // Enable Ticker Interrupt
	OCR0B  = 148; // End of Period (148 Ticks)

	TCNT0  = 0b00000000; // Reset Counter Register
	TIFR0  = 0b00000111; // Clear Interrupt flags
}

void startPWM() {
	TCCR0B = 0b00000100;// Prescaler 256 --> 31250 Hz
	TIMSK0 = 0b00000111; // Enable A,B Interrupts

}

void stopPWM() {
	TCCR0B = 0;
	TIMSK0 = 0;
}

void setPWM( bool r2l, float val ) {
	// 0 ... 1
	// 0 ... 148
	if (r2l)
		valRL = 148*val;
	else
		valFB = 148*val;
}

//ISR(TIMER0_COMPA_vect) {
//	if ( !endOfPeriodIsrActive ) {
//		valTimer = TCNT0;
//		if ( valTimer == valRL )
//			digitalWrite( PIN_PWM_RL, LOW);
//
//		if ( valTimer == valFB )
//			digitalWrite( PIN_PWM_FB, LOW);
//	}
//}
//
//ISR(TIMER0_COMPB_vect) {
//	endOfPeriodIsrActive = true;
//	digitalWrite( PIN_PWM_RL, HIGH );
//	digitalWrite( PIN_PWM_FB, HIGH );
//	endOfPeriodIsrActive = false;
//}
//
//
