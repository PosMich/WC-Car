package com.mmt.webcar;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.UnknownHostException;
import java.security.SecureRandom;
import java.util.Timer;
import java.util.TimerTask;

import org.java_websocket.WebSocket;
import org.java_websocket.WebSocketImpl;
import org.json.JSONException;
import org.json.JSONObject;

import com.mmt.utils.CameraView;
import com.mmt.utils.IP;
import com.mmt.utils.Motion2Sound;
import com.mmt.utils.Motion2Sound.InvalidFrequencyException;
import com.mmt.utils.WCServer;
import com.mmt.utils.WCSocket;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.ImageFormat;
import android.graphics.Rect;
import android.graphics.YuvImage;
import android.hardware.Camera;
import android.hardware.Camera.PreviewCallback;
import android.net.NetworkInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.util.Base64;
import android.util.Log;
import android.view.SurfaceView;
import android.widget.TextView;

public class WebCarReleaseStreamActivity extends Activity implements
	CameraView.CameraReadyCallback {
	
	private static final String TAG = "WebCar :: Stream"; 
	private String mToken;
	private SecureRandom mPrng;
	
	private TextView mTextIP;
	private TextView mTextToken;
	
	boolean inProcessing = false;
	
	private WCServer mServer = null;
	private WCSocket mSocket = null;
	private CameraView mCameraView;
	private Motion2Sound Driver= null;
	
	/* receivers for phone connector & wifi */
	private MusicIntentReceiver mMusicReceiver;
	private WifiIntentReceiver mWifiReceiver;
	
	private WifiManager mWifi;
	private Timer timer;
	
	final Context context = this;
	
	public enum Type {
		CONNECT(0),
		DRIVE(1),
		KILL(2);
		
		private int code;
		private Type(int c) {
			code = c;
		}
		
		public int val() {
			return code;
		}
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.activity_web_car_release_stream);
		
		mTextIP = (TextView) findViewById(R.id.textReleaseStreamingIP);
		mTextToken = (TextView) findViewById(R.id.textReleaseStreamingToken);
		
		try {
			mPrng = SecureRandom.getInstance( "SHA1PRNG" );
			mToken = "Token: " + Integer.valueOf(mPrng.nextInt()).toString();
			
			mTextIP.setText(IP.getIPAddress(true) + ":8080");
			mTextToken.setText(mToken);
			
			mMusicReceiver = new MusicIntentReceiver();
			mWifiReceiver = new WifiIntentReceiver();
			
			timer = new Timer();			
			mWifi = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
			
			timer.scheduleAtFixedRate(new TimerTask() {
				  @Override
				  public void run() {
					  int linkSpeed = mWifi.getConnectionInfo().getLinkSpeed();
					  Log.d( TAG + " :: Speed", "Current Speed: " + linkSpeed);
				  }
				}, 1000, 1000);
			
			initCamera();
			
		} catch (Exception e) {
			Log.e( TAG, e.getMessage() );
		}
		
		try {
			Driver = new Motion2Sound(
					1000,	// min left frequency
					9000,	// max left frequency
					11000,	// min right frequency
					20000,	// max right frequency
					100,	// min backward frequency
					400,	// max backward frequency
					600,	// min forward frequency
					900,	// max forward frequency
					10000, 	// straightFreq
					500		//stopFreq
					);

			Driver.drive(0.5, 0.5);
		} catch (InvalidFrequencyException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
	
	@Override
	public void onPause() {
		super.onPause();

		inProcessing = true;
		if (mServer != null)
			mServer.stop();
		mCameraView.StopPreview();
		
		// unregister receivers
		unregisterReceiver(mMusicReceiver);
		unregisterReceiver(mWifiReceiver);
		
		finish();
	}
	
	@Override
	public void onResume() {
		registerReceiver(mMusicReceiver, new IntentFilter(Intent.ACTION_HEADSET_PLUG));
		registerReceiver(mWifiReceiver, new IntentFilter(WifiManager.NETWORK_STATE_CHANGED_ACTION));
		super.onResume();
	}
	
	@Override
	public void onCameraReady() {
		boolean initws = initWebServer();
		
		if ( initws ) {
			
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

		@Override
		public void onPreviewFrame(byte[] frame, Camera camera) {
			if (!inProcessing) {
				inProcessing = true;			

				try {
				
					int picWidth = mCameraView.Width();
					int picHeight = mCameraView.Height();
					
					boolean ret;
					
					ByteArrayOutputStream out = new ByteArrayOutputStream();
				
					YuvImage newImage = new YuvImage(frame, ImageFormat.NV21,
						picWidth, picHeight, null);
					
					ret = newImage.compressToJpeg( new Rect( 0, 0, picWidth, picHeight ), 40, out );
					
					if( ret ) {
						byte[] imageBytes = out.toByteArray();
						
						String byteString = Base64.encodeToString(imageBytes, Base64.NO_WRAP);
						
						mSocket.send( byteString );
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
		mSocket = new WCSocket(port) {
			@Override
			public void onMessage( WebSocket conn, String message ) {
				try {
					JSONObject json = new JSONObject(message);
					
					if (json.getInt("type") == Type.CONNECT.val()) {
						
					} else if (json.getInt("type") == Type.DRIVE.val()) {
						try {
							Driver.drive(json.getDouble("l2r"), json.getDouble("b2f"));
						} catch (Exception e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
					} else if (json.getInt("type") == Type.KILL.val()) {
						
					}
					
					
				} catch (JSONException e) {
					e.printStackTrace();
				}
				
			}
		};
		

		mSocket.start();
		Log.d(TAG, "WebCar Socket started on port: " + mSocket.getPort());

	}
	
	private class WifiIntentReceiver extends BroadcastReceiver {
		@Override
		public void onReceive(Context context, Intent intent) {
			
			if ( intent.getAction().equals( WifiManager.NETWORK_STATE_CHANGED_ACTION ) ) {
			  NetworkInfo info = (NetworkInfo)intent.getParcelableExtra(WifiManager.EXTRA_NETWORK_INFO);
			  if (info.getState().equals(NetworkInfo.State.CONNECTED)) {
				  Log.d( TAG, "Wifi - Network has changed to CONNECTED");
			  } else if (info.getState().equals(NetworkInfo.State.DISCONNECTED)) {
				  Log.d( TAG, "Wifi - Network has changed to DISCONNECTED");
			  }
			}

		}
	}
	
	private class MusicIntentReceiver extends BroadcastReceiver {
		@Override
		public void onReceive(Context context, Intent intent) {
			if (intent.getAction().equals(Intent.ACTION_HEADSET_PLUG)) {
				int state = intent.getIntExtra("state", -1);
				switch (state) {
					case 0:
						// unplugged
						Log.d( TAG, "Phone connector has been unplugged." );
						break;
					case 1:
						// plugged in
						Log.d( TAG, "Phone connector has been plugged in." );
						break;
					default:
						// unknown
						Log.d( TAG, "Phone connector status is unknown." );
						break;
				}
			}
		}
	}

}
