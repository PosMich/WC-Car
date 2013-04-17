package com.mmt.webcar;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioManager;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

public class WebCarReleaseAudioActivity extends Activity {
	
	private static final String TAG = "WebCar :: Audio";
	
	final Context context = this;
	private MusicIntentReciever musicReciever;
	private AudioManager mAudioManager;
	private ImageView mStatusAudio;
	private int mVolume = -1;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.activity_web_car_release_audio);

		final View contentView = findViewById(R.id.fullscreen_content);
		mStatusAudio = (ImageView) findViewById(R.id.imageStatusAudio);
		
		mAudioManager = (AudioManager) this.getSystemService(Context.AUDIO_SERVICE);
		
		musicReciever = new MusicIntentReciever();
	}
	
	private class MusicIntentReciever extends BroadcastReceiver {
		@Override
		public void onReceive(Context context, Intent intent) {
			if (intent.getAction().equals(Intent.ACTION_HEADSET_PLUG)) {
				int state = intent.getIntExtra("state", -1);
				switch (state) {
				case 0:
					// unplugged
					mStatusAudio.setImageDrawable(getResources().
							getDrawable(R.drawable.error));
					mStatusAudio.setVisibility(1);
					setSystemVolume(false);
					break;
				case 1:
					// plugged in
					mStatusAudio.setImageDrawable(getResources().
							getDrawable(R.drawable.okay));
					mStatusAudio.setVisibility(1);
					setSystemVolume(true);
					try {
						Thread.sleep(750);
						Intent releaseIntent = new Intent(WebCarReleaseAudioActivity.this, WebCarReleaseStreamActivity.class);
						WebCarReleaseAudioActivity.this.startActivity(releaseIntent);
					} catch (InterruptedException e){
						Log.e( TAG, e.getMessage() );
					}
					break;
				default:
					// unknown
					mStatusAudio.setVisibility(0);
					setSystemVolume(false);
					break;
				}
			}
		}
	}
	
	@Override
	public void onPause() {
		super.onPause();
		unregisterReceiver(musicReciever);
		finish();
	}
	
	@Override
	public void onResume() {
		IntentFilter filter = new IntentFilter(Intent.ACTION_HEADSET_PLUG);
		registerReceiver(musicReciever, filter);
		super.onResume();
	}
	
	public void setSystemVolume(boolean turnOn ) {
		if( turnOn ) {
			mAudioManager.setStreamVolume(AudioManager.STREAM_MUSIC, 
				mAudioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC),
				AudioManager.FLAG_SHOW_UI);
		} else {
			if(mVolume != -1) {
				mAudioManager.setStreamVolume(AudioManager.STREAM_MUSIC, mVolume,
					AudioManager.FLAG_SHOW_UI);
			}
		}
	}
}
