package com.example.myfirstapp;

import android.os.Bundle;
import android.app.Activity;
import android.view.Menu;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.MotionEvent;
import android.os.Handler;
import android.media.AudioTrack;
import android.media.AudioManager;
import android.media.AudioFormat;
import android.view.WindowManager;
import android.widget.TextView;
import android.widget.Button;

public class MainActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_main);

	    Button fwd 		= (Button) findViewById(R.id.buttonForward);
	    Button bwd 		= (Button) findViewById(R.id.buttonBackward);
	    Button lft 		= (Button) findViewById(R.id.buttonLeft);
	    Button rght 	= (Button) findViewById(R.id.buttonRight);
	    Button fwdRght 	= (Button) findViewById(R.id.buttonForwardRight);
	    Button fwdLft 	= (Button) findViewById(R.id.buttonForwardLeft);
	    Button bwdRght 	= (Button) findViewById(R.id.buttonBackwardRight);
	    Button bwdLft 	=(Button) findViewById(R.id.buttonBackwardLeft);
    
	    fwd.setOnTouchListener(new OnTouchListener() {
	        @Override
	        public boolean onTouch(View v, MotionEvent event) {
	            if(event.getAction() == MotionEvent.ACTION_DOWN) {
	                driveForward();
	            } else if (event.getAction() == MotionEvent.ACTION_UP) {
	                stop();
	            }
	            return false;
	        }
	    });
	    bwd.setOnTouchListener(new OnTouchListener() {
	        @Override
	        public boolean onTouch(View v, MotionEvent event) {
	            if(event.getAction() == MotionEvent.ACTION_DOWN) {
	                driveBackward();
	            } else if (event.getAction() == MotionEvent.ACTION_UP) {
	                stop();
	            }
	            return false;
	        }
	    });
	    rght.setOnTouchListener(new OnTouchListener() {
	        @Override
	        public boolean onTouch(View v, MotionEvent event) {
	            if(event.getAction() == MotionEvent.ACTION_DOWN) {
	                driveRight();
	            } else if (event.getAction() == MotionEvent.ACTION_UP) {
	                stop();
	            }
	            return false;
	        }
	    });
	    lft.setOnTouchListener(new OnTouchListener() {
	        @Override
	        public boolean onTouch(View v, MotionEvent event) {
	            if(event.getAction() == MotionEvent.ACTION_DOWN) {
	                driveLeft();
	            } else if (event.getAction() == MotionEvent.ACTION_UP) {
	                stop();
	            }
	            return false;
	        }
	    });
	    fwdRght.setOnTouchListener(new OnTouchListener() {
	        @Override
	        public boolean onTouch(View v, MotionEvent event) {
	            if(event.getAction() == MotionEvent.ACTION_DOWN) {
	                driveForwardRight();
	            } else if (event.getAction() == MotionEvent.ACTION_UP) {
	                stop();
	            }
	            return false;
	        }
	    });
	    bwdRght.setOnTouchListener(new OnTouchListener() {
	        @Override
	        public boolean onTouch(View v, MotionEvent event) {
	            if(event.getAction() == MotionEvent.ACTION_DOWN) {
	                driveBackwardRight();
	            } else if (event.getAction() == MotionEvent.ACTION_UP) {
	                stop();
	            }
	            return false;
	        }
	    });
	    fwdLft.setOnTouchListener(new OnTouchListener() {
	        @Override
	        public boolean onTouch(View v, MotionEvent event) {
	            if(event.getAction() == MotionEvent.ACTION_DOWN) {
	                driveForwardLeft();
	            } else if (event.getAction() == MotionEvent.ACTION_UP) {
	                stop();
	            }
	            return false;
	        }
	    });
	    bwdLft.setOnTouchListener(new OnTouchListener() {
	        @Override
	        public boolean onTouch(View v, MotionEvent event) {
	            if(event.getAction() == MotionEvent.ACTION_DOWN) {
	                driveBackwardLeft();
	            } else if (event.getAction() == MotionEvent.ACTION_UP) {
	                stop();
	            }
	            return false;
	        }
	    });

        TextView t = (TextView) findViewById(R.id.NativeSampleRate);
        t.setText(AudioTrack.getNativeOutputSampleRate(AudioManager.STREAM_MUSIC)+"Hz");	    
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }
    
    
    
    //btn.add("fwd", (Button) findViewById(R.id.buttonForward));
    /*
    private Button[] bt = {
	    (Button) findViewById(R.id.buttonForward),
	    (Button) findViewById(R.id.buttonBackward),
	    (Button) findViewById(R.id.buttonLeft),
	    (Button) findViewById(R.id.buttonRight),
	    (Button) findViewById(R.id.buttonForwardRight),
	    (Button) findViewById(R.id.buttonForwardLeft),
	    (Button) findViewById(R.id.buttonBackwardRight),
	    (Button) findViewById(R.id.buttonBackwardLeft)
    };*/
    
    private final int STOP	= 10500;
    
    private final int RIGHT 	= 20500;
    private final int LEFT 	= 500;
    private final int BACKWRD = 10000;
    private final int FORWRD 	= 10999;
    
    private final int FORWRD_RIGHT 	= 20999;
    private final int FORWRD_LEFT 	= 999;
    private final int BACKWRD_RIGHT 	= 20000;
    private final int BACKWRD_LEFT 	= 0;

    private final int FREQ_MAX = 22500;
    
    // originally from http://marblemice.blogspot.com/2010/04/generate-and-play-tone-in-android.html
    // and modified by Steve Pomeroy <steve@staticfree.info>
    private final double duration = 5; // seconds
    private final int sampleRate = 2*FREQ_MAX;
    private final int numSamples = (int) (duration * sampleRate);
    private final double sample[] = new double[numSamples];
    private double freqOfTone = STOP; // hz
    
    private AudioTrack track = null;

    private final byte generatedSnd[] = new byte[2 * numSamples];

    Handler handler = new Handler();

    @Override
    protected void onStop() {
    	super.onStop();
    	
    	track.pause();
    }
    
    
    @Override
    protected void onResume() {
        super.onResume();

    	getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        
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
    
    void stopSound() {
    	track.pause();
    }
    
    void startSound() {
    	playSound(STOP);
    }

    void playSound(double Hz){
    	if (track != null) {
    		track.pause();
    		track.stop();
        	track.release();
    	}
    	

        TextView t = (TextView) findViewById(R.id.Frequency);
    	
        t.setText(Hz+"Hz");
        
    	freqOfTone = Hz;
    	
    	genTone();
        track = new AudioTrack(AudioManager.STREAM_MUSIC,
                sampleRate, AudioFormat.CHANNEL_OUT_MONO,
                AudioFormat.ENCODING_PCM_16BIT, generatedSnd.length,
                AudioTrack.MODE_STATIC);
        track.write(generatedSnd, 0, generatedSnd.length);
        
        track.setLoopPoints(0, generatedSnd.length/4 -1, -1);
        track.play();
    }

    
    public void driveForward() {
    	playSound(FORWRD);
    }
    public void driveLeft() {
    	playSound(LEFT);
    }
    public void driveRight() {
    	playSound(RIGHT);
    }
    public void driveBackward() {
    	playSound(BACKWRD);
    }
    public void driveForwardRight() {
    	playSound(FORWRD_RIGHT);
    }
    public void driveForwardLeft() {
    	playSound(FORWRD_LEFT);
    }
    public void driveBackwardRight() {
    	playSound(BACKWRD_RIGHT);
    }
    public void driveBackwardLeft() {
    	playSound(BACKWRD_LEFT);
    }
    public void stop() {
    	playSound(STOP);
    }
    public void hoit(View v) {
    	stopSound();
    }

    public void weida(View v) {
    	startSound();
    }
}
