package GameComponents.PlanetWars
{
	import GameComponents.GameComponent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public final class Terrain extends GameComponent
	{
		override public function OnStart():void
		{
		}

		public function InitFromServer(terrainFromServer : Object): void
		{
			mContinentLength = terrainFromServer.ContinentLength;
			mOrder = CreateOrder(terrainFromServer.Order);

			for (var c:int=0; c < terrainFromServer.Continents.length; c++)
			{
				CreateContinent(terrainFromServer.Continents[c].data);
			}
		}

		public function ServerMergeContinent(continentFromServer : Object) : void
		{
			CreateContinent(continentFromServer);
		}

		private function CreateOrder(orderFromServer : Array) : Array
		{
			var ret : Array = new Array;
			for (var c:int=0; c < orderFromServer.length; c++)
				ret.push(new Point(orderFromServer[c].data.X, orderFromServer[c].data.Y));
			return ret;
		}

		private function CreateContinent(continent : Object):void
		{
			var newContinentBitmap : Bitmap = CreateContinentBitmap(continent);

			TheVisualObject.addChild(newContinentBitmap);

			var continentID : int = continent.ContinentID;

			var x : int = mOrder[continentID].x;
			var y : int = mOrder[continentID].y;
			var w : int = newContinentBitmap.width;
			var h : int = newContinentBitmap.height;

			var rect : Rectangle = newContinentBitmap.getBounds(newContinentBitmap);

			newContinentBitmap.x =  (x + y - 1)*w*0.5;
			newContinentBitmap.y = (-x + y - 2)*h*0.5;

			mContinentBitmaps.push(newContinentBitmap);
		}

		private function CreateContinentBitmap(continent : Object): Bitmap
		{
			var continentCells : Array = continent.Cells;
			var terrainDef : Array = new Array(mContinentLength);

			for (var c:int=0; c < mContinentLength; c++)
			{
				terrainDef[c] = new Array(mContinentLength);

				for (var d:int=0; d < mContinentLength; d++)
				{
					terrainDef[c][d] = continentCells[c*mContinentLength+d] as String;
				}
			}

			var terrainMC : MovieClip = new MovieClip();

			for (c=0; c < mContinentLength-1; c++)
			{
				for (d=0; d < mContinentLength-1; d++)
				{
					var terrainType : String = terrainDef[c+1][d] + terrainDef[c+1][d+1] +
											   terrainDef[c][d+1] + terrainDef[c][d];
					var terrainTile : MovieClip = TheGameModel.TheAssetLibrary.CreateMovieClip(terrainType);

					var terrainX : int = (d*((terrainTile.width*0.5)+1.0)) + (c*((terrainTile.width*0.5)+1.0));
					var terrainY : int = -(d*terrainTile.height*0.5) + (c*terrainTile.height*0.5);

					terrainMC.addChild(terrainTile);
					terrainTile.x = terrainX;
					terrainTile.y = terrainY;
				}
			}

			var rect : Rectangle = terrainMC.getBounds(terrainMC);
			var bmapData:BitmapData = new BitmapData(terrainMC.width, terrainMC.height, true, 0x00FF00FF);
			bmapData.draw(terrainMC, new Matrix(1, 0, 0, 1, -rect.left, -rect.top));

			var finalBitmap : Bitmap = new Bitmap(bmapData);
			return finalBitmap;
		}

		private var mContinentLength : int = -1;
		private var mContinentBitmaps : Array = new Array();
		private var mOrder : Array;
	}
}