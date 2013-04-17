package com.mmt.webcar;


import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;

public class WebCarActivity extends Activity {
   

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);        

        setContentView(R.layout.activity_web_car);

        final View contentView = findViewById(R.id.fullscreen_content);
        final Button releaseButton = (Button) findViewById(R.id.btnRelease);
        releaseButton.setOnClickListener(onBtnRelease);

    }

    OnClickListener onBtnRelease = new OnClickListener() {
		
		@Override
		public void onClick(View v) {
			// Call new Activity
			Intent releaseIntent = new Intent(WebCarActivity.this, WebCarReleaseWLANActivity.class);
			WebCarActivity.this.startActivity(releaseIntent);
		}
	};
}
