package alecmce.utils 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;

	public class PixelFontTest extends Sprite 
	{
		private var instance:PixelWriter;
		private var data:BitmapData;

		public function PixelFontTest()
		{
			instance = new PixelWriter();
			data = new BitmapData(400,20,true, 0xFFFFEE66);
			
			instance.write("ABCDEFGHIJKLMNOPQRSTUVWXYZ\r1234567890", data, new Point());
			
			var bmp:Bitmap = new Bitmap(data);
			bmp.scaleX = bmp.scaleY = 4;
			
			addChild(bmp);
			
		}
	}
}
