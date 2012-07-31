package GameComponents
{
	import Model.GameModel;
	import Model.UpdateEvent;

	import PathFinding.*;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import utils.GenericEvent;
	import utils.MovieClipLabels;
	import utils.Point3;

	/**
	 * Componente para hacer que un objeto se comporte como personaje.
	 */
	public final class Character extends GameComponent
	{
		public var WalkSpeed : Number = 1;
		public var StartOrientation : String = "SE";
		public var CamFollow : Boolean = true;

		[NonSerializable]
		public function get MouseControlled() : Boolean { return mMouseControlled; }
		public function set MouseControlled(val:Boolean):void { mMouseControlled = val; }


		override public function OnStart() : void
		{
			// Exigimos que el AStarMapSpace exista en el mapa!
			mSearchSpace = TheGameModel.FindGameComponentByShortName("AStarMapSpace") as AStarMapSpace;
			mAStart = new AStar(mSearchSpace);

			// Controlamos el click
			TheVisualObject.stage.addEventListener(MouseEvent.CLICK, OnClick);

			var frameOfStop : int = MovieClipLabels.GetFrameOfLabel("stop", TheVisualObject);
			TheVisualObject.addFrameScript(frameOfStop-1, OnVisualFrameStop);

			// Posición inicial
			TheVisualObject.gotoAndStop("idle"+StartOrientation);

			// Posición inicial
			if (TheGameModel.GlobalGameState.NextStartWorldPos != null)
				TheIsoComponent.WorldPos = TheGameModel.GlobalGameState.NextStartWorldPos;

			// Orientación inicial
			if (TheGameModel.GlobalGameState.NextOrientation != null)
				TheVisualObject.gotoAndStop("idle"+TheGameModel.GlobalGameState.NextOrientation);
			else
				TheVisualObject.gotoAndStop("idle"+StartOrientation);
		}

		override public function OnStartComplete():void
		{
			if (CamFollow)
			{
				TheGameModel.TheIsoCamera.CheckLimits = true;
				TheGameModel.TheIsoCamera.TargetPos = new Point(TheIsoComponent.WorldPos.x, TheIsoComponent.WorldPos.z);
			}
		}

		override public function OnPause():void
		{
			TheVisualObject.stage.removeEventListener(MouseEvent.CLICK, OnClick);
			TheVisualObject.gotoAndStop("idle"+mLastHeading);
			mPath = null;
		}

		override public function OnResume():void
		{
			TheVisualObject.stage.addEventListener(MouseEvent.CLICK, OnClick);
		}

		override public function OnStop():void
		{
			TheVisualObject.stage.removeEventListener(MouseEvent.CLICK, OnClick);
		}


		private function OnClick(event:MouseEvent) : void
		{
			if (!mMouseControlled)
				return;

			var mousePos : Point = TheGameModel.TheRenderCanvas.globalToLocal(new Point(event.stageX, event.stageY));
			var worldClickPos : Point3 = TheGameModel.TheIsoCamera.IsoScreenToWorld(mousePos);

			NavigateTo(worldClickPos);
		}


		public function NavigateTo(globalPos : Point3) : void
		{
			var oldDir : Point3 = null;
			if (mPath != null)
			{
				var firstPoint : Point3 = GetFirstPoint();
				var secondPoint : Point3 = mSearchSpace.SearchToWorldSpace(mPath[mCurrentPathPoint+1]);

				oldDir = secondPoint.Substract(firstPoint);
			}
			var srcPoint : IntPoint = mSearchSpace.WorldToSearchSpace(TheIsoComponent.WorldPos);
			var dstPoint : IntPoint = mSearchSpace.WorldToSearchSpace(globalPos);

			var path : Array = mAStart.Solve(srcPoint, dstPoint);

			if (path != null)
			{
				mPath = path;
				mFirstStartingPoint = TheIsoComponent.WorldPos;
				mCurrentPathPoint = -1;
				mCurrentDist = 0;
				mLastHeading = "";

				if (oldDir != null)
				{
					firstPoint = GetFirstPoint();
					secondPoint = mSearchSpace.SearchToWorldSpace(mPath[mCurrentPathPoint+1]);

					var currDir : Point3 =	secondPoint.Substract(firstPoint);

					// Anti-deslizamiento
					if (currDir.DotProduct(oldDir) <= 0)
						mPath.splice(0, 0, srcPoint);
				}

				dispatchEvent(new GenericEvent("NavigationStart", globalPos.Clone()));
			}
			else
			{
				trace("Path no encontrado");
			}
		}

		private function DrawPath():void
		{
			TheGameModel.TheIsoCamera.TheIsoBackground.UnlitAllOfColor(0xFF0000);
			for each (var pathPoint : IntPoint in mPath)
			{
				var wPos : Point3 = mSearchSpace.SearchToWorldSpace(pathPoint);
				TheGameModel.TheIsoCamera.TheIsoBackground.LightCell(wPos, 0xFF0000);
			}
		}
		
		public function NavigationStop():void
		{
			TheVisualObject.gotoAndStop("idle"+mLastHeading);
			mPath = null;
		}		

		public function OrientTo(toPoint : Point3) : void
		{
			var currHeading : String = GetHeadingString(TheIsoComponent.WorldPos, toPoint);

			if (currHeading != mLastHeading)
			{
				TheVisualObject.gotoAndStop("idle"+currHeading);
				mLastHeading = currHeading;
			}
		}

		public function OrientToHeadingString(heading : String) : void
		{
			if (heading != mLastHeading)
			{
				TheVisualObject.gotoAndStop("idle"+heading);
				mLastHeading = heading;
			}
		}

		override public function OnUpdate(event:UpdateEvent):void
		{
			// Movimiento
			InterpolateMovement(event.ElapsedTime);

			// La camara nos sigue
		 	if (CamFollow)
				TheGameModel.TheIsoCamera.TargetPos = new Point(TheIsoComponent.WorldPos.x, TheIsoComponent.WorldPos.z);

			// Hacemos transparente el escenario
			TheGameModel.MakeTransparentOthers(TheIsoComponent);
		}

		private function GetFirstPoint():Point3
		{
			if (mCurrentPathPoint != -1)
				return mSearchSpace.SearchToWorldSpace(mPath[mCurrentPathPoint]);
			else
				return mFirstStartingPoint.Clone();
		}

		private function InterpolateMovement(elapsedTime : Number) : void
		{
			if (mPath != null)
			{
				var firstPoint : Point3 = GetFirstPoint();
				var secondPoint : Point3 = secondPoint = mSearchSpace.SearchToWorldSpace(mPath[mCurrentPathPoint+1]);

				var distTotal : Number = secondPoint.Distance(firstPoint);
				var distStep : Number = elapsedTime*WalkSpeed*0.001;

				// Paso al siguiente punto?
				if (mCurrentDist + distStep >= distTotal)
				{
					mCurrentPathPoint++;
					mCurrentDist = 0;
					distStep = 0;

					if (mCurrentPathPoint == mPath.length-1)
					{
						mPath = null;
						TheIsoComponent.SetWorldPosRounded(secondPoint);
						TheVisualObject.gotoAndStop("stop");
					}
					else
					{
						firstPoint = mSearchSpace.SearchToWorldSpace(mPath[mCurrentPathPoint]);
						secondPoint = mSearchSpace.SearchToWorldSpace(mPath[mCurrentPathPoint+1]);
					}
				}

				if (mPath != null)
				{
					var currHeading : String = GetHeadingString(firstPoint, secondPoint);
					if (currHeading != mLastHeading)
					{
						TheVisualObject.gotoAndStop("walk"+currHeading);
						mLastHeading = currHeading;
					}
					mCurrentDist += distStep;
					TheIsoComponent.WorldPos = firstPoint.AddToThis(firstPoint.GetScaledDirection(secondPoint, mCurrentDist));
				}
				else
				{
					dispatchEvent(new Event("NavigationEnd"));
				}
			}
		}

		private function DrawCurrentCell():void
		{
			var snapPos : Point3 = GameModel.GetSnappedWorldPos(TheIsoComponent.WorldPos);
			if (mLastRenderedCell != null)
			{
				if (!snapPos.IsEqual(mLastRenderedCell))
				{
					TheGameModel.TheIsoCamera.TheIsoBackground.UnlitAllOfColor(0x0000FF);
					TheGameModel.TheIsoCamera.TheIsoBackground.LightCell(snapPos, 0x0000FF);
					mLastRenderedCell = snapPos;
				}
			}
			else
				mLastRenderedCell = snapPos;
		}

		private function OnVisualFrameStop() : void
		{
			TheVisualObject.gotoAndStop("idle"+mLastHeading);
		}

		private function GetHeadingString(firstPoint : Point3, secondPoint : Point3) : String
		{
			var headingVect : Point3 = secondPoint.Substract(firstPoint);
			var ret : String = "";

			if (headingVect.z > 0.1)
			{
				if (headingVect.x > 0.1)
					ret = "N";
				else
				if 	(headingVect.x < -0.1)
					ret = "W";
				else
					ret = "NW";
			}
			else
			if (headingVect.z < -0.1)
			{
				if (headingVect.x > 0.1)
					ret = "E";
				else
				if (headingVect.x < -0.1)
					ret = "S";
				else
					ret = "SE";
			}
			else
			{
				if (headingVect.x > 0.1)
					ret = "NE";
				else
				if (headingVect.x < -0.1)
					ret = "SW";
				else
					ret = "";	// Estamos parados
			}

			return ret;
		}

		public function SetNavigationEnabled(enabled : Boolean) : void
		{
			if (enabled)
				TheVisualObject.stage.addEventListener(MouseEvent.CLICK, OnClick);
			else
				TheVisualObject.stage.removeEventListener(MouseEvent.CLICK, OnClick);
		}

		private var mPath : Array;
		private var mCurrentPathPoint : int = 0;
		private var mCurrentDist : Number = 0;
		private var mFirstStartingPoint : Point3;
		private var mLastHeading : String = "";
		private var mSearchSpace : AStarMapSpace;
		private var mAStart : AStar;
		private var mMouseControlled : Boolean = true;

		// Debug
		private var mLastRenderedCell : Point3 = null;
	}
}