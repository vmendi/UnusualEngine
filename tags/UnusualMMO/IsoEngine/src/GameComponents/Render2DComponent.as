package GameComponents
{
	import Model.AssetObject;
	import Model.GameModel;

	import flash.events.Event;
	import flash.geom.Point;

	import utils.Point3;

	public final class Render2DComponent extends GameComponent
	{
		public var ZOrder : int = 0;
		public var HideOnStart : Boolean = false;

		override public function OnStart():void
		{
			if (HideOnStart)
				TheVisualObject.visible = false;
		}

		override public function AddToScene():void
		{
			ScreenPos = mNotYetInScenePos;

			mIsoComponentAdd = true;
			TheGameModel.TheRender2DCamera.addChild(TheVisualObject);
		}
		
		override public function RemoveFromScene():void
		{
			TheGameModel.TheRender2DCamera.removeChild(TheVisualObject);
		}

		override public function OnAddedToAssetObject(assetObj : AssetObject) : void
		{			
			if (assetObj != null)
			{
				var isoComp : IsoComponent = assetObj.FindGameComponentByShortName("IsoComponent") as IsoComponent;
	
				if (isoComp != null)
					mNotYetInScenePos = isoComp.RemoveFromAssetObjectNoRender2DAdd();
					
				super.OnAddedToAssetObject(assetObj);
			}
			else
			// Es posible que nuestro antiguo (puesto que assetObj == null) AssetObj sea de libreria o que estemos reentrando
			if (TheSceneObject != null && mIsoComponentAdd)
			{
				var curr2DCoords : Point = TheVisualObject.localToGlobal(Point3.ZERO_POINT2);
					
				isoComp = TheAssetObject.AddGameComponent("GameComponents::IsoComponent") as IsoComponent;
				curr2DCoords = TheGameModel.TheRenderCanvas.globalToLocal(curr2DCoords);
				isoComp.SetWorldPosRounded((TheGameModel.TheIsoCamera.IsoScreenToWorld(curr2DCoords)));	
			}
		}


		public function RemoveFromAssetObjectNoIsoComponentAdd() : Point3
		{
			mIsoComponentAdd = false;	// En la reentrada por OnAddedToAssetObject(null) no añadirá el IsoComp

			var curr2DCoords : Point = Point3.ZERO_POINT2;

			if (TheVisualObject != null)
				curr2DCoords = TheVisualObject.localToGlobal(Point3.ZERO_POINT2);

			TheAssetObject.RemoveGameComponent("GameComponents::Render2DComponent");

			var ret : Point3 = Point3.ZERO_POINT3;

			if (TheVisualObject != null)
			{
				curr2DCoords = TheGameModel.TheRenderCanvas.globalToLocal(curr2DCoords);
				ret = GameModel.GetRoundedWorldPos(TheGameModel.TheIsoCamera.IsoScreenToWorld(curr2DCoords));
			}

			return ret;
		}


		[Bindable(event="ScreenPosChanged")]
		public function get ScreenPos() : Point
		{
			if (TheVisualObject != null)
				return new Point(TheVisualObject.x, TheVisualObject.y);

			return mNotYetInScenePos;
		}

		public function set ScreenPos(pos : Point):void
		{
			// Cuando no estamos en pantalla, no tenemos VisualObject
			if (TheVisualObject != null)
			{
				TheVisualObject.x = pos.x;
				TheVisualObject.y = pos.y;
			}
			else
			{
				// Cuando no estamos en la scena todavía, almacenamos la posicion para luego
				mNotYetInScenePos = pos;
			}

			dispatchEvent(new Event("ScreenPosChanged"));
		}

		// Al no ser serializable, nunca se llamará aquí sin estar en la escena (y no será el motor, sino un tweener por ejemplo)
		public function get ScreenPosX() : Number {	return TheVisualObject.x;	}
		public function set ScreenPosX(x : Number) : void {	TheVisualObject.x = x;	}
		public function IsScreenPosXSerializable() : Boolean { return false; }

		public function get ScreenPosY() : Number {	return TheVisualObject.y;	}
		public function set ScreenPosY(y : Number) : void {	TheVisualObject.y = y;	}
		public function IsScreenPosYSerializable() : Boolean { return false; }


		private var mNotYetInScenePos : Point = new Point(0,0);
		private var mIsoComponentAdd : Boolean = true;
	}
}