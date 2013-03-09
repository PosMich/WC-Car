package com.example.myfirstapp;

import android.os.Bundle;
import android.app.Activity;
import android.view.Menu;
import android.view.View;
import android.os.Handler;
import android.media.AudioTrack;
import android.media.AudioManager;
import android.media.AudioFormat;

public class MainActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }
    
    private final int STOP	= 20500;
    
    private final int RIGHT 	= 40500;
    private final int LEFT 	= 500;
    private final int BACKWRD = 20000;
    private final int FORWRD 	= 20999;
    
    private final int FORWRD_RIGHT 	= 40999;
    private final int FORWRD_LEFT 	= 999;
    private final int BACKWRD_RIGHT 	= 40000;
    private final int BACKWRD_LEFT 	= 0;

    private final int FREQ_MAX = 20000;
    
    // originally from http://marblemice.blogspot.com/2010/04/generate-and-play-tone-in-android.html
    // and modified by Steve Pomeroy <steve@staticfree.info>
    private final double duration = 0.1; // seconds
    private final int sampleRate = 2*FREQ_MAX;
    private final int numSamples = (int) (duration * sampleRate);
    private final double sample[] = new double[numSamples];
    private double freqOfTone = STOP; // hz
    
    private AudioTrack track = null;

    private final byte generatedSnd[] = new byte[2 * numSamples];

    Handler handler = new Handler();

    @Override
    protected void onResume() {
        super.onResume();
        
        playSound(freqOfTone);
        
/*
        // Use a new tread as this can take a while
        final Thread thread = new Thread(new Runnable() {
            public void run() {
                genTone();
                handler.post(new Runnable() {

                    public void run() {
                        playSound(freqOfTone);
                    }
                });
            }
        });
        thread.start();
        */
    }
    

    void genTone(){
        // fill out the array
        for (int i = 0; i < numSamples; ++i) {
            sample[i] = Math.sin(2 * Math.PI * i / (sampleRate/freqOfTone));
        }

        // convert to 16 bit pcm sound array
        // assumes the sample buffer is normalised.
        int idx = 0;
        for (final double dVal : sample) {
            // scale to maximum amplitude
            final short val = (short) ((dVal * 32767));
            // in 16 bit wav PCM, first byte is the low order byte
            generatedSnd[idx++] = (byte) (val & 0x00ff);
            generatedSnd[idx++] = (byte) ((val & 0xff00) >>> 8);

        }
    }

    void playSound(double Hz){
    	if (track != null) {
    		track.pause();
    		track.stop();
        	track.release();
    	}
    	freqOfTone = Hz;
    	genTone();
        track = new AudioTrack(AudioManager.STREAM_MUSIC,
                sampleRate, AudioFormat.CHANNEL_OUT_MONO,
                AudioFormat.ENCODING_PCM_16BIT, generatedSnd.length,
                AudioTrack.MODE_STATIC);
        track.write(generatedSnd, 0, generatedSnd.length);
        
        if (Hz == STOP) {
        	track.setLoopPoints(0, generatedSnd.length, -1);
        }
        track.play();
    }

    
    public void driveForward(View v) {
    	playSound(FORWRD);
    }
    public void driveLeft(View v) {
    	playSound(LEFT);
    }
    public void driveRight(View v) {
    	playSound(RIGHT);
    }
    public void driveBackward(View v) {
    	playSound(BACKWRD);
    }
    public void driveForwardRight(View v) {
    	playSound(FORWRD_RIGHT);
    }
    public void driveForwardLeft(View v) {
    	playSound(FORWRD_LEFT);
    }
    public void driveBackwardRight(View v) {
    	playSound(BACKWRD_RIGHT);
    }
    public void driveBackwardLeft(View v) {
    	playSound(BACKWRD_LEFT);
    }
    public void stop(View v) {
    	playSound(STOP);
    }
    
}
