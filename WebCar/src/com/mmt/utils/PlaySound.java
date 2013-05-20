package com.mmt.utils;


import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.util.Log;


public class PlaySound {
	
	private static PlaySound playSound = null;
	
	public class InvalidFrequencyException extends Exception {
		public InvalidFrequencyException() {	
		}
		public InvalidFrequencyException(String s) {
			super(s);
		}	
	}
	
	private final String TAG = "PlaySound";
	// send this to show valid controll cmds
	private final int Freqwatchdog = 4321;
	
	private int maxFreq;
    private int sampleRate;

    private AudioTrack track = null;

    private int currFreq;

    private double samples[];
    private double sample[];
    private double samplesRight[];
    private double samplesLeft[];
    private byte generatedSnd[];
    
    
	/*
	 * constructor
	 * 	
	 */
	private PlaySound() {
		sampleRate = AudioTrack.getNativeOutputSampleRate(AudioManager.STREAM_MUSIC);
		maxFreq = sampleRate/2;
		Log.d(TAG, "constructor called");
		Log.d(TAG, "sampleRate: "+sampleRate);
		Log.d(TAG, "maxFreq: "+maxFreq);
	}
	
	public static PlaySound getInstance(){
		// Singleton :)
		if (playSound == null)
			playSound = new PlaySound();
		return playSound;
	}
	
	public void setFreq(int Freq) throws InvalidFrequencyException {
		
		if (Freq > maxFreq)
			throw new InvalidFrequencyException("Frequency out of range!\nMax: "+maxFreq+"\ninput: "+Freq);
		
		if (Freq == currFreq)
			return;

		Log.d(TAG, "changing Freq to "+Freq);
		
		currFreq = Freq;
		currFreq = 3333;

		int numSamples = (int) (((double)1/currFreq)* sampleRate);
        
        sample = new double[numSamples];
        generatedSnd = new byte[2 * numSamples];
    	
        // fill out the array
        for (int i = 0; i < numSamples; ++i) {
            sample[i] = Math.sin(2 * Math.PI * i / (sampleRate/currFreq));
        }
        for (int i = 0; i < numSamples; ++i) {
            samples[i] = Math.sin(2 * Math.PI * i / (sampleRate/Freqwatchdog));
        }

        short val, val2;
        for (int i = 0; i<sample.length; ) {
            // max 
            val = (short) ((sample[i] * 32767));
            val2 = (short) ((sample[i] * 32767));
            
            // in 16 bit wav PCM, first byte is the low order byte
            generatedSnd[i++] = (byte) (val & 0x00ff);
            //generatedSnd[i++] = (byte) ((val & 0xff00) >>> 8);
            //generatedSnd[i++] = (byte) (val2 & 0x00ff);
            generatedSnd[i++] = (byte) ((val & 0xff00) >>> 8);
        }
        
        if (track != null) {
    		track.pause();
    		track.stop();
        	track.release();
    	}
    	
        track = new AudioTrack(AudioManager.STREAM_MUSIC,
                sampleRate, AudioFormat.CHANNEL_OUT_MONO,
                AudioFormat.ENCODING_PCM_16BIT, generatedSnd.length,
                AudioTrack.MODE_STATIC);

        track.write(generatedSnd, 0, generatedSnd.length);

        track.setLoopPoints(0, generatedSnd.length/2, -1);
        
        track.play();
	}
	
	public void start(int Freq) throws Exception {
		setFreq(Freq);
	}
	
	public void stop() {
		Log.d(TAG, "stopping");
		if (track == null)
			return;
		track.pause();
		track.stop();
		track.release();
		track = null;
	}
}