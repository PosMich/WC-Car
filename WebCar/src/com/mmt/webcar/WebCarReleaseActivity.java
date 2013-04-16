package com.mmt.webcar;

import com.mmt.webcar.util.SystemUiHider;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.view.MotionEvent;
import android.view.View;
import android.view.MenuItem;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.support.v4.app.NavUtils;

public class WebCarReleaseActivity extends Activity {
	
	private EditText mPassphrase;
	private EditText mPassphraseReentered;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.activity_web_car_release);

		final View contentView = findViewById(R.id.fullscreen_content);
		final Button btnConfirm = (Button) findViewById(R.id.btnConfirmPassphrase);
		
		btnConfirm.setOnClickListener(btnConfirmAction);
		
		
	}
	
	OnClickListener btnConfirmAction = new OnClickListener() {
		
		@Override
		public void onClick(View v) {
			
			mPassphrase = (EditText) findViewById(R.id.editTextPassphrase);
			mPassphraseReentered = (EditText) findViewById(R.id.editTextPassphraseReenter);
				
			if ( mPassphrase.getText().toString().isEmpty() ) {
				mPassphrase.setError("can't be empty");
			} else if ( mPassphrase.getText().toString().length() < 5 ) {
				mPassphrase.setError("Minimal Length: 5");
			} else if ( mPassphraseReentered.getText().toString().isEmpty() ) {
				mPassphraseReentered.setError("can't be empty");
			} else if ( mPassphraseReentered.getText().toString().length() < 5 ) {
				mPassphraseReentered.setError("Minimal Length: 5");
			} else if( ! mPassphrase.getText().toString().equals(mPassphraseReentered.getText().toString() ) ) {
				mPassphraseReentered.setError("passphrases have to match.");
			} else {
				Intent releaseIntent = new Intent(WebCarReleaseActivity.this, WebCarReleaseAudioActivity.class);
				WebCarReleaseActivity.this.startActivity(releaseIntent);
			}
				
		}
	};
}
