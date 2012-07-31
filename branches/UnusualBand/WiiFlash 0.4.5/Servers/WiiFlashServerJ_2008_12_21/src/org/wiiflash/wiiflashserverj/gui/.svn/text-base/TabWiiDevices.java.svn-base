/** 
 * Copyright (C) 2008 Alan Ross
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


package org.wiiflash.wiiflashserverj.gui;

import java.awt.*;
import java.util.ArrayList;

import javax.swing.*;
import javax.swing.border.*;

import org.wiiflash.wiiflashserverj.data.WiiDeviceData;

public class TabWiiDevices extends JPanel
{
	public final static long serialVersionUID = 0;
	
	private ImageIcon ICON_CONNECTED;
	private ImageIcon ICON_NOTCONNECTED;
	private ImageIcon ICON_NUNCHUCK;
	private ImageIcon ICON_CLASSIC;
	private ImageIcon ICON_BOARD;
	
	private ArrayList<JLabel> icons;
	private ArrayList<JTextArea> infos;
	
	private JScrollPane sp;
	
	/**
	 * What a mess
	 */
	public TabWiiDevices()
	{
		JPanel p = new JPanel();
		p.setLayout(null);
		p.setPreferredSize(new Dimension(300, 250));
		p.setBackground(Color.WHITE);
		//p.setLayout(new GridLayout(4,2,0,10));
		//p.setBounds(0,0,100,100);
		//p.setOpaque(true);
		
		ICON_NOTCONNECTED = new ImageIcon("assets/wiimote_disconnected.png");
		ICON_CONNECTED = new ImageIcon("assets/wiimote_connected.png");
		ICON_NUNCHUCK = new ImageIcon("assets/wiimote_nunchuck.png");
		ICON_CLASSIC = new ImageIcon("assets/wiimote_classic.png");
		ICON_BOARD = new ImageIcon("assets/wiimote_board.png");
		
		icons = new ArrayList<JLabel>();
		infos = new ArrayList<JTextArea>();
		
		Rectangle iconBounds = new Rectangle(20,15,50,50);
		Rectangle infoBounds = new Rectangle(100,15,300,50);
		
		for(int i = 0; i < 4; i++)
		{
			icons.add(makeIcon(ICON_NOTCONNECTED, iconBounds));
			iconBounds.y += 60;
			infos.add(makeInfo(infoBounds));
			infoBounds.y += 60;
			p.add(icons.get(i));
			p.add(infos.get(i));
		}
		
		sp = new JScrollPane(p,JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED, JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
		sp.setBorder(new CompoundBorder(new EmptyBorder(0,0,0,0) , new EtchedBorder()));
		
		setLayout(new GridLayout(1, 1, 0, 0));
		add(sp);
	}
	
	
	/**
	 * Creates a JLabel with given ImageIcon and its bounds
	 * 
	 * @param icon
	 * @param bounds
	 * @return JLabel
	 */
	private JLabel makeIcon(ImageIcon icon, Rectangle bounds)
	{
		JLabel l = new JLabel(icon);
		l.setBounds(bounds);
		return l;
	}
	
	
	/**
	 * Creates a JTextArea with given bounds
	 * 
	 * @param bounds
	 * @return JTextArea
	 */
	private JTextArea makeInfo(Rectangle bounds)
	{
		JTextArea t	= new JTextArea();
		t.setBounds(bounds);
		t.setFont(new Font("SansSerif", Font.PLAIN, 12));
		t.setBackground(null);
		t.setText(getInfo(null));
		return t;
	}
	
	
	/**
	 * Reset all Device icons to disconnected status
	 */
	public void resetIcons()
	{
		for(int i = 0; i< infos.size(); i++)
		{
			icons.get(i).setIcon(ICON_NOTCONNECTED);
			infos.get(i).setText(getInfo(null));
		}
	}
	
	/**
	 * Reset given Device icon to disconnected status
	 * 
	 * @param deviceID, the id of the Wii device
	 */
	public void resetIcon(int deviceID)
	{
		for(int i = 0; i< infos.size(); i++)
		{
			if(deviceID == i)
			{
				icons.get(i).setIcon(ICON_NOTCONNECTED);
				infos.get(i).setText(getInfo(null));
			}
		}
	}
	
	

	/**
	 * update icons representing the connected devices
	 */
	public void updateIcons(WiiDeviceData data)
	{
		for(int i = 0; i< infos.size(); i++)
		{
			if(data != null && data.id == i)
			{
				if(data instanceof WiiDeviceData)
				{
					if(data.hasExtension == 0) icons.get(i).setIcon(ICON_CONNECTED); //ohhh boy this is so stupid
					if(data.hasExtension == 1) icons.get(i).setIcon(ICON_NUNCHUCK);
					if(data.hasExtension == 2) icons.get(i).setIcon(ICON_CLASSIC);
					if(data.hasExtension == 3) icons.get(i).setIcon(ICON_BOARD);
					infos.get(i).setText(getInfo(data));
				}
			}
		}
	}
	
	
	
	/**
	 * put together a string containing relevant info of Wii device
	 * @param data
	 * @return info, the string containing relevant info about the connected device
	 */
	private String getInfo(WiiDeviceData data)
	{
		String info = "";
		
		if(data != null)
		{
			info = "WiiMote ID: " + data.id + "\n";
			info += "Bluetooth ID: " + data.bluetooth + "\n";
			info += "Battery: " + (data.battery*100) + "%\n";
		}
		else
		{
			info = "WiiMote ID: - \n";
			info += "Bluetooth ID: - \n";
			info += "Battery: - \n";
		}
		
		return info;
	}
	

}
