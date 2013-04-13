package com.example.wccarui;

import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.util.List;
import java.util.Properties;

import com.example.wc_car_ui.R;
import com.example.wccarui.CameraView.CameraReadyCallback;
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
import android.os.Handler;
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
 
public class MainActivity extends Activity 
	implements View.OnTouchListener, CameraView.CameraReadyCallback, OverlayView.UpdateDoneCallback{
 
	boolean inProcessing = false;
    final int maxVideoNumber = 3;
    VideoFrame[] videoFrames = new VideoFrame[maxVideoNumber];
    byte[] preFrame = new byte[1024*1024*8];
    
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
        
        for(int i = 0; i < maxVideoNumber; i++) {
            videoFrames[i] = new VideoFrame(1024*1024*2);        
        }    

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
        if ( mServer != null)
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
	};
	
	/* TEAONLY ZEUGS */
	
    @Override
    public void onCameraReady() {
        if ( initWebServer() ) {
            int wid = mCameraView.Width();
            int hei = mCameraView.Height();
            mCameraView.StopPreview();
            mCameraView.setupCamera(wid, hei, previewCb_);
            mCameraView.StartPreview();
        }
    }
    
    @Override
    public void onUpdateDone() {
    }
    
    @Override
    public void onDestroy(){
        super.onDestroy();
    }   

    @Override
    public void onStart(){
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
        SurfaceView cameraSurface = (SurfaceView)findViewById(R.id.surface_camera);
        mCameraView = new CameraView(cameraSurface);        
        mCameraView.setCameraReadyCallback(this);

//        overlayView_ = (OverlayView)findViewById(R.id.surface_overlay);
//        overlayView_.setOnTouchListener(this);
//        overlayView_.setUpdateDoneCallback(this);
    }
    
    private boolean initWebServer() {
        String ipAddr = IP.getIPAddress(true);
        if ( ipAddr != null ) {
            try{
                mServer = new WCServer(8080, this); 
                mServer.registerCGI("/cgi/query", doQuery);
                mServer.registerCGI("/cgi/setup", doSetup);
                mServer.registerCGI("/stream/live.jpg", doCapture);
            }catch (IOException e){
                mServer = null;
            }
        }
        if ( mServer != null) {
            // tvMessage1.setText( getString(R.string.msg_access_local) + " http://" + ipAddr  + ":8080" );
            NatPMPClient natQuery = new NatPMPClient();
            natQuery.start();  
            return true;
        } else {
//            tvMessage1.setText( getString(R.string.msg_error) );
//            tvMessage2.setVisibility(View.GONE);
            return false;
        }
          
    }
    
    private PreviewCallback previewCb_ = new PreviewCallback() {
        public void onPreviewFrame(byte[] frame, Camera c) {
            if ( !inProcessing ) {
                inProcessing = true;
           
                int picWidth = mCameraView.Width();
                int picHeight = mCameraView.Height(); 
                ByteBuffer bbuffer = ByteBuffer.wrap(frame); 
                bbuffer.get(preFrame, 0, picWidth*picHeight + picWidth*picHeight/2);

                inProcessing = false;
            }
        }
    };
    
    private WCServer.CommonGatewayInterface doQuery = new WCServer.CommonGatewayInterface () {
        @Override
        public String run(Properties parms) {
            String ret = "";
            List<Camera.Size> supportSize =  mCameraView.getSupportedPreviewSize();                             
            ret = ret + "" + mCameraView.Width() + "x" + mCameraView.Height() + "|";
            for(int i = 0; i < supportSize.size() - 1; i++) {
                ret = ret + "" + supportSize.get(i).width + "x" + supportSize.get(i).height + "|";
            }
            int i = supportSize.size() - 1;
            ret = ret + "" + supportSize.get(i).width + "x" + supportSize.get(i).height ;
            return ret;
        }
        
        @Override 
        public InputStream streaming(Properties parms) {
            return null;
        }    
    }; 

    private WCServer.CommonGatewayInterface doSetup = new WCServer.CommonGatewayInterface () {
        @Override
        public String run(Properties parms) {
            int wid = Integer.parseInt(parms.getProperty("wid")); 
            int hei = Integer.parseInt(parms.getProperty("hei"));
            Log.d("TEAONLY", ">>>>>>>run in doSetup wid = " + wid + " hei=" + hei);
            mCameraView.StopPreview();
            mCameraView.setupCamera(wid, hei, previewCb_);
            mCameraView.StartPreview();
            return "OK";
        }   
 
        @Override 
        public InputStream streaming(Properties parms) {
            return null;
        }    
    };

    private WCServer.CommonGatewayInterface doCapture = new WCServer.CommonGatewayInterface () {
        @Override
        public String run(Properties parms) {
           return null;
        }   
        
        @Override 
        public InputStream streaming(Properties parms) {
            VideoFrame targetFrame = null;
            for(int i = 0; i < maxVideoNumber; i++) {
                if ( videoFrames[i].acquire() ) {
                    targetFrame = videoFrames[i];
                    break;
                }
            }
            // return 503 internal error
            if ( targetFrame == null) {
                Log.d("TEAONLY", "No free videoFrame found!");
                return null;
            }

            // compress yuv to jpeg
            int picWidth = mCameraView.Width();
            int picHeight = mCameraView.Height(); 
            YuvImage newImage = new YuvImage(preFrame, ImageFormat.NV21, picWidth, picHeight, null);
            targetFrame.reset();
            boolean ret;
            inProcessing = true;
            try{
                ret = newImage.compressToJpeg( new Rect(0,0,picWidth,picHeight), 30, targetFrame);
            } catch (Exception ex) {
                ret = false;    
            } 
            inProcessing = false;

            // compress success, return ok
            if ( ret == true)  {
                parms.setProperty("mime", "image/jpeg");
                InputStream ins = targetFrame.getInputStream();
                return ins;
            }
            // send 503 error
            targetFrame.release();

            return null;
        }
    }; 

    static private native String nativeQueryInternet();
    private class NatPMPClient extends Thread {
        String queryResult;
        Handler handleQueryResult = new Handler(getMainLooper());  
        @Override
        public void run(){
             queryResult = nativeQueryInternet();
            if ( queryResult.startsWith("error:") ) {
                handleQueryResult.post( new Runnable() {
                    @Override
                    public void run() {
//                        tvMessage2.setText( getString(R.string.msg_access_query_error));                        
                    }
                });
            } else {
                handleQueryResult.post( new Runnable() {
                    @Override
                    public void run() {
//                        tvMessage2.setText( getString(R.string.msg_access_internet) + " " + queryResult );
                    }
                });
            }
        }    
    }
    
    
}


