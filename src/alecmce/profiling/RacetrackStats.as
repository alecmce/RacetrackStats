package alecmce.profiling 
{
	import alecmce.stats.ui.iterativegraph.IterativeCompoundGraph;
	import alecmce.stats.ui.iterativegraph.IterativeGraphWithRollingMean;
	import alecmce.utils.PixelButton;
	import alecmce.utils.PixelWriter;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.utils.getTimer;

	/**
	 * Creates a graph of the amount of processing time the Flash Player is taking
	 * to complete each portion of its cycle. 
	 * 
	 * The stats are collected into an array of data, which is passed into the
	 * graph every frame. The data collected is [enter-frame,pre-render,render]. They
	 * are colour coded according to the RacetrackStatsStyle that is defined. See
	 * the RacetrackStatsStyle constructor for details of the default colourings
	 * 
	 * @author Alec McEachran
	 * 
	 * (c) 2010 alecmce.com
	 * 
	 * Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
	 */
	public class RacetrackStats extends Sprite
	{
		/** the singleton instance -- RacetrackStats must be a singleton, see below */
		private static var stats:RacetrackStats;
		
		/**
		 * The singleton instance enforces that only one RacetrackStats is created. It
		 * should be referenced at the top of the application, even if it is not
		 * immediately added to the stage. Failure to do so will cause bad data.
		 * 
		 * Listener priority is particular to the class in which listeners are defined,
		 * so if I add a low priority listener from object A, then a high-priority listener
		 * from object B, the listener from object A will be triggered before the listener
		 * from object B. The only way RacetrackStats can guarantee that it captures all
		 * of your code execution time is if it hooks itself to the ENTER_FRAME event before
		 * any other code does.
		 * 
		 * However, you may not want to launch RacetrackStats immediately, because other items
		 * may need to be constructed or initialised before it can be added to the stage; in this
		 * case call RacetrackStats.prep() first, then construct RacetrackStats at your leisure
		 */
		public static function getInstance():RacetrackStats
		{
			if (!stats)
				stats = new RacetrackStats();
			
			return stats;
		}
		
		private const SINGLETON_ERROR:String = "Please reference RacetrackStats from the singleton instance, as early as possible in the application, otherwise results will be distorted";
		
		private const ORIGIN:Point = new Point(0, 0);
		private const OVERLAY:Point = new Point(2, 2);
		private const OUTPUT:Point = new Point(40, 2);
		private const TO_MEGABYTES:Number = 9.53674316e-7;
		
		private var style:RacetrackStatsStyle;
		
		private var data:Array;

		private var compound:IterativeCompoundGraph;
		private var code:IterativeGraphWithRollingMean;
		private var prerender:IterativeGraphWithRollingMean;
		private var render:IterativeGraphWithRollingMean;
		private var framerate:IterativeGraphWithRollingMean;		private var memory:IterativeGraphWithRollingMean;
		private var graph:Bitmap;
		private var graphs:Array;		private var descriptions:Array;
		private var index:uint;

		private var writer:PixelWriter;
		private var overlay:BitmapData;
		private var output:BitmapData;
		private var rect:Rectangle;

		private var prev:PixelButton;
		private var next:PixelButton;
		private var description:Bitmap;

		private var time:int;
		private var second_time:int;
		private var frames_per_second:int;
		
		private var maxMemory:uint;
		
		private var adjustFrameRate:Boolean;
		private var frameRateIncrement:int;

		public function RacetrackStats(style:RacetrackStatsStyle = null)
		{
			if (stats)
			{
				throw new Error(SINGLETON_ERROR);
			}
			else 
			{
				stats = this;
				stats.addEventListener(Event.ENTER_FRAME, stats.dummyEnterFrame);
			}
			
			this.style = style ||= new RacetrackStatsStyle();
			this.adjustFrameRate = style.adjustFrameRate;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.RENDER, onRenderBegins, false, int.MAX_VALUE);
			addEventListener(Event.RENDER, onRenderEnds, false, -int.MAX_VALUE);
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);			
			init();	
			if (adjustFrameRate)
			{
				stage.frameRate = 64;
				frameRateIncrement = 1;
			}
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame, false, int.MAX_VALUE);
			second_time = time = getTimer();
		}
		
		private function onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			
			addEventListener(Event.ENTER_FRAME, dummyEnterFrame);			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function init():void
		{
			var width:uint = style.width;
			var height:uint = style.height;
			
			graphics.beginFill(0xFFFFFF);			graphics.drawRect(0, 0, width, height);			graphics.endFill();
			
			overlay = new BitmapData(width, height, true, 0);
			output = new BitmapData(width, height, true, 0);
			rect = overlay.rect;
			writer = new PixelWriter();
			writer.write("FPS\nMEM\nCODE\n\PRE\nSYS", overlay, OVERLAY);
			
			data = [0,0,0];
			
			compound = new IterativeCompoundGraph(width, height, 50, style.compoundBars());
			code = new IterativeGraphWithRollingMean(width,height,50,style.codeBar(),style.codeTrend(),style.meanValues);
			prerender = new IterativeGraphWithRollingMean(width,height,50,style.prerenderBar(),style.prerenderTrend(),style.meanValues);
			render = new IterativeGraphWithRollingMean(width,height,50,style.renderBar(),style.renderTrend(),20);
			framerate = new IterativeGraphWithRollingMean(width,height,stage.frameRate + 1, style.framerateBar(), style.framerateTrend(), style.meanValues);
			memory = new IterativeGraphWithRollingMean(width,height,1000, style.memoryBar(), style.memoryTrend(), style.meanValues);
			graphs = [compound, code, prerender, render, framerate, memory];
			descriptions = style.descriptions;
			index = 0;
			
			addChild(new Bitmap(output));
			addChild(graph = new Bitmap(compound.data));
			
			addChild(prev = new PixelButton(PixelButton.LEFT));			addChild(next = new PixelButton(PixelButton.RIGHT));

			prev.addEventListener(MouseEvent.CLICK, onPrevious);			prev.x = 2;
			prev.y = height - PixelButton.HEIGHT - 2;
			
			next.addEventListener(MouseEvent.CLICK, onNext);
			next.x = PixelButton.WIDTH + 4;
			next.y = height - PixelButton.HEIGHT - 2;
			
			var offset:int = next.x + next.width + 6;
			description = new Bitmap(new BitmapData(width - offset, PixelButton.HEIGHT, true, 0));
			description.x = offset;
			description.y = height - PixelButton.HEIGHT;
			addChild(description);
			writer.write(descriptions[index], description.bitmapData, ORIGIN);
			
			frames_per_second = 0;
		}
		
		private function onNext(event:MouseEvent):void 
		{
			index = ++index % 6;
			updateGraph();
		}

		private function onPrevious(event:MouseEvent):void 
		{
			index = index ? --index : 5;
			updateGraph();
		}
		
		private function updateGraph():void
		{			graph.bitmapData = graphs[index].data;
			
			var data:BitmapData = description.bitmapData;
			data.fillRect(data.rect, 0);
			writer.write(descriptions[index], description.bitmapData, ORIGIN);
		}
		
		private function dummyEnterFrame(event:Event):void
		{
			// worth doing anything useful here?
		}

		private function onEnterFrame(event:Event):void
		{
			var t:int = getTimer();
			data[2] += t - time;
			++frames_per_second;
			
			if (t - second_time > 999)
			{
				update();
				second_time = t;
			}
			
			stage.invalidate();
			time = getTimer();
		}

		private function onRenderBegins(event:Event):void
		{
			var t:int = getTimer();
			data[0] += t - time;
			time = t;
		}
		
		private function onRenderEnds(event:Event):void 
		{
			var t:int = getTimer();
			data[1] += t - time;
			time = t;
		}
		
		private function update():void 
		{
			output.copyPixels(overlay, rect, ORIGIN);
			
			var frameRate:int = stage.frameRate;
			var bytes:uint = System.totalMemory;
			if (bytes > maxMemory)
				maxMemory = bytes;
			
			var text:String = frames_per_second + "/" + frameRate + "\n";
			text += (bytes * TO_MEGABYTES).toFixed(1) + "/" + (maxMemory * TO_MEGABYTES).toFixed(1) + "MB\n";
			text += int(data[0] * 0.1) + "%\n";			text += int(data[1] * 0.1) + "%\n";			text += int(data[2] * 0.1) + "%\n";
			writer.write(text, output, OUTPUT);
			
			var n:Number = 1 / frames_per_second;
			data[0] *= n;
			data[1] *= n;			data[2] *= n;			compound.update(data);
			code.update(data[0]);
			prerender.update(data[1]);
			render.update(data[2]);
			framerate.update(frames_per_second);
			memory.update(bytes);
			
			if (adjustFrameRate)
			{
				if (frames_per_second >= frameRate)
				{
					if (frameRateIncrement < 1)
						frameRateIncrement = 1;
					
					stage.frameRate += frameRateIncrement;
					frameRateIncrement *= 2;
				}
				else if (frames_per_second < frameRate * 0.6)
				{
					if (frameRateIncrement > -1)
						frameRateIncrement = -1;
					
					frameRate += frameRateIncrement;
					stage.frameRate = frameRate > 1 ? frameRate : 1;
					frameRateIncrement *= 2;
				}
				else
				{
					frameRateIncrement = 0;
				}
			}
			
			data[0] = data[1] = data[2] = 0;
			frames_per_second = 0;
		}
	}
}