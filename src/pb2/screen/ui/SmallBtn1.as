package pb2.screen.ui 
{
	import com.greensock.easing.Quad;
	import com.jaycsantos.util.GameLoop;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.text.TextField;
	import pb2.util.pb2internal;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class SmallBtn1 extends Pb2Btn 
	{
		use namespace pb2internal
		
		public static const FADE_DUR:uint = 100
		
		
		public function SmallBtn1( text:String, w:uint=60 ) 
		{
			super();
			
			addChild( _bg = new Shape );
			addChild( _txf = UIFactory.createFixedTextField(_text = text, 'smBtn1', 'left') );
			if ( !w ) w = _txf.width +10 >>0;
			_w = w;
			
			_txf.x = (w -_txf.width)/2;
			
			_bg.alpha = 0;
			with ( _bg.graphics ) {
				lineStyle( 1, 0x727272, 1, false, 'normal', null, 'mitter' );
				beginFill( 0x333333 );
				drawRect( 0, 0, _w, 15 );
				endFill();
			}
			
			with ( graphics ) {
				beginFill( 0, 0 );
				drawRect( 0, 0, _w, 15 );
				endFill();
			}
		}
		
		
		override public function update():void 
		{
			if ( _locked ) return;
			
			var t:int = FADE_DUR -(_timer -GameLoop.instance.time);
			if ( t < FADE_DUR )
				_bg.alpha = _isHover? Quad.easeIn(t, 0, 1, FADE_DUR): Quad.easeIn(t, 1, -1, FADE_DUR);
			else
				_bg.alpha = _isHover? 1: 0;
			
		}
		
		
			// -- private --
			
			pb2internal var _bg:Shape, _txf:TextField, _text:String, _w:uint
			protected var _timer:uint
			
			override protected function _movr( e:Event ):void 
			{
				super._movr(e);
				
				if ( !_locked ) {
					_timer = GameLoop.instance.time +FADE_DUR;
					_txf.htmlText = '<p class="smBtn1"><span class="smBtn1_ovr">'+ _text +'</span></p>';
				}
			}
			
			override protected function _mout( e:Event ):void 
			{
				super._mout(e);
				
				if ( !_locked ) {
					_timer = GameLoop.instance.time +FADE_DUR;
					_txf.htmlText = '<p class="smBtn1">'+ _text +'</p>';
				}
			}
			
	}

}