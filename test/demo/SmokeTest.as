package demo 
{
	import flash.display.Sprite;

	public class SmokeTest extends Sprite 
	{
		private var smoke:Smoke;
		
		public function SmokeTest()
		{
			smoke = new Smoke(200,400);
			addChild(smoke);
			
			smoke.start();
		}
	}
}
