package Framework
{
	import flash.geom.Point;

	public class MathUtils
	{
		//
		// Comprueba si un punto(pos) está contenido dentro de un rectángulo
		//
		static public function PointInRect( pos:Point, topLeft:Point, size:Point ) : Boolean
		{
			if( pos.x < (topLeft.x) || pos.y < (topLeft.y) )
				return( false );
			if( pos.x > topLeft.x+size.x || pos.y > topLeft.y+size.y )
				return( false );
			
			return true;
		}
		
		//
		// Comprueba si un círculo(pos, radio) está contenido "completamenta" dentro de un rectángulo
		//
		static public function CircleInRect( pos:Point, radius:Number, topLeft:Point, size:Point ) : Boolean
		{
			if( pos.x < (topLeft.x+radius) || pos.y < (topLeft.y+radius) )
				return( false );
			if( pos.x > topLeft.x+size.x-radius || pos.y > topLeft.y+size.y-radius )
				return( false );
				
			return true;
		}
		
		
		//
		// Compara si dos valores flotantes son iguales con un un unmbral determinado 
		// NOTE: Necesario para no comparar nunca dos flotantes con ==
		//
		static public function ThresholdEqual(a : Number, b : Number, threshold : Number) : Boolean
		{
			return Math.abs(b-a) <= threshold;
		}
		
		//
		// Compara si dos valores decimales no son iguales con un un unmbral determinado 
		// NOTE: Necesario para no comparar nunca dos flotantes con !=
		//
		static public function ThresholdNotEqual(a : Number, b : Number, threshold : Number) : Boolean
		{
			return Math.abs(b-a) > threshold;
		}
		
		static public function Tanh(x : Number) : Number
		{
			return (Math.exp(2*x) - 1) / (Math.exp(2*x) + 1);
		}
	}
}
