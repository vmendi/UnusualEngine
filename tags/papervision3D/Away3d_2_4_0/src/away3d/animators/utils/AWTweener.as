﻿package away3d.animators.utils
{

	public class AWTweener {
		/**
		 * AWTweener, a simplified tweening system to allow native tweens. Supports linear, ease in or ease out. Sophisticated tweens can be done using third party tweeners.
		 *
		 */
		function AWTweener(){}
		 
		private static function tweenVal( t:Number, b:Number, endvalue:Number, d:Number, easeIn:Boolean, easeOut:Boolean):Number {
			var c:Number = endvalue - b;
			var pwease:Boolean;
			if (!easeOut) {
				pwease = easeIn;
			} else if (easeIn) {
				pwease = easeOut;
				t = d - t;
				b = b + c;
				c = -c;
			} else {
				if (t < d * .5) {
					pwease = true;
				} else {
					pwease = true;
					t = d - t;
					b = b + c;
					c = -c;
				}
				c *= .5;
				d *= .5;
			}
			var diff:Number;
			if (pwease)
				diff = Math.pow(t / d, 2);
			else
				diff = t / d;
				
			return b + c * diff;
		}
		
		/**
		 * precalculates the numerical tween, returns steps as array
		 * 
		 * @param	 	fps						Number. Frame rate per second. Default = 30.
		 * @param	 	startval					Number. Start value. Default = 0.
		 * @param	 	endval					Number. End value. Default = 1.
		 * @param	 	duration					Number. Duration in millisec. Default = 250.
		 * @param	 	easeIn					Boolean. If the values are tweened with an ease in. Default = false.
		 * @param	 	easeOut					Boolean. If the values are tweened with an ease out. Default = false.
		 * 
		 * @return Array	Returns an array contatining the tweened values
		 */
		 
		public static function calculate( fps:Number = 30, startval:Number = 0, endval:Number = 1, duration:Number = 250, easeIn:Boolean = false, easeOut:Boolean = false):Array
		{
			var aTween:Array = [];
			var elapT:Number = fps;

			while (elapT < duration) {
				aTween.push(AWTweener.tweenVal( elapT, startval, endval, duration, easeIn, easeOut));
				elapT += fps;
			}
			
			aTween.push(endval);
			
			return aTween;
		}
		
	}
}