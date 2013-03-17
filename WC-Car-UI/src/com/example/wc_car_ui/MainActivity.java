package com.example.wc_car_ui;

import com.utils.IP;

import android.app.Activity;
import android.app.Dialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
 
public class MainActivity extends Activity {
 
	final Context context = this;
	private Button buttonShowCreditsDialog;
	private Button buttonStartConnection;
	private Button buttonStopConnection;
	private TextView textIPAddress;
	private TextView textViewAudioStatus;
	private ImageView imageViewAudioStatus;
	private MusicIntentReciever musicReciever;
 
	public void onCreate(Bundle savedInstanceState) {
 
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);
		
		musicReciever = new MusicIntentReciever();
 
		buttonShowCreditsDialog = (Button) findViewById(R.id.buttonShowCustomDialog);
		buttonStartConnection = (Button) findViewById(R.id.buttonStartConnection);
		buttonStopConnection = (Button) findViewById(R.id.buttonStopConnection);
		
		textIPAddress = (TextView) findViewById(R.id.textIPAddress);
		textViewAudioStatus = (TextView) findViewById(R.id.textViewAudioStatus);
		
		imageViewAudioStatus = (ImageView) findViewById(R.id.imageViewAudioStatus);
		
		// add listener for button "startConnection"
		buttonStartConnection.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				
				textIPAddress.setText("IP: " + IP.getIPAddress(true));
				
			}
		});
		
		// add listener for button "stopConnection"
		buttonStopConnection.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				
				textIPAddress.setText("IP: ");
				
			}
		});
 
		// add button listener
		buttonShowCreditsDialog.setOnClickListener(new OnClickListener() {
 
		  @Override
		  public void onClick(View v) {
 
			// custom dialog
			final Dialog dialog = new Dialog(context);
			dialog.setContentView(R.layout.custom);
			dialog.setTitle("Credits");
 
			// set the custom dialog components - text, image and button
			TextView textCreditsDialog = (TextView) dialog.findViewById(R.id.textCreditsDialog);
			textCreditsDialog.setText(R.string.contentCredits);
 
			Button buttonCancelCreditsDialog = (Button) dialog.findViewById(R.id.dialogButtonOK);
			// if button is clicked, close the custom dialog
			buttonCancelCreditsDialog.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
					dialog.dismiss();
				}
			});
 
			dialog.show();
		  }
		});
	}
	
	@Override 
	public void onResume() {
	    IntentFilter filter = new IntentFilter(Intent.ACTION_HEADSET_PLUG);
	    registerReceiver(musicReciever, filter);
	    super.onResume();
	}
	
	private class MusicIntentReciever extends BroadcastReceiver {
		 @Override 
		 public void onReceive(Context context, Intent intent) {
			 if (intent.getAction().equals(Intent.ACTION_HEADSET_PLUG)) {
				 int state = intent.getIntExtra("state", -1);
		         switch (state) {
		            case 0:
		            	textViewAudioStatus.setText("Audio Status: Unplugged.");
		            	imageViewAudioStatus.setImageResource(R.drawable.unplugged);
		                break;
		            case 1:
		            	textViewAudioStatus.setText("Audio Status: Plugged.");
		            	imageViewAudioStatus.setImageResource(R.drawable.plugged);
		                break;
		            default:
		            	textViewAudioStatus.setText("Audio Status: Unknown.");
		            	imageViewAudioStatus.setImageResource(R.drawable.unplugged);
		         }
		     }
		 }
	}
	
	@Override
	public void onPause() {
	    unregisterReceiver(musicReciever);
	    super.onPause();
	}
}


