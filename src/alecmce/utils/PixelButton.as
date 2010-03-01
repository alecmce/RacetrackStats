package alecmce.utils 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * 
	 * @author Alec McEachran
	 * 
	 * (c) 2010 alecmce.com
	 * 
	 * Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
	 */
	public class PixelButton extends Sprite 
	{
		public static const LEFT:int = 0;		public static const RIGHT:int = WIDTH + 1;
		
		public static const WIDTH:uint = 8;
		public static const HEIGHT:uint = 8;
		
		[Embed(source="../../../img/pixelbuttons.gif")]
		private var embeddedClass:Class;		
		
		public function PixelButton(type:int)
		{
			useHandCursor = true;
			
			var asset:Bitmap = new embeddedClass();
			var data:BitmapData = new BitmapData(WIDTH,HEIGHT,false);
			data.copyPixels(asset.bitmapData, new Rectangle(type,0,WIDTH,HEIGHT), new Point(0, 0));
			asset.bitmapData.dispose();
			asset.bitmapData = data;
			addChild(asset);
		}
	}
}
