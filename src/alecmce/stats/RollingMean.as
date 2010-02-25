package alecmce.stats 
{

	public class RollingMean 
	{
		
		private var _values:Array;
		private var _count:int;
		private var _sum:int;
		
		private var _valuesToCount:int;
		private var _inverseValuesToCount:Number;
		private var _maxIndex:int;

		public function RollingMean(valuesToCount:int) 
		{
			_values = [];
			_count = 0;
			_sum = 0;
			
			_valuesToCount = valuesToCount;
			_inverseValuesToCount = 1 / valuesToCount;
			_maxIndex = valuesToCount - 1;
		}
		
		public function update(value:Number):Boolean
		{
			var isEstablished:Boolean = _count == _valuesToCount;
			
			_sum += value;
			if (isEstablished)
			{
				_sum -= _values.shift();
				_values[_maxIndex] = value;
			}
			else
			{
				_values[_count++] = value;
			}
			
			return isEstablished;
		}
		
		public function get mean():Number
		{
			return _sum * _inverseValuesToCount;
		}
	}
}
