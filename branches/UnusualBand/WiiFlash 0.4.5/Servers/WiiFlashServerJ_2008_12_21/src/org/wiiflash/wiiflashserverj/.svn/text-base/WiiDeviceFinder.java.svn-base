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

//import WiiremoteJ
import wiiremotej.event.*;

public class WiiDeviceFinder implements WiiDeviceDiscoveryListener
{
	//used for log
	private final String CLASS_NAME = "WiiDeviceFinder";
	private WiiFlashServerJ wfs;
	
	/**
	 * Construct a new WiiDeviceFinder object
	 * @param wfs, the instance of WiiFlashServerJ
	 */
	public WiiDeviceFinder(WiiFlashServerJ wfs)
    {
		super();
		this.wfs = wfs;
	}
	
	/**
	 * called when a wii device was discovered
	 * @param evt, WiiDeviceDiscoveredEvent
	 */
	public void wiiDeviceDiscovered(WiiDeviceDiscoveredEvent evt)
    {
		wfs.log(CLASS_NAME,"wiiDeviceDiscovered " + evt.toString());
		wfs.addWiiDevice(evt.getWiiDevice());
    }
    
	/**
	 * called when finished looking for wii devices
	 * @param numberFound, Amount of WiiDevices found when searching
	 */
    public void findFinished(int numberFound)
    { 
    	wfs.log(CLASS_NAME,"Search stopped, found " + numberFound + " Wiimote(s)");
    }
    
    
    
}