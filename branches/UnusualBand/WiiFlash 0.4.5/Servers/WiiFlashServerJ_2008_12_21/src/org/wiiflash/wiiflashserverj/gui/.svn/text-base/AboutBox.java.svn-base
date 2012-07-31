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
import java.awt.event.WindowListener;
import java.awt.event.WindowEvent;

import javax.swing.*;

public class AboutBox extends JFrame
{
	public final static long serialVersionUID = 0;
	
    private Font titleFont, bodyFont;

	/**
	* Create an AboutBox object
	*/
    public AboutBox()
	{
        super("");
        this.setResizable(false);
        this.addWindowListener(new WindowListener()
    	{
        	public void windowOpened(WindowEvent e){}
        	public void windowClosing(WindowEvent e){ setVisible(false); }
        	public void windowClosed(WindowEvent e){ }
        	public void windowIconified(WindowEvent e){}
        	public void windowDeiconified(WindowEvent e){}
        	public void windowActivated(WindowEvent e){}
        	public void windowDeactivated(WindowEvent e){}
        });
        
        // Initialize useful fonts
        titleFont = new Font("Lucida Grande", Font.BOLD, 14);
        if (titleFont == null) { titleFont = new Font("SansSerif", Font.BOLD, 14); }
        bodyFont  = new Font("Lucida Grande", Font.PLAIN, 10);
        if (bodyFont == null) { bodyFont = new Font("SansSerif", Font.PLAIN, 10); }
		
        JLabel h = new JLabel("About WiiFlashServerJ 0.4.3");
		h.setFont(titleFont);
		h.setBounds(10, 10, 380, 60);
		h.setHorizontalAlignment(JLabel.CENTER);
		        
		JTextArea t =  new JTextArea();
		t.setBounds(10, 80, 380, 200);
		t.setFont(bodyFont);
		t.setEditable(false);
		t.setBackground(null);
		t.setLineWrap(true);
		t.setText("WiiFlashServerJ passes on data received from connected Wiimotes.\n");
		t.append("The data is transformed into a way WiiFlash 0.4.3 (WiiFlash.org) can handle it.\n");
		t.append("Without the following libraries this application would do absolutly nothing:\n\n");
		t.append("WiiRemoteJ (v 1.5): http://www.wiili.org/WiiremoteJ\n");
		t.append("Bluecove (v 2.0.3): http://code.google.com/p/bluecove/\n\n");	
		t.append("WiiFlashServerJ: Copyright (c) 2008 Alan Ross\n\n");
		t.append("(Alpha version: 30 july 2008)\n\n");
		t.append("Enjoy");
		
		this.getContentPane().setLayout(null);
		this.getContentPane().add(h);
		this.getContentPane().add(t);
		this.pack();
        this.setLocation(200, 350);
        this.setSize(400, 300);
    }
}