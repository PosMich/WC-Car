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
	
	private final double duration = 0.5;
	private final int sampleRate = 44100;
	private final int numSamples = (int) (duration*sampleRate);
	private final double sample[] = new double[numSamples];
	private double freqOfTone = 10500;
	private AudioTrack Track;
	
	private final byte generatedSnd[] = new byte[2*numSamples];
	/*
	
	private int maxFreq;
    private int sampleRate;
    private int numSamples;

    private AudioTrack track = null;

    private int currFreq;
    
    private double sample[];
    private byte generatedSnd[];
    
    Handler handler = new Handler();
    */
    @Override
    protected void onResume() {
    	super.onResume();
    	/*
    	final Thread thread = new Thread(new Runnable() {
    		public void run() {
    			genTone();
    			handler.post(new Runnable() {
    				public void run() {
    					playSound();
    				}
    			});
    		}
    	});
    	*/
    }
	/*
	 * constructor
	 * 	
	 */
	private PlaySound() {
		/*sampleRate = AudioTrack.getNativeOutputSampleRate(AudioManager.STREAM_MUSIC);
		maxFreq = sampleRate/2;
		numSamples = (int) (duration*sampleRate);
		sample = new double[numSamples];
		generatedSnd = new byte[2*numSamples];*/
		Log.d(TAG, "constructor called");
		/*Log.d(TAG, "sampleRate: "+sampleRate);
		Log.d(TAG, "maxFreq: "+maxFreq);*/

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
		/*
		if (Freq > maxFreq)
			throw new InvalidFrequencyException("Frequency out of range!\nMax: "+maxFreq+"\ninput: "+Freq);

		if (Freq == currFreq)
			return;

		Log.d(TAG, "changing Freq to "+Freq);

		currFreq = Freq;
		*/
/*
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

        track.setStereoVolume(1, 1);
        track.write(generatedSnd, 0, generatedSnd.length);

        track.setLoopPoints(0, generatedSnd.length/2, -1);
        
        track.play();
        */
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
		
		Track = new AudioTrack(AudioManager.STREAM_MUSIC,
					sampleRate, AudioFormat.CHANNEL_OUT_MONO,
					AudioFormat.ENCODING_PCM_16BIT, generatedSnd.length,
					AudioTrack.MODE_STATIC);
		
		Track.write(generatedSnd, 0, generatedSnd.length);
		Track.setStereoVolume(1, 1);
		Track.setLoopPoints(0, generatedSnd.length/2, -1);
        
		Track.play();
	}

	public void start(int Freq) throws Exception {
		setFreq(Freq);
	}

	public void stop() {
		if (Track == null)
			return;
		Track.pause();
		Track.stop();
		Track.release();
		Track = null;
	}
	
	
}