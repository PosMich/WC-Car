package com.mmt.webcar;

import com.mmt.utils.OnBtnCreditScreenClickListener;
import com.mmt.utils.OnHomeBtnClickListener;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.NetworkInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.util.Log;
import android.widget.Button;
import android.widget.ImageView;

public class WebCarReleaseWLANActivity extends Activity {
	
	private final static String TAG = "WebCar :: WIFI";

	private ImageView mStatusWifi;
	private WifiIntentReceiver mWifiReceiver;
	private Button mHomeButton;
	private Button mCreditScreenButton;
	
	final Context context = this;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.activity_web_car_release_wlan);
		
		mHomeButton = (Button) findViewById(R.id.btnHome);
		mHomeButton.setOnClickListener(new OnHomeBtnClickListener());
		
		mCreditScreenButton = (Button) findViewById(R.id.btnCreditScreen);
		mCreditScreenButton.setOnClickListener(new OnBtnCreditScreenClickListener());
		
		mStatusWifi = (ImageView) findViewById(R.id.imageStatusWLAN);		
		mWifiReceiver = new WifiIntentReceiver();
		
		Intent releaseIntent = new Intent(WebCarReleaseWLANActivity.this, WebCarReleaseActivity.class);
		WebCarReleaseWLANActivity.this.startActivity(releaseIntent);
	
	}
	
	private class WifiIntentReceiver extends BroadcastReceiver {
		@Override
		public void onReceive(Context context, Intent intent) {
			
			final String action = intent.getAction();
			
			if ( action.equals( WifiManager.NETWORK_STATE_CHANGED_ACTION ) )
			{
			  NetworkInfo info = (NetworkInfo)intent.getParcelableExtra(WifiManager.EXTRA_NETWORK_INFO);
			  if (info.getState().equals(NetworkInfo.State.CONNECTED)) {
			    mStatusWifi.setImageDrawable(getResources().
				getDrawable(R.drawable.okay));
				mStatusWifi.setVisibility(1);
				try {
					Thread.sleep(750);
					Intent releaseIntent = new Intent(WebCarReleaseWLANActivity.this, WebCarReleaseActivity.class);
					WebCarReleaseWLANActivity.this.startActivity(releaseIntent);
				} catch (InterruptedException e) {
					Log.e( TAG , e.getMessage() );
				}
					
			  } else if (info.getState().equals(NetworkInfo.State.DISCONNECTED)){
				  mStatusWifi.setImageDrawable(getResources().getDrawable(R.drawable.error));
				  mStatusWifi.setVisibility(1);
			  }
			}

		}
	}
	
	@Override
	public void onPause() {
		super.onPause();
		unregisterReceiver(mWifiReceiver);
		finish();
	}
	
	@Override
	public void onResume() {
		IntentFilter filter = new IntentFilter(WifiManager.NETWORK_STATE_CHANGED_ACTION);
		registerReceiver(mWifiReceiver, filter);
		super.onResume();
	}
	
}
