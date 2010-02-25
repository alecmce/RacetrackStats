package alecmce.stats.ui.iterativegraph 
{

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
	public class IterativeCompoundGraph extends AbstractIterativeGraph
	{
		private var _colors:Array;
		private var _height:int;
		
		public function IterativeCompoundGraph(width:int, height:int, maximum:Number, colors:Array)
		{
			super(width, height, maximum);
			_colors = colors;
			_height = height;
		}
		
		public function get colors():Array
		{
			return _colors;
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
				total += values[i];
			
			if (total > _maximum)
				resampleMaximum(total);
			
			i = count;
			_rect.top = _rect.bottom;
			while (i--)
			{
				_rect.top -= int(values[i] * _multiplier);
				_data.fillRect(_rect, _colors[i]);
				_rect.bottom = _rect.top;
			}
		}
		
	}
}
