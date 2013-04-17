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
import android.widget.ImageView;
import android.support.v4.app.NavUtils;
import android.text.Editable;
import android.text.TextWatcher;

public class WebCarReleaseActivity extends Activity {
	
	private EditText mPassphrase;
	private EditText mPassphraseReentered;
	private ImageView mStatusPassphrase;
	private ImageView mStatusPassphraseReentered;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.activity_web_car_release);

		final View contentView = findViewById(R.id.fullscreen_content);
		final Button btnConfirm = (Button) findViewById(R.id.btnConfirmPassphrase);
		
		mPassphrase = (EditText) findViewById(R.id.editTextPassphrase);
		mPassphraseReentered = (EditText) findViewById(R.id.editTextPassphraseReenter);
		
		mPassphrase.addTextChangedListener(passphraseWatcher);
		mPassphraseReentered.addTextChangedListener(passphraseReenteredWatcher);
		
		mStatusPassphrase = (ImageView) findViewById(R.id.imageStatusPassphrase);
		mStatusPassphraseReentered = (ImageView) findViewById(R.id.imageStatusPassphraseReentered);
		
		btnConfirm.setOnClickListener(btnConfirmAction);
		
		
	}
	
	OnClickListener btnConfirmAction = new OnClickListener() {
		
		@Override
		public void onClick(View v) {	
			
			String phrase = mPassphrase.getText().toString();
			String phraseReenterd = mPassphraseReentered.getText().toString();
			
			if ( phrase.isEmpty() ) {
//				mPassphrase.setError("can't be empty");
			} else if ( phrase.length() < 5 ) {
//				mPassphrase.setError("Minimal Length: 5");
			} else if ( phraseReenterd.isEmpty() ) {
//				mPassphraseReentered.setError("can't be empty");
			} else if ( phraseReenterd.length() < 5 ) {
//				mPassphraseReentered.setError("Minimal Length: 5");
			} else if( ! phrase.equals(phraseReenterd ) ) {
//				mPassphraseReentered.setError("passphrases have to match.");
			} else {
				Intent releaseIntent = new Intent(WebCarReleaseActivity.this, WebCarReleaseAudioActivity.class);
				WebCarReleaseActivity.this.startActivity(releaseIntent);
			}
				
		}
	};
	
	TextWatcher passphraseWatcher = new TextWatcher() {
		
		@Override
		public void onTextChanged(CharSequence s, int start, int before, int count) {
		}
		
		@Override
		public void beforeTextChanged(CharSequence s, int start, int count,
				int after) {			
		}
		
		@Override
		public void afterTextChanged(Editable s) {
			String phrase = mPassphrase.getText().toString(); 
			mStatusPassphrase.setImageDrawable(getResources().getDrawable(R.drawable.error));
			if( phrase.isEmpty() )
				mStatusPassphrase.setVisibility(1);
			else if (phrase.length() < 5)
				mStatusPassphrase.setVisibility(1);
			else
				mStatusPassphrase.setImageDrawable(getResources().getDrawable(R.drawable.okay));
		}
	};
	
	TextWatcher passphraseReenteredWatcher = new TextWatcher() {
		
		@Override
		public void onTextChanged(CharSequence s, int start, int before, int count) {
		}
		
		@Override
		public void beforeTextChanged(CharSequence s, int start, int count,
				int after) {			
		}
		
		@Override
		public void afterTextChanged(Editable s) {
			String phrase = mPassphrase.getText().toString();
			String phraseReentered = mPassphraseReentered.getText().toString();
			mStatusPassphraseReentered.setImageDrawable(getResources().getDrawable(R.drawable.error));
			if( ! phraseReentered.equals(phrase) )
				mStatusPassphraseReentered.setVisibility(1);
			else
				mStatusPassphraseReentered.setImageDrawable(getResources().getDrawable(R.drawable.okay));
		}
	};
}
