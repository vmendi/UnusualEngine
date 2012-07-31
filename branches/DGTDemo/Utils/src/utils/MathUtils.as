package utils
{
	public class MathUtils
	{
		//
		// Comparación con margen de error, fundamental para no comparar nunca dos flotantes con ==
		//
		static public function ThresholdEqual(a : Number, b : Number, threshold : Number) : Boolean
		{
			return Math.abs(b-a) <= threshold;
		}

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