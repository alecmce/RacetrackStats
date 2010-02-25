package alecmce.utils 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;

	public class PixelFontTest extends Sprite 
	{
		private var instance:PixelFont;
		private var data:BitmapData;

		public function PixelFontTest()
		{
			instance = new PixelFont();
			data = new BitmapData(400,20,true, 0xFFFFEE66);
			
			instance.write("ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890", data, new Point());
			
			addChild(new Bitmap(data));
		}
	}
}
