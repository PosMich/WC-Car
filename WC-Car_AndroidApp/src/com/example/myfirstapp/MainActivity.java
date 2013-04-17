package com.example.myfirstapp;

import android.os.Bundle;
import android.os.Message;
import android.app.Activity;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.MotionEvent;
import android.os.Handler;
import android.hardware.Camera.Size;
import android.media.AudioTrack;
import android.media.AudioManager;
import android.media.AudioFormat;
import android.media.AudioTrack.OnPlaybackPositionUpdateListener;
import android.view.WindowManager;
import android.widget.TextView;
import android.widget.Button;

public class MainActivity extends Activity {

	PlaySound AudioGenerator = new PlaySound();
	
	public void playSound(int Freq) {
		try {
			AudioGenerator.setFreq(Freq);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
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
    
    
    private final int STOP	= 10500;
    
    private final int RIGHT 	= 19500;
    private final int LEFT 	= 01500;
    private final int BACKWRD = 10100;
    private final int FORWRD 	= 10999;
    
    private final int FORWRD_RIGHT 	= 19999;
    private final int FORWRD_LEFT 	= 1999; // 01999
    private final int BACKWRD_RIGHT 	= 1100;
    private final int BACKWRD_LEFT 	= 1100;

    
    @Override
    protected void onResume() {
        super.onResume();
    	getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }
    
    void stopSound() {
    	AudioGenerator.stop();
    }
    
    void startSound() {
    	playSound(STOP);
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

    @Override
    protected void onDestroy() {
    	AudioGenerator.stop();
    	super.onDestroy();
    }
}
