package {
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import gs.TweenLite;
	
	[SWF (width="915", height="508", frameRate="30", backgroundColor="0xffffff")]

	public class GuessPassword2 extends Sprite
	{
		[Embed(source='GuessLib2.swf', symbol='bSubmit')] 		public var bfSubmit:Class;
		[Embed(source='GuessLib2.swf', symbol='mcPassword')] 	public var mcPassword:Class;
		[Embed(source='GuessLib2.swf', symbol='grLogin')] 		public var grLogin:Class;
		[Embed(source='GuessLib2.swf', symbol='grLoginError')] 	public var grLoginError:Class;
		[Embed(source='GuessLib2.swf', symbol='mcDesktop')] 	public var mcDesktop:Class;
		[Embed(source='GuessLib2.swf', symbol='btCerrar')] 		public var btCerrar:Class;
		
		private var gText : MovieClip;
		private var bSubmit : SimpleButton;
		private var mPassword : MovieClip;
		private var mStatus : MovieClip;
		private var gLogin : Bitmap;
		private var gLoginError : Bitmap;
		private var mDesktop : MovieClip;
		private var bCerrar : SimpleButton;
		private var bEnded : Boolean = false;
		private var nScore : int = 1000;

		public function IsEnded () : Boolean 
		{
			return bEnded;
		}

		/*public function GuessPassword2 (): void
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
			if(mPassword.tPass.text == 'paula' || mPassword.tPass.text == 'Paula') 
			{
				removeChild(bCerrar);
		    	mDesktop = new mcDesktop
		    	addChild(mDesktop);
		    	var timeEnd:Timer = new Timer (2000, 1);
		    	timeEnd.addEventListener(TimerEvent.TIMER, MakeEndAnim);
		        timeEnd.start();
			}
			else
			{
				gLoginError.visible = true;
				mPassword.tPass.text = '';
		    	if (nScore > 0)
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
