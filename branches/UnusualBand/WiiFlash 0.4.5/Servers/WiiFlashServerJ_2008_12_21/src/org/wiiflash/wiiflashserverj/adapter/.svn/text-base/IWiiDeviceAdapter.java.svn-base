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

import org.wiiflash.wiiflashserverj.data.WiiDeviceData;


public interface IWiiDeviceAdapter
{
	public boolean setup();
	public WiiDeviceData getData();
	public void disconnect();
	
	// from oop this makes no sence, but I want to force 
	// error to be handled when trying to set these functions when using e.g balance board
	public void setLEDLights(int lightID);
	
	public void startVibrating();
	public void stopVibrating();
	 
	public void startMouseControl();
	public void stopMouseControl();
}
