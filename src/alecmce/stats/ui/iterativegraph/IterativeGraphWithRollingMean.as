package alecmce.stats.ui.iterativegraph 
{
	import alecmce.stats.RollingMean;

	import flash.geom.Rectangle;

	public class IterativeGraphWithRollingMean extends IterativeGraph 
	{
		private var _rollingPointerBounds:Rectangle;
		private var _rollingColor:uint;
		private var _rollingMean:RollingMean;
		
		public function IterativeGraphWithRollingMean(width:int, height:int, maximum:Number, color:uint, rollingColor:uint, valuesToCount:int)
		{
			super(width, height, maximum, color);
			
			_rollingPointerBounds = new Rectangle(width - 2, 0, 2, 2);
			_rollingColor = rollingColor;
			_rollingMean = new RollingMean(valuesToCount);
		}

		override public function update(value:Number):void 
		{
			var isEstablished:Boolean = _rollingMean.update(value);
			
			super.update(value);
			
			if (isEstablished)
			{
				var mean:Number = _rollingMean.mean;
				_rollingPointerBounds.y = int((_maximum - mean) * _multiplier); - 1;
				_data.fillRect(_rollingPointerBounds, _rollingColor);
			}
		}
	}
}
