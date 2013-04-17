package com.mmt.webcar;

import android.app.Activity;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;

public class WebCarReleaseWLANActivity extends Activity {
	
	private final static String TAG = "WebCar :: WIFI";
	
	ConnectivityManager mConnManager;
	NetworkInfo mWifi;
	ImageView mStatusWifi;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.activity_web_car_release_wlan);
		
		final View contentView = findViewById(R.id.fullscreen_content);
		
		mStatusWifi = (ImageView) findViewById(R.id.imageStatusWLAN);
		mConnManager = (ConnectivityManager) getSystemService(CONNECTIVITY_SERVICE);
		mWifi = mConnManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
		
		if(mWifi.isConnected()) {
			try {
				mStatusWifi.setImageDrawable(getResources().
					getDrawable(R.drawable.okay));
				mStatusWifi.setVisibility(1);
				Thread.sleep(750);
				Intent releaseIntent = new Intent(WebCarReleaseWLANActivity.this, WebCarReleaseActivity.class);
				WebCarReleaseWLANActivity.this.startActivity(releaseIntent);
				
			} catch (InterruptedException e) {
				Log.d( TAG, e.getMessage() );
			}
		} else {
			mStatusWifi.setImageDrawable(getResources().
				getDrawable(R.drawable.error));
			mStatusWifi.setVisibility(1);
		}

	}
}
