package pb2.util 
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class UIkit 
	{
		public static function createButton( text:String, onClick:Function ):Sprite
		{
			var t:TextField = new TextField;
			t.text = text;
			t.selectable = false;
			var tf:TextFormat = t.getTextFormat();
			tf.font = 'Arial';
			tf.size = 11;
			tf.align = TextFormatAlign.CENTER;
			tf.color = 0xAAAAAA;
			t.height = 16;
			t.width = 70;
			t.setTextFormat( tf );
			
			var s:Sprite = new Sprite;
			s.addChild( t );
			with( s.graphics ) {
				beginFill( 0x333333, 1 );
				lineStyle( 0.5, 0x444444 );
				moveTo( 0, s.height );
				lineTo( 0, 0 );
				lineTo( s.width, 0 );
				lineStyle( 0.5, 0x3c3c3c );
				lineTo( s.width, s.height );
				moveTo( 0, s.height );
				endFill();
			}
			
			s.buttonMode = s.useHandCursor = s.mouseEnabled = true;
			s.mouseChildren = false;
			s.addEventListener( MouseEvent.CLICK, onClick );
			
			s.cacheAsBitmap = true;
			
			return s;
		}
		
		public static function makeIntoButton( clip:InteractiveObject, onClick:Function ):void
		{
			if ( clip is Sprite )
				Sprite(clip).buttonMode = Sprite(clip).useHandCursor = true;
			
			clip.mouseEnabled = true;
			if ( clip is DisplayObjectContainer )
				DisplayObjectContainer(clip).mouseChildren = false;
				
			clip.addEventListener( MouseEvent.CLICK, onClick, false, 0, true );
		}
		
		
		public function UIkit() 
		{
			
		}
		
	}

}