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
	public class IterativeGraph extends AbstractIterativeGraph
	{
		private var _color:uint;
		
		public function IterativeGraph(width:int, height:int, maximum:Number, color:uint)
		{
			super(width, height, maximum);
			_color = color;
		}
		
		public function get color():uint
		{
			return _color;
		}
		
		public function update(value:Number):void
		{
			_data.scroll(-2, 0);
			_rect.top = 0;
			_data.fillRect(_rect, 0);
			
			if (value > _maximum)
				resampleMaximum(value);
			else
				_rect.top = int((_maximum - value) * _multiplier);
			
			_data.fillRect(_rect, _color);
		}
		
	}
}
