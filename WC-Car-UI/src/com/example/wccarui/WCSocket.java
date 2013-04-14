package com.example.wccarui;

import java.net.InetSocketAddress;
import java.net.UnknownHostException;
import java.util.Collection;

import org.java_websocket.WebSocket;
import org.java_websocket.handshake.ClientHandshake;
import org.java_websocket.server.WebSocketServer;

import android.util.Log;

public class WCSocket extends WebSocketServer{
	
	private static final String TAG = "WC-Socket";

	public WCSocket( int port ) throws UnknownHostException {
		super( new InetSocketAddress( port ) );
	}

	public WCSocket( InetSocketAddress address ) {
		super( address );
	}

	@Override
	public void onOpen( WebSocket conn, ClientHandshake handshake ) {
		Log.d( TAG,  conn.getRemoteSocketAddress().getAddress().getHostAddress() + " entered the room!" );
	}

	@Override
	public void onClose( WebSocket conn, int code, String reason, boolean remote ) {
		Log.d( TAG,  conn + " has left the room!" );
	}

	@Override
	public void onMessage( WebSocket conn, String message ) {
		Log.d( TAG,  conn + ": " + message );
		this.send( message );
	}

	@Override
	public void onError( WebSocket conn, Exception ex ) {
		ex.printStackTrace();
		if( conn != null ) {
			// some errors like port binding failed may not be assignable to a specific websocket
		}
	}

	/**
	 * Sends <var>text</var> to all currently connected WebSocket clients.
	 * 
	 * @param text
	 *            The String to send across the network.
	 * @throws InterruptedException
	 *             When socket related I/O errors occur.
	 */
	
	public void send( String text ) {
		Collection<WebSocket> con = connections();
		synchronized ( con ) {
			for( WebSocket c : con ) {
				c.send( text );;
			}
		}
	}	
	
}
