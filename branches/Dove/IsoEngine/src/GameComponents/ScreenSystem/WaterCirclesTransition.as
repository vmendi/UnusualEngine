package GameComponents.ScreenSystem
{
	import Model.GameModel;
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.geom.Point;
	
	public class WaterCirclesTransition
	{
		public var TotalTime : Number = 2200;
		
		public var TimeBetweenDonuts : Number = 0.3;	// Tiempo en segundos q tarda el siguiente en aparecer
		public var DonutsSpeed : Number = 300;			// Pixeles / sec
		public var DonutsWidth : Number = 45;			// Radio de los donuts, pixels
		public var CircleParamTime : Number = 0.50;		// Tiempo parametrico en el que sale el circulo central
		public var MaxDim : Number = 0;
		
		public function WaterCirclesTransition(globalCenterPoint : Point, gameModel : GameModel)
		{
			mGlobalCenterPoint = globalCenterPoint;
			MaxDim = Math.max(gameModel.TheRenderCanvas.width, gameModel.TheRenderCanvas.height);
		}
		
		public function Transition(oldScreen : MovieClip, targetScreen : MovieClip, elapsedTime : Number): Boolean
		{
			var isFinished : Boolean = false;

			if (mCurrentTime == 0)
			{
				mMask = new Shape();
				mMask.cacheAsBitmap = true;
				targetScreen.parent.addChild(mMask);
				targetScreen.mask = mMask;
				
				mAddCirclesTarget = new Shape();
				oldScreen.addChild(mAddCirclesTarget);
				
				mAddCirclesOld = new Shape();
				targetScreen.addChild(mAddCirclesOld);
			}
			
			mCurrentTime += elapsedTime;
			mCurrentSineTime += elapsedTime;
			
			if (mCurrentSineTime > mTotalSineTime)
				mCurrentSineTime = 0;
						
			if (mCurrentTime >= TotalTime)
			{
				mCurrentTime = TotalTime;
				isFinished = true;
			}
		
			var interpParam : Number = mCurrentTime / TotalTime;
			var localCoord : Point = mAddCirclesTarget.globalToLocal(mGlobalCenterPoint); 
			var finalRad : Number = (interpParam-CircleParamTime)*MaxDim/(1.0-CircleParamTime);
			
			mMask.graphics.clear();
			mAddCirclesOld.graphics.clear();
			mAddCirclesTarget.graphics.clear();
			mAddCirclesTarget.graphics.lineStyle(2, 0xB8C7E0);
			mAddCirclesOld.graphics.lineStyle(2, 0xB8C7E0);
			
			var numCircles : int = Math.floor(mCurrentTime*0.001 / TimeBetweenDonuts) + 1;
			
			while (numCircles > mCircleRadius.length)
			{
				mCircleRadius.push(0);
			}

			for (var c:int=0; c < numCircles; c++)
			{			
				mCircleRadius[c] += DonutsSpeed*elapsedTime*0.001;
				
				// Optimizacion, si este donut es mas pequeño q el gran circulo final...
				if (interpParam > CircleParamTime && finalRad > mCircleRadius[c])
					break;
				
				mMask.graphics.beginFill(0x00FF00);
				mMask.graphics.drawCircle(localCoord.x, localCoord.y, mCircleRadius[c]);
				
				mAddCirclesTarget.graphics.drawCircle(localCoord.x, localCoord.y, mCircleRadius[c]);
				
				if (mCircleRadius[c]-DonutsWidth > 0)
				{
					mMask.graphics.drawCircle(localCoord.x, localCoord.y, mCircleRadius[c]-DonutsWidth);
					mAddCirclesTarget.graphics.drawCircle(localCoord.x, localCoord.y, mCircleRadius[c]-DonutsWidth);
				}

				mMask.graphics.endFill();
			}
		
			if (interpParam > CircleParamTime)
			{
				mMask.graphics.beginFill(0x000000);
				mMask.graphics.drawCircle(localCoord.x, localCoord.y, finalRad);
				mMask.graphics.endFill();
				
				mAddCirclesOld.graphics.drawCircle(localCoord.x, localCoord.y, finalRad);
			}
			
			if (isFinished)
			{
				mAddCirclesTarget.parent.removeChild(mAddCirclesTarget);
				mAddCirclesOld.parent.removeChild(mAddCirclesOld);
				
				targetScreen.parent.removeChild(targetScreen.mask);
				targetScreen.mask = null;
			}
										
			return isFinished;
		}
		
		private var mCurrentSineTime : Number = 0;
		private var mTotalSineTime : Number = 1000.0;

		private var mCircleRadius : Array = new Array();
		private var mMask : Shape;
		private var mAddCirclesTarget : Shape;
		private var mAddCirclesOld : Shape;
		private var mCurrentTime : Number = 0;
		private var mGlobalCenterPoint :  Point;
		private var mLocalCenterPoint : Point;
	}
}