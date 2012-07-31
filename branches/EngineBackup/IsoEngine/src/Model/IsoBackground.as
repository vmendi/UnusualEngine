package Model
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	
	import utils.Point3;


	/**
	 * El fondo del juego. Sabe cargar y renderizar la imagen desde un SWF y lleva la caminabilidad de las celda "de fondo".
	 *
	 * El 0,0 del SWF se pondrá en el 0,0 del mundo de juego (justo el centro de la pantalla al arrancar el editor)
	 */
	public class IsoBackground extends UIComponent
	{
		public function get NonWalkable() : Array { return mNonWalkable; }

		public function IsoBackground(isoEngine:IsoEngine)
		{
			mIsoEngine = isoEngine;
			mNonWalkable = new Array();
			mLightedCells = new Array();
		}

		public function SetCameraCenter(camCenter : Point) : void
		{
			if (mIsoGrid)
				mIsoGrid.SetCameraCenter(camCenter);
		}

		public function SelectSWF(swf : String) : void
		{
			mSWFName = swf;

			LoadImmediateSWF();
		}

		public function LoadFromXML(xml : XML) : void
		{
			InnerLoadFromXML(xml);

			mSWFName = xml.child("SWFName").toString();

			LoadQueuedSWF();
		}

		private function InnerLoadFromXML(xml : XML):void
		{
			mNonWalkable = new Array();

			for each(var cellXML : XML in xml.child("Cell"))
			{
				CreateNonWalkable(new Point3(cellXML.attribute("x").toString(), 0,
												 cellXML.attribute("y").toString()));
			}

			GridRenderingEnabled = (xml.child("GridRenderingEnabled") == "true")? true : false;
			WalkableRenderingEnabled = (xml.child("WalkableRenderingEnabled") == "true")? true : false;
		}

		public function GetBounds() : IsoBounds
		{
			var ret : IsoBounds = new IsoBounds();

			if (mNonWalkable.length != 0)
			{
				ret.Left = int.MAX_VALUE;
				ret.Right = int.MIN_VALUE;
				ret.Back = int.MAX_VALUE;
				ret.Front = int.MIN_VALUE;
			}

			for each(var cell : Object in mNonWalkable)
            {
                if (cell.ThePoint.x < ret.Left)
                    ret.Left = cell.ThePoint.x;
                if ((cell.ThePoint.x + GameModel.CellSizeMeters) > ret.Right)
                    ret.Right = cell.ThePoint.x + GameModel.CellSizeMeters;
                if (cell.ThePoint.y < ret.Back)
                    ret.Back = cell.ThePoint.y;
                if ((cell.ThePoint.y + GameModel.CellSizeMeters) > ret.Front)
                    ret.Front = cell.ThePoint.y + GameModel.CellSizeMeters;
            }

			return ret;
		}

		private function LoadQueuedSWF() : void
		{
			DestroyContent();

			if (mSWFName == "")
				return;

			// La cola ya debe venir creada
			mIsoEngine.TheCentralLoader.AddToQueue(mSWFName, true, "SWF", OnSWFLoadComplete);
		}

		private function OnSWFLoadComplete(loader:Loader):void
		{
			mContent = loader.content as DisplayObject;
			addChild(mContent);
			setChildIndex(mContent, 0);
		}

		private function LoadImmediateSWF() : void
		{
			DestroyContent();

			if (mSWFName == "")
				return;

			mIsoEngine.TheCentralLoader.Load(mSWFName, true, swfLoaded);

			function swfLoaded(loader:Loader):void
			{
				mContent = loader.content;
				addChild(mContent);
				setChildIndex(mContent, 0);
			}
		}

		public function GetContentBounds() : Rectangle
		{
			if (mContent != null)
				return mContent.getBounds(mContent);

			return this.getBounds(this);
		}

		public function GetXML() : XML
		{
			var ret : XML = <IsoBackground>
								<SWFName>{mSWFName}</SWFName>
								<WalkableRenderingEnabled>{mWalkableRenderingEnabled}</WalkableRenderingEnabled>
								<GridRenderingEnabled>{mGridRenderingEnabled}</GridRenderingEnabled>
						    </IsoBackground>

			for each(var cell : Object in mNonWalkable)
			{
				var cellXML : XML = <Cell x={cell.ThePoint.x} y={cell.ThePoint.y}/>
				ret.appendChild(cellXML);
			}

			return ret;
		}

		public function ToggleCell(snappedWorldPos : Point3) : void
		{
			var wasDisabled : Boolean = EnableIfDisabled(snappedWorldPos);

			if (!wasDisabled)
				CreateNonWalkable(snappedWorldPos);
		}

		private function CreateNonWalkable(snappedWorldPos : Point3) : void
		{
			var cell : Object = {ThePoint:new Point(snappedWorldPos.x, snappedWorldPos.z), TheMovieClip:null };

			if (mWalkableRenderingEnabled)
			{
				cell.TheMovieClip = CreateCellMovieClip(snappedWorldPos);
				addChild(cell.TheMovieClip);
			}

			mNonWalkable.push(cell);
		}

		private function CreateCellMovieClip(snappedWorldPos : Point3, color : int = 0xFF0000) : MovieClip
		{
			var movieClip : MovieClip = new MovieClip();

			var p1 : Point = IsoCamera.IsoProject(new Point3(GameModel.CellSizeMeters, 0, 0));
			var p2 : Point = IsoCamera.IsoProject(new Point3(GameModel.CellSizeMeters, 0, GameModel.CellSizeMeters));
			var p3 : Point = IsoCamera.IsoProject(new Point3(0, 0, GameModel.CellSizeMeters));

			movieClip.graphics.lineStyle(1, color, 1.0);
			movieClip.graphics.beginFill(color, 0.3);
			movieClip.graphics.moveTo(0, 0);
			movieClip.graphics.lineTo(p1.x, p1.y);
			movieClip.graphics.lineTo(p2.x, p2.y);
			movieClip.graphics.lineTo(p3.x, p3.y);
			movieClip.graphics.lineTo(0, 0);
			movieClip.graphics.endFill();
			movieClip.cacheAsBitmap = true;

			var mcPos : Point = IsoCamera.IsoProject(snappedWorldPos);
			movieClip.x = mcPos.x;
			movieClip.y = mcPos.y;

			return movieClip;
		}

		private function EnableIfDisabled(snappedWorldPos : Point3):Boolean
		{
			var ret : Boolean = false;

			for (var c : int = 0; c < mNonWalkable.length; c++)
			{
				if (mNonWalkable[c].ThePoint.x == snappedWorldPos.x &&
					mNonWalkable[c].ThePoint.y == snappedWorldPos.z)
					{
						ret = true;
						removeChild(mNonWalkable[c].TheMovieClip);
						mNonWalkable.splice(c, 1);
						break;
					}
			}
			return ret;
		}

		private function IsDisabled(snappedWorldPos : Point3) : Boolean
		{
			for (var c : int = 0; c < mNonWalkable.length; c++)
			{
				if (mNonWalkable[c].x == snappedWorldPos.x &&
					mNonWalkable[c].z == snappedWorldPos.z)
					return true;
			}
			return false;
		}

		public function ToggleGridRendering() : Boolean
		{
			GridRenderingEnabled = !mGridRenderingEnabled;

			return mGridRenderingEnabled;
		}

		public function ToggleWalkableRendering() : Boolean
		{
			WalkableRenderingEnabled = !mWalkableRenderingEnabled;

			return mWalkableRenderingEnabled;
		}

		public function set GridRenderingEnabled(enabled : Boolean):void
		{
			if (mGridRenderingEnabled == enabled)
				return;

			mGridRenderingEnabled = enabled;

			if (mGridRenderingEnabled)
			{
				if (mIsoGrid == null)
				{
					mIsoGrid = new IsoGrid();
					mIsoGrid.Generate(20/GameModel.CellSizeMeters, 20/GameModel.CellSizeMeters, GameModel.CellSizeMeters);
				}

				addChild(mIsoGrid);
				
				if (mContent != null)
					setChildIndex(mIsoGrid, 1);
				else
					setChildIndex(mIsoGrid, 0);
			}
			else
			{
				removeChild(mIsoGrid);
			}
		}

		public function get GridRenderingEnabled() : Boolean { return mGridRenderingEnabled; }

		public function set WalkableRenderingEnabled(enabled : Boolean):void
		{
			if (mWalkableRenderingEnabled == enabled)
				return;

			mWalkableRenderingEnabled = enabled;

			if (mWalkableRenderingEnabled)
			{
				for each(var cell : Object in mNonWalkable)
				{
					if (cell.TheMovieClip == null)
						cell.TheMovieClip = CreateCellMovieClip(new Point3(cell.ThePoint.x, 0,
																		   cell.ThePoint.y));
					addChild(cell.TheMovieClip);
				}
			}
			else
			{
				for each(cell in mNonWalkable)
					removeChild(cell.TheMovieClip);
			}
		}

		public function get WalkableRenderingEnabled() : Boolean { return mWalkableRenderingEnabled; }

		public function EnableGridAndWalkableRendering() : void
		{
			WalkableRenderingEnabled = true;
			GridRenderingEnabled = true;
		}


		public function DeleteBackground():void
		{
			DestroyContent();
			mSWFName = "";
		}

		private function DestroyContent():void
		{
			if (mContent != null)
			{
				removeChild(mContent);
				mContent = null;
			}
		}

		/** Interface para la ayuda al debug, ortogonal con el resto */
		public function LightCell(snappedWorldPos : Point3, color : int) : void
		{
			var cell : Object = {ThePoint:new Point(snappedWorldPos.x, snappedWorldPos.z) };

			cell.TheMovieClip = CreateCellMovieClip(snappedWorldPos, color);
			cell.TheColor = color;
			addChild(cell.TheMovieClip);

			mLightedCells.push(cell);
		}

		public function UnlitAll() : void
		{
			for each(var cell : Object in mLightedCells)
				removeChild(cell.TheMovieClip);
			mLightedCells = new Array();
		}

		public function UnlitAllOfColor(color : int) : void
		{
			for (var c:int=0; c < mLightedCells.length; c++)
			{
				var cell : Object = mLightedCells[c];
				if (cell.TheColor == color)
				{
					removeChild(cell.TheMovieClip);
					mLightedCells.splice(c, 1);
					c--;
				}
			}
		}

		private var mLightedCells : Array;

		private var mNonWalkable : Array;
		private var mSWFName : String = "";
		private var mContent : DisplayObject;

		private var mGridRenderingEnabled : Boolean = false;
		private var mWalkableRenderingEnabled : Boolean = false;
		private var mIsoGrid : IsoGrid;
		private var mIsoEngine : IsoEngine;
	}
}