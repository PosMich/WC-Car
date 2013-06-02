package com.mmt.webcar;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.text.Editable;
import android.text.TextWatcher;

public class WebCarReleaseActivity extends Activity {
	
	private EditText mPassphrase;
	private EditText mPassphraseReentered;
	private ImageView mStatusPassphrase;
	private ImageView mStatusPassphraseReentered;
	private Button mHomeButton;
	private Button mCreditScreenButton;
	final Context context = this;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.activity_web_car_release);
		
		final Button btnConfirm = (Button) findViewById(R.id.btnConfirmPassphrase);
		
		mPassphrase = (EditText) findViewById(R.id.editTextPassphrase);
		mPassphraseReentered = (EditText) findViewById(R.id.editTextPassphraseReenter);
		
		mPassphrase.addTextChangedListener(passphraseWatcher);
		mPassphraseReentered.addTextChangedListener(passphraseReenteredWatcher);
		
		mStatusPassphrase = (ImageView) findViewById(R.id.imageStatusPassphrase);
		mStatusPassphraseReentered = (ImageView) findViewById(R.id.imageStatusPassphraseReentered);
		
		mHomeButton = (Button) findViewById(R.id.btnHome);
		mHomeButton.setOnClickListener(onHomeButton);
		
		mCreditScreenButton = (Button) findViewById(R.id.btnCreditScreen);
        mCreditScreenButton.setOnClickListener(onBtnCreditScreen);
		
		btnConfirm.setOnClickListener(btnConfirmAction);
		
		if( !((WebCarApplication)getApplication()).getPassphrase().equals("") ) {
			mPassphrase.setText( ((WebCarApplication)getApplication()).getPassphrase() );
			mPassphraseReentered.setText( ((WebCarApplication)getApplication()).getPassphrase() );
		}
				
	}
	
	OnClickListener onHomeButton = new OnClickListener() {
		
		@Override
		public void onClick(View v) {
			// Call new Activity
			Intent releaseIntent = new Intent(WebCarReleaseActivity.this, WebCarActivity.class);
			WebCarReleaseActivity.this.startActivity(releaseIntent);
		}
	};
	
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
				((WebCarApplication)getApplication()).setPassphrase( phrase );
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
