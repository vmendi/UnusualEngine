package {
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import gs.TweenLite;
	
	[SWF (width="915", height="508", frameRate="30", backgroundColor="0xffffff")]

	public class PowerShellBug extends Sprite
	{
		[Embed(source='PowerShellLib.swf', symbol='bgPowershell')] 	public var bgPowershell:Class;
		[Embed(source='PowerShellLib.swf', symbol='grSuccess')] 	public var grSuccess:Class;
		[Embed(source='PowerShellLib.swf', symbol='mcTextArea')] 	public var mcTextArea:Class;
		[Embed(source='PowerShellLib.swf', symbol='mcTextCheck')] 	public var mcTextCheck:Class;
		[Embed(source='PowerShellLib.swf', symbol='mcResultArea')] 	public var mcResultArea:Class;
		[Embed(source='PowerShellLib.swf', symbol='btRun')] 		public var btRun:Class;
		[Embed(source='PowerShellLib.swf', symbol='btCerrar')] 		public var btCerrar:Class;

		[Embed(source='PowerShellLib.swf', symbol='mcBocata01')] 	public var mcBocata01:Class;
		[Embed(source='PowerShellLib.swf', symbol='mcBocata02')] 	public var mcBocata02:Class;
		[Embed(source='PowerShellLib.swf', symbol='mcBocata03')] 	public var mcBocata03:Class;

		private var gPowershell : Bitmap;
		private var gSuccess : Bitmap;
		private var mTextArea : MovieClip;
		private var mTextCheck : MovieClip;
		private var mResultArea : MovieClip;
		private var bRun : SimpleButton;
		private var bCerrar : SimpleButton;
		private var bEnded : Boolean = false;
		private var nScore : int = 1000;

		private var mBocata01 : Sprite;
		private var mBocata02 : Sprite;
		private var mBocata03 : Sprite;
		
		public function IsEnded() : Boolean 
		{
			return bEnded;
		}

		public function GetScore() : int 
		{
			return nScore;
		}

		/*public function PowerShellBug ():void
		{
			Start();
		}*/

		public function Start():void
		{
			gPowershell = new bgPowershell();
			gPowershell.alpha = 0;
			addChild(gPowershell);

			mTextArea = new mcTextArea();
			mTextArea.x = 42;
			mTextArea.y = 65;			
			addChild(mTextArea);

			mTextCheck = new mcTextCheck();

			mResultArea = new mcResultArea();
			mResultArea.x = 42;
			mResultArea.y = 267;			
			addChild(mResultArea);

			bRun = new btRun();
			bRun.x = 241;
			bRun.y = 3;		
			bRun.addEventListener(MouseEvent.CLICK, CheckScript);
			addChild(bRun);

			bCerrar = new btCerrar();
			bCerrar.x = 820;
			bCerrar.y = 12;		
			bCerrar.addEventListener(MouseEvent.CLICK, MakeClose);
			addChild(bCerrar);
			
			TweenLite.to(gPowershell, 1, {alpha:1});
			ShowInstrucciones();
		}
		private function ShowInstrucciones () : void
		{
			mBocata01 = new mcBocata01();
			mBocata01.x = 470;
			mBocata01.y = 360;
			mBocata01.visible = false;
			addChildAt(mBocata01, 1);
			
			mBocata02 = new mcBocata02();
			mBocata02.x = 470;
			mBocata02.y = 200;
			mBocata02.visible = false;
			addChildAt(mBocata02, 1);

			mBocata03 = new mcBocata03();
			mBocata03.x = 470;
			mBocata03.y = 280;
			mBocata03.visible = false;
			addChildAt(mBocata03, 1);
			
			TweenLite.delayedCall(5, showBocata, [ mBocata01 ] );
			TweenLite.delayedCall(10, killBocata, [ mBocata01 ] );
			TweenLite.delayedCall(15, showBocata, [ mBocata02 ] );
			TweenLite.delayedCall(20, killBocata, [ mBocata02 ] );
			TweenLite.delayedCall(25, showBocata, [ mBocata03 ] );
			TweenLite.delayedCall(30, killBocata, [ mBocata03 ] );
		}
		private function showBocata ( Bocata : Sprite ) : void {
			nScore = nScore - 100; 
			Bocata.visible = true 
		}
		private function killBocata ( Bocata : Sprite ) : void { 
			Bocata.visible = false 
		}

		public function MakeClose (e:MouseEvent) : void
		{
			nScore = -1;
			bEnded = true;
		}
		public function Stop () : void
		{
			TweenLite.killDelayedCallsTo(showBocata, [ mBocata01 ]);
			TweenLite.killDelayedCallsTo(killBocata, [ mBocata01 ]);
			TweenLite.killDelayedCallsTo(showBocata, [ mBocata02 ]);
			TweenLite.killDelayedCallsTo(killBocata, [ mBocata02 ]);
		}
		public function CheckScript (e:MouseEvent) : void
		{
			if (mTextArea.tTextArea.text == mTextCheck.tTextArea.text)
			{
				mResultArea.tResult.htmlText = mResultArea.tResult.htmlText + "<font color='#00cc00'>SCRIPT CORRECTO</font><br/>"; // + mTextArea.tTextArea.text;
				gSuccess = new grSuccess();
				gSuccess.alpha = 0;
				addChild (gSuccess);
				addEventListener(Event.ENTER_FRAME, DoSuccess)
				removeChild(bRun);
			} 
			else 
			{
				mResultArea.tResult.htmlText = mResultArea.tResult.htmlText + "<font color='#cc0000'>ERROR de sintaxis, compruebe el contenido y vuelva a intentarlo</font><br/>"; // + mTextArea.tTextArea.text;
				if (nScore > 0)
					nScore = nScore - 100;
			}
		}
		public function DoSuccess (e:Event) : void
		{
			if (gSuccess.alpha < 1) {
				gSuccess.alpha = gSuccess.alpha + 0.1; 
			} 
			else 
			{
		    	var theTimer:Timer = new Timer (2000, 1);
		    	theTimer.addEventListener(TimerEvent.TIMER, MakeEnd);
		        theTimer.start();
				removeEventListener(Event.ENTER_FRAME, DoSuccess)
			}
		}
		public function MakeEnd (Event:TimerEvent) : void 
		{
			bEnded = true;
		}
	}
}
