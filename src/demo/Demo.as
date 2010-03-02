package demo 
{
	import flash.display.DisplayObject;

	public interface Demo 
	{
		function get display():DisplayObject;
		
		function start():void;
		
		function stop():void;
		
		function reset():void;
		
	}
}
