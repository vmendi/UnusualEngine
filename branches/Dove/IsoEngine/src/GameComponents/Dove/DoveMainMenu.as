package GameComponents.Dove
{
	import GameComponents.GameComponent;
	import GameComponents.Render2DComponent;
	import GameComponents.ScreenSystem.ScreenNavigator;
	import GameComponents.ScreenSystem.WaterCirclesTransition;
	
	import Model.SceneObject;
	import Model.UpdateEvent;
	
	import Singularity.Geom.BezierSpline;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import gs.TweenLite;
	import gs.easing.Sine;
	
	import utils.Delegate;
	import utils.MovieClipListener;

	public class DoveMainMenu extends GameComponent
	{
		public var Amplitude : Number = 300;
		public var PosK : Number = 200;
		public var SpeedK : Number = 5;
		
		public var PointSpacing : Number = 20;
		
		override public function OnStart():void
		{	
			mInitialYPos = TheVisualObject.y;
							
			mPaintShape = new Shape();
			TheVisualObject.addChildAt(mPaintShape, 0);
			
			TheVisualObject.stage.addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
						
			TheVisualObject.mcButProducts.addEventListener(MouseEvent.CLICK, OnButtonProductsClicked);
			TheVisualObject.mcButTest.addEventListener(MouseEvent.CLICK, OnButtonTestClicked);
			TheVisualObject.mcButWall.addEventListener(MouseEvent.CLICK, OnButtonWallClicked);
			
			TheVisualObject.mcButCondiciones.addEventListener(MouseEvent.CLICK, OnButtonCondicionesClicked);
			
			mScreenNav = TheAssetObject.FindGameComponentByShortName("ScreenNavigator") as ScreenNavigator;
		}
		
		private function OnButtonCondicionesClicked(e:Event) : void
		{
			navigateToURL(new URLRequest("Assets/Dove/condiciones.html"), "_blank");
		}
		
		override public function OnStop():void
		{
			TheVisualObject.stage.removeEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
		}
						
		private function OnButtonProductsClicked(event:MouseEvent):void
		{
			MakeTransition(TheVisualObject.mcButProducts, "mcProducts");	
		}
		
		private function OnButtonTestClicked(event:MouseEvent):void
		{				
			MakeTransition(TheVisualObject.mcButTest, "mcTest");
		}
		
		private function OnButtonWallClicked(event:MouseEvent):void
		{	
			//mScreenNav.GotoScreen("mcForm", new FadeTransition(500).Transition);
			//MoveToBottom();
			
			MakeTransition(TheVisualObject.mcButWall, "mcWorkInProgress");
			//GotoTrucos();
		}
		
		public function GotoTrucos() : void
		{
			navigateToURL(new URLRequest("http://www.embellecetupiel.com/Trucos"), "_self");
		}
		
		public function MakeTransition(but:DisplayObject, mcName:String) : void
		{	
			if (mTheDelegate != null)// || mScreenNav.IsTransitioning())
				return;

			var gota : Render2DComponent = TheGameModel.CreateSceneObjectFromMovieClip("mcGota", "Render2DComponent") as Render2DComponent;
			gota.ScreenPos = new Point(but.x + but.width*0.5, GetGotaYPos());
			
			mTheDelegate = Delegate.create(OnGotaImpacto, but, mcName);
			MovieClipListener.AddFrameScript(gota.TheVisualObject, "impacto", OnSignalGotaImpacto);
			MovieClipListener.AddFrameScript(gota.TheVisualObject, "end", Delegate.create(OnGotaDestroy, gota.TheSceneObject));
		}
		
		private var mTheLaunchDelegate : Function;
		private var mTheDelegate : Function;
		
		private function OnGotaDestroy(gota:SceneObject):void
		{
			gota.TheVisualObject.stop();
			TheGameModel.DeleteSceneObject(gota);	
		}
		
		private function OnSignalGotaImpacto():void
		{
			mTheLaunchDelegate = mTheDelegate;
			mTheDelegate = null;			
		}
				
		private function OnGotaImpacto(button:DisplayObject, screen:String):void
		{
			mScreenNav.GotoScreen(screen, new WaterCirclesTransition(GetGlobalCirclePosOf(button), TheGameModel).Transition);
			Perturbate(mPaintShape.globalToLocal(GetGlobalCirclePosOf(button)), 2);			
			MoveToBottom();
		}
		
		private function Perturbate(localMouse : Point, multiplier : Number):void
		{
			var numPoints : int = mPoints.length;
			var idxMousePoint : Number = Math.floor(Math.abs(localMouse.x) / PointSpacing);
					
			var ceroCount : int = -1;
			for (var c:int=idxMousePoint-1; c < idxMousePoint+2; c++)
			{
				var factor : Number = 1 / (Math.abs(ceroCount) + 1);
				ceroCount++;
				if (c >= 0 && c < numPoints-1)
				{
					mSpeeds[c].y += Amplitude*factor*multiplier;
				}
			}
		}
		
		private function MoveToBottom():void
		{
			var finalCoord : Number = 160 + GetSecondaryYPos();						
			TweenLite.to(TheVisualObject, 1, { y:finalCoord, ease:Sine.easeInOut });
			
			mIsInBottom = true;
		}
		
		private function GetGlobalCirclePosOf(but : DisplayObject) : Point
		{
			return but.localToGlobal(new Point(but.width*0.5, GetSecondaryYPos()));
		}
		
		private function GetSecondaryYPos() : Number {	return 60;	}
		private function GetGotaYPos() : Number { return mIsInBottom? 180 : 120; }
		
		public function ResetPos() : void
		{
			TweenLite.to(TheVisualObject, 1, { y:mInitialYPos, ease:Sine.easeInOut });
			mIsInBottom = false;
		}	
		
		private function OnMouseMove(event:MouseEvent):void
		{
			if (mPaintShape != null)
			{
				mLocalMouse = mPaintShape.globalToLocal(new Point(event.stageX, event.stageY));
			}
		}
		
		override public function OnUpdate(event:UpdateEvent):void
		{
			var localZero : Point = TheVisualObject.globalToLocal(new Point(0, 0));
			var currWidth : Number = Math.abs(2*localZero.x);

			if (currWidth != mLastWidth)
			{
				mLastWidth = currWidth;
											
				mPaintShape.x = localZero.x;
				mPaintShape.y = -36;
				
				// Sumamos 3 para salirnos del todo por la derecha
				var numPoints : Number = Math.floor(mLastWidth/PointSpacing)+3; 
				mPoints = new Array();
				mSpeeds = new Array();
				
				for (var c:int = 0; c < numPoints; c++)
				{
					var newPoint : Point = new Point(c*PointSpacing, 0);
					mPoints.push(newPoint);
					
					var newSpeed : Point = new Point(0, 0);
					mSpeeds.push(newSpeed);
				}
			}
			
			numPoints = mPoints.length;
			
			if (mLocalMouse != null)
			{	
				if (Math.abs(mLocalMouse.y) < 30)
				{
					var idxMousePoint : Number = Math.floor(Math.abs(mLocalMouse.x) / PointSpacing);
					
					var ceroCount : int = -1;
					for (c=idxMousePoint-1; c < idxMousePoint+2; c++)
					{
						var factor : Number = 1 / (Math.abs(ceroCount) + 1);
						ceroCount++;
						if (c >= 0 && c < numPoints-1)
						{
							mSpeeds[c].y += Amplitude*factor;
							
							if (mSpeeds[c].y > Amplitude)
								mSpeeds[c].y = Amplitude;
						}
					}
				}

				mLocalMouse = null;
			}
			
			for (c = 0; c < numPoints; c++)
			{
				mPoints[c].y +=  mSpeeds[c].y*event.ElapsedTime/1000;
				mSpeeds[c].y += (-PosK*mPoints[c].y*event.ElapsedTime/1000) - (SpeedK*mSpeeds[c].y*event.ElapsedTime/1000);
			}
			
			mPaintShape.graphics.clear();
			
			var onShapeMax : Point = mPaintShape.globalToLocal(new Point(TheVisualObject.stage.stageWidth, TheVisualObject.stage.stageHeight));
			
			var spline : BezierSpline = new BezierSpline();
			spline.container = mPaintShape;

			for (c = 0; c < numPoints; c++)
			{
				spline.addControlPoint(mPoints[c].x, mPoints[c].y);	
			}
			spline.addControlPoint(currWidth, onShapeMax.y);
			spline.addControlPoint(0, onShapeMax.y);
			spline.addControlPoint(0, 0);
			
			mPaintShape.graphics.moveTo(0, 0);
			spline.drawFilled(0xc0cbf0, 0xFFFFFF);
			
			if (mTheLaunchDelegate != null)
			{
				mTheLaunchDelegate();
				mTheLaunchDelegate = null;
			}
		}
		
		
		private var mInitialYPos : Number;
		private var mLocalMouse : Point;
		private var mLastWidth : Number = -1;
		private var mPoints : Array;
		private var mSpeeds : Array;
		private var mIsInBottom : Boolean = false;
				
		private var mPaintShape : Shape;
				
		private var mScreenNav : ScreenNavigator;
	}
}