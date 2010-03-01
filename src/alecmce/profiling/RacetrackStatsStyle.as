package alecmce.profiling 
{
	/**
	 * 
	 * 
	 * @author Alec McEachran
	 * 
	 * (c) 2010 alecmce.com
	 * 
	 * Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
	 */
	public class RacetrackStatsStyle 
	{
		
		public var codeRGB:uint;
		public var prerenderRGB:uint;
		public var renderRGB:uint;
		public var framerateRGB:uint;
		public var memoryRGB:uint;

		private var _defaultAlpha:uint;
		private var _trendAlpha:uint;		

		/** whether to adjust the frame-rate dynamically depending upon load */
		public var adjustFrameRate:Boolean;
		
		public var descriptions:Array;

		public function RacetrackStatsStyle() 
		{
			codeRGB = 0x00FF00;
			prerenderRGB = 0x1E90FF;
			renderRGB = 0xFF0000;
			framerateRGB = 0x9900FF;
			memoryRGB = 0x999999;
			
			_defaultAlpha = 0x66;
			_trendAlpha = 0xFF;
			
			adjustFrameRate = true;
			
			descriptions = ["compound","code","prerender","render","framerate","memory"];
		}

		public function compoundBars():Array
		{
			var alpha:uint = _defaultAlpha << 24;
			return [alpha | codeRGB, alpha | prerenderRGB, alpha | renderRGB];
		}
		
		public function codeBar():uint { return (_defaultAlpha << 24) | codeRGB; }
		public function codeTrend():uint { return (_trendAlpha << 24) | codeRGB; }
		public function prerenderBar():uint { return (_defaultAlpha << 24) | prerenderRGB; }
		public function prerenderTrend():uint { return (_trendAlpha << 24) | prerenderRGB; }
		public function renderBar():uint { return (_defaultAlpha << 24) | renderRGB; }
		public function renderTrend():uint { return (_trendAlpha << 24) | renderRGB; }
		public function framerateBar():uint { return (_defaultAlpha << 24) | framerateRGB; }
		public function framerateTrend():uint { return (_trendAlpha << 24) | framerateRGB; }
		public function memoryBar():uint { return (_defaultAlpha << 24) | memoryRGB; }
		public function memoryTrend():uint { return (_trendAlpha << 24) | memoryRGB; }
			
	}
}
