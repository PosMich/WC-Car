package com.mmt.webcar;

import android.app.Application;

public class WebCarApplication extends Application{
	private int mVolume = -1;
	private String mPassphrase;
	private int mToken;
	
	public void setVolume( int vVolume ) {
		mVolume = vVolume;
	}
	
	public int getVolume() {
		return mVolume;
	}
	
	public void setPassphrase( String vPassphrase ) {
		mPassphrase = vPassphrase;
	}
	
	public String getPassphrase() {
		return mPassphrase;
	}
	
	public void setToken( int vToken ) {
		mToken = vToken;
	}
	
	public int getToken() {
		return mToken;
	}
	
	@Override
	public void onCreate() {
		mVolume = -1;
		mPassphrase = "";
	}
}