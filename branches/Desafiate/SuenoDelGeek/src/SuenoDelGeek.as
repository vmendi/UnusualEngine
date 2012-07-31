package {

	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import utils.MovieClipListener;

	[SWF (width="915", height="508", frameRate="30", backgroundColor="0xffffff")]

	public class SuenoDelGeek extends Sprite
	{
		// Librería de sprites
		[Embed(source='GeekLib.swf', symbol='mcScore')]			public var mcScoreClass:Class;
		[Embed(source='GeekLib.swf', symbol='mcPersonaje')]	 	public var mcPersonaje:Class;
		[Embed(source='GeekLib.swf', symbol='mcPingu')]			public var mcPingu:Class;
		[Embed(source='GeekLib.swf', symbol='mcBack')]			public var mcBack:Class;
		[Embed(source='GeekLib.swf', symbol='mcIntro')]			public var mcIntro:Class;
		[Embed(source='GeekLib.swf', symbol='grInstrucciones')]	public var grInstrucciones:Class;
		[Embed(source='GeekLib.swf', symbol='mcBounds')]		public var mcBounds:Class;
		[Embed(source='GeekLib.swf', symbol='btCerrar')]		public var btCerrar:Class;

		// Definición de elementos
	    private var mBack : MovieClip;
	    private var mPlayer : MovieClip;
	    private var mPingu : MovieClip;
	    private var mScore : MovieClip;
	    private var gInstrucciones : Bitmap;
	    private var bCerrar : SimpleButton;
	    private var aPingu : Array = new Array();
	    private var vDied : Boolean = false;
	    private var iEnemyCount : int = 0;
	    private var gravAcc : int;
	    private var gravAccInit : int = 35;
	    private var grav : int;
	    private var gravHi : int = 5;
	    private var gravLo : int = 2;
	    private var mIntro : MovieClip;
	    private var mBounds : MovieClip;
	    private var aBounds : Array = new Array();
	    private var vScore : int = 0;
	    private var mHasDied : Boolean = false;
	    private var mOnAir : Boolean = false;
	    private var mJumpTimer : Timer;
	    private var mJumpImpulse : int;
	    private var mGameOverTimer : Timer;

		// Variables de control
	    private var mLastTime : int=0;
	    //private var bgMover : Timer;
		private var endFall : Boolean = false;
		private var hitCount : int = 0;

		public function GetScore() : int 
		{
			return vScore;
		}

	    public function IsEnded() : Boolean
	    {
	    	return vDied;
	    }

  		/* public function SuenoDelGeek () : void
		{
			Start();
		} */ 
		   
	    public function Start() : void
	    {
	    	gravAcc = gravAccInit;
	    	mIntro = new mcIntro();
	    	addChild (mIntro);
	    	MovieClipListener.AddFrameScript(mIntro, "end", OnIntroAnimEnd);
	    }
	    
		public function MakeClose (e:MouseEvent) : void
		{
			vScore = -1;
			Stop();
			vDied = true;
		}
		
	    public function Stop() : void
	    {
	    	removeEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
	    	removeEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
	        removeEventListener(Event.ENTER_FRAME, onEnterFrame);
	        mGameOverTimer.removeEventListener(TimerEvent.TIMER, GameOver);
	    }
	    
		private function GameOver(e:TimerEvent) : void
		{
			Stop();
			vDied = true;
		}	    

	    private function OnIntroAnimEnd() : void
	    {
	    	ShowInstructions();
	    }
	    
	    public function ShowInstructions() : void
	    {
	    	mIntro.stop();
	    	removeChild(mIntro);

	    	mScore = new mcScoreClass();

	    	mPlayer = new mcPersonaje();
	    	mPlayer.stop();
	    	mPlayer.x = 200;
	    	mPlayer.y = 385;

			mBack = new mcBack();
	    	mBack.x = 0;
	    	mBack.y = 0;
	    	addChild (mBack);

			gInstrucciones = new grInstrucciones();
	    	gInstrucciones.x = 302;
	    	gInstrucciones.y = 163;
	    	addChild (gInstrucciones);
	    	
	    	addEventListener(MouseEvent.MOUSE_UP, StartGame); 

	    }
	    public function StartGame(e:Event) : void
	    {
	    	removeChild(gInstrucciones);
	    	removeEventListener(MouseEvent.MOUSE_UP, StartGame);

	        addEventListener(Event.ENTER_FRAME, onEnterFrame);

	    	var enemyMaker : Timer = new Timer (500, 1);
	    	enemyMaker.addEventListener(TimerEvent.TIMER, makeEnemy);
	        enemyMaker.start();
	        
	    	mGameOverTimer = new Timer (120000, 1);
	    	mGameOverTimer.addEventListener(TimerEvent.TIMER, GameOver);
	        mGameOverTimer.start();	        
	        
	    	addChild (mPlayer);

	    	addEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
	    	addEventListener(MouseEvent.MOUSE_UP, OnMouseUp);

	    	mScore.x = 680;
	    	mScore.y = 20;
	    	addChild(mScore);

			bCerrar = new btCerrar();
			bCerrar.x = 820;
			bCerrar.y = 12;		
			bCerrar.addEventListener(MouseEvent.CLICK, MakeClose);
			addChild(bCerrar);
	    }

		private function onEnterFrame (e:Event):void
		{
			var enemyMaker : Timer ;
	        if (vScore == 500) {
		    	enemyMaker = new Timer (3000, 1);
		    	enemyMaker.addEventListener(TimerEvent.TIMER, makeEnemy);
		        enemyMaker.start();
	        }
	        if (vScore == 1000) {
		    	enemyMaker = new Timer (3300, 1);
		    	enemyMaker.addEventListener(TimerEvent.TIMER, makeEnemy);
		        enemyMaker.start();
	        }
	        if (vScore == 1500) {
		    	enemyMaker = new Timer (3600, 1);
		    	enemyMaker.addEventListener(TimerEvent.TIMER, makeEnemy);
		        enemyMaker.start();
	        }
	        if (vScore == 2000) {
		    	enemyMaker = new Timer (4000, 1);
		    	enemyMaker.addEventListener(TimerEvent.TIMER, makeEnemy);
		        enemyMaker.start();
	        }
	        if (vScore == 2500) {
		    	enemyMaker = new Timer (4300, 1);
		    	enemyMaker.addEventListener(TimerEvent.TIMER, makeEnemy);
		        enemyMaker.start();
	        }

			bgMakeMove();
			enemyMakeMove();
			makeJump();

			for (var i:int = 0; aPingu[i] != undefined; i++) {
				if (mPlayer.hitTestObject(aBounds[i]))
				{
					playerDie();
				}
			}
			vScore++;
			mScore.tScore.text = vScore
		}
	    private function makeWin ():void
	    {
			var vDiedAssign:Timer = new Timer (1500, 1);
	    	vDiedAssign.addEventListener(TimerEvent.TIMER, makeDieVar);
	        vDiedAssign.start();
	    }
	    
		private function makeEnemy (event:TimerEvent) : void
		{
			aPingu[iEnemyCount] = new mcPingu();
	    	aPingu[iEnemyCount].x = 1000;
	    	aPingu[iEnemyCount].y = 340;
	    	addChild (aPingu[iEnemyCount]);
			aBounds[iEnemyCount] = new mcBounds();
	    	aBounds[iEnemyCount].x = 1000;
	    	aBounds[iEnemyCount].y = 340;
	    	addChild (aBounds[iEnemyCount]);
	    	iEnemyCount++;
		}
		
		private function enemyMakeMove():void
		{
			for (var i:int = 0; aPingu[i] != undefined; i++) {
				if (aPingu[i].x >= -100)
				{
					aPingu[i].x -= 15;
					aBounds[i].x -= 15;
				} else {
					aPingu[i].x = 1000;
					aBounds[i].x = 1000;
				}
			}
		}
		
		private function bgMakeMove():void
		{
			var newX : int = mBack.x - 5;
 			if (newX <= -1411)
			{
				newX += 1411;
			}
			mBack.x = newX;
		}
		
		private function OnMouseDown(e:MouseEvent):void
		{
	    	if (!mOnAir)
	    	{
	    		grav = gravLo;
	    		mJumpImpulse = 0;
		    	mJumpTimer = new Timer(150, 1);
		    	mJumpTimer.addEventListener(TimerEvent.TIMER, EndImpulse);
		        mJumpTimer.start();
		        playerJump();
	    	}
		}

		private function OnMouseUp(e:MouseEvent):void
		{
    		grav = gravHi;
			mJumpTimer.removeEventListener(TimerEvent.TIMER, EndImpulse);
		}
		
		private function EndImpulse(e:TimerEvent):void
		{
			grav = gravHi;
		}

	    private function playerJump ():void
	    {
	    	if (!mOnAir && !mHasDied)
	    	{
	    		mOnAir = true;
		    	endFall = false;
		    	// Calculo del impulso 
		    	gravAcc = gravAccInit + Math.round(mJumpImpulse/10);
	    	}
	    }
	    
	    private function makeJump ():void
	    {
			if (!mHasDied && mOnAir)
			{
		    	if (gravAcc > 15) {
			    	mPlayer.gotoAndStop("Impulse");
		    	} else if (gravAcc <= 15 && gravAcc > -15) {
			    	mPlayer.gotoAndStop("Jump");
				} else {
			    	mPlayer.gotoAndStop("Fall");
				}

		    	if (mPlayer.y <= 385 && endFall == false)
		    	{
		    		var newPos : int = mPlayer.y - gravAcc;
		    		if (newPos > 385) 
		    		{
		    			endFall = true;
		    			newPos = 385;
		    		}
		    		mPlayer.y = newPos;
		    		gravAcc = gravAcc - grav;
		    	}
		    	else
		    	{
		    		mPlayer.y = 385;
		    		mOnAir = false;
			    	mPlayer.gotoAndStop("Run");
		    	} 
	  		}
	    }
	    
	    
	    private function playerDie ():void
	    {
	    	mHasDied = true;
	    	removeEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
	    	removeEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
	        removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			mGameOverTimer.removeEventListener(TimerEvent.TIMER, GameOver);
			
	        mPlayer.gotoAndStop("Die");

			var vDiedAssign:Timer = new Timer (1500, 1);
	    	vDiedAssign.addEventListener(TimerEvent.TIMER, makeDieVar);
	        vDiedAssign.start();
	    }

	    private function makeDieVar (event: TimerEvent): void
	    {
			vDied = true;
	    }

	    private function makeDie (): void
	    {
	    	mPlayer.gotoAndStop("Die");
	    }

	    private function playerRun (event:TimerEvent):void
	    {
	    	if (vDied == false)
	    		mPlayer.gotoAndStop("Run");
	    }
	}
}