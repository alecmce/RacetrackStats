package alecmce.stats.ui.iterativegraph 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	/**
	 * A base-class that contains functionality common to the other iterative
	 * graphs in this namespace
	 * 
	 * @author Alec McEachran
	 * 
	 * (c) 2010 alecmce.com
	 * 
	 * Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
	 */
	internal class AbstractIterativeGraph 
	{
		
		protected const OVER_ESTIMATE:Number = 1.2;

		protected var _bitmap:Bitmap;
		protected var _data:BitmapData;
		protected var _rect:Rectangle;
		protected var _maximum:Number;
		protected var _multiplier:Number;
		
		public function AbstractIterativeGraph(width:int, height:int, maximum:Number)
		{
			_rect = new Rectangle(width - 2, 0, 2, height);
			
			_maximum = maximum;
			_multiplier = height / maximum;
			
			_data = new BitmapData(width, height, true, 0);
			_bitmap = new Bitmap(_data);
		}
		
		public function get bitmap():Bitmap
		{
			return _bitmap;
		}
		
		public function get maximum():Number
		{
			return _maximum;
		}
		
		protected function resampleMaximum(value:Number):void 
		{
			var newMaximum:Number = value * OVER_ESTIMATE;
			_multiplier = _data.height / newMaximum;
			
			var dH:Number = _maximum / newMaximum;
			var dY:Number = _multiplier * (newMaximum - _maximum);
			var matrix:Matrix = new Matrix(1,0,0,dH,0,dY);

			var replacement:BitmapData = new BitmapData(_data.width, _data.height, true, 0);
			replacement.draw(_data, matrix);
			_bitmap.bitmapData = replacement;
			_data.dispose();
			_data = replacement;
			
			_maximum = newMaximum;
		}
	}
}
