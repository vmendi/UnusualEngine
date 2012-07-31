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

package org.wiiflash.wiiflashserverj.adapter;


import java.awt.AWTException;
import java.util.Timer;
import java.util.TimerTask;

import org.wiiflash.wiiflashserverj.WiiFlashServerJ;
import org.wiiflash.wiiflashserverj.data.WiiDeviceData;


//import WiiremoteJ
import wiiremotej.*;
import wiiremotej.event.*;


public class WiiMoteAdapter extends WiiRemoteAdapter implements IWiiDeviceAdapter
{
	//used for log
	private final String CLASS_NAME = "WiiMoteAdapter";
	
	private WiiFlashServerJ wfs;
	private WiiRemote remote;
	private WiiDeviceData data;
	
    /**
     * Creates a new WiiMoteAdapter object
     * 
     * @param wfs the WiiFlashServerJ
     * @param remote the WiiRemote
     */
    public WiiMoteAdapter(WiiFlashServerJ wfs, WiiRemote remote, int moteID)
    {
    	this.wfs = wfs;
    	this.remote = remote;
        
        data = new WiiDeviceData();
        
        try{ data.bluetooth = remote.getBluetoothAddress(); }
    	catch(Exception e){}
    	
    	data.id = moteID;
    }
    
    /**
     * initialize the WiiRemote adapter
     */
    public boolean setup()
    {
    	boolean noErrorsOccured = true;
    	wfs.log(CLASS_NAME +" "+data.id, "starting up");
        
        try
        {
        	remote.addWiiRemoteListener(this);
        	remote.enableContinuous();
        	remote.setAccelerometerEnabled(true);
            //remote.setSpeakerEnabled(true);
            remote.setIRSensorEnabled(true, WRIREvent.EXTENDED);
            remote.setLEDIlluminated(data.id, true);
            
            remote.requestStatus();
        }
        catch(Exception e)
        {
        	if(e.getMessage() == "Error sending data!")
        	{
        		noErrorsOccured = false;
        		wfs.log(CLASS_NAME +" "+data.id, "ERROR OCCURED during setup");
        	}
        }
        return noErrorsOccured;
    }
    
    /**
     * get Data of Wiimote
     * @return all WiiMoteData
     */
    public WiiDeviceData getData()
    {
    	return data;
    }
    
    /**
     * Set the LED lights of this WiiRemote.
     * Pass Light ID to toggle LED light.
     * 
     * @param lightID (0=Light1, 1=Light2 ...)
     */
    public void setLEDLights(int lightID)
    {
    	try
    	{
    		boolean[] leds = remote.getLEDLights();
    		if(lightID == 0){ leds[0] = !leds[0]; }
    		if(lightID == 1){ leds[1] = !leds[1]; }
    		if(lightID == 2){ leds[2] = !leds[2]; }
    		if(lightID == 3){ leds[3] = !leds[3]; }
    		
    		remote.setLEDLights(leds);
    	}
    	catch(Exception e){}
    }
    
    /**
     * Start vibrating this WiiRemote
     */
    public void startVibrating()
    {
    	try{ remote.startVibrating(); }
    	catch(Exception e){}
    }
    
    /**
     * Stop vibrating this WiiRemote
     */
    public void stopVibrating()
    {
    	try{ remote.stopVibrating(); }
    	catch(Exception e){}
    }
    
    /**
     * Start using this WiiRemote as mouse
     */
    public void startMouseControl()
    {
    	wfs.log(CLASS_NAME, "start mouse control");
    	try{ remote.setMouse(TiltAccelerometerMouse.getDefault()); }
    	catch(AWTException e){}
    }
    
    /**
     * Stop using this WiiRemote as mouse
     */
    public void stopMouseControl()
    {
    	wfs.log(CLASS_NAME, "stop mouse control");
    	remote.setMouse(null);
    }
    
    /**
	 * Disconnect this WiiRemote
	 */
	public void disconnect()
	{
		wfs.log(CLASS_NAME +" "+data.id, "disconnect");
		if(remote != null || remote.isConnected())
		{ remote.disconnect(); }
	}
	
    /**
	 * Fires whenever input is received on the regular input reports (0x30...0x3f).
	 * 
	 * [NOTE] Buttons: WiiFlash uses bit shifting and the logic AND operator to find the buttons that 
	 * were pressed.
	 * if the button e.g. LEFT is pressed then  0000.0000.0000.0000.0000.0000.0001.0000 is sent = 32
	 * if the button e.g. RIGHT is pressed then 0000.0000.0000.0000.0000.0000.0010.0000 is sent = 64
	 * this way the button id AND state are encoded into one single number. It also is possible
	 * to encode states of several buttons into that number:
	 * If button LEFT & RIGHT are pressed then 0000.0000.0000.0000.0000.0000.0011.0000 is sent = 96
	 * 
	 * EXTENSION DATA IS NOT IMPLEMENTED / PROCESSED YET
	 */
	public void	combinedInputReceived(WRCombinedEvent evt) 
    {
		try
		{
			//get remote button input
			data.mButtons = 0;
			if (evt.getButtonEvent().isPressed(WRButtonEvent.ONE)){ data.mButtons += data.ONE; }
			if (evt.getButtonEvent().isPressed(WRButtonEvent.TWO)){ data.mButtons += data.TWO; }
			if (evt.getButtonEvent().isPressed(WRButtonEvent.A)){ data.mButtons += data.A; }
	        if (evt.getButtonEvent().isPressed(WRButtonEvent.B)){ data.mButtons += data.B; }
	        if (evt.getButtonEvent().isPressed(WRButtonEvent.PLUS)){ data.mButtons += data.PLUS; }
	        if (evt.getButtonEvent().isPressed(WRButtonEvent.MINUS)){ data.mButtons += data.MINUS; }
	        if (evt.getButtonEvent().isPressed(WRButtonEvent.HOME)){ data.mButtons += data.HOME; }
	        if (evt.getButtonEvent().isPressed(WRButtonEvent.UP)){ data.mButtons += data.UP; }
	        if (evt.getButtonEvent().isPressed(WRButtonEvent.DOWN)){ data.mButtons += data.DOWN; }
	        if (evt.getButtonEvent().isPressed(WRButtonEvent.RIGHT)){ data.mButtons += data.RIGHT; }
	        if (evt.getButtonEvent().isPressed(WRButtonEvent.LEFT)){ data.mButtons += data.LEFT; }
	        
	        //get remote acceleration input
	        data.mAccelX = (float) evt.getAccelerationEvent().getXAcceleration();
	        data.mAccelY = (float) evt.getAccelerationEvent().getYAcceleration(); 
	        data.mAccelZ = (float) evt.getAccelerationEvent().getZAcceleration();
			
			//get remote IR input
	        data.irP[0].setLocation(-10,-10);
	        data.irP[1].setLocation(-10,-10);
	        data.irP[2].setLocation(-10,-10);
	        data.irP[3].setLocation(-10,-10);
	        data.irS[0] = 0;
	        data.irS[1] = 0;
	        data.irS[2] = 0;
	        data.irS[3] = 0;
			
			int lightCounter = 0;
			for (IRLight light : evt.getIREvent().getIRLights())
	        {
	            if (light != null)
	            {
	            	data.irP[lightCounter].setLocation((float)light.getX(), -(float)light.getY());
	            	//If Extension is plugged in, WiiremoteJ sends -1 as the size of the point 
	            	if(data.hasExtension == 0){ data.irS[lightCounter] = (float)light.getSize(); }
	            	else { data.irS[lightCounter] = (float) .1; }
	            	lightCounter++;
	            }
	        }
		
			//get extensions input
			if (evt.getExtensionEvent() instanceof WRNunchukExtensionEvent)
	        { 
				data.hasExtension = 1; 
				WRNunchukExtensionEvent NEvt = (WRNunchukExtensionEvent)evt.getExtensionEvent();
		        
				data.nButtons = 0;
				if (NEvt.isPressed(WRNunchukExtensionEvent.C)){ data.nButtons += data.NC; }
				if (NEvt.isPressed(WRNunchukExtensionEvent.Z)){ data.nButtons += data.NZ; }
				
				data.nStickX = (float) NEvt.getAnalogStickData().getX();
				data.nStickY = (float) NEvt.getAnalogStickData().getY();
				
				data.nAccelX = (float) NEvt.getAcceleration().getXAcceleration();
				data.nAccelY = (float) NEvt.getAcceleration().getYAcceleration();
				data.nAccelZ = (float) NEvt.getAcceleration().getZAcceleration();				
			}
			//Classic controller (NOT IMPLEMENTED YET, JUST GUESSING...)
	        else if (evt.getExtensionEvent() instanceof WRClassicControllerExtensionEvent)
	        { 
	        	data.hasExtension = 2;
				WRClassicControllerExtensionEvent CEvt = (WRClassicControllerExtensionEvent)evt.getExtensionEvent();
				
				data.cButtons = 0;
				if (CEvt.isPressed(WRClassicControllerExtensionEvent.A)){ data.cButtons += data.A; }
		        if (CEvt.isPressed(WRClassicControllerExtensionEvent.B)){ data.cButtons += data.B; }
		        if (CEvt.isPressed(WRClassicControllerExtensionEvent.DPAD_LEFT)){ data.cButtons += data.LEFT; }
		        if (CEvt.isPressed(WRClassicControllerExtensionEvent.DPAD_RIGHT)){ data.cButtons += data.RIGHT; }
		        if (CEvt.isPressed(WRClassicControllerExtensionEvent.DPAD_UP)){ data.cButtons += data.UP; }
		        if (CEvt.isPressed(WRClassicControllerExtensionEvent.DPAD_DOWN)){ data.cButtons += data.DOWN; }
		        if (CEvt.isPressed(WRClassicControllerExtensionEvent.PLUS)){ data.cButtons += data.PLUS; }
		        if (CEvt.isPressed(WRClassicControllerExtensionEvent.MINUS)){ data.cButtons += data.MINUS; }
		        if (CEvt.isPressed(WRClassicControllerExtensionEvent.HOME)){ data.cButtons += data.HOME; }
		        
		        if (CEvt.isPressed(WRClassicControllerExtensionEvent.Y)){ data.cButtons += data.Y; }
		        if (CEvt.isPressed(WRClassicControllerExtensionEvent.X)){ data.cButtons += data.X; }
		        if (CEvt.isPressed(WRClassicControllerExtensionEvent.LEFT_Z)){ data.cButtons += data.ZL; }
		        if (CEvt.isPressed(WRClassicControllerExtensionEvent.RIGHT_Z)){ data.cButtons += data.ZR; }
		        if (CEvt.isPressed(WRClassicControllerExtensionEvent.LEFT_TRIGGER)){ data.cButtons += data.L; }
		        if (CEvt.isPressed(WRClassicControllerExtensionEvent.RIGHT_TRIGGER)){ data.cButtons += data.R; }
		        
		        data.cStickLX = (float) CEvt.getLeftAnalogStickData().getX();
		        data.cStickLY = (float) CEvt.getLeftAnalogStickData().getY();
		        data.cStickRX= (float) CEvt.getRightAnalogStickData().getX();
		        data.cStickRY= (float) CEvt.getRightAnalogStickData().getY();
		        
		        //CEvt.getLeftTrigger(); ???
		        //CEvt.getRightTrigger(); ???
			}
			//Guitar (NOT SUPPORTED BY WIIFLASH)
	        //else if (evt.getExtensionEvent() instanceof WRGuitarExtensionEvent)
	        //{ data.hasExtension = 3; wfs.log(CLASS_NAME +" "+data.id, "guitar extension"); }
			
			wfs.sendRemoteData(data);
		}
		catch(Exception e){}
	}

	
	
	
	
	/**
	 * Fires whenever data is received on the status report.
	 */
	public void	statusReported(WRStatusEvent evt)
	{
		// no constant update, just at beginning...
		data.battery = (float) (evt.getBatteryLevel());
		
		wfs.updateDeviceStatus(data);
		//wfs.log(CLASS_NAME + " " + data.id, "status | Battery level: " + (data.battery*100)+ "%");
		//wfs.log(CLASS_NAME + " " + data.id, "status | Continuous: " + evt.isContinuousEnabled());
		//wfs.log(CLASS_NAME + " " + data.id, "status | Remote continuous: " + remote.isContinuousEnabled());
		
		//now ask for status of remote every 10 seconds
		Timer t = new Timer();
		t.schedule(new TimerTask()
		{ 
			public void run()
			{ 
				Boolean requestStatus = true;
				while(requestStatus && remote.isConnected())
				{
					try
					{ 
						remote.requestStatus();
						Thread.sleep(10000);
					}
					catch(Exception e){ requestStatus = false; System.err.println(e.getMessage()); }
				}
			} 
		}, 10000);
	}
	
	
	/**
	 * Fires when the WiiRemote disconnects.
	 */
	public void	disconnected() 
    {
		 wfs.log(CLASS_NAME +" "+data.id, "was disconnected");
		 wfs.removeWiiDevice(data.id);
	}

	
	/**
	 * Fires when an extension is connected and properly setup.
	 */      
	public void	extensionConnected(WiiRemoteExtension extension) 
    {
		wfs.log(CLASS_NAME +" "+data.id, "Extension connected");
		
		try
        {
			if(extension.getCode() == 0) data.hasExtension = 1;	//Nunchuck
			else if(extension.getCode() == 257) data.hasExtension = 2; //Classic
			else if(extension.getCode() == 259) data.hasExtension = 3;	//Guitar
			
			remote.setIRSensorEnabled(true, WRIREvent.BASIC); 
    		remote.setExtensionEnabled(true);
        }
    	catch(Exception e){ wfs.log(CLASS_NAME +" "+data.id, e.getMessage()); }
    	wfs.updateDeviceStatus(data);
	}
	
	
	/**
	 * Fires when an extension disconnects.
	 */
	public void	extensionDisconnected(WiiRemoteExtension extension) 
    {
		wfs.log(CLASS_NAME +" "+data.id, "Extension disconnected");
		
		try
        {
			data.hasExtension = 0;
			remote.setExtensionEnabled(false);
			remote.setIRSensorEnabled(true, WRIREvent.EXTENDED);
        }
    	catch(Exception e){ wfs.log(CLASS_NAME +" "+data.id, e.getMessage()); }
    	wfs.updateDeviceStatus(data);
	}
	
	
	
	/**
	 * Fires when an extension is partially inserted.
	 */
	public void	extensionPartiallyInserted() 
	{
		wfs.log(CLASS_NAME +" "+data.id, "Put in Extension properly");
		
		try
        {
			data.hasExtension = 0;
			remote.setExtensionEnabled(false);
			remote.setIRSensorEnabled(true, WRIREvent.EXTENDED);
        }
    	catch(Exception e){ wfs.log(CLASS_NAME +" "+data.id, e.getMessage()); }
    	wfs.updateDeviceStatus(data);
	}
	
	
	/**
	 * Fires when an extension of an unknown type connects.
	 */
	public void	extensionUnknown() 
    {
		wfs.log(CLASS_NAME +" "+data.id, "Extension unknown");
		
		try
        {
			data.hasExtension = 0;
			remote.setExtensionEnabled(false);
			remote.setIRSensorEnabled(true, WRIREvent.EXTENDED);
        }
    	catch(Exception e){ wfs.log(CLASS_NAME +" "+data.id, e.getMessage()); }
    	wfs.updateDeviceStatus(data);
	}
	
	
}