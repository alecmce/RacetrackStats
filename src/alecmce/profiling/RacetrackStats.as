package alecmce.profiling 
{
	import alecmce.stats.ui.iterativegraph.IterativeCompoundGraph;
	import alecmce.stats.ui.iterativegraph.IterativeGraphWithRollingMean;
	import alecmce.utils.PixelButton;
	import alecmce.utils.PixelWriter;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
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
	 * are colour coded, by default to the following colors:
	 * 
	 * enter-frame: green
	 * pre-render: blue
	 * render: red
	 * 
	 * @author Alec McEachran
	 * 
	 * (c) 2010 alecmce.com
	 * 
	 * Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
	 */
	public class RacetrackStats 
	{
		private const HANDLE_ERROR:String = "At the top of your application class, please add the line RacetrackStats.prep() in order for Racetrack stats to function correctly";
		
		private const WIDTH:int = 100;
		private const HEIGHT:int = 60;
		private const VALUES_TO_COUNT:int = 20;
		private const ORIGIN:Point = new Point(0, 0);
		private const OVERLAY:Point = new Point(2, 2);
		private const OUTPUT:Point = new Point(52, 2);
		private const TO_MEGABYTES:Number = 9.53674316e-7;
		
		private var stage:Stage;
		
		private var container:DisplayObjectContainer;
		
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
		
		private var adjustFrameRate:Boolean;

		public function RacetrackStats(stage:Stage, style:RacetrackStatsStyle = null)
		{
			if (!handle)
				throw new Error(HANDLE_ERROR);
			
			if (!style)
				style = new RacetrackStatsStyle();
			
			this.stage = stage;
			this.adjustFrameRate = style.adjustFrameRate;
			
			container = new Sprite();
			
			overlay = new BitmapData(WIDTH, HEIGHT, true, 0);
			output = new BitmapData(WIDTH, HEIGHT, true, 0);
			rect = overlay.rect;
			writer = new PixelWriter();
			writer.write("FPS\nMEMORY\nCODE\n\PRERENDER\nRENDER", overlay, OVERLAY);
			
			data = [0,0,0];
			
			compound = new IterativeCompoundGraph(WIDTH, HEIGHT, 50, style.compoundBars());
			code = new IterativeGraphWithRollingMean(WIDTH,HEIGHT,50,style.codeBar(),style.codeTrend(),VALUES_TO_COUNT);
			prerender = new IterativeGraphWithRollingMean(WIDTH,HEIGHT,50,style.prerenderBar(),style.prerenderTrend(),VALUES_TO_COUNT);
			render = new IterativeGraphWithRollingMean(WIDTH,HEIGHT,50,style.renderBar(),style.renderTrend(),20);
			framerate = new IterativeGraphWithRollingMean(WIDTH,HEIGHT,stage.frameRate + 1, style.framerateBar(), style.framerateTrend(), VALUES_TO_COUNT);
			memory = new IterativeGraphWithRollingMean(WIDTH,HEIGHT,1000, style.memoryBar(), style.memoryTrend(), VALUES_TO_COUNT);
			graphs = [compound, code, prerender, render, framerate, memory];
			descriptions = style.descriptions;
			index = 0;
			
			container.addChild(new Bitmap(output));
			container.addChild(graph = new Bitmap(compound.data));
			
			container.addChild(prev = new PixelButton(PixelButton.LEFT));			container.addChild(next = new PixelButton(PixelButton.RIGHT));

			prev.addEventListener(MouseEvent.CLICK, onPrevious);			prev.x = 2;
			prev.y = HEIGHT - PixelButton.HEIGHT - 2;
			
			next.addEventListener(MouseEvent.CLICK, onNext);
			next.x = PixelButton.WIDTH + 4;
			next.y = HEIGHT - PixelButton.HEIGHT - 2;
			
			var offset:int = next.x + next.width + 6;
			description = new Bitmap(new BitmapData(WIDTH - offset, PixelButton.HEIGHT, true, 0));
			description.x = offset;
			description.y = HEIGHT - PixelButton.HEIGHT;
			container.addChild(description);
			writer.write(descriptions[index], description.bitmapData, ORIGIN);
			
			stage.addChild(container);
			
			frames_per_second = 0;
			second_time = time = getTimer();
			
			var node:Sprite = new Sprite();
			DisplayObjectContainer(stage.root).addChild(node);
			
			handle.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, int.MAX_VALUE);
			stage.addEventListener(Event.RENDER, onRenderBegins, false, int.MAX_VALUE);
			stage.addEventListener(Event.RENDER, onRenderEnds, false, -int.MAX_VALUE);	
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
			
			var text:String = frames_per_second + "/" + frameRate + "\n";
			text += (bytes * TO_MEGABYTES).toFixed(1) + "MB\n";
			text += data.join("\n");
			writer.write(text, output, OUTPUT);
			
			var n:Number = 1 / frames_per_second;
			
			data[0] *= n;
			data[1] *= n;			data[2] *= n;			compound.update(data);
			code.update(data[0]);
			prerender.update(data[1]);
			render.update(data[2]);
			framerate.update(frames_per_second);
			memory.update(bytes)
			
			if (adjustFrameRate)
			{
				if (frames_per_second >= frameRate)
					stage.frameRate++;
				else if (frames_per_second < frameRate * 0.8)
					stage.frameRate--;
			}
			
			data[0] = data[1] = data[2] = 0;
			frames_per_second = 0;
		}
		
		
		private static var handle:Shape;
		
		public static function prep():void
		{
			handle = new Shape();
			handle.addEventListener(Event.ENTER_FRAME, onHandle);
		}
		
		private static function onHandle(event:Event):void
		{
			handle.removeEventListener(Event.ENTER_FRAME, onHandle);
		}
	}
}