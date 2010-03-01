package alecmce.utils 
{
	import alecmce.profiling.RacetrackStats;
	import alecmce.stats.ui.iterativegraph.IterativeCompoundGraph;
	import alecmce.stats.ui.iterativegraph.IterativeCompoundGraphWithRollingMeans;
	import alecmce.stats.ui.iterativegraph.IterativeGraph;
	import alecmce.stats.ui.iterativegraph.IterativeGraphWithRollingMean;

	import flash.display.Bitmap;
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
		private var maximum:int;

		public function RenderStatsTest()
		{	
			slowness = 1;
			maximum = 100;
			
			var bmp:Bitmap;
			
			iterative = new IterativeGraph(200, 100, maximum, 0xFFFF0000);
			addChild(bmp = new Bitmap(iterative.data));
			bmp.y = 100;
			
			compound = new IterativeCompoundGraph(200, 100, maximum, [0xFFFF0000,0xFFFFFF00,0xFF00FF00,0xFF1E90FF]);
			addChild(bmp = new Bitmap(compound.data));
			bmp.y = 200;
			
			average = new IterativeGraphWithRollingMean(200, 100, maximum, 0x66FF0000, 0xFFFF0000, 100);
			addChild(bmp = new Bitmap(average.data));
			bmp.y = 300;
			
			compaverage = new IterativeCompoundGraphWithRollingMeans(200, 100, maximum, [0x66FF0000,0x66FFFF00,0x6600FF00,0x661E90FF], [0xFFFF0000,0xFFFF8800,0xFF00FF00,0xFF1E90FF], 100);
			addChild(bmp = new Bitmap(compaverage.data));
			bmp.x = 200; bmp.y = 200;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stats = new RacetrackStats(stage);
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
			for (var i:uint = 0; i < value * 10; i++)
				Math.pow(i, 2) / Math.sin(i) / Math.cos(i) / Math.sqrt(i);
		}
		
		
	}
}
