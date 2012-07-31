package {
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import gs.TweenLite;
	
	import utils.Delegate;

	[SWF (width="915", height="508", frameRate="30", backgroundColor="0xffffff")]

	public class VendingMachine extends Sprite
	{
		[Embed(source='VendingLib.swf', symbol='spVending')] 	public var spVending:Class;
		[Embed(source='VendingLib.swf', symbol='spVendingM')] 	public var spVendingM:Class;
		[Embed(source='VendingLib.swf', symbol='btTilt')] 		public var btTilt:Class;
		[Embed(source='VendingLib.swf', symbol='spItem1')] 		public var spItem1:Class;
		[Embed(source='VendingLib.swf', symbol='spItem2')] 		public var spItem2:Class;
		[Embed(source='VendingLib.swf', symbol='spItem3')] 		public var spItem3:Class;
		[Embed(source='VendingLib.swf', symbol='mcItemDrop')] 	public var mcItemDrop:Class;
		[Embed(source='VendingLib.swf', symbol='mcBolsa')] 		public var mcBolsa:Class;
		[Embed(source='VendingLib.swf', symbol='btCerrar')] 	public var btCerrar:Class;
		[Embed(source='VendingLib.swf', symbol='mcBocata01')] 	public var mcBocata01:Class;
		[Embed(source='VendingLib.swf', symbol='mcBocata02')] 	public var mcBocata02:Class;
		[Embed(source='VendingLib.swf', symbol='mcBocata03')] 	public var mcBocata03:Class;
		[Embed(source='VendingLib.swf', symbol='mcBocataError')] 	public var mcBocataError:Class;
		
		private var sVending : Sprite;
		private var sVendingM : MovieClip;
		private var sItem : Sprite;
		private var mItemDrop : MovieClip;
		private var mBolsa : MovieClip;
		private var bTiltTL : SimpleButton;
		private var bTiltTR : SimpleButton;
		private var bTiltBL : SimpleButton;
		private var bTiltBR : SimpleButton;
		private var bCerrar : SimpleButton;
		private var mBocata01 : Sprite;
		private var mBocata02 : Sprite;
		private var mBocata03 : Sprite;
		private var mBocataError : Sprite;

		private var mDirection : int = -1;
		private var puzzStat : int = 0;
		private var iMoves : int = 0;
		private var aSolution : Array = new Array(1, 3, 2, 4);
		private var bEnded : Boolean = false;
		
		private var bMessageShow : Boolean = false;
		
		private var nScore : int = 1000;

		public function IsEnded() : Boolean 
		{
			return bEnded;
		}
		/*public function VendingMachine () : void
		{
			Start();
		}*/
		public function Start() : void
		{
	    	sVending = new spVending();
	    	sVending.alpha = 0;
	    	addChild(sVending);

			mBolsa = new mcBolsa();
			mBolsa.alpha = 0;
	    	mBolsa.x = 372;
	    	mBolsa.y = 200;
	    	mBolsa.stop();
	    	addChild(mBolsa);
	    	
	    	TweenLite.to(sVending, 1, {alpha: 1});
	    	TweenLite.to(mBolsa, 1, {alpha: 1});
	    	
	    	var theTimer : Timer = new Timer(1000, 1);
	    	theTimer.addEventListener(TimerEvent.TIMER, GameStart);
	        theTimer.start();
		}
		public function GameStart(e:TimerEvent) : void
		{

	    	bTiltTL = new btTilt();
	    	bTiltTL.x = 100;
	    	addChild(bTiltTL);

	    	bTiltTR = new btTilt();
	    	bTiltTR.x = 470;
	    	addChild(bTiltTR);

	    	bTiltBL = new btTilt();
	    	bTiltBL.x = 100;
	    	bTiltBL.y = 250;
	    	addChild(bTiltBL);

	    	bTiltBR = new btTilt();
	    	bTiltBR.x = 470;
	    	bTiltBR.y = 250;
	    	addChild(bTiltBR);
	    	
			bCerrar = new btCerrar();
			bCerrar.x = 820;
			bCerrar.y = 12;		
			bCerrar.addEventListener(MouseEvent.CLICK, MakeClose);
			addChild(bCerrar);

	    	bTiltTL.addEventListener(MouseEvent.CLICK, Delegate.create(moveMachine, 1));
	    	bTiltTR.addEventListener(MouseEvent.CLICK, Delegate.create(moveMachine, 2));
	    	bTiltBL.addEventListener(MouseEvent.CLICK, Delegate.create(moveMachine, 3));
	    	bTiltBR.addEventListener(MouseEvent.CLICK, Delegate.create(moveMachine, 4));
	    	
	    	addEventListener(Event.ENTER_FRAME, onEnterFrame);
	    	
			mBocata01 = new mcBocata01();
			mBocata01.x = 470;
			mBocata01.y = 400;
			mBocata01.visible = false;
			addChildAt(mBocata01,5);
			
			mBocata02 = new mcBocata02();
			mBocata02.x = 470;
			mBocata02.y = 400;
			mBocata02.visible = false;
			addChildAt(mBocata02,5);

			mBocata03 = new mcBocata03();
			mBocata03.x = 470;
			mBocata03.y = 400;
			mBocata03.visible = false;
			addChildAt(mBocata03,5);

			mBocataError = new mcBocataError();
			mBocataError.x = 470;
			mBocataError.y = 400;
			mBocataError.visible = false;
			addChildAt(mBocataError,5);

		}
		public function MakeClose (e:MouseEvent) : void
		{
			nScore = -1;
			bEnded = true;
		}
		public function Stop() : void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		public function GetScore() : int 
		{
			return nScore;
		}
		public function moveMachine (e:Event, direction:int) : void
		{
			removeChild(bTiltTL);
			removeChild(bTiltTR);
			removeChild(bTiltBL);
			removeChild(bTiltBR);

	    	sVendingM = new spVendingM();
	    	addChildAt(sVendingM,1);
	    	mDirection = direction;
	    	if (puzzStat >= 0 && puzzStat <= 3) 
	    	{
		    	puzzStat++;
		    	
	    	}
    		if (aSolution[iMoves] == mDirection)
    		{
    			iMoves++;
    		}
    		else 
    		{
    			iMoves = 0;
    			mBolsa.gotoAndStop(0);
    			puzzStat = 0;
    			if (nScore > 0)
    				nScore = nScore - 50;
    			showMessage(mBocataError);
    		}
	    }
		private function makeDieF (event:TimerEvent) : void
		{
			bEnded = true;
		}
	    public function onEnterFrame (e:Event) : void
	    {
    		//trace (nScore);	    		
	    	//trace(mBolsa.currentFrame);
    		if (mBolsa.currentFrame == 65) 
    		{
    			mBolsa.stop();
		    	removeEventListener(Event.ENTER_FRAME, onEnterFrame);

				TweenLite.to(mBolsa, 1, {alpha:0});
				TweenLite.to(sVending, 1, {alpha:0});

		    	var makeDie:Timer = new Timer (2000, 1);
		    	makeDie.addEventListener(TimerEvent.TIMER, makeDieF);
		        makeDie.start();

    		}
	    	switch (mDirection)
	    	{
	    		case -1:
	    			return;
	    			break;
	    		case 1:
	    			if(sVendingM.currentFrame < 6) 
	    			{
	    				sVendingM.x--; 
	    				sVendingM.y--; 
	    			}
	    			else
	    			{
	    				sVendingM.x++; 
	    				sVendingM.y++; 
	    			} 
	    			break;
	    		case 2:
	    			if(sVendingM.currentFrame < 6) 
	    			{
	    				sVendingM.x++; 
	    				sVendingM.y--; 
	    			}
	    			else
	    			{
	    				sVendingM.x--; 
	    				sVendingM.y++; 
	    			} 
	    			break;
	    		case 3:
	    			if(sVendingM.currentFrame < 6) 
	    			{
	    				sVendingM.x--; 
	    				sVendingM.y++; 
	    			}
	    			else
	    			{
	    				sVendingM.x++; 
	    				sVendingM.y--; 
	    			} 
	    			break;
	    		case 4:
	    			if(sVendingM.currentFrame < 6) 
	    			{
	    				sVendingM.x++; 
	    				sVendingM.y++; 
	    			}
	    			else
	    			{
	    				sVendingM.x--; 
	    				sVendingM.y--; 
	    			} 
	    			break;
	    		default: 
	    			trace("none");
	    			break;
	    	}
	    	if (puzzStat != 0) 
	    	{
	    		mBolsa.play();
	    		if (puzzStat == 1 && mBolsa.currentFrame == 5) 
	    		{
	    			mBolsa.stop();
	    			showMessage(mBocata01);
	    		}
	    		else if (puzzStat == 2 && mBolsa.currentFrame == 10) 
	    		{
	    			mBolsa.stop();
	    			showMessage(mBocata02);
	    		}
	    		else if (puzzStat == 3 && mBolsa.currentFrame == 15) 
	    		{
	    			mBolsa.stop();	    			
	    			showMessage(mBocata03);
	    		}
	    	}
	    		
	    	if(sVendingM.currentFrame == 12) 
	    	{
				addChild(bTiltTL);
				addChild(bTiltTR);
				addChild(bTiltBL);
				addChild(bTiltBR);
	    		mDirection = -1;
	    		removeChild(sVendingM);
	    	}
	    }
	    private function showMessage (mBocata : Sprite) : void
	    {
	    	mBocata01.visible = false;
	    	mBocata02.visible = false;
	    	mBocata03.visible = false;
	    	mBocataError.visible = false;
	    	mBocata.visible = true;
	    	
	    	var makeHide:Timer = new Timer (2000, 1);
	    	makeHide.addEventListener(TimerEvent.TIMER, Delegate.create(hideMessage, mBocata));
	        makeHide.start();
	    }
	    private function hideMessage (event:TimerEvent, mBocata : Sprite) : void
	    {
	    	mBocata.visible = false;
	    }
	}
}

