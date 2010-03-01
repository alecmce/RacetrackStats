package alecmce.stats.ui.iterativegraph 
{
	import alecmce.stats.RollingMean;

	import flash.geom.Rectangle;

	/**
	 * Renders a sequence of positive values on a graph between 0 and a positive
	 * maximum. An initial maximum may be set but if the value surpasses that
	 * maximum the graph will re-dimension itself to keep accurate data.
	 * 
	 * @author Alec McEachran
	 * 
	 * (c) 2010 alecmce.com
	 * 
	 * Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
	 */
	public class IterativeCompoundGraphWithRollingMeans extends AbstractIterativeGraph
	{
		private var _rollingPointerBounds:Rectangle;

		private var _barColors:Array;		private var _meanColors:Array;		private var _means:Array;
		private var _established:Array;
		private var _height:int;
		
		public function IterativeCompoundGraphWithRollingMeans(width:int, height:int, maximum:Number, barColors:Array, meanColors:Array, valuesToCount:int)
		{
			super(width, height, maximum);
			_barColors = barColors;			_meanColors = meanColors;
			
			_means = [];
			_established = [];
			
			var len:int = barColors.length;
			for (var i:int = 0; i < len; i++)
			{
				_means[i] = new RollingMean(valuesToCount);
				_established[i] = false;
			}
			
			_rollingPointerBounds = new Rectangle(width - 2, 0, 2, 2);
			_height = height;
		}
		
		public function get colors():Array
		{
			return _barColors;
		}
		
		public function update(values:Array):void
		{
			_data.scroll(-2, 0);
			_rect.top = 0;
			_rect.bottom = _height;
			_data.fillRect(_rect, 0);
			
			var count:int = values.length;
			var total:int = 0;
			
			var i:int = count;
			while (i--)
			{
				var value:Number = values[i];
				var mean:RollingMean = _means[i];
				
				_established[i] = mean.update(value);
				total += value;
			}
			
			if (total > _maximum)
				resampleMaximum(total);
			
			i = count;
			_rect.top = _rect.bottom;
			while (i--)
			{
				_rect.top -= int(values[i] * _multiplier);
				_data.fillRect(_rect, _barColors[i]);
				_rect.bottom = _rect.top;
			}
			
			i = count;
			_rollingPointerBounds.y = _height;
			while (i--)
			{
				_rollingPointerBounds.y -= _means[i].mean * _multiplier;
				
				if (!_established[i])
					continue;
				
				_data.fillRect(_rollingPointerBounds, _meanColors[i]);
			}
		}
		
	}
}
