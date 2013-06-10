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
import android.widget.EditText;
import android.widget.ImageView;
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
		mHomeButton.setOnClickListener(new OnHomeBtnClickListener());
		
		mCreditScreenButton = (Button) findViewById(R.id.btnCreditScreen);
		mCreditScreenButton.setOnClickListener(new OnBtnCreditScreenClickListener());
		
		btnConfirm.setOnClickListener(btnConfirmAction);
		
		if( !((WebCarApplication)getApplication()).getPassphrase().equals("") ) {
			mPassphrase.setText( ((WebCarApplication)getApplication()).getPassphrase() );
			mPassphraseReentered.setText( ((WebCarApplication)getApplication()).getPassphrase() );
		}
				
	}
	
	OnClickListener btnConfirmAction = new OnClickListener() {
		
		@Override
		public void onClick(View v) {	
			
			String phrase = mPassphrase.getText().toString();
			String phraseReenterd = mPassphraseReentered.getText().toString();
			
			if ( !phrase.isEmpty() 
					&& !( phrase.length() < 5 )
					&& !( phraseReenterd.isEmpty() )
					&& !( phraseReenterd.length() < 5 )
					&& phrase.equals( phraseReenterd ) ) {
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
	
}
