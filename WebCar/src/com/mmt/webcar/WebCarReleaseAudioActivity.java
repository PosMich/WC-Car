package com.mmt.webcar;

import android.app.Activity;
import android.app.Dialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioManager;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

public class WebCarReleaseAudioActivity extends Activity {
	
	private static final String TAG = "WebCar :: Audio";
	
	final Context context = this;
	private MusicIntentReceiver mMusicReceiver;
	private AudioManager mAudioManager;
	private ImageView mStatusAudio;
	private Button mHomeButton;
	private Button mCreditScreenButton;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.activity_web_car_release_audio);

		mHomeButton = (Button) findViewById(R.id.btnHome);
		mHomeButton.setOnClickListener(onHomeButton);
		
		mCreditScreenButton = (Button) findViewById(R.id.btnCreditScreen);
        mCreditScreenButton.setOnClickListener(onBtnCreditScreen);
		
		// status image for phone connector
		mStatusAudio = (ImageView) findViewById(R.id.imageStatusAudio);
		
		// audio manager for manipulating volume
		mAudioManager = (AudioManager) this.getSystemService(Context.AUDIO_SERVICE);
		
		// receiver for phone connector
		mMusicReceiver = new MusicIntentReceiver();
		
		// set the global volume of the phone to change it back on pause/close
		((WebCarApplication)getApplication()).setVolume( mAudioManager.getStreamVolume(AudioManager.STREAM_MUSIC) );
	}
	
	private class MusicIntentReceiver extends BroadcastReceiver {
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
		unregisterReceiver(mMusicReceiver);
		finish();
	}
	
	@Override
	public void onResume() {
		IntentFilter filter = new IntentFilter(Intent.ACTION_HEADSET_PLUG);
		registerReceiver(mMusicReceiver, filter);
		super.onResume();
	}
	
	public void setSystemVolume(boolean turnOn ) {
		if( turnOn ) {
			mAudioManager.setStreamVolume(AudioManager.STREAM_MUSIC, 
				mAudioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC),
				AudioManager.FLAG_SHOW_UI);
		} else {
			// reset global system volume
			mAudioManager.setStreamVolume(AudioManager.STREAM_MUSIC, ((WebCarApplication)getApplication()).getVolume(),
				AudioManager.FLAG_SHOW_UI);
		}
	}
	
	OnClickListener onHomeButton = new OnClickListener() {
		
		@Override
		public void onClick(View v) {
			// Call new Activity
			Intent releaseIntent = new Intent(WebCarReleaseAudioActivity.this, WebCarActivity.class);
			WebCarReleaseAudioActivity.this.startActivity(releaseIntent);
		}
	};
	
    OnClickListener onBtnCreditScreen = new OnClickListener() {
		
		@Override
		public void onClick(View v) {
			// custom dialog
			final Dialog dialog = new Dialog(context);
			dialog.setContentView(R.layout.custom);
			dialog.setTitle("Credits");

			// set the custom dialog components - text, image and button
			TextView textCreditsDialog = (TextView) dialog
					.findViewById(R.id.textCreditsDialog);
			textCreditsDialog.setText(R.string.contentCredits);

			Button buttonCancelCreditsDialog = (Button) dialog
					.findViewById(R.id.dialogButtonOK);
			// if button is clicked, close the custom dialog
			buttonCancelCreditsDialog.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
					dialog.dismiss();
				}
			});

			dialog.show();
		}
	};
}