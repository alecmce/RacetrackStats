package alecmce.utils 
{
	import alecmce.stats.RacetrackStats;
	import alecmce.stats.ui.iterativegraph.IterativeCompoundGraph;
	import alecmce.stats.ui.iterativegraph.IterativeCompoundGraphWithRollingMeans;
	import alecmce.stats.ui.iterativegraph.IterativeGraph;
	import alecmce.stats.ui.iterativegraph.IterativeGraphWithRollingMean;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;

	public class RenderStatsTest extends Sprite 
	{
		RacetrackStats.prep();
		
		private static const COUNT:int = 4;

		public var stats:RacetrackStats;

		public var iterative:IterativeGraph;
		public var compound:IterativeCompoundGraph;
		public var average:IterativeGraphWithRollingMean;		public var compaverage:IterativeCompoundGraphWithRollingMeans;
		
		private var slowness:int;
		private var step:int;
		private var maximum:int;

		public function RenderStatsTest()
		{	
			slowness = 1;
			maximum = 100;
			
			iterative = new IterativeGraph(200, 100, maximum, 0xFFFF0000);
			iterative.bitmap.y = 100;
			addChild(iterative.bitmap);
			
			compound = new IterativeCompoundGraph(200, 100, maximum, [0xFFFF0000,0xFFFFFF00,0xFF00FF00,0xFF1E90FF]);
			compound.bitmap.y = 200;
			addChild(compound.bitmap);
			
			average = new IterativeGraphWithRollingMean(200, 100, maximum, 0x66FF0000, 0xFFFF0000, 100);
			average.bitmap.y = 300;
			addChild(average.bitmap);
			
			compaverage = new IterativeCompoundGraphWithRollingMeans(200, 100, maximum, [0x66FF0000,0x66FFFF00,0x6600FF00,0x661E90FF], [0xFFFF0000,0xFFFF8800,0xFF00FF00,0xFF1E90FF], 100);
			compaverage.bitmap.x = 200;			compaverage.bitmap.y = 200;
			addChild(compaverage.bitmap);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stats = new RacetrackStats(stage, true);
		}

		private function onEnterFrame(event:Event):void 
		{
			var t:int = getTimer();
			slowdown(slowness++);
			
			iterative.update(int(Math.random() * maximum));
			average.update(int(Math.random() * maximum));
			
			var count:int = COUNT;
			var arr:Array = [];
			
			var i:int = count;
			while (i--)
				arr.push(int(Math.random() * maximum * 0.33));
			
			compound.update(arr);			compaverage.update(arr);
		}
		
		private function slowdown(value:uint):void
		{
			for (var i:uint = 0; i < value; i++)
				Math.pow(i, 2) / Math.sin(i) / Math.cos(i) / Math.sqrt(i);
		}
		
		
	}
}
