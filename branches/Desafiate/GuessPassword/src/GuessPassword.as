package {
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import gs.TweenLite;

	[SWF (width="915", height="508", frameRate="30", backgroundColor="0xffffff")]

	public class GuessPassword extends Sprite
	{
		[Embed(source='GuessLib.swf', symbol='bSubmit')] 		public var bfSubmit:Class;
		[Embed(source='GuessLib.swf', symbol='mcPassword')] 	public var mcPassword:Class;
		[Embed(source='GuessLib.swf', symbol='grLogin')] 		public var grLogin:Class;
		[Embed(source='GuessLib.swf', symbol='grLoginError')] 	public var grLoginError:Class;
		[Embed(source='GuessLib.swf', symbol='mcDesktop')] 		public var mcDesktop:Class;
		[Embed(source='GuessLib.swf', symbol='btCerrar')] 		public var btCerrar:Class;

		[Embed(source='GuessLib.swf', symbol='mcBocata01')] 	public var mcBocata01:Class;
		[Embed(source='GuessLib.swf', symbol='mcBocata02')] 	public var mcBocata02:Class;
		[Embed(source='GuessLib.swf', symbol='mcBocata03')] 	public var mcBocata03:Class;

		private var gText : MovieClip;
		private var bSubmit : SimpleButton;
		private var mPassword : MovieClip;
		private var mStatus : MovieClip;
		private var gLogin : Bitmap;
		private var gLoginError : Bitmap;
		private var mDesktop : MovieClip;
		private var bCerrar : SimpleButton;

		private var mBocata01 : Sprite;
		private var mBocata02 : Sprite;
		private var mBocata03 : Sprite;

		private var bEnded : Boolean = false;
		private var nScore : int = 1000;
		
		private var bGuessed : Boolean = false;

		public function IsEnded () : Boolean 
		{
			return bEnded;
		}

		/*public function GuessPassword (): void
		{
			Start();
		}*/

		public function Start() : void
		{
	    	gLogin = new grLogin
			gLogin.alpha = 0;
	    	addChild(gLogin);

	    	TweenLite.to(gLogin, 1, {alpha:1});

	    	gLoginError = new grLoginError
	    	gLoginError.visible = false;
	    	addChild(gLoginError);

	    	mPassword = new mcPassword();
	    	mPassword.x = 360;
	    	mPassword.y = 352;
	    	addChild (mPassword);

			bCerrar = new btCerrar();
			bCerrar.x = 820;
			bCerrar.y = 12;		
			bCerrar.addEventListener(MouseEvent.CLICK, MakeClose);
			addChild(bCerrar);

	    	bSubmit = new bfSubmit();
	    	bSubmit.addEventListener(MouseEvent.CLICK, checkPass); 
	    	addEventListener(KeyboardEvent.KEY_UP, CheckKey);
	    	bSubmit.x = 575;
	    	bSubmit.y = 340;
	    	addChild (bSubmit);

	    	ShowInstrucciones();
		}
		private function ShowInstrucciones () : void
		{
			mBocata01 = new mcBocata01();
			mBocata01.x = 470;
			mBocata01.y = 380;
			mBocata01.visible = false;
			addChild(mBocata01);
			
			mBocata02 = new mcBocata02();
			mBocata02.x = 470;
			mBocata02.y = 380;
			mBocata02.visible = false;
			addChild(mBocata02);
			
			TweenLite.delayedCall(5, showBocata, [ mBocata01 ] );
			TweenLite.delayedCall(10, killBocata, [ mBocata01 ] );
			TweenLite.delayedCall(15, showBocata, [ mBocata02 ] );
			TweenLite.delayedCall(20, killBocata, [ mBocata02 ] );
		}
		private function showBocata ( Bocata : Sprite ) : void {
	    	if (nScore >= 100)
				nScore = nScore - 100; 
			Bocata.visible = true 
		}
		private function killBocata ( Bocata : Sprite ) : void { 
			Bocata.visible = false 
		}
		private function CheckKey (event:KeyboardEvent) : void
		{
			if (event.keyCode == 13) checkPass(null);
		}
		public function GetScore () : int
		{
			return nScore;
		}
		public function MakeClose (e:MouseEvent) : void
		{
			nScore = -1;
			bEnded = true;
		}
		public function Stop () : void
		{
		}
		private function checkPass(e:Event) : void
		{
			//trace('"' + mPassword.tPass.text + '" ' + (mPassword.tPass.text == 'helene123'));
			if(mPassword.tPass.text == 'adriana' || mPassword.tPass.text == 'Adriana') 
			{
				removeChild(bCerrar);
		    	mDesktop = new mcDesktop
		    	addChild(mDesktop);
		    	var timeEnd:Timer = new Timer (2000, 1);
		    	timeEnd.addEventListener(TimerEvent.TIMER, MakeEndAnim);
		        timeEnd.start();
		        
		        killBocata(mBocata01);
		        killBocata(mBocata02);
		        
				TweenLite.killDelayedCallsTo(showBocata, [ mBocata01 ]);
				TweenLite.killDelayedCallsTo(killBocata, [ mBocata01 ]);
				TweenLite.killDelayedCallsTo(showBocata, [ mBocata02 ]);
				TweenLite.killDelayedCallsTo(killBocata, [ mBocata02 ]);
			}
			else
			{
				gLoginError.visible = true;
				mPassword.tPass.text = '';
		    	if (nScore >= 100)
		    		nScore = nScore - 100;
			}
		}
		private function MakeEndAnim (event:TimerEvent) : void
		{
			removeChild(gLogin);
			removeChild(mPassword);
			if (gLoginError != null)
				removeChild(gLoginError); 
			TweenLite.to(mDesktop, 1, {alpha: 0});
	    	var timeEnd:Timer = new Timer (1000, 1);
	    	timeEnd.addEventListener(TimerEvent.TIMER, MakeEnd);
	        timeEnd.start();
		}
		private function MakeEnd (event:TimerEvent) : void
		{
			bEnded = true;
		}
	}
}
