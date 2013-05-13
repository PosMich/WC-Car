package com.mmt.utils;

import java.io.*;
import android.content.Context;

public class WCServer extends NanoHTTPD
{
	private static final String TAG = "WebCar :: Server";
    
    public WCServer(int port, Context ctx) throws IOException {
        super(port, ctx.getAssets());
    }
    
    public WCServer(int port, String wwwroot) throws IOException {
        super(port, new File(wwwroot).getAbsoluteFile() );
    }

}
