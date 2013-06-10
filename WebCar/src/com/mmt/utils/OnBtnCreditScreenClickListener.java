package com.mmt.utils;

import com.mmt.webcar.R;

import android.app.Dialog;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;

public class OnBtnCreditScreenClickListener implements OnClickListener {
	
	@Override
	public void onClick(View v) {
		final Dialog dialog = new Dialog(v.getContext());
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

}
