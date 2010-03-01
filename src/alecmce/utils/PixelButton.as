package alecmce.utils 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class PixelButton extends Sprite 
	{
		public static const PLUS:int = 0;
		public static const MINUS:int = 6;		public static const LEFT:int = 11;		public static const RIGHT:int = 17;
		
		[Embed(source="../../../img/pixelbutton.gif")]
		private var embeddedClass:Class;		
		
		public function PixelButton(type:int)
		{
			useHandCursor = true;
			
			var asset:Bitmap = new embeddedClass();
			var data:BitmapData = new BitmapData(5,5,false);
			data.copyPixels(asset.bitmapData, new Rectangle(type,0,5,5), new Point(0, 0));
			asset.bitmapData.dispose();
			asset.bitmapData = data;
			addChild(asset);
		}
	}
}
