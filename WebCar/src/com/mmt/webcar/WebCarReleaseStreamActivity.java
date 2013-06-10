package com.mmt.webcar;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.UnknownHostException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Collection;
import java.util.Properties;
import java.util.Timer;
import java.util.TimerTask;

import org.java_websocket.WebSocket;
import org.java_websocket.WebSocketImpl;
import org.java_websocket.handshake.Handshakedata;
import org.json.JSONException;
import org.json.JSONObject;

import com.mmt.utils.CameraView;
import com.mmt.utils.IP;
import com.mmt.utils.Motion2Sound;
import com.mmt.utils.Motion2Sound.InvalidFrequencyException;
import com.mmt.utils.NanoHTTPD.Response;
import com.mmt.utils.WCServer;
import com.mmt.utils.WCSocket;

import android.app.Activity;
import android.app.AlertDialog;
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
import android.media.AudioManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Handler;
import android.util.Base64;
import android.util.Log;
import android.view.SurfaceView;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;

public class WebCarReleaseStreamActivity extends Activity implements
	CameraView.CameraReadyCallback {
	
	private static final String TAG = "Stream"; 
	private String mToken;
	private SecureRandom mPrng;
	private boolean connected;
	private Handler mHandler;
	
	private TextView mTextIP;
	private TextView mTextToken;
	private AlertDialog mWifiAlertDialog;
	private AlertDialog mConnectorAlertDialog;
	
	boolean inProcessing;
	
	private WCServer mServer = null;
	private WCSocket mSocket = null;
	private CameraView mCameraView;
	private Motion2Sound Driver= null;
	
	/* receivers for phone connector & wifi */
	private MusicIntentReceiver mMusicReceiver;
	private WifiIntentReceiver mWifiReceiver;
	
	private WifiManager mWifi;
	private Timer mTimer;
	
	private Button mHomeButton;
	private Button mCreditScreenButton;
	
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
		mHandler = new Handler();
		
		inProcessing = false;
		connected = false;
		mTextIP = (TextView) findViewById(R.id.textReleaseStreamingIP);
		mTextToken = (TextView) findViewById(R.id.textReleaseStreamingToken);
		
		AlertDialog.Builder connectorAlertBuilder = new AlertDialog.Builder(context);
		connectorAlertBuilder.setMessage( "Phone connector has been unplugged!\nPlease plug the connector in again." );
		mConnectorAlertDialog = connectorAlertBuilder.create();
		
		AlertDialog.Builder wifiAlertBuilder = new AlertDialog.Builder(context);
		wifiAlertBuilder.setMessage( "Wifi Signal has been lost!\nPlease go back in the Wifi-range" );
		mWifiAlertDialog = wifiAlertBuilder.create();
		
		mHomeButton = (Button) findViewById(R.id.btnHome);
		mHomeButton.setOnClickListener(onHomeButton);
		
		mCreditScreenButton = (Button) findViewById(R.id.btnCreditScreen);
        mCreditScreenButton.setOnClickListener(onBtnCreditScreen);
		
		try {
			
			mTextIP.setText(IP.getIPAddress(true) + ":8080");
			setToken();
			mTextToken.setText("Token: " + mToken);
			
			mMusicReceiver = new MusicIntentReceiver();
			mWifiReceiver = new WifiIntentReceiver();
			
			mWifi = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
			
			initCamera();
			
		} catch (Exception e) {
			Log.e( TAG, e.getMessage() );
		}
		
		try {
			Driver = new Motion2Sound(
					2000,	// min left frequency
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
			Log.d("PlaySound", "drive(0,0)");
			Driver.drive(0.0, 0.0);
		} catch (InvalidFrequencyException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	
	}
	
	private void setToken() {
		
		try {
			mPrng = SecureRandom.getInstance( "SHA1PRNG" );
		} catch (NoSuchAlgorithmException e) {
			Log.e( TAG, e.getMessage() );
		}
		int token = mPrng.nextInt();
		if (token < 0)
			token*=-1;
		mToken = Integer.valueOf(token).toString();
		
	}
	
	private void startTimer() {
		try {
			mTimer = new Timer();
			mTimer.scheduleAtFixedRate(new TimerTask() {
				  @Override
				  public void run() {
					  int linkSpeed = mWifi.getConnectionInfo().getLinkSpeed();
					  Log.d( TAG + ".Speed", "Current Speed: " + linkSpeed);
					  mSocket.send("{\"type\": \"signal_strength\", \"value\": \"" + linkSpeed + "\"}");
				  }
				}, 1000, 1000);
		} catch (Exception e) {
			Log.e( TAG, e.getMessage() );
		}
	}	
	
	private void stopTimer() {
		
		mTimer.cancel();
		mTimer.purge();
		
	}
	
	@Override
	public void onPause() {
		super.onPause();
		
		inProcessing = true;
		if (mServer != null)
			mServer.stop();
		mCameraView.StopPreview();
		
		stopTimer();
		
		// unregister receivers
		unregisterReceiver(mMusicReceiver);
		unregisterReceiver(mWifiReceiver);	
	}
	
	@Override
	public void onResume() {
		startTimer();
		inProcessing = false;
		
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
						mSocket.send("{\"type\": \"image_data\", \"value\": \"" + byteString + "\"}");
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
	
	
	private boolean initWebServer() {
		
		String ipAddr = IP.getIPAddress(true);
		if (ipAddr != null) {
			try {
				setupSocket(8081);
				mServer = new WCServer(8080, this) {
					@Override
					public Response serve( String uri, String method, Properties header, Properties parms, Properties files ) {
						
						if( method.equalsIgnoreCase( "POST" ) ) {
							// check admin passphrase and server admin interface
							String passphrase = ((WebCarApplication)getApplication()).getPassphrase();
							Log.d( TAG + " :: Connection", "Got a post request. " + "Param: " + 
									parms.getProperty("passphrase") + " - should be: " + passphrase );
							
							if( parms.getProperty("passphrase").equals(passphrase) ) {
								Collection<WebSocket> con = mSocket.connections();
								synchronized ( con ) {
									for( WebSocket c : con ) {
										c.close();
									}
								}
								setToken();
								
								mHandler.post(new Runnable() {
						            @Override
						            public void run() {
						                // This gets executed on the UI thread so it can safely modify Views
						            	mTextToken.setText("Token: " + mToken);
						            }
						        });
								
								
							}
						}
						
						return super.serve( uri, method, header, parms, files );
					}
				};

			} catch (IOException e) {
				mServer = null;
			}
		}
		if (mServer != null)
			return true;
		else
			return false;
		
	}
	

	public void setupSocket(int port) throws UnknownHostException {
		WebSocketImpl.DEBUG = true;
		mSocket = new WCSocket(port) {
			@Override
			public void onMessage( WebSocket conn, String message ) {
				try {
					JSONObject json = new JSONObject(message);
					
					if (json.getInt("type") == Type.CONNECT.val()) {
						Log.d( TAG + ".Message", "Type is correct." );
						if( !connected ) {							
							if( json.getString("token").equals(mToken) ) {
								Log.d( TAG + ".Message", "Token is correct." );
								connected = true;
							} else {
								conn.close();
							}
						}
					} else if (json.getInt("type") == Type.DRIVE.val() && connected ) {
						try {
							Log.d( TAG + ".Message", "L2R: " + json.getDouble("l2r") 
									+ ", B2F: " + json.getDouble("b2f") );
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
			
			@Override
			public void send( String text ) {
				if( connected )
					super.send( text );
			}
			
			@Override
			protected boolean addConnection( WebSocket ws ) {
				if( this.connections().size() == 0 ) {
					Log.d(TAG + " :: Connection", "i've added a connection.");
					return super.addConnection(ws);
				} else {
					Log.d(TAG + " :: Connection", "i've blocked a connection.");
					ws.close();
					return false;
				}
			}
			
			@Override
			public void onClose( WebSocket conn, int code, String reason, boolean remote ) {
				connected = false;
				super.onClose(conn, code, reason, remote);
			}
		};
		

		mSocket.start();
		Log.d(TAG, "WebCar Socket started on port: " + mSocket.getPort());
		
	}
	
	@Override
	public void onStop() {
		
		try {
			mSocket.stop();
		} catch(Exception e) {
			Log.e( TAG, e.getMessage() );
		}
		
		super.onStop();
	}
	
	private class WifiIntentReceiver extends BroadcastReceiver {
		@Override
		public void onReceive(Context context, Intent intent) {
			
			if ( intent.getAction().equals( WifiManager.NETWORK_STATE_CHANGED_ACTION ) ) {
			  NetworkInfo info = (NetworkInfo)intent.getParcelableExtra(WifiManager.EXTRA_NETWORK_INFO);
			  if (info.getState().equals(NetworkInfo.State.CONNECTED)) {
				  Log.d( TAG, "Wifi - Network has changed to CONNECTED");
				  mWifiAlertDialog.dismiss();
			  } else if (info.getState().equals(NetworkInfo.State.DISCONNECTED)) {
				  Log.d( TAG, "Wifi - Network has changed to DISCONNECTED");
				  mWifiAlertDialog.show();
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
						mConnectorAlertDialog.show();
						break;
					case 1:
						// plugged in
						Log.d( TAG, "Phone connector has been plugged in." );
						mConnectorAlertDialog.dismiss();
						break;
					default:
						// unknown
						Log.d( TAG, "Phone connector status is unknown." );
						
						mConnectorAlertDialog.show();
						break;
				}
			}
		}
	}
	
	
	OnClickListener onHomeButton = new OnClickListener() {
		
		@Override
		public void onClick(View v) {
			// Call new Activity
			Intent releaseIntent = new Intent(WebCarReleaseStreamActivity.this, WebCarActivity.class);
			WebCarReleaseStreamActivity.this.startActivity(releaseIntent);
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
