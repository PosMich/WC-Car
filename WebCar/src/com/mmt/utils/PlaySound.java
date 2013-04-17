package com.mmt.utils;


import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.util.Log;


public class PlaySound {
	public class InvalidFrequencyException extends Exception {
		public InvalidFrequencyException() {	
		}
		public InvalidFrequencyException(String s) {
			super(s);
		}
		
	}
	
	private int maxFreq;
    private int sampleRate;

    private AudioTrack track = null;

    private int currFreq;
    
    private double sample[];
    private byte generatedSnd[];
    
	/*
	 * constructor
	 * 	
	 */
	public PlaySound() {
		sampleRate = AudioTrack.getNativeOutputSampleRate(AudioManager.STREAM_MUSIC);
		maxFreq = sampleRate/2;
		Log.d("PlaySound", "constructor called");
		Log.d("PlaySound", "sampleRate: "+sampleRate);
		Log.d("PlaySound", "maxFreq: "+maxFreq);
		
	}
	
	public void setFreq(int Freq) throws Exception {
		
		if (Freq > maxFreq)
			throw new InvalidFrequencyException("Frequency out of range!\nMax: "+maxFreq+"\ninput: "+Freq);
		
		if (Freq == currFreq)
			return;

		Log.d("PlaySound", "changing Freq to "+Freq);
		
		currFreq = Freq;
		
        int numSamples = (int) (((double)1/currFreq) * sampleRate);
        
        sample = new double[numSamples];
        generatedSnd = new byte[2 * numSamples];
    	
        // fill out the array
        for (int i = 0; i < numSamples; ++i) {
            sample[i] = Math.sin(2 * Math.PI * i / (sampleRate/currFreq));
        }

        short val;
        for (int i = 0; i<sample.length; ) {
            // max 
            val = (short) ((sample[i] * 32767));
            
            // in 16 bit wav PCM, first byte is the low order byte
            generatedSnd[i++] = (byte) (val & 0x00ff);
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
		Log.d("PlaySound", "stopping");
		if (track == null)
			return;
		track.pause();
		track.stop();
		track.release();
		track = null;
	}
}