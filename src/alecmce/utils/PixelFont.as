package alecmce.utils 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Writes text to BitmapData using copy-pixels from a pixel-font gif. The
	 * text is Silkscreen font, embedded into the class.
	 * 
	 * To use, point the PixelFont at a bitmapdata object as follows:
	 * 
	 * @see http://www.kottke.org/plus/type/silkscreen/
	 */
	public class PixelFont 
	{
		private const START:Array = [0,5,10,15,20, 24,28,33,38,40, 45,50,54,60,66, 71,76,81,86,91, 95,100,106,112,118, 124,128,133,137,142, 147,152,157,162,167, 172];
		private const LENGTH:Array = [4,4,4,4,3, 3,4,4,1,4, 4,3,5,5,4, 4,4,4,5,3, 4,5,5,5,5, 3,4,3,4,4, 4,4,4,4,4, 4];

		[Embed(source="../../../img/pixelfont.gif")]
		private var embeddedClass:Class;		
		
		private var source:BitmapData;
		
		private var rect:Rectangle;

		public function PixelFont() 
		{
			var asset:Bitmap = new embeddedClass();
			source = asset.bitmapData;
			rect = new Rectangle(0,0,4,5);
		}
		
		public function write(text:String, to:BitmapData, start:Point):void
		{
			var working:Point = start.clone();
			
			var length:int = text.length;
			for (var i:int = 0; i < length; i++)
			{
				var index:int = text.charCodeAt(i);
				if (index > 64 && index < 91)
					index -= 65;
				else if (index > 47 && index < 58)
					index -= 22;
				else
				{
					if (index == 10 || index == 13)
					{
						working.x = start.x;
						working.y += 7;
					}
					
					continue;
				}
				
				var width:int = LENGTH[index];
				rect.x = START[index];
				rect.width = width;
				
				to.copyPixels(source, rect, working, null, null, true);
				working.offset(width + 2, 0);
			}
		}
		
	}
}
