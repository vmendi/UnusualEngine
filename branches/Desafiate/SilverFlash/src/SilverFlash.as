package {
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;

	[SWF (width="915", height="508", frameRate="30", backgroundColor="0x000000")]

	public class SilverFlash extends Sprite
	{
		[Embed(source='SilverLib.swf', symbol='btCerrar')] 		public var btCerrar:Class;
		[Embed(source='SilverLib.swf', symbol='grSilver')] 		public var grSilver:Class;

		private var gSilver : Sprite;
		private var bCerrar : SimpleButton;
		private var nScore : int = -1;
		private var bEnded : Boolean = false;

		/*public function SilverFlash()
		{
			Start();
		}*/
		public function Start() : void
		{
			gSilver = new grSilver();
			gSilver.x = 915/2;
			gSilver.y = 508/2;
			addChild(gSilver);

			bCerrar = new btCerrar();
			bCerrar.x = 820;
			bCerrar.y = 12;
			bCerrar.addEventListener(MouseEvent.CLICK, MakeClose);
			addChild(bCerrar);
		}
		public function Stop() : void
		{

		}
		public function GetbtNavegar() : SimpleButton
		{
			return gSilver["btNavegar"];
		}
		public function GetScore () : int
		{
			return nScore;
		}
		public function MakeClose (e:MouseEvent) : void
		{
			bEnded = true;
		}
		public function IsEnded () : Boolean
		{
			return bEnded;
		}
	}
}
