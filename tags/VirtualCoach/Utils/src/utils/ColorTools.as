package utils
{
	/**
	/* http://mojocolors.googlecode.com/svn/trunk/
	 * http://mojocolors.googlecode.com/svn/trunk/mojocolors/src/ch/badmojo/color/ColorTool.as
	 * */
	public class ColorTools
	{
		public static function ConvertToHexFromRGB(red : Number, green : Number, blue : Number) : uint
		{
			return (red << 16 | green << 8 | blue);
		}

		public static function ConvertHSVToRGB(h : Number,s : Number, v : Number) : Array
		{
			s = s / 100;
			v = v / 100;

			var i : Number;
			var f : Number;
			var p : Number;
			var q : Number;
			var t : Number;
			var red : Number = 0;
			var green : Number = 0;
			var blue : Number = 0;

			if( s == 0 ) {
				// achromatic (grey)
				red = green = blue = v;
				return new Array(red, green, blue);
			}
			if(h > 360) {
				h = h - 360;
			}
			if(h < 0) {
				h = 360 + h;
			}
			h = h / 60;
			// sector 0 to 5
			i = Math.floor(h);
			f = h - i;
			// factorial part of h
			p = v * ( 1 - s );
			q = v * ( 1 - s * f );
			t = v * ( 1 - s * ( 1 - f ) );

			switch( i ) {
				case 0:
					red = v;
					green = t;
					blue = p;
					break;
				case 1:
					red = q;
					green = v;
					blue = p;
					break;
				case 2:
					red = p;
					green = v;
					blue = t;
					break;
				case 3:
					red = p;
					green = q;
					blue = v;
					break;
				case 4:
					red = t;
					green = p;
					blue = v;
					break;
				default:
					// case 5:
					red = v;
					green = p;
					blue = q;
					break;
			}
			return new Array(red, green, blue);
		}
	}
}