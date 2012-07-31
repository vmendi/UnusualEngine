package utils
{
	public final class MovieClipListener
	{
		import flash.display.*;
		import flash.system.*;
		import flash.utils.*;
		import flash.text.*;
		import flash.events.*;
	
	
		static public function AddFrameScript(mc:MovieClip, labelName:String, func : Function) : void
		{
			for (var i:int=0;i < mc.currentLabels.length;i++)
			{
				if (mc.currentLabels[i].name==labelName)
				{
					mc.addFrameScript(mc.currentLabels[i].frame-1, func);
				}
			}
		}
		
		public function MovieClipListener(target : MovieClip):void
		{
			mTarget = target;
		}
		
		public function listenToAnimEnd(callback : Function, once : Boolean, numLoops : int = 1) : void
		{
			if (numLoops <= 0)
				throw "Incorrect number of loops, the minimun is 1";
				
			mTarget.addEventListener(Event.ENTER_FRAME, OnEnterFrame);
		
			mLabel = null;
			mCallback = callback;
			mOnce = once;
			mNumLoops = numLoops;
			mCurrLoops = 0;
		}
		
		public function listenToLabel(label:String, callback:Function, once:Boolean, numLoops:int = 1) : void
		{
			if (numLoops <= 0)
				throw "Incorrect number of loops, the minimun is 1";

			mTarget.addEventListener(Event.ENTER_FRAME, OnEnterFrame);
			
			mLabel = label;
			mCallback = callback;
			mOnce = once;
			mNumLoops = numLoops;
			mCurrLoops = 0;
		}
		
		private function OnEnterFrame(event : Event) : void
		{
			if (mLabel != null)
			{
				if (mTarget.currentLabel == mLabel)
					Trigger();
			}
			else			
			if (mTarget.currentFrame == mTarget.totalFrames)
			{
				Trigger();	
			}
		}
		
		private function Trigger():void
		{
			mCurrLoops++;
			
			if (mOnce)
			{
				if (mCurrLoops == mNumLoops)
				{
					mTarget.removeEventListener(Event.ENTER_FRAME, OnEnterFrame);
					mCallback();
				}
			}
			else
			{
				if (mCurrLoops == mNumLoops)
				{
					mCallback();
					mCurrLoops = 0;
				}
			}
		}
		
		private var mCallback : Function = null;
		private var mOnce : Boolean = true;
		private var mLabel : String = null;
		private var mNumLoops : int = 0;
		
		private var mListening : Object = new Object;
		private var mTarget : MovieClip;
		private var mCurrLoops : int = 0;
	}

}