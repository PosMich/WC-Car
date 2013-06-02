package com.mmt.webcar;


import com.mmt.utils.Motion2Sound;
import com.mmt.utils.Motion2Sound.InvalidFrequencyException;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;

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
        mCreditScreenButton.setOnClickListener(onBtnCreditScreen);
        
        mHomeButton = (Button) findViewById(R.id.btnHome);
        mHomeButton.setOnClickListener(onHomeButton);
        
    }

    OnClickListener onBtnRelease = new OnClickListener() {
		
		@Override
		public void onClick(View v) {
			// Call new Activity
			Intent releaseIntent = new Intent(WebCarActivity.this, WebCarReleaseWLANActivity.class);
			WebCarActivity.this.startActivity(releaseIntent);
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
	
	OnClickListener onHomeButton = new OnClickListener() {
		
		@Override
		public void onClick(View v) {
			// Call new Activity
			Intent releaseIntent = new Intent(WebCarActivity.this, WebCarActivity.class);
			WebCarActivity.this.startActivity(releaseIntent);
		}
	};
}
