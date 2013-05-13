package com.mmt.webcar;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.UnknownHostException;
import java.security.GeneralSecurityException;
import java.security.SecureRandom;
import java.util.UUID;

import org.java_websocket.WebSocketImpl;

import com.mmt.utils.CameraView;
import com.mmt.utils.IP;
import com.mmt.utils.WCServer;
import com.mmt.utils.WCSocket;

import android.app.Activity;
import android.content.Context;
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
import android.widget.TextView;

public class WebCarReleaseStreamActivity extends Activity implements
	CameraView.CameraReadyCallback {
	
	private static final String TAG = "WebCar :: Stream";
	private static final int TOKEN_LENGTH = 8; 
	private String mToken;
	private SecureRandom mPrng;
	
	private TextView mTextIP;
	private TextView mTextToken;
	
	boolean inProcessing = false;
	
	private WCServer mServer = null;
	private WCSocket mSocket = null;
	private CameraView mCameraView;
	
	final Context context = this;

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
		} catch (GeneralSecurityException e) {
			Log.e( TAG, e.getMessage() );
		}
		

//		final View contentView = findViewById(R.id.fullscreen_content);
		
		initCamera();
	}
	
	@Override
	public void onPause() {
		super.onPause();

		inProcessing = true;
		if (mServer != null)
			mServer.stop();
		mCameraView.StopPreview();
		
		finish();
	}
	
	@Override
	public void onCameraReady() {
		boolean initws = initWebServer();
		String test = (initws) ? "true" : "false";
		Log.d( TAG, test );
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

/*	@Override
	public boolean onTouch(View v, MotionEvent evt) {

		return false;
	}*/

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
					
					Log.d( TAG, picWidth + " x " + picHeight );
					
					boolean ret;
					
					ByteArrayOutputStream out = new ByteArrayOutputStream();
				
					YuvImage newImage = new YuvImage(frame, ImageFormat.NV21,
						picWidth, picHeight, null);
					
					
					
					ret = newImage.compressToJpeg( new Rect( 0, 0, picWidth, picHeight ), 40, out );
					
					Log.d( TAG + " :: Image", "File to send is " + out.size() + "byte large.");
					
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
		mSocket = new WCSocket(port);

		mSocket.start();
		Log.d("WC-Socket", "ChatServer started on port: " + mSocket.getPort());

	}

}
