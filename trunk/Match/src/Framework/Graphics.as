package Framework
{
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	
	import flash.display.MovieClip;

	
	public class Graphics
	{
		//----------------------------------------------------------------
		// Efectos
		
		//
		// Cambia la transformación de color del elemento
		//
		static public function ChangeColor( element: *, color: uint ): void
		{
			var colorTransform : ColorTransform = element.transform.colorTransform;
			colorTransform.color = color;
			element.transform.colorTransform = colorTransform;
		}

		//
		// Cambia el multiplicador de color de cada componente
		// 
		static public function ChangeColorMultiplier( element: *, r:Number, g:Number, b:Number ): void
		{
			var colorTransform : ColorTransform = element.transform.colorTransform;
			colorTransform.redMultiplier = r;
			colorTransform.greenMultiplier = g;
			colorTransform.blueMultiplier = b;
			element.transform.colorTransform = colorTransform;
		}
		
		//
		// Asigna una filtro de glow
		// TODO: Actualmente asigna una lista con el filtro : Esto implica que se destruyen los filtros que existan
		//
		static public function SetGlow( display: *, addFilter: Boolean, blurDistance: Number = 10, color: Number = 0xFFFFFF ) : void
		{
			var myFilters: Array = new Array( );
			
			var alpha	 : Number = .7;
			
			var blurX	 : Number = blurDistance;
			var blurY    : Number = blurDistance; 
			var strength :Number  = 2;
			var inner    :Boolean = false;
			var knockout :Boolean = false;
			var quality  :Number  = BitmapFilterQuality.HIGH;
			
			var filter	 : BitmapFilter = new GlowFilter( color,
				alpha,
				blurX,
				blurY,
				strength,
				quality,
				inner,
				knockout );
			
			// En el caso de que se quiera a�adir el filtro al array de filtros del objeto
			if ( addFilter ) myFilters = display.filters;
			
			myFilters.push( filter );
			
			display.filters = myFilters;		
		}

		//
		// Asigna una filtro de sombra
		// TODO: Actualmente asigna una lista con el filtro : Esto implica que se destruyen los filtros que existan
		//
		static public function SetShadow( display: * , distance: Number = 0, angle: int = 0, blur: uint = 12 ) : void
		{
			var color	: Number = 0x000000;
			var alpha	: Number = .7;
			
			var blurX	: Number = blur;
			var blurY   : Number = blur; 
			
			var filter	 : BitmapFilter = new DropShadowFilter( distance, angle, color, alpha, blurX, blurY );
			
			var myFilters: Array 		= new Array();
			myFilters.push( filter );
			
			display.filters = myFilters;			
		}
		
		// Efectos
		//----------------------------------------------------------------
		
		//----------------------------------------------------------------
		// Etiquetas
		
		/**
		 Numero de fotogramas que hay entre dos etiquetas
		 */
		public static function GetNumberOfFramesBetween(label1 : String, label2 : String, mc : MovieClip) : int
		{
			return GetFrameOfLabel(label2, mc) - GetFrameOfLabel(label1, mc);
		}
		
		//
		// Comprueba si existe una etiqueta en el movieclip
		//
		public static function HasLabel( label : String, mc : MovieClip ) : Boolean
		{
			var labels : Array = mc.currentLabels;
			
			for (var c: int = 0; c < labels.length; c++)
			{
				if (labels[c].name == label)
					return( true );
			}

			return( false );
		}
		
		
		
		/**
		 Numero de fotograma en el que está una etiqueta, basado en 1
		 */
		public static function GetFrameOfLabel(lab : String, mc : MovieClip) : int
		{
			var labels : Array = mc.currentLabels;
			var ret : int = -1;
			
			for (var c: int = 0; c < labels.length; c++)
			{
				if (labels[c].name == lab)
				{
					ret = labels[c].frame;
					break;
				}
			}
			
			if (ret == -1)
				throw  new Error( "Etiqueta no encontrada " + lab );
			
			return ret;
		}
		
		/**
		 *  Para subscribir las funciones a los labels de un movieclip: { label: XXXXX, func: XXXX}
		 */
		public static function AddFrameScripts(labelAndFuncs : Array, targetMC : MovieClip):void
		{
			for (var c:int = 0; c < labelAndFuncs.length; c++)
			{
				var frame : int = GetFrameOfLabel(labelAndFuncs[c].label, targetMC);
				targetMC.addFrameScript(frame-1, labelAndFuncs[c].func);
			}
		}
		
		public static function RemoveFrameScripts(labelAndFuncs : Array, targetMC : MovieClip):void
		{
			for (var c:int = 0; c < labelAndFuncs.length; c++)
			{
				var frame : int = GetFrameOfLabel(labelAndFuncs[c].label, targetMC);
				targetMC.addFrameScript(frame-1, null);
			}
		}
		
		// Etiquetas
		//----------------------------------------------------------------
		
	}
}