package com.mmt.webcar;

import com.mmt.utils.IP;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

public class WebCarReleaseStreamActivity extends Activity {
	
	private TextView mTextIP;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.activity_web_car_release_stream);
		
		mTextIP = (TextView) findViewById(R.id.textReleaseStreamingIP);
		mTextIP.setText(IP.getIPAddress(true) + ":8080");

		final View contentView = findViewById(R.id.fullscreen_content);
	}

}
