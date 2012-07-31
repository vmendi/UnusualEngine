package utils
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	//
	// Singleton para manejo por polling del teclado
	//
	public final class KeyboardHandler
	{
		//  Constructor privatizado con el truco del parámetro imposible
		public function KeyboardHandler(doNotCallHere:PrivateKeyboardSingleton)
		{
		}
		
		public static function Init(stage : Stage) : void
		{
			if (mInstance == null)
			{
				mInstance = new KeyboardHandler(new PrivateKeyboardSingleton());			
				mInstance.SetStage(stage);
			}
			
			mInstance.SubscribeListeners();
		}
		
		public static function ShutDown() : void
		{
			mInstance.RemoveListeners();
			mInstance = null;
		}
		
		private function RemoveListeners() : void
		{
			mStage.removeEventListener(KeyboardEvent.KEY_DOWN, mInstance.OnKeyDown);
			mStage.removeEventListener(KeyboardEvent.KEY_UP, mInstance.OnKeyUp);
			
			mStage.removeEventListener(Event.ENTER_FRAME, mInstance.OnEnterFrame);
		}
		
		private function SubscribeListeners():void
		{
			mStage.addEventListener(KeyboardEvent.KEY_DOWN, mInstance.OnKeyDown);
			mStage.addEventListener(KeyboardEvent.KEY_UP, mInstance.OnKeyUp);
			
			// Queremos asegurarnos de que la proxma vez al menos nos llaman los últimos.
			// Es decir, dentro del frame, queremos que todos los listeners se procesen antes
			// que nosotros para que puedan leer las teclas en Once. Nosotros somos los ultimos
			// y reseteamos el estado
			mStage.addEventListener(Event.ENTER_FRAME, mInstance.OnEnterFrame, false, int.MIN_VALUE);
		}
		
		public static function get Keyb() : KeyboardHandler
		{
			if (mInstance == null)
				throw "Debes llamar primero a Init";
			
			return mInstance;
		}
		
		public function IsControlDown() : Boolean
		{ 
			return mIsControlDown;
		}
		
		//
		// Para obtener los KeyCodes existe flash.ui.Keyboard
		//		
		public function IsKeyPressed(keyCode : uint, ctrl:Boolean=false) : Boolean
		{
			var str : String = keyCode.toString();

			if (ctrl && !mIsControlDown)
				return false;
			else if (!ctrl && mIsControlDown)
				return false;

			return mKeys.hasOwnProperty(str)? (mKeys[str] as Boolean) : false; 
		}
		
		public function IsKeyPressedRepeatWithOS(keyCode : uint, ctrl:Boolean=false) : Boolean
		{
			var str : String = keyCode.toString();
			
			if (ctrl && !mIsControlDown)
				return false;
			else if (!ctrl && mIsControlDown)
				return false;

			return mKeysOnce.hasOwnProperty(str)? (mKeysOnce[str] as Boolean) : false;
		}
		
		protected function OnKeyDown(event:KeyboardEvent) : void
		{
			mIsControlDown = event.ctrlKey;
			
			mKeys[event.keyCode.toString()] = true;
			mKeysOnce[event.keyCode.toString()] = true;
		}

		protected function OnKeyUp(event:KeyboardEvent) : void
		{
			mIsControlDown = event.ctrlKey;

			mKeys[event.keyCode.toString()] = false;
			mKeysOnce[event.keyCode.toString()] = false;
		}
		
		protected function OnEnterFrame(event:Event):void
		{
			mKeysOnce = new Object();
		}
				
		private function SetStage(st : Stage):void { mStage = st; }
		
		
		// Para futura expansion
		private function numToChar(num:int):String 
		{
	        if (num > 47 && num < 58) {
	            var strNums:String = "0123456789";
	            return strNums.charAt(num - 48);
	        } else if (num > 64 && num < 91) {
	            var strCaps:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	            return strCaps.charAt(num - 65);
	        } else if (num > 96 && num < 123) {
	            var strLow:String = "abcdefghijklmnopqrstuvwxyz";
	            return strLow.charAt(num - 97);
	        } else {
	            return num.toString();
	        }
	    }

		private static var mInstance : KeyboardHandler = null;
		private var mKeys : Object = new Object();
		private var mKeysOnce : Object = new Object();
		private var mStage : Stage = null;
		private var mIsControlDown : Boolean = false;
	}
}

class PrivateKeyboardSingleton
{
	public function PrivateKeyboardSingleton()
	{		
	}
}

