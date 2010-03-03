package demo 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;

	/**
	 * Render/Processor heavy smoke effect
	 * 
	 * @author Alec McEachran
	 * 
	 * (c) 2010 alecmce.com
	 * 
	 * Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
	 */
	public class Smoke extends Bitmap implements Demo
	{
		private const PARTICLES:int = 10000000;
		
		private var _initX:int;
		private var _initY:int;
		
		private var halfWidth:int;
		
		private var _x:Array;		private var _y:Array;		private var _dx:Array;		private var _dy:Array;		private var _ddx:Array;		private var _ddy:Array;
		private var _alpha:Array;
		private var _count:int;
	
		private var toggle:Boolean;
		
		private var _inited:Boolean;
	
		public function Smoke(width:int, height:int)
		{
			super(new BitmapData(width, height, true, 0));
			halfWidth = width * 0.5;
			
			reset();
			filters = [new GlowFilter(0x99FFFFFF,1,10,10,30,1), new BlurFilter(10,10,2)];
		}

		private function initialIteration(event:Event):void 
		{
			init(_count);
			if (_count++ == PARTICLES)
			{
				removeEventListener(Event.ENTER_FRAME, initialIteration);
				addEventListener(Event.ENTER_FRAME, loopIteration);
				_inited = true;
			}
			
			loopIteration(event);
		}

		private function init(index:int):void
		{
			_x[index] = _initX + Math.random() * 10;
			_y[index] = _initY - Math.random() * 10;
			_dx[index] = Math.random() - 0.5;
			_dy[index] = -1;
			_ddx[index] = (Math.random() * 0.0008) - 0.0004;
			_ddy[index] = Math.random() * -0.08;
			_alpha[index] = 0x66FFFFFF;
		}

		private function loopIteration(event:Event):void 
		{
			bitmapData.lock();
			bitmapData.fillRect(bitmapData.rect, 0);
			
			toggle = !toggle;
			
			var i:int = _count;
			while (--i > -1)
			{
				bitmapData.setPixel32(_x[i], _y[i], _alpha[i]);
				
				if (toggle)
				{
					_alpha[i] -= 0x01000000;
					if (_alpha[i] <= 0)
					{
						init(i);
						continue;
					}
				}
				
				_y[i] += _dy[i];
				_x[i] += _dx[i];
				_dx[i] += _ddx[i];
				_dy[i] += _ddy[i];
			}
			
			bitmapData.unlock();	
		}
		
		public function start():void
		{
			if (_inited)
				addEventListener(Event.ENTER_FRAME, loopIteration);
			else
				addEventListener(Event.ENTER_FRAME, initialIteration);
		}
		
		public function stop():void
		{
			if (_inited)
				removeEventListener(Event.ENTER_FRAME, loopIteration);
			else
				removeEventListener(Event.ENTER_FRAME, initialIteration);
		}
		
		public function reset():void
		{
			_initX = width * 0.5;
			_initY = height;
			
			if (_inited && hasEventListener(Event.ENTER_FRAME))
			{
				removeEventListener(Event.ENTER_FRAME, loopIteration);
				addEventListener(Event.ENTER_FRAME, initialIteration);
			}
			
			_inited = false;
		
			_x = [];
			_y = [];
			_dx = [];
			_dy = [];
			_ddx = [];
			_ddy = [];
			_alpha = [];
			_count = 0;
			
			toggle = false;
		}
		
		public function get display():DisplayObject
		{
			return this;
		}
	}
}
