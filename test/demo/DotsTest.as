package demo 
{
	import flash.display.Sprite;

	public class DotsTest extends Sprite 
	{
		private var dots:TrippyDots;
		
		public function DotsTest()
		{
			dots = new TrippyDots(200,400);
			addChild(dots);
			
			dots.start();
		}
	}
}
