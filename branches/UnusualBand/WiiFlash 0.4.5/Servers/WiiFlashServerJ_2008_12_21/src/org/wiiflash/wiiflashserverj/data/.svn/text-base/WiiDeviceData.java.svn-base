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

package org.wiiflash.wiiflashserverj.data;


//import regular java
import java.awt.geom.Point2D;


public class WiiDeviceData
{
	public int id			= 0;	//ID of WiiRemote (0 <= id <= 3)
	public String bluetooth = "";	//the Bluetooth address of the Wiimote
	public float battery	= 0;
	
	//WiiRemote buttons, e.g. value of LEFT stands for button id & is pressed
	public final int ONE 	= 0x8000;
	public final int TWO 	= 0x4000;
	public final int A 		= 0x2000;
	public final int B 		= 0x1000;
	public final int PLUS 	= 0x0800;
	public final int MINUS	= 0x0400;
	public final int HOME 	= 0x0200;
	public final int UP 	= 0x0100;
	public final int DOWN 	= 0x0080;
	public final int RIGHT	= 0x0040;
	public final int LEFT 	= 0x0020;
	
	//Nunchuk buttons
	public final int NC 	= 0x02;
	public final int NZ 	= 0x01;
	
	//Classic controller buttons
	public final int X		= 0x8000;
	public final int Y		= 0x4000;
	public final int L		= 0x10;
	public final int R		= 0x08;
	public final int ZL		= 0x04;
	public final int ZR		= 0x02;
	
	public int hasExtension = 0;	//0 = None, 1 = Nunchuck, 2 = Classic Controller, 3 = Board
	
	//IR points
	public Point2D.Float[] irP = { new Point2D.Float(), new Point2D.Float(), 
								new Point2D.Float(), new Point2D.Float() };
	
	public float[] irS 		= { 0,0,0,0 };

	//WiiRemote data
	public int mButtons 	= 0;	// number encoding button state(s) and id(s)
	public float mAccelX	= 0;
	public float mAccelY	= 0;
	public float mAccelZ	= 0;
	
	//Nunchuck data
	public int nButtons 	= 0;	// number encoding button state(s) and id(s)
	public float nAccelX	= 0;
	public float nAccelY	= 0;
	public float nAccelZ	= 0;
	public float nStickX	= 0;
	public float nStickY	= 0;
	
	//Classic controller data
	public float cButtons	= 0;	// number encoding button state(s) and id(s)
	public float cStickLX	= 0;
	public float cStickLY	= 0;
	public float cStickRX	= 0;
	public float cStickRY	= 0;
	
	//BalanceBoard data
	public float kgBottomLeft	= 0;
	public float kgBottomRight	= 0;
	public float kgTopLeft		= 0;
	public float kgTopRight		= 0;
	public float kgTotal		= 0;
	
	/**
	 * 
	 */
	public void resetWiimoteData()
	{
		id = 0;
		hasExtension = 0;
		battery	= 0;
		
		irP[0].x = 0;
		irP[0].y = 0;
		irS[0] = 0;
		irP[1].x = 0;
		irP[1].y = 0;
		irS[1] = 0;
		irP[2].x = 0;
		irP[2].y = 0;
		irS[2] = 0;
		irP[3].x = 0;
		irP[3].y = 0;
		irS[3] = 0;
		
		mButtons = 0;
		mAccelX	= 0;
		mAccelY	= 0;
		mAccelZ	= 0;
	}
	
	
	/**
	 * 
	 */
	public void resetNunchuckData()
	{
		nButtons = 0;
		nAccelX	= 0;
		nAccelY	= 0;
		nAccelZ	= 0;
		nStickX	= 0;
		nStickY	= 0;
	}
	
	/**
	 * 
	 */
	public void resetClassicControllerData()
	{
		cButtons = 0;
		cStickLX = 0;
		cStickLY = 0;
		cStickRX = 0;
		cStickRY = 0;
	}
	
	/**
	 * reset data values representing data of balance board
	 */
	public void resetBoardData()
	{
		kgBottomLeft	= 0;
		kgBottomRight	= 0;
		kgTopLeft		= 0;
		kgTopRight		= 0;
		kgTotal			= 0;		
	}

}
