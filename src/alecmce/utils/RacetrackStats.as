package alecmce.utils 
{
	import alecmce.stats.ui.iterativegraph.IterativeCompoundGraphWithRollingMeans;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
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
		private var graph:IterativeCompoundGraphWithRollingMeans;
//		private var drawing:IterativeGraphWithRollingMean;
//		private var code:IterativeGraphWithRollingMean;
//		private var renders:IterativeGraphWithRollingMean;
//		private var framerate:IterativeGraphWithRollingMean;

		private var writer:PixelWriter;
		private var overlay:BitmapData;
		private var output:BitmapData;
		private var rect:Rectangle;

		private var time:int;
		private var second_time:int;
		private var frames_per_second:int;

		public function RacetrackStats(stage:Stage)
		{
			this.stage = stage;
			
			container = new Sprite();
			
			overlay = new BitmapData(WIDTH, HEIGHT, true, 0);
			output = new BitmapData(WIDTH, HEIGHT, true, 0);
			rect = overlay.rect;
			writer = new PixelWriter();
			writer.write("FPS\nMEMORY\nCODE\n\PRERENDER\nRENDER", overlay, OVERLAY);
			
			data = [0,0,0];
			
			var barColors:Array = [0x6600FF00,0x661E90FF,0x66FF0000];
			var meanColors:Array = [0xFF00FF00,0xFF1E90FF,0xFFFF0000];
			
			graph = new IterativeCompoundGraphWithRollingMeans(WIDTH, HEIGHT, 50, barColors, meanColors, VALUES_TO_COUNT);
//			code = new IterativeGraphWithRollingMean(100,60,50,0x6600FF00,0xFF00FF00,20);
//			renders = new IterativeGraphWithRollingMean(100,60,50,0x661E90FF,0xFF1E90FF,20);
//			renders.bitmap.x = 100;
//			drawing = new IterativeGraphWithRollingMean(100,60,50,0x66FF0000,0xFFFF0000,20);
//			drawing.bitmap.x = 200;
//			framerate = new IterativeGraphWithRollingMean(100,60,50,0x669900FF,0xFF9900FF,20);
//			framerate.bitmap.x = 300;
			
			container.addChild(graph.bitmap);
//			container.addChild(renders.bitmap);
//			container.addChild(drawing.bitmap);
//			container.addChild(framerate.bitmap);
			container.addChild(new Bitmap(output));
			
			stage.addChild(container);
			
			frames_per_second = 0;
			second_time = time = getTimer();
			
			var node:Sprite = new Sprite();
			DisplayObjectContainer(stage.root).addChild(node);
			
			if (!handle)
				throw new Error(HANDLE_ERROR);
			
			handle.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, int.MAX_VALUE);
			stage.addEventListener(Event.RENDER, onRenderBegins, false, int.MAX_VALUE);
			stage.addEventListener(Event.RENDER, onRenderEnds, false, -int.MAX_VALUE);	
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
			graph.update(data);
			stage.invalidate();
			
			output.copyPixels(overlay, rect, ORIGIN);
			
			var text:String = frames_per_second + "/" + stage.frameRate + "\n";
			text += (System.totalMemory * TO_MEGABYTES).toFixed(1) + "MB\n";
			text += data.join("\n");
			writer.write(text, output, OUTPUT);
			
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