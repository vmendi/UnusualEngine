package GameComponents.IsoRacer
{
	import GameComponents.AStarMapSpace;
	import GameComponents.GameComponent;
	
	import Model.GameModel;
	import Model.IsoOrient;
	import Model.UpdateEvent;
	
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import utils.KeyboardHandler;
	import utils.Point3;
	
	/**
	 * Componente para hacer que un objeto se comporte como vehículo.
	 */
	public final class Vehicle extends GameComponent
	{
		
		public var MaxBackSpeed : Number =  -5;
		public var MaxSpeed : Number = 15
		public var Acceleration : Number = 0.6;
		public var Deceleration : Number = 1;
		public var SpeedDecay : Number = 1.05;
		public var InitAngle : Number = 0;
		public var InitSpeed : Number = 0;
		public var CollisionBounds : Number = 0.1;
		
		override public function OnStart() : void
		{
			TheGameModel.TheIsoCamera.CheckLimits = true;
			mAngle = InitAngle;
			mSpeed = InitSpeed;
			mAStarMap = TheGameModel.FindGameComponentByShortName("AStarMapSpace") as AStarMapSpace;
			mCellSizeInMeters = GameModel.CellSizeMeters;
			UpdateCar();
			TheGameModel.TheIsoCamera.TargetPos = new Point(TheIsoComponent.WorldPos.x, TheIsoComponent.WorldPos.z);
		}
		
		override public function OnPause():void
		{
		}
		
		override public function OnResume():void
		{			
		}
		
		override public function OnUpdate(event:UpdateEvent):void
		{
			if (!mStopped)
			{
				// Teclas
				ListenForKeys();
							
				// Movimiento
				InterpolateMovement(event.ElapsedTime);
			}
						
			// Centramos la camara en nosotros
			TheGameModel.TheIsoCamera.TargetPos = new Point(TheIsoComponent.WorldPos.x, TheIsoComponent.WorldPos.z);
			
			// Hacemos transparente el escenario
			TheGameModel.MakeTransparentOthers(TheIsoComponent);			
		}
		
		private function ListenForKeys():void
		{	
			mSmoke = false;
			
			if ( KeyboardHandler.Keyb.IsKeyPressed(Keyboard.UP) && !mInAir)
			{
				mSpeed += Acceleration;
				if (mSpeed < 3)
					mSmoke = true;
			}
			else if ( KeyboardHandler.Keyb.IsKeyPressed(Keyboard.DOWN) && mSpeed > MaxBackSpeed && !mInAir)
			{
				mSpeed -= Deceleration;
			}
			else if (!mInAir)
			{
				mSpeed /= SpeedDecay;		
			}
			
			if (KeyboardHandler.Keyb.IsKeyPressed(Keyboard.LEFT))
			{
				mTurnDir = 40;
				mNewSteer = 100;
				mTiltDir = 1;
				if (mNewSlide < 15)
					mNewSlide += 0.2;
			}
			else if (KeyboardHandler.Keyb.IsKeyPressed(Keyboard.RIGHT))
			{
				mTurnDir = -40;
				mNewSteer = -100;
				mTiltDir = -1;
				if (mNewSlide < 15)
					mNewSlide += 0.2;
			}
			else
			{
				ResetControl();
			}	
		}
		
		private function ResetControl() : void
		{
			mTurnDir = 0;
			mNewSteer = 0;
			mTiltDir = 0;
			mNewSlide = 0;
			mSteer = 0;
		}
		
		private function InterpolateMovement(elapsedTime : Number):void
		{				
			var NewVx : Number;
			var NewVz : Number;
			var NewX : Number;
			var NewY : Number;
			var NewZ : Number;
			
			if (mSpeed > MaxSpeed)
				mSpeed = MaxSpeed;
			
			mTilt = mTilt + (((mTiltDir * (((mSpeed + 4) / 1.6) / 5)) - mTilt) / 3);
			mSlide = mSlide + ((mNewSlide - mSlide) / 10);
			mSteer = mSteer + ((mNewSteer - mSteer) / 10);
			mRotate = mSteer / 1000;
			
			// Ángulo
			mAngAdd = mRotate * mSpeed;
			if (mAngAdd > 0.5)
			{
				mAngAdd = 0.5;
				mT++;
			}
			else if (mAngAdd < -0.5)
			{
				mAngAdd = -0.5;
				mT++;
			}
			else
			{
				mT = 0;
			}
			
			mAngle = mAngle + mAngAdd;
			
			if (Math.round(mAngle) > 40)
			{
				mAngle = 1;
			}
			else if (Math.round(mAngle) < 1)
			{
				mAngle = 40;
			}
			
			if ( !mInAir && !mAuto )
			{
				NewVx = mSpeed * Math.sin(((Math.round(mAngle) * 9) + 135) * Math.PI/180);
				NewVz = -mSpeed * Math.cos(((Math.round(mAngle) * 9) + 135) * Math.PI/180);
				mVx = mVx + ((NewVx - mVx) / (mSlide + 1));
				mVz = mVz + ((NewVz - mVz) / (mSlide + 1));
			}
			mAuto = false;
			
			mX = TheIsoComponent.WorldPos.x;
			mY = TheIsoComponent.WorldPos.y;
			mZ = TheIsoComponent.WorldPos.z;
			
			TestCollision();
			
			mX = mX + (mVx/60);
			mY = mY;
			mZ = mZ + (mVz/60);
			
			Pinta(mX, mY, mZ);
						
			TheIsoComponent.WorldPos = new Point3(mX,mY,mZ);
			
			try {	// Hack para evitar cascazo: body, etc... no existen al principio hasta que no pasan unos frames
				UpdateCar();
			} catch (e:Error) {}
			
		}
		
		private function Pinta(x:Number, y:Number, z:Number):void
		{

			var floor : Number = 0;
			mShadowInc = 0;
			if (y >= floor) {
				mBank = int(mTilt) * 40;
				mWheelsTurn = mTurnDir;
				y = floor;
				mVy = (-mVy) / 2;
				mGroundDis = 0;
				//TheVisualObject.car.gotoAndPlay(6);
				mIncline = 80;
				mInAir = false;

			} else {
				mInAir = true;;
				mGroundDis = floor - y;
			}
			
		}
		
		public function EnableMovement(enabled : Boolean) : void
		{
			mStopped = !enabled;
		}
		
		private function TestCollision() : void
		{
			var collisionCount : Number = 0;
			var srcPoint : Point3 = GameModel.GetSnappedWorldPos(TheIsoComponent.WorldPos);
			var zonaEjeZ : Number = 0;
			var zonaEjeX : Number = 0;
			var zona : int = 0;
			
			// Cálculo de la zona de la celda actual en la que se encuentra el coche
			if (TheIsoComponent.WorldPos.z > srcPoint.z+mCellSizeInMeters-CollisionBounds && mVz > 0)
			{
				zonaEjeZ = 8;
			}
			else if (TheIsoComponent.WorldPos.z < srcPoint.z+CollisionBounds && mVz < 0)
			{
				zonaEjeZ = 2;
			}
			else
			{
				zonaEjeZ = 0;
			}
			
			if (TheIsoComponent.WorldPos.x > srcPoint.x+mCellSizeInMeters-CollisionBounds && mVx > 0)
			{
				zonaEjeX = 1;
			}
			else if (TheIsoComponent.WorldPos.x < srcPoint.x+CollisionBounds && mVx < 0)
			{
				zonaEjeX = 4;
			}
			else
			{
				zonaEjeX = 0;
			}
			
			zona = zonaEjeZ + zonaEjeX;
			
			// Test de la colisión segun la zona
			for (var i : Number = 0; i < mTestListZone[zona].length; i++){
				// Comprueba que si es la colision de la esquina no ha colisionado antes con otra
				if ( (i < mTestListZone[zona].length-1) || (collisionCount < 1) ) {
					if (!mAStarMap.IsNeighborWalkable(mTestListZone[zona][i], TheIsoComponent.WorldPos))
					{
						collisionCount++;
						DoReaction(mTestListZone[zona][i]);
					}
				}
			}

		}
		
		private function UpdateCar() : void
		{
			TheVisualObject.car.body.gotoAndStop( ( Math.round(mAngle) + mIncline ) + mBank);
			TheVisualObject.car.wheels.gotoAndStop( ( Math.round(mAngle) + mIncline ) + mWheelsTurn);
			TheVisualObject.shadow.gotoAndStop( Math.round( mAngle + mShadowInc ) );			
		}
		
		private function DoReaction(direction : Number) : void
		{
			var srcPoint : Point3 = GameModel.GetSnappedWorldPos(TheIsoComponent.WorldPos);
			
			
			switch (direction) {
				
				case IsoOrient.NORTH_WEST:
					mVz = (-mVz) / 5;
					mZ = srcPoint.z+mCellSizeInMeters-CollisionBounds;
					
					if ((mAngle <= 8) && (mAngle >= 2))
					{
						mSpeed = (-mSpeed) / 2;
					}
					else
					{
						mSpeed = mSpeed / 2;
						if (Math.sqrt(mVx) > 0)
							mAngle = mAngle - 1;
						else
							mAngle = mAngle + 1;
					}
				break;
				
				case IsoOrient.NORTH_EAST:
					mVx = (-mVx) / 5;
					mX = srcPoint.x+mCellSizeInMeters-CollisionBounds;
					
					if ((mAngle <= 38) && (mAngle >= 32)) {
						mSpeed = (-mSpeed) / 2;
					}
					else
					{
						mSpeed = mSpeed / 2;
						if (Math.sqrt(mVz) > 0) {
							mAngle = mAngle + 1;
						} else {
							mAngle = mAngle - 1;
						}
					}
				break;
				
				case IsoOrient.SOUTH_EAST:
					mVz = (-mVz) / 5;
					mZ = srcPoint.z+CollisionBounds;
					
					if ((mAngle <= 28) && (mAngle >= 22))
					{
						mSpeed = (-mSpeed) / 2;
					}
					else
					{
						mSpeed = mSpeed / 2;
						if (Math.sqrt(mVx) > 0) {
							mAngle = mAngle + 1;
						} else {
							mAngle = mAngle - 1;
						}
					}
				break;
				
				case IsoOrient.SOUTH_WEST:
					mVx = (-mVx) / 5;
					mX = srcPoint.x+CollisionBounds;
					
					if ((mAngle <= 18) && (mAngle >= 12)) {
						mSpeed = (-mSpeed) / 2;
					}
					else
					{
						mSpeed = mSpeed / 2;
						if (Math.sqrt(mVz) > 0) {
							mAngle = mAngle - 1;
						} else {
							mAngle = mAngle + 1;
						}
					}
				break;
				
				case IsoOrient.NORTH:
					mVz = (-mVz) / 5;
					mVx = (-mVx) / 5;
					mX = srcPoint.x+mCellSizeInMeters-CollisionBounds;
					mZ = srcPoint.z+mCellSizeInMeters-CollisionBounds;
					mSpeed = (-mSpeed) / 4;
				break;
				
				case IsoOrient.EAST:
					mVz = (-mVz) / 5;
					mVx = (-mVx) / 5;
					mX = srcPoint.x+mCellSizeInMeters-CollisionBounds;
					mZ = srcPoint.z+CollisionBounds;
					mSpeed = (-mSpeed) / 4;
				break;
				
				case IsoOrient.SOUTH:
					mVz = (-mVz) / 5;
					mVx = (-mVx) / 5;
					mX = srcPoint.x+CollisionBounds;
					mZ = srcPoint.z+CollisionBounds;
					mSpeed = (-mSpeed) / 4;
				break;
				
				case IsoOrient.WEST:
					mVz = (-mVz) / 5;
					mVx = (-mVx) / 5;
					mX = srcPoint.x+CollisionBounds;
					mZ = srcPoint.z+mCellSizeInMeters-CollisionBounds;
					mSpeed = (-mSpeed) / 4;
				break;
				
			}
			
		}
		
	
		private var mSmoke : Boolean = false;
		private var mInAir : Boolean = false;
		private var mSpeed : Number = 0;
		
		private var mTurnDir : Number = 0;
		private var mNewSteer : Number = 0;
		private var mTiltDir : Number = 1;
		private var mNewSlide : Number = 15;
		
		private var mSteer : Number = 0;
		private var mTilt : Number = 0;
		private var mSlide : Number = 0;
		private var mRotate : Number = 0;
		private var mAngAdd : Number = 0;
		private var mAngle : Number = 0;
		private var mT : Number = 0;
		private var mAuto : Boolean; // COMPROBAR
		private var mVx : Number = 0;
		private var mVz : Number = 0;
		private var mVy : Number = 0;
		private var mX : Number;
		private var mY : Number;
		private var mZ : Number;
		
		private var mShadowInc : Number = 0;
		private var mBank : Number = 0;
		private var mWheelsTurn : Number = 0;
		private var mIncline : Number = 0;
		private var mGroundDis : Number = 0;
		
		private var mAStarMap : AStarMapSpace;
		private var mIsoOrient : IsoOrient;
		private var mCellSizeInMeters : Number;
		private var mStopped : Boolean = false;
		
		private var mTestListZone : Array = [[],
										    [IsoOrient.NORTH_EAST],
										    [IsoOrient.SOUTH_EAST],
										    [IsoOrient.NORTH_EAST,IsoOrient.SOUTH_EAST,IsoOrient.EAST],
										    [IsoOrient.SOUTH_WEST],
										    null,
										    [IsoOrient.SOUTH_EAST,IsoOrient.SOUTH_WEST,IsoOrient.SOUTH],
										    null,
										    [IsoOrient.NORTH_WEST],
										    [IsoOrient.NORTH_WEST,IsoOrient.NORTH_EAST,IsoOrient.NORTH],
										    null,
										    null,
										    [IsoOrient.SOUTH_WEST,IsoOrient.NORTH_WEST,IsoOrient.WEST]];
	}
}