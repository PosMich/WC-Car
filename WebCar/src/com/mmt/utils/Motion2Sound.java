
package com.mmt.utils;

import android.util.Log;

import com.mmt.utils.PlaySound;

public class Motion2Sound {
	public class InvalidFrequencyException extends Exception {
		public InvalidFrequencyException() {	
		}
		public InvalidFrequencyException(String s) {
			super(s);
		}	
	}
	
	/*********************** variables ***********************/
	
	private static final String TAG = "Motion2Sound"; 
	
	/* boundaries --> drive left */
	private int minFreqLeft;
	private int maxFreqLeft;
	
	/* boundaries --> drive right */
	private int minFreqRight;
	private int maxFreqRight;

	/* boundaries --> drive forward */
	private int minFreqFwd;
	private int maxFreqFwd;
	
	/* boundaries --> drive backward */
	private int maxFreqBwd;
	private int minFreqBwd;
	
	/* drive straight Frequency */
	private int straightFreq;
	
	/* stop Frequency */
	private int stopFreq;
	
	/* playSound */
	private static final PlaySound myPlaySound = PlaySound.getInstance();
	
	
	/****************** constructor *******************/
	/* constructor */
	public Motion2Sound(int minFreqLeft, 
			int maxFreqLeft,
			int minFreqRight,
			int maxFreqRight, 
			int minFreqBwd,
			int maxFreqBwd,
			int minFreqFwd, 
			int maxFreqFwd, 
			int straightFreq,
			int stopFreq) throws InvalidFrequencyException {
		
		this.setMinFreqLeft(minFreqLeft);
		this.setMaxFreqLeft(maxFreqLeft);
		
		this.setMinFreqRight(minFreqRight);
		this.setMaxFreqRight(maxFreqRight);
		
		this.setMinFreqFwd(minFreqFwd);
		this.setMaxFreqFwd(maxFreqFwd);
		
		this.setMinFreqBwd(minFreqBwd);
		this.setMaxFreqBwd(maxFreqBwd);

		this.setStraightFreq(straightFreq);
		this.setStopFreq(stopFreq);
	}
	
	
	
	public void drive(double left2right, double bwd2fwd) throws Exception {
		Log.d("Motion2Sound","l2r: "+left2right+" |b2f: "+bwd2fwd);
		int b2f = getFreqbwd2fwd(bwd2fwd);
		int l2r = getFreqlft2rght(left2right);
		Log.d(TAG, "bwd2fwd: "+b2f);
		Log.d(TAG, "left2right: "+l2r);
		
		myPlaySound.setFreq( l2r+b2f );
	}
	

	/****************** private functions *******************/
	private int getFreqlft2rght(double l2r) {
		if (l2r > 0) {
			/* keep in boundaries */
			if (l2r > 1) 
				l2r = 1;
			
			/* drive right */
			return (int) (minFreqRight+l2r*(maxFreqRight-minFreqRight))/1000*1000;
			
		} else if (l2r < 0) {
			/* keep in boundaries */
			if (l2r < -1) 
				l2r = -1;
			
			/* drive left */
			return (int) (maxFreqLeft+l2r*(maxFreqLeft-minFreqLeft))/1000*1000;
		} else {
			/* drive straight */
			return straightFreq;
		}
	}
	
	private int getFreqbwd2fwd(double b2f) {
		if (b2f > 0) {
			/* keep in boundaries */
			if (b2f > 1) 
				b2f = 1;
			
			/* drive forward */
			return (int) (minFreqFwd+b2f*(maxFreqFwd-minFreqFwd));
			
		} else if (b2f < 0) {
			/* keep in boundaries */
			if (b2f < -1) 
				b2f = -1;
			
			/* drive backward */
			return (int) (maxFreqBwd+b2f*(maxFreqBwd-minFreqBwd));
		} else {
			/* stop */
			return stopFreq;
		}
	}
	
	

	/****************** getter/setter *******************/
	
	public int getMinFreqLeft() {
		return minFreqLeft;
	}

	public void setMinFreqLeft(int minFreqLeft) {
		this.minFreqLeft = minFreqLeft;
	}

	public int getMaxFreqLeft() {
		return maxFreqLeft;
	}

	public void setMaxFreqLeft(int maxFreqLeft) {
		this.maxFreqLeft = maxFreqLeft;
	}

	public int getMinFreqRight() {
		return minFreqRight;
	}

	public void setMinFreqRight(int minFreqRight) {
		this.minFreqRight = minFreqRight;
	}

	public int getMaxFreqRight() {
		return maxFreqRight;
	}

	public void setMaxFreqRight(int maxFreqRight) {
		this.maxFreqRight = maxFreqRight;
	}

	public int getMinFreqFwd() {
		return minFreqFwd;
	}

	public void setMinFreqFwd(int minFreqFwd) {
		this.minFreqFwd = minFreqFwd;
	}

	public int getMaxFreqFwd() {
		return maxFreqFwd;
	}

	public void setMaxFreqFwd(int maxFreqFwd) {
		this.maxFreqFwd = maxFreqFwd;
	}

	public int getMaxFreqBwd() {
		return maxFreqBwd;
	}

	public void setMaxFreqBwd(int maxFreqBwd) {
		this.maxFreqBwd = maxFreqBwd;
	}

	public int getMinFreqBwd() {
		return minFreqBwd;
	}

	public void setMinFreqBwd(int minFreqBwd) {
		this.minFreqBwd = minFreqBwd;
	}

	public int getStopFreq() {
		return stopFreq;
	}

	public void setStopFreq(int stopFreq) {
		this.stopFreq = stopFreq;
	}

	public int getStraightFreq() {
		return straightFreq;
	}

	public void setStraightFreq(int straightFreq) {
		this.straightFreq = straightFreq;
	}
	
	public void stop() {
		myPlaySound.stop();
	}
}
