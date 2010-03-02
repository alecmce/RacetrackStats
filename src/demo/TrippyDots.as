package demo 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;

	/**
	 * Render heavy animation with transparencies and a blur filter
	 * 
	 * @author Alec McEachran
	 * 
	 * (c) 2010 alecmce.com
	 * 
	 * Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
	 */
	public class TrippyDots extends Sprite implements Demo 
	{
		private const COLORS:Array = [0xFF0000,0xFF8800,0xFFEE00,0x00FF00,0x1E90FF,0x9900FF];
		private const QUANTITY:int = 1000;
		private const MULTIPLIER:Number = 1 / 50;
		
		private var _width:int;
		private var _height:int;
		
		public function TrippyDots(width:int, height:int)
		{
			_width = width;
			_height = height;
			
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0x00FF00, 1);
			sprite.graphics.drawRect(0, 0, width, height);
			sprite.graphics.endFill();
			
			mask = sprite;
			
			filters = [new BlurFilter(4,0,1)];
		}
		
		public function start():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);		}

		private function onEnterFrame(event:Event):void 
		{
			var ball:Sprite;
			var i:int = numChildren;
			var half:int = i * 0.5;
			
			if (i == QUANTITY)
			{
				i--;
				removeChildAt(0);
			}
			
			while (i--)
			{
				ball = Sprite(getChildAt(i));
				ball.x += (i - half) * MULTIPLIER;
				if (ball.x > _width)
					ball.x -= _width;
				else if (ball.x < 0)
					ball.x += _width;
			}
			
			if (i == QUANTITY)
				return;
			
			ball = new Sprite();
			ball.graphics.beginFill(COLORS[int(Math.random() * COLORS.length)], 0.3);
			ball.graphics.drawCircle(0, 0, Math.random() * 20);
			ball.graphics.endFill();
			ball.x = Math.random() * _width;
			ball.y = Math.random() * _height;
			addChild(ball);
			
		}

		public function stop():void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function reset():void
		{
			var i:int = numChildren;
			while (i--)
				removeChildAt(i);
		}
		
		public function get display():DisplayObject
		{
			return this;
		}
	}
}
