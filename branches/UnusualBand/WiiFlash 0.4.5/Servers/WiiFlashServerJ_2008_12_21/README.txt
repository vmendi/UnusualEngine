
------------------------------------------------------
WIIFLASHSERVERJ
------------------------------------------------------



ABOUT
------------------------------------------------------
WiiFlashServerJ aims at being the Mac OS X or Linux version 
of the Windows server, providing data for the WiiFlash 0.4.3 library. 
As the source for the Windows server version was not open 
when working on this little application the probability of it 
some how working differently than the windows version is quite high...

Credit for the backbone of Wiiremote communication (WiiRemoteJ)
used in WiiFlashServerJ goes to Michael Diamond.



FAQ
------------------------------------------------------
I can't connect my Wiimote:
	+ Press buttons 1 & 2 simultaneously on your Wiimote and try again
	+ Sometimes, while connecting, WiiFlashServerJ can't send data to your Wiimote, 
	in this case it is disconnected automaticly. Just try connecting again
	+ On Mac OS X go to 'System Preferences' and delete all Wiimotes in 'Bluetooth' panel
	+ Are other versions of this application running at the same time?
	+ Are other applications connected to your Wiimote?
	+ Are other Bluetooth devices nearby trying to connect to your Wiimote(s)?
	+ Is the Wiimote battery nearly empty?
	+ Try restarting WiiFlashServerJ

My WiiFlash application is not getting any (proper) data from WiiFlashServerJ:
	+ Are other versions of WiiFlashServerJ running at the same time?
	+ Try restarting WiiFlashServerJ
	+ Try reconnecting your Wiimote again
	+ Perhaps you are using an older version of the WiiFlash 0.4.3 API
	(There has been a small but important update since the WiiFlash 0.4.3 API first was released)
	This affects data from extension and the IR data.
	+ Sometimes IR or Nunchuck data is not sent properly, in this case restart WiiFlashServerJ

My problem is not on this short FAQ:
	Leave a note on the WiiFlash.org forum and try to be as precise as possible,
	or send me a quick message via http://lab.adjazent.com/



COMPILE & REQUIREMENTS
------------------------------------------------------
To compile properly this software requires following .jar files:

Bluecove (v 2.0.3) http://code.google.com/p/bluecove/
WiiRemoteJ (v 1.5) http://www.wiili.org/WiiremoteJ



CONTACT
------------------------------------------------------
Feel free to send any bug reports or questions. Just leave
a note on http://lab.adjazent.com/



Enjoy


