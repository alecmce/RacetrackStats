package demo
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;

	/**
	 * Processor heavy prime-factor calculations
	 * 
	 * @author Alec McEachran
	 * 
	 * (c) 2010 alecmce.com
	 * 
	 * Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
	 */
	public class PrimeFactors extends TextField implements Demo
	{
		private static const ITERATIONS:int = 100;
		
		private const LINES:int = 24;
		
		private var value:int = 2;
		
		public function PrimeFactors(width:int, height:int) 
		{
			super();
			this.width = width;
			this.height = height;
			selectable = false;
			backgroundColor = 0x000000;
			background = true;
			
			defaultTextFormat = new TextFormat("_sans",12,0xFFFFFF);
			
		}

		private function onEnterFrame(event:Event):void 
		{
			for (var n:int = 0; n < ITERATIONS; n++)
			{
				var v:int = value;
				var lines:Array = [];
				for (var i:int = 0; i < LINES; i++)
					lines.push(v + " = " + decompose(v++).join("x"));
			}
			
			value = v;
			text = lines.join("\n");
		}

		
		/**
		 * use seive of Erasothenes to decompose n into its prime factors
		 */
		public function decompose(n:int):Array
		{
			var i:int;
			var k:Number;
			var arr:Array;
			var count:int;
			
			i = 2;
			arr = [];
			count = 0;
			while (i <= n / i)
			{
				k = n / i;
				if (k == int(k))
				{
					arr[count++] = i;
					n /= i;
				}
				else
				{
					i++;
				}
			}
			
			arr[count] = n;
			
			return arr;
		}
		
		public function start():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);		}
		
		public function stop():void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function reset():void
		{
			value = 2;
			text = "";
		}
		
		public function get display():DisplayObject
		{
			return this;
		}
	}
}