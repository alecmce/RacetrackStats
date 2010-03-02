package demo 
{
	import flash.display.Sprite;

	public class PrimeFactorsTest extends Sprite 
	{
		private var factors:PrimeFactors;
		
		public function PrimeFactorsTest()
		{
			factors = new PrimeFactors(200,400);
			addChild(factors);
			
			factors.start();
		}
	}
}
