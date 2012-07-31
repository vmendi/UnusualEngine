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

import java.awt.Font;
import java.awt.Point;
import java.awt.Color;
import java.awt.GridLayout;

import javax.swing.JTextArea;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.border.CompoundBorder;
import javax.swing.border.EmptyBorder;
import javax.swing.border.EtchedBorder;

public class TabLog extends JPanel
{
	public final static long serialVersionUID = 0;
	
	private JTextArea log;
	private JScrollPane sp;
	
	public TabLog()
	{
		setBackground(Color.WHITE);
		log = new JTextArea();
		log.setFont(new Font("SansSerif", Font.PLAIN, 12));
		sp = new JScrollPane(log,JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED, JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
		sp.setBorder(new CompoundBorder(new EmptyBorder(0,0,0,0) , new EtchedBorder()));
		//sp.setBorder(null);
		//sp.setPreferredSize(new Dimension(470, 250));
		
		setLayout(new GridLayout(1, 1, 0, 0));
		add(sp);
	}
	
	

	/**
	 * write a message to the log
	 */
	public void write(String msg)
	{
		sp.getViewport().setViewPosition(new Point(0,log.getLineCount()*100));
		log.append(msg + "\n");
	}
	
	
	
	/**
	 * write a message and the name of where message is coming from to the log
	 */
	public void write(String name, String msg)
	{
		sp.getViewport().setViewPosition(new Point(0,log.getLineCount()*100));
		log.append(name +  ": " + msg + "\n");
	}

}
