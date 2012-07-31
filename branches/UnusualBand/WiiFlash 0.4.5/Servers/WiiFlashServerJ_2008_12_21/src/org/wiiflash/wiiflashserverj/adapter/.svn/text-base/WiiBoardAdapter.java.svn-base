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



//import WiiremoteJ
import org.wiiflash.wiiflashserverj.WiiFlashServerJ;
import org.wiiflash.wiiflashserverj.data.WiiDeviceData;

import wiiremotej.*;
import wiiremotej.event.*;


public class WiiBoardAdapter extends BalanceBoardAdapter implements IWiiDeviceAdapter
{
	//used for log
	private final String CLASS_NAME = "WiiBoardAdapter";
	
	private WiiFlashServerJ wfs;
	private BalanceBoard board;
	private WiiDeviceData data;
	
    /**
     * Creates a new WiiBoardAdapter object
     * 
     * @param wfs the WiiFlashServerJ
     * @param remote the WiiRemote
     */
    public WiiBoardAdapter(WiiFlashServerJ wfs, BalanceBoard board, int boardID)
    {
    	this.wfs = wfs;
    	this.board = board;
        
        data = new WiiDeviceData();
        
        try{ data.bluetooth = board.getBluetoothAddress(); }
    	catch(Exception e){}
    	
        data.id = boardID;
    }
    
    /**
     * initialize the Balance board adapter
     */
    public boolean setup()
    {
    	boolean noErrorsOccured = true;
    	wfs.log(CLASS_NAME +" "+data.id, "starting up");
        
        try
        {
        	board.addBalanceBoardListener(this);
        	
        	board.requestStatus();
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
	 * Disconnect this WiiRemote
	 */
	public void disconnect()
	{
		wfs.log(CLASS_NAME +" "+data.id, "disconnect");
		if(board != null || board.isConnected())
		{ board.disconnect(); }
	}
	
    /**
	 * Fires whenever input is received on the regular input reports
	 */
	public void	combinedInputReceived(BBCombinedEvent evt) 
    {
		try
		{
			// this is the core of the problem. wiiflash handles the balance board as an
			// extension, wiiremotej handles it as a separate device.
			data.hasExtension = 3; 
			data.kgTopLeft = (float) evt.getMassEvent().getMass(MassConstants.TOP, MassConstants.LEFT);
			data.kgTopRight = (float) evt.getMassEvent().getMass(MassConstants.TOP, MassConstants.RIGHT);
			data.kgBottomLeft = (float) evt.getMassEvent().getMass(MassConstants.BOTTOM, MassConstants.LEFT);
			data.kgBottomRight = (float) evt.getMassEvent().getMass(MassConstants.BOTTOM, MassConstants.RIGHT);
			data.kgTotal = (float) evt.getMassEvent().getTotalMass();
		    
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
		wfs.log(CLASS_NAME +" "+data.id, "status | Battery level: " + (data.battery*100)+ "%");
		wfs.log(CLASS_NAME +" "+data.id, "status | Continuous: " + evt.isContinuousEnabled());
	}
	
	
	/**
	 * Fires when the WiiRemote disconnects.
	 */
	public void	disconnected() 
    {
		wfs.log(CLASS_NAME +" "+data.id, "was disconnected");
		wfs.removeWiiDevice(data.id);
	}
	
	
	public void setLEDLights(int lightID){ wfs.log(CLASS_NAME +" Setting LEDs is not supported by Balance Board!"); }
	
	public void startVibrating(){ wfs.log(CLASS_NAME +" Vibrating is not supported by Balance Board!"); }
	public void stopVibrating(){ wfs.log(CLASS_NAME +" Vibrating is not supported by Balance Board!"); }
	 
	public void startMouseControl(){ wfs.log(CLASS_NAME +" Mouse control is not supported by Balance Board!"); }
	public void stopMouseControl(){ wfs.log(CLASS_NAME +" Mouse control is not supported by Balance Board!"); }

	
}