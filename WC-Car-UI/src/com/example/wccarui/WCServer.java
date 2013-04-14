package com.example.wccarui;

import java.io.*;
import android.content.Context;

public class WCServer extends NanoHTTPD
{
    static final String TAG="WCServer";
    
    public WCServer(int port, Context ctx) throws IOException {
        super(port, ctx.getAssets());
    }
    
    public WCServer(int port, String wwwroot) throws IOException {
        super(port, new File(wwwroot).getAbsoluteFile() );
    }

}
