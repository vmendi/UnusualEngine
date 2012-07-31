package GameComponents
{
	import Model.AssetObject;
	import Model.GameModel;
	import Model.IsoBounds;
	import Model.IsoCamera;

	import flash.events.Event;
	import flash.geom.Point;

	import utils.Point3;

	public final class IsoComponent extends GameComponent
	{
		public var WidthInCells : int = 0;
		public var HeightInCells : int = 0;
		public var Transparent : Boolean = true;
		public var Walkable : Boolean = false;
		public var ForceToBackground : Boolean = false;


		/** Posición en el mundo */
		[Bindable(event="WorldPosChanged")]
		public function get WorldPos() : Point3  { return mWorldPos; }

		/** Cambia la posición en mundo */
		public function set WorldPos(p : Point3) : void
		{
			mWorldPos = p;
			UpdateVisualObjectPos();
			dispatchEvent(new Event("WorldPosChanged"));
		}

		public const SOUTH_EAST : int = 0;
		public const SOUTH_WEST : int = 1;
		public const NORTH_WEST : int = 2;
		public const NORTH_EAST : int = 3;

		public function NextOrientation() : void
		{
			Orientation = Orientation+1;
		}

		[Bindable(event="OrientationChanged")]
		public function get Orientation() : int 	{ return mOrientation; }
		public function set Orientation(or : int):void
		{
			mOrientation = or;

			if (mOrientation > NORTH_EAST)
				mOrientation = SOUTH_EAST;

			UpdateVisualObjectOrient();
			dispatchEvent(new Event("OrientationChanged"));
		}

		/** Ancho en celdas del objeto, depende de la orientación */
		public function get OrientedWidthInCells() : int
		{
			if (mOrientation == NORTH_EAST || mOrientation == SOUTH_WEST)
				return HeightInCells;

			return WidthInCells;
		}

		/** Alto en celdas del objeto, depende de la orientación */
		public function get OrientedHeightInCells() : int
		{
			if (mOrientation == NORTH_EAST || mOrientation == SOUTH_WEST)
				return WidthInCells;

			return HeightInCells;
		}

		/** Coordenada X en mundo de la esquina frontal derecha. Se usa para ordenar en profundidad */
		public function get FrontRigthX() : Number { return mWorldPos.x + (OrientedWidthInCells*GameModel.CellSizeMeters); }
		/** Coordenada Z en mundo de la esquina frontal derecha. Se usa para ordenar en profundidad */
		public function get FrontRigthZ() : Number { return mWorldPos.z + (OrientedHeightInCells*GameModel.CellSizeMeters); }

		/** Bounds en espacio de mundo */
		public function get Bounds() : IsoBounds
		{
			mBounds.Left = mWorldPos.x;
			mBounds.Back = mWorldPos.z;
			mBounds.Right = mWorldPos.x + (OrientedWidthInCells*GameModel.CellSizeMeters);
			mBounds.Front = mWorldPos.z + (OrientedHeightInCells*GameModel.CellSizeMeters);

			return mBounds;
		}

		/** Cambia la posición en mundo pero haciendo primero un snap a celda */
		public function SetWorldPosSnapped(p : Point3) : void
		{
			WorldPos = GameModel.GetSnappedWorldPos(p);
		}

		/** Cambia la posición en mundo pero haciendo primero un snap a celda redondeando a la más cercana */
		public function SetWorldPosRounded(p : Point3) : void
		{
			WorldPos = GameModel.GetRoundedWorldPos(p);
		}


		private function UpdateVisualObjectPos() : void
		{
			// Es posible que no estemos todavía insertados en la escena.
			if (TheSceneObject != null)
			{
				var pos : Point = IsoCamera.IsoProject(mWorldPos);

				TheVisualObject.x = Math.floor(pos.x);
				TheVisualObject.y = Math.floor(pos.y);
			}
		}

		private function UpdateVisualObjectOrient() : void
		{
			// Es posible que no estemos todavía insertados en la escena, pero si tenemos SceneObject
			// el IsoComponent exige que exista su VisualObject, no puede ser un SceneObject vacio.
			if (TheSceneObject != null)
			{
				var orientString : Array = [ "se", "sw", "nw", "ne" ];

				TheVisualObject.gotoAndStop(orientString[mOrientation]);

				TheSceneObject.InvalidateBoundingRectangle();
			}
		}

		public function IsoComponent()
		{
			mBounds = new IsoBounds();
		}

		override public function AddToScene():void
		{
			mRender2DAdd = true;
			TheGameModel.TheIsoCamera.addChild(TheVisualObject);

			// Refrescamos el estado de pantalla.
			UpdateVisualObjectPos();
			UpdateVisualObjectOrient();
		}

		override public function RemoveFromScene():void
		{
			TheGameModel.TheIsoCamera.removeChild(TheVisualObject);
		}

		override public function OnAddedToAssetObject(assetObj : AssetObject) : void
		{
			if (assetObj != null)
			{
				var render2D : Render2DComponent = assetObj.FindGameComponentByShortName("Render2DComponent") as Render2DComponent;

				if (render2D != null)
					mWorldPos = render2D.RemoveFromAssetObjectNoIsoComponentAdd();

				super.OnAddedToAssetObject(assetObj);
			}
			else
			if (TheVisualObject != null && mRender2DAdd)
			{
				var curr2DCoords : Point = TheVisualObject.localToGlobal(Point3.ZERO_POINT2);

				// No llamamos a OnAddedToAssetObj(null) pq no nos hace falta quitar el TheVisualObject de la camara, puesto que lo hará
				// este Add (al añadirlo a otro flash lo quita del actual)
				render2D = TheAssetObject.AddGameComponent("GameComponents::Render2DComponent") as Render2DComponent;
				render2D.ScreenPos = TheGameModel.TheRender2DCamera.globalToLocal(curr2DCoords);
			}
		}


		public function RemoveFromAssetObjectNoRender2DAdd() : Point
		{
			mRender2DAdd = false;	// En la reentrada por OnAddedToAssetObject(null) no añadirá el Render2D

			var curr2DCoords : Point = Point3.ZERO_POINT2;

			if (TheVisualObject != null)
				curr2DCoords = TheVisualObject.localToGlobal(Point3.ZERO_POINT2);

			TheAssetObject.RemoveGameComponent("GameComponents::IsoComponent");

			if (TheVisualObject != null)
				curr2DCoords = TheGameModel.TheRender2DCamera.globalToLocal(curr2DCoords);

			return curr2DCoords;
		}


		/** Auxiliar para ayudar al Sorter */
		[NonSerializable]
		public function set SortingProcessed(val : Boolean) : void { mSortingProcessed = val; }
		public function get SortingProcessed() : Boolean { return mSortingProcessed; }

		private var mSortingProcessed : Boolean = false;
		private var mBounds : IsoBounds;
		private var mWorldPos : Point3 = new Point3(0, 0, 0);
		private var mOrientation : int = SOUTH_EAST;

		private var mRender2DAdd : Boolean = true;
	}
}