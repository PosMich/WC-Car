package com.mmt.utils;

import com.mmt.webcar.WebCarActivity;

import android.content.Intent;
import android.view.View;
import android.view.View.OnClickListener;

public class OnHomeBtnClickListener implements OnClickListener{

	@Override
	public void onClick(View v) {
		// Call new Activity
		Intent releaseIntent = new Intent(v.getContext(), WebCarActivity.class);
		v.getContext().startActivity(releaseIntent);
	}
}
