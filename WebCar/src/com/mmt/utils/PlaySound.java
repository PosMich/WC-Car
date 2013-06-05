package com.mmt.utils;

import android.app.Activity;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.os.Handler;
import android.util.Log;


public class PlaySound extends Activity {
	
	private static PlaySound playSound = null;
	
	public class InvalidFrequencyException extends Exception {
		public InvalidFrequencyException() {	
		}
		public InvalidFrequencyException(String s) {
			super(s);
		}

	}
	
	private final String TAG = "PlaySound";
	
	private final int duration = 1;
	private final int sampleRate = 44100;
	private final int numSamples = (duration*sampleRate);
	private final double sample[] = new double[numSamples];
	private double freqOfTone = 10500;
	private AudioTrack track;
	
	private byte generatedSnd[] = new byte[2*numSamples];
	/*
	 * constructor
	 * 	
	 */
	private PlaySound() {
		Log.d(TAG, "constructor called");
	}
	
	public static PlaySound getInstance() {
		// Singleton :)
		if (playSound == null) {
			playSound = new PlaySound();
		}
		return playSound;
	}

	public void setFreq(int Freq) throws Exception {
		Log.d(TAG, "changing freq to: "+Freq);
		freqOfTone = Freq;
		genTone();
		playSound();
	}
	
	void genTone() {
		for ( int i=0; i<numSamples; ++i)
			sample[i] = Math.sin( 2*Math.PI*i/( sampleRate/freqOfTone ) );
		
		int idx = 0;
		for ( final double dVal : sample ) {
			final short val = (short) ((dVal*32767));
			
			generatedSnd[idx++] = (byte) (val & 0x00ff);
			generatedSnd[idx++] = (byte) (val & 0xff00);
		}
	}
	
	void playSound() {
		stop();
		
		track = new AudioTrack(AudioManager.STREAM_MUSIC,
					sampleRate, AudioFormat.CHANNEL_OUT_MONO,
					AudioFormat.ENCODING_PCM_16BIT, generatedSnd.length,
					AudioTrack.MODE_STATIC);
		
		track.write(generatedSnd, 0, generatedSnd.length);
		track.setStereoVolume(1, 1);
		track.setLoopPoints(0, generatedSnd.length/2, -1);
        
		track.play();
	}

	public void start(int Freq) throws Exception {
		setFreq(Freq);
	}

	public void stop() {
		if (track == null)
			return;
		track.pause();
		track.stop();
		track.release();
		track = null;
	}
	
	
}