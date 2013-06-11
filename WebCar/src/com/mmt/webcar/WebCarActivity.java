package com.mmt.webcar;


import com.mmt.utils.OnBtnCreditScreenClickListener;
import com.mmt.utils.OnHomeBtnClickListener;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;


public class WebCarActivity extends Activity {
	
	private Button mReleaseButton;
	private Button mCreditScreenButton;
	private Button mHomeButton;
	
	final Context context = this;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);   
        
    	

        setContentView(R.layout.activity_web_car);

        mReleaseButton = (Button) findViewById(R.id.btnRelease);
        mReleaseButton.setOnClickListener(onBtnRelease);
        
        mCreditScreenButton = (Button) findViewById(R.id.btnCreditScreen);
        mCreditScreenButton.setOnClickListener(new OnBtnCreditScreenClickListener());
        
        mHomeButton = (Button) findViewById(R.id.btnHome);
        mHomeButton.setOnClickListener(new OnHomeBtnClickListener());

    }

    OnClickListener onBtnRelease = new OnClickListener() {
		
		@Override
		public void onClick(View v) {
			// Call new Activity
			Intent releaseIntent = new Intent(WebCarActivity.this, WebCarReleaseWLANActivity.class);
			WebCarActivity.this.startActivity(releaseIntent);
		}
	};
	
}
