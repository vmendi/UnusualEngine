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
 * 
 * 
 * Note: This application aims at being the Mac OS X or Linux version of 
 * the Windows server, providing data for the WiiFlash 0.4.3 library. 
 * As the source for the Windows server version was not open when working 
 * on this little application the probability of it some how working differently 
 * than the windows version is quite high...
 * 
 * To compile properly this software requires following .jar files:
 * 
 * 	   Bluecove (v 2.0.3) http://code.google.com/p/bluecove/
 * 	   WiiRemoteJ (v 1.5) http://www.wiili.org/WiiremoteJ
*/



package org.wiiflash.wiiflashserverj;

//import regular java
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;
import java.io.IOException;
import java.net.ServerSocket;
import java.util.ArrayList;

import javax.swing.ImageIcon;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JTabbedPane;

import org.wiiflash.wiiflashserverj.adapter.IWiiDeviceAdapter;
import org.wiiflash.wiiflashserverj.adapter.WiiBoardAdapter;
import org.wiiflash.wiiflashserverj.adapter.WiiMoteAdapter;
import org.wiiflash.wiiflashserverj.data.WiiDeviceData;
import org.wiiflash.wiiflashserverj.gui.AboutBox;
import org.wiiflash.wiiflashserverj.gui.TabLog;
import org.wiiflash.wiiflashserverj.gui.TabWiiDevices;

import wiiremotej.BalanceBoard;
import wiiremotej.WiiDevice;
import wiiremotej.WiiRemote;
import wiiremotej.WiiRemoteJ;

import com.apple.eawt.Application;
import com.apple.eawt.ApplicationEvent;


public class WiiFlashServerJ
{
	//Application & UI
	private JFrame f;
	private AboutBox aboutBox;
	private TabLog tabLog;
	private TabWiiDevices tabWiimotes;
	
	//Log info
	private final String CLASS_NAME = "WiiFlashServerJ";
	
	//SocketConnection
	private boolean listen = true;
	
	private final int PORT = 0x4a54;	// default WiiFlash port
	
	//List of all connected Wiimotes
	private ArrayList<IWiiDeviceAdapter> wiiDevices;
	public final int MAX_WIIMOTE_COUNT = 4;
	
	private ArrayList<SocketConnection> clients;
	public final int MAX_CLIENT_COUNT = 10;
	
	/**
	 * Creates a new WiiFlashServerJ
	 */
	public WiiFlashServerJ()
	{
		wiiDevices = new ArrayList<IWiiDeviceAdapter>();
		clients = new ArrayList<SocketConnection>();
		
		//WiiRemoteJ should log also, (is sent to console)
		WiiRemoteJ.setConsoleLoggingAll();
		
		initUI();
		discoverWiiDevices();
		startServer();
	}
	
	
	//---------------------------------------------------------------------------
	// UI & APPLICATION
	//---------------------------------------------------------------------------
	
	/**
	 * initialize the user interface of this app.
	 */
	public void initUI()
	{
		//initialize frame
		f = new JFrame(CLASS_NAME);
		f.setSize(710,350);
		f.setResizable(false);
		f.addWindowListener(new WindowListener()
		{
	    	public void windowOpened(WindowEvent e){}
	    	public void windowClosing(WindowEvent e){ handleQuitAppication(); }
	    	public void windowClosed(WindowEvent e){ }
	    	public void windowIconified(WindowEvent e){}
	    	public void windowDeiconified(WindowEvent e){}
	    	public void windowActivated(WindowEvent e){}
	    	public void windowDeactivated(WindowEvent e){}
	    });
		//Apple Inc. specific stuff. Its used when app is quitting (by shortcut, menu or window..) (!)
	    Application fApp = Application.getApplication();
		fApp.addApplicationListener(new com.apple.eawt.ApplicationAdapter()
		{ 
			public void handleQuit(ApplicationEvent e){ handleQuitAppication(); }
			public void handleAbout(ApplicationEvent e)
			{
				if (aboutBox == null) { aboutBox = new AboutBox(); }
                aboutBox.setResizable(false);
				aboutBox.setVisible(true);
                e.setHandled(true);
			}
		});
		
		ImageIcon bgimage = new ImageIcon("assets/bg.jpg");
		JLabel bg = new JLabel(bgimage);
		bg.setBounds(0,0,710,350);
		
		tabLog = new TabLog();
		tabWiimotes = new TabWiiDevices();
		
		JTabbedPane tp = new JTabbedPane();
		tp.setBounds(210,10,490,310);
		tp.addTab( "Wiimotes", tabWiimotes);
		tp.addTab( "Log", tabLog);

		f.getContentPane().setLayout(null);
		f.getContentPane().add(tp);
		f.getContentPane().add(bg);
		f.setVisible(true);
	    f.setEnabled(true);
	    
	    log("Welcome to " + CLASS_NAME);
	}
	
	
	
	
	/**
	 * Important: Disconnect all Wiis so next time you try to connect you don't get any errors.
	 * well, you should get a few less.
	 * If Wiimotes don't seem to be able to connect (on Mac OS X), go to 
	 * 'System Preferences' > 'Bluetooth' and remove your Wiimotes from the list. 
	 */
	public void handleQuitAppication() 
	{	
		disconnectWiiDevices();
		stopServer();
		System.out.println(CLASS_NAME +  " quit");
		System.exit(0);
	}

	
	/**
	 * write a message to the log
	 */
	public void log(String msg)
	{
		tabLog.write(msg);
		System.out.println(msg);
	}
	
	
	
	/**
	 * write a message and the name of where message is coming from to the log
	 */
	public void log(String name, String msg)
	{
		tabLog.write(name, msg);
		System.out.println(name + ", " + msg);
	}
	
	
	
	
	//---------------------------------------------------------------------------
	// SERVER
	//---------------------------------------------------------------------------
	
	
	/**
	 * Start the SocketConnection. Wait till a client is found, then make instance of SocketConnection
	 * so more then one client can connect.
	 * This is also the place where a few seconds of thought should be regarded as
	 * helpful. If one client assigns Wiimote an id and the other client does so
	 * too, but using another id..? what happens if a client requests setting the LED 
	 * or rumble... but the other client does not... hmm.
	 */
	public void startServer()
	{
		log(CLASS_NAME, "starting SocketConnection");
		
		try
		{
			ServerSocket serverSocket = null;
			
			try{ serverSocket = new ServerSocket(PORT, MAX_CLIENT_COUNT); } 
			catch (Exception e)
			{ 
				log(CLASS_NAME, "could NOT listen on default WiiFlash port: " + PORT);
				log("----------------------------------------------");
				log("HELP:");
				log("Are other versions of this application running at the same time?");
				log("Try restarting " + CLASS_NAME);
				log("----------------------------------------------");
				listen = false; 
			}
			
			while (listen)
			{
				log(CLASS_NAME, "waiting for client on default WiiFlash port: " + PORT);
				SocketConnection socketConnection = new SocketConnection(this, serverSocket.accept());
				socketConnection.start();
				clients.add(socketConnection);
			}
			
			serverSocket.close();
		}
	    catch (IOException e){ log("SocketConnection IOException: " + e.getMessage() ); }
	}
	
	
	
	
	/**
	 * Stop the server.
	 */
	public void stopServer()
	{
		log(CLASS_NAME, "shutdown socket connections");
		
		listen = false;
		for(int i = 0; i< clients.size(); i++)
		{ clients.get(i).quit(); }
	}
	
	
	/**
	 * write data do socket (send Wiimote data to the server to write to socket / WiiFlash)
	 */
	public void sendRemoteData(WiiDeviceData data)
	{
		//log(CLASS_NAME, "send remote data to connected clients");
		
		for(int i = 0; i< clients.size(); i++)
		{ clients.get(i).sendWiiData(data); }
	}
	
	
	//---------------------------------------------------------------------------
	// WIIREMOTE / WIIDEVICES
    //---------------------------------------------------------------------------
	
	/**
	 * Look for Wiimotes (where buttons 1 & 2 are pressed.)
	 */
	public void discoverWiiDevices() 
	{
		log(CLASS_NAME, "Start searching. Press Button 1 & 2 on Wiimote");
		
		//WiiRemoteJ.findRemotes(new WiiDeviceFinder(this), MAX_WIIMOTE_COUNT);
		WiiRemoteJ.findDevices(new WiiDeviceFinder(this), WiiRemoteJ.ALL);
    }
	
	
	
	/**
	 * Disconnect all Wii devices that are connected to WiiFlashServerJ.
	 * Should be called when quitting the application, to free all connected
	 * Wii devices. More info to why we want to do this: handleQuitAppication()
	 */
	public void disconnectWiiDevices() 
	{
		WiiRemoteJ.stopFind();
		
		for(int i = 0; i< wiiDevices.size(); i++)
		{
			wiiDevices.get(i).disconnect();
			log(CLASS_NAME, "disconnect [Wii devices " + i+"]");
		}
		
		wiiDevices.clear();
		tabWiimotes.resetIcons();
	}
	
	
	/**
	 * Add a WiiMoteAdapter or a WiiBoardAdapter to the WiiFlashServerJ, 
	 * so the server can send its data.
	 * 
	 * @param device, the WiiDevice (Wiiremote or Balance board) found
	 */
	public void addWiiDevice(WiiDevice device)
	{
		if(wiiDevices.size() < MAX_WIIMOTE_COUNT)
		{
			if(device instanceof WiiRemote)
			{ 
				log(CLASS_NAME, "added [Wiimote " + wiiDevices.size() + "]:");
				
				WiiMoteAdapter wma = new WiiMoteAdapter(this, (WiiRemote)device, wiiDevices.size());
				wiiDevices.add(wma);
				if( wma.setup() ) //no errors during setup
				{ 
					tabWiimotes.updateIcons(wma.getData());
				}
				else
				{ 
					log("----------------------------------------------");
					log("HELP:");
					log("Press buttons 1 & 2 simultaneously on your Wiimote and try again");
					log("OS X: Go to 'System Preferences' and delete all Wiimotes in 'Bluetooth'");
					log("Are other versions of this application running at the same time?");
					log("Are other applications connected to your Wiimote?");
					log("Are other Bluetooth devices nearby?");
					log("Are other Bluetooth devices trying to connect to Wiimote(s)?");
					log("Is the Wiimote battery nearly empty?");
					log("Try restarting " + CLASS_NAME);
					log("----------------------------------------------");
					removeWiiDevice(wma.getData().id);
				}
			}
			if(device instanceof BalanceBoard)
			{ 
				log(CLASS_NAME, "added [BalanceBoard " + wiiDevices.size() + "]:");
				
				WiiBoardAdapter wba = new WiiBoardAdapter(this, (BalanceBoard)device, wiiDevices.size());
				wiiDevices.add(wba);
				if( wba.setup() ) //no errors during setup
				{ 
					tabWiimotes.updateIcons(wba.getData());
				}
				else
				{ 
					log("----------------------------------------------");
					log("HELP:");
					log("OS X: Go to 'System Preferences' and delete all Wii devices in 'Bluetooth'");
					log("Are other versions of this application running at the same time?");
					log("Are other applications connected to your Wiimote?");
					log("Are other Bluetooth devices nearby?");
					log("Are other Bluetooth devices trying to connect to Balance board(s)?");
					log("Is the Balance board battery nearly empty?");
					log("Try restarting " + CLASS_NAME);
					log("----------------------------------------------");
					removeWiiDevice(wba.getData().id);
				}
				
			}
			
		}
		else
		{
			log(CLASS_NAME, "could NOT add [Wii device " + wiiDevices.size() + "]:  (you can't add more then " + MAX_WIIMOTE_COUNT +")");
		}
	}
	
	/**
	 * Remote a Wii device from WiiServerServerJ
	 * 
	 * @param ID of Wii device to be removed
	 */
	public void removeWiiDevice(int deviceID)
	{
		for(int i = 0; i< wiiDevices.size(); i++)
		{
			if(i == deviceID)
			{
				log(CLASS_NAME, "remove [Wii device " + i+"]");
				wiiDevices.get(i).disconnect();
				wiiDevices.remove(i);
				tabWiimotes.resetIcon(i);
			}
		}
	}
	
	
	/**
	 * Passes on data of a Wii device to set icon and text
	 * 
	 * @param data
	 */
	public void updateDeviceStatus(WiiDeviceData data)
	{
		tabWiimotes.updateIcons(data);
	}
	
	
	

	/**
	 * Set the LED Lights of a given Wiimote
	 * 
	 * @param remoteID
	 * @param lightID
	 */
	public void setLEDLights(int deviceID, int lightID)
	{
		log("client request: [Wii device"+deviceID+"] set LED" + lightID);
		
		for(int i=0; i< wiiDevices.size(); i++)
		{
			if(wiiDevices.get(i).getData().id == deviceID)
			{ 
				wiiDevices.get(i).setLEDLights(lightID);
			}
		}
	}
	
	
	
	/**
	 * Start vibrating a Wiimote, given by its ID
	 * 
	 * @param remoteID
	 */
	public void startVibrating(int deviceID)
	{
		log("client request: [Wii device"+deviceID+"] start vibrating");
		
		for(int i=0; i< wiiDevices.size(); i++)
		{
			if(wiiDevices.get(i).getData().id == deviceID)
			{ 
				wiiDevices.get(i).startVibrating();
			}
		}
	}
	
	
	/**
	 * Stop vibrating a Wiimote, given by its ID
	 * 
	 * @param remoteID
	 */
	public void stopVibrating(int deviceID)
	{
		log("client request: [Wii device"+deviceID+"] stop vibrating");
		for(int i=0; i< wiiDevices.size(); i++)
		{
			if(wiiDevices.get(i).getData().id == deviceID)
			{ wiiDevices.get(i).stopVibrating(); }
		}
	}
	
	
	/**
	 * Start using a Wiimote as mouse, given by its ID
	 * 
	 * @param remoteID
	 */
	public void startMouseControl(int moteID)
	{
		log("client request: [Wiimote"+moteID+"] start mouse control");
		
		for(int i=0; i< wiiDevices.size(); i++)
		{
			if(wiiDevices.get(i).getData().id == moteID)
			{ wiiDevices.get(i).startMouseControl(); }
		}
	}
	
	
	/**
	 * Stop using a Wiimote as mouse, given by its ID
	 * 
	 * @param remoteID
	 */
	public void stopMouseControl(int moteID)
	{
		log("client request: [Wiimote"+moteID+"] stop mouse control");
		for(int i=0; i< wiiDevices.size(); i++)
		{
			if(wiiDevices.get(i).getData().id == moteID)
			{ wiiDevices.get(i).stopMouseControl(); }
		}
	}
	
	
	/**
	 * Starts the WiiFlashServer application
	 * 
	 * @param args
	 */
	public static void main(String[] args)
	{
		new WiiFlashServerJ();
	}

}
