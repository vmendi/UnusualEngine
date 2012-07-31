/** 
 * Copyright (C) 2008 Alan Ross, hello@adjazent.com
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

package org.wiiflash.wiiflashserverj;

//import regular java
import java.net.Socket;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.nio.ByteBuffer;

import org.wiiflash.wiiflashserverj.data.WiiDeviceData;


public class SocketConnection extends Thread
{
	//used for log
	private final String CLASS_NAME = "SocketConnection";
	//small buffer. WiiFlash starts processing when pointer reaches Buffer size
	private final int BUFFER_SIZE_OUT = 80;	// in first WiiFlash 0.4 release this was 92
	// flash client sends this string to request a policy file 
	private final String POLICY_REQUEST = "<policy-file-request/>";
	
	private WiiFlashServerJ wfs;
	
    private Socket socket = null;
    
    private boolean quit = false;
    
    private DataInputStream socketIn;
    private DataOutputStream socketOut;
    private ByteBuffer out;
    private StringBuffer in;
    
    /**
	 * Creates a new SocketConnection thread with given socket.
	 */
    public SocketConnection(WiiFlashServerJ wfs, Socket socket)
    {
    	this.wfs = wfs;
    	this.socket = socket;
    	try
		{
			out = ByteBuffer.allocate(BUFFER_SIZE_OUT);
			in = new StringBuffer();
        	socketIn = new DataInputStream(socket.getInputStream());
    		socketOut = new DataOutputStream(socket.getOutputStream());
		}
    	catch(Exception e){ System.err.println(e.getMessage()); }
    }
    
    /**
     * Send and listen on port until quit.
     */
    public void run()
    {
    	wfs.log(CLASS_NAME, "start sending & listen for input from client");
    
		try
		{
			socket.setTcpNoDelay(true);
    		//socket.setSoTimeout(10000);
    		
			byte b;
			byte moteID;
			byte moteAction;
			byte moteParam;
			
			while (!quit)
			{
				//read input as byte
				b = socketIn.readByte();
				in.appendCodePoint(b);
				
				//check if flash policy file was requested	
				if( in.toString().equals(POLICY_REQUEST) ){ sendFlashPolicyFile(); }
				//System.out.println("Client input: " + in.toString());
				
				
				//check if valid ID of Wiimote
				if(b >= 0 && b <= 3)
				{
					moteID = b;
					moteAction = socketIn.readByte();
					moteParam = socketIn.readByte();
					//System.out.println(id + " " + action + " " + param);
					
					//handle rumble request
					if(moteAction == 0x72)
					{
						if(moteParam == 0x31){ wfs.startVibrating(moteID); }
						if(moteParam == 0x30){ wfs.stopVibrating(moteID); }
					}
					//handle LED request
					if(moteAction == 0x6c){ wfs.setLEDLights(moteID, moteParam); }
					//handle mouse control request
					if(moteAction == 0x76)
					{
						if(moteParam == 0x31){ wfs.startMouseControl(moteID); }
						if(moteParam == 0x30){ wfs.stopMouseControl(moteID); }
					}
				}
			}
			
			wfs.log(CLASS_NAME, "has quit");
		    socketIn.close();
		    socketOut.close();
	    	socket.close();
				
		}
		catch (Exception e)
		{ System.err.println("Exception "+e.getMessage()); }
    }
    
	
    
    /**
     * Return true if SocketConnection is running, false if not.
     */
    public boolean isRunning()
    {	
    	return !quit;
    }
    
    
    /**
     * Quit running server.
     */
    public void quit()
    {
    	wfs.log(CLASS_NAME, "quitting");
    	quit = true;
    }
   
    
    
    /**
     * send cross domain flash policy. This allows 
     * a flash client to run and connect to the socket
     */
    public void sendFlashPolicyFile()
	{
		try
		{
	    	wfs.log(CLASS_NAME, "send Flash policy file");
			
			String flashPolicy = "<?xml version='1.0'?>" +
				"<!DOCTYPE cross-domain-policy SYSTEM '/xml/dtds/cross-domain-policy.dtd'>" +
				"<cross-domain-policy>" +
				"<site-control permitted-cross-domain-policies='all'/>" +
				"<allow-access-from domain='*' to-ports='*'/>" +
				"</cross-domain-policy>";
			//haven't figured out this problem fully. yet.
			//if using PrintWriter, Flash always accepts the policy file
			//if using the DataOutputStream it sometimes works. yeah. so much fun debugging. thanks....
			//PrintWriter pw = new PrintWriter(socket.getOutputStream(), true);
			//pw.println(flashPolicy + "\u0000"); pw.flush();
			
			//write bytes, even though we are writing a string, flash client does not accept writeUTF().
			socketOut.writeBytes(flashPolicy+"\n\u0000");
			socketOut.flush();
		}
		catch(Exception e){System.err.println(e.getMessage());}
	}
    
    
    
    /**
     * Send the wiimote data collected by the WiiMoteData class.
     * All separate data values are inserted into a byte array the way WiiFlash wants the data.
     *  
     * @param data, the data of of a connected Wiimote
     */
    public void sendWiiData(WiiDeviceData data)
	{
    	try
    	{
	    	out.clear();							// clear byte buffer
	    	out.position(0);						// set pointer to 0
			
	    	out.put((byte) data.id);				// wiimote id (0 - 3)
	    	out.put((byte) (data.battery*200));		// wiimote battery level convert from 0 - 1 to 0 - 200
			
	    	out.putShort((short) data.mButtons);	// mote button IDs & state (short)
	    	out.putFloat((float) data.mAccelX);		// mote x acceleration
	    	out.putFloat((float) data.mAccelY);		// mote y acceleration
	    	out.putFloat((float) data.mAccelZ);		// mote z acceleration
			
	    	out.put((byte) data.hasExtension);		// has extension (0=none, 1=nunchuck, 2=classic, 3= board)
	    	
			if(data.hasExtension == 0)				// no extension
			{
				out.position(38);					// just jump ahead
			}
			if(data.hasExtension == 1)				// nunchuck
			{
				out.put((byte) data.nButtons);		// button IDs & state (byte)
				out.putFloat((float) data.nStickX);	// stick X
				out.putFloat((float) data.nStickY);	// stick Y
				out.putFloat((float) data.nAccelX);	// nunchuck accel x
				out.putFloat((float) data.nAccelY);	// nunchuck accel y
				out.putFloat((float) data.nAccelZ);	// nunchuck accel z
			}
			if(data.hasExtension == 2)				// classic controller <- CAREFULL: THIS PART IS STILL BLIND GUESSING
			{
				out.putShort((short) data.cButtons);// button IDs & state (short)
				out.putFloat((float) data.cStickLX);// stickXLeft
				out.putFloat((float) data.cStickLY);// stickYLeft
				out.putFloat((float) data.cStickRX);// stickXRight
				out.putFloat((float) data.cStickLY);// stickYRight
			}
			
			if(data.hasExtension == 3)				// balance board <- CAREFULL: THIS PART IS STILL BLIND GUESSING
			{
				out.putFloat((float) data.kgTopLeft);	// kg on top left
				out.putFloat((float) data.kgTopRight);	// kg on top right
				out.putFloat((float) data.kgBottomRight);// kg on bottom right
				out.putFloat((float) data.kgBottomLeft);// kg on bottom left
				out.putFloat((float) data.kgTotal);		// kg total
			}
			
			if( data.irP[0].x != -10 ){ out.put((byte) 1); }	// point1 is active
			else{ out.put((byte) 0); }
			out.putFloat((float) data.irP[0].x);		// ir x1
			out.putFloat((float) data.irP[0].y);		// ir y1
			
			if( data.irP[1].x != -10 ){ out.put((byte) 1); }	// point2 is active
			else{ out.put((byte) 0); }
			out.putFloat((float) data.irP[1].x);		// ir x2
			out.putFloat((float) data.irP[1].y);		// ir y2
			
			if( data.irP[2].x != -10 ){ out.put((byte) 1); }	// point3 is active
			else{ out.put((byte) 0); }
			out.putFloat((float) data.irP[2].x);		// ir x3
			out.putFloat((float) data.irP[2].y);		// ir y3
			
			if( data.irP[3].x != -10 ){ out.put((byte) 1); }	// point4 is active
			else{ out.put((byte) 0); }
			out.putFloat((float) data.irP[3].x);		// ir x4
			out.putFloat((float) data.irP[3].y);		// ir y4
			
			out.put((byte) (data.irS[0]*15));			// ir size of p1 convert 0 - 1 to 0 - 15
			out.put((byte) (data.irS[1]*15));			// ir size of p2
			out.put((byte) (data.irS[2]*15));			// ir size of p3
			out.put((byte) (data.irS[3]*15));			// ir size of p4
			
			//write output to socket / WiiFlash
			socketOut.write(out.array());
			socketOut.flush();
			//wfs.log(CLASS_NAME, "send remote data");
		}
		catch(Exception e){}	
	}
}