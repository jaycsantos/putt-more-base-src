package  
{
	import com.jaycsantos.util.GameLoop;
	import com.jaycsantos.util.ns.internalGameloop;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class DOutput extends Sprite 
	{
		protected static var texts:Vector.<String> = new Vector.<String>();
		
		public static function show( ...msgs ):void
		{
			texts.push( msgs.join(' ') );
		}
		
		
		protected var text:TextField;
		
		public function DOutput() 
		{
			mouseEnabled = false;
			mouseChildren = false;
			tabEnabled = false;
			tabChildren = false;
			
			
			addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		protected function init( e:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, init );
			
			
			var format:TextFormat = new TextFormat( '_sans', 9, 0xffff00 );
			format.align = TextFormatAlign.RIGHT;
			
			text = new TextField();
			text.autoSize = TextFieldAutoSize.RIGHT;
			text.condenseWhite = true;
			text.selectable = false;
			text.mouseEnabled = false;
			text.defaultTextFormat = format;
			text.x = PuttBase2.STAGE_WIDTH-5;
			text.y = 200;
			
			addChild( text );
			
			GameLoop.instance.internalGameloop::addCallback( update );
		}
		
		protected function update():void
		{
			var txt:String = "";
			for each( var s:String in texts )
				txt += s +"\n";
			text.text = txt;
			
			texts.splice( 0, texts.length );
		}
		
		
	}

}