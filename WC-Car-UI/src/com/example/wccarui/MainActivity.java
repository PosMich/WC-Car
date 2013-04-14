package com.example.wccarui;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.UnknownHostException;

import org.java_websocket.WebSocketImpl;

import com.example.wc_car_ui.R;
import com.utils.IP;

import android.app.Activity;
import android.app.Dialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.ImageFormat;
import android.graphics.Rect;
import android.graphics.YuvImage;
import android.hardware.Camera;
import android.hardware.Camera.PreviewCallback;
import android.os.Bundle;
import android.util.Base64;
import android.util.Log;
import android.view.MotionEvent;
import android.view.SurfaceView;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

public class MainActivity extends Activity implements View.OnTouchListener,
		CameraView.CameraReadyCallback {

	private static final String TAG = "WC-Car-Activity";
	
	boolean inProcessing = false;

	WCServer mServer = null;
	private CameraView mCameraView;;

	final Context context = this;
	private Button buttonShowCreditsDialog;
	private Button buttonStartConnection;
	private Button buttonStopConnection;
	private TextView textIPAddress;
	private TextView textViewAudioStatus;
	private ImageView imageViewAudioStatus;
	private MusicIntentReciever musicReciever;

	private WCSocket mWCSocket = null;

	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		requestWindowFeature(Window.FEATURE_NO_TITLE);
		Window win = getWindow();
		win.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

		setContentView(R.layout.main);

		musicReciever = new MusicIntentReciever();

		// get buttons from view and bind click-events
		buttonShowCreditsDialog = (Button) findViewById(R.id.buttonShowCustomDialog);
		buttonShowCreditsDialog.setOnClickListener(onCreditsShow);

		buttonStartConnection = (Button) findViewById(R.id.buttonStartConnection);
		buttonStartConnection.setOnClickListener(onStartConnection);

		buttonStopConnection = (Button) findViewById(R.id.buttonStopConnection);
		buttonStopConnection.setOnClickListener(onStopConnection);

		// get text views
		textIPAddress = (TextView) findViewById(R.id.textIPAddress);
		textViewAudioStatus = (TextView) findViewById(R.id.textViewAudioStatus);

		// get image view
		imageViewAudioStatus = (ImageView) findViewById(R.id.imageViewAudioStatus);

		System.loadLibrary("natpmp");

		initCamera();
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
		super.onPause();
		unregisterReceiver(musicReciever);

		inProcessing = true;
		if (mServer != null)
			mServer.stop();
		mCameraView.StopPreview();
		finish();
	}

	public OnClickListener onStartConnection = new OnClickListener() {

		@Override
		public void onClick(View v) {
			textIPAddress.setText("IP: " + IP.getIPAddress(true));
		}
	};

	public OnClickListener onStopConnection = new OnClickListener() {

		@Override
		public void onClick(View v) {

			textIPAddress.setText("IP: ");

		}
	};

	public OnClickListener onCreditsShow = new OnClickListener() {
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

	/* TEAONLY ZEUGS */

	@Override
	public void onCameraReady() {
		if (initWebServer()) {
			int wid = mCameraView.Width();
			int hei = mCameraView.Height();
			mCameraView.StopPreview();
			mCameraView.setupCamera(wid, hei, previewCb_);
			mCameraView.StartPreview();
		}
	}

	@Override
	public void onDestroy() {
		super.onDestroy();
	}

	@Override
	public void onStart() {
		super.onStart();
	}

	@Override
	public void onBackPressed() {
		super.onBackPressed();
	}

	@Override
	public boolean onTouch(View v, MotionEvent evt) {

		return false;
	}

	private void initCamera() {
		SurfaceView cameraSurface = (SurfaceView) findViewById(R.id.surface_camera);
		mCameraView = new CameraView(cameraSurface);
		mCameraView.setCameraReadyCallback(this);
	}

	private boolean initWebServer() {
		String ipAddr = IP.getIPAddress(true);
		if (ipAddr != null) {
			try {
				setupSocket(8081);
				mServer = new WCServer(8080, this);

			} catch (IOException e) {
				mServer = null;
			}
		}
		if (mServer != null)
			return true;
		else
			return false;
		
	}

	private PreviewCallback previewCb_ = new PreviewCallback() {
		public void onPreviewFrame(byte[] frame, Camera c) {
			if (!inProcessing) {
				inProcessing = true;			

				try {
				
					int picWidth = mCameraView.Width();
					int picHeight = mCameraView.Height();
					
					Log.d( TAG, picWidth + " x " + picHeight );
					
					boolean ret;
					
					ByteArrayOutputStream out = new ByteArrayOutputStream();
				
					YuvImage newImage = new YuvImage(frame, ImageFormat.NV21,
						picWidth, picHeight, null);
					
					
					
					ret = newImage.compressToJpeg( new Rect( 0, 0, picWidth, picHeight ), 20, out );
					
					Log.d( TAG + " :: Image", "File to send is " + out.size() + "byte large.");
					
					if( ret ) {
						byte[] imageBytes = out.toByteArray();
						
						String byteString = Base64.encodeToString(imageBytes, Base64.NO_WRAP);
						
						mWCSocket.send( byteString );
					} else {
						Log.d( TAG + " :: Image", "Failed to compress frame to jpeg." );
					}
				} catch (Exception e) {
					Log.e( TAG, e.getMessage() );
				}

				inProcessing = false;
			}
		}
	};

	public void setupSocket(int port) throws UnknownHostException {

		WebSocketImpl.DEBUG = true;
		mWCSocket = new WCSocket(port);

		mWCSocket.start();
		Log.d("WC-Socket", "ChatServer started on port: " + mWCSocket.getPort());

	}

};
