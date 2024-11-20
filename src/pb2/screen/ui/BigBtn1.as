package pb2.screen.ui 
{
	import com.greensock.easing.Sine;
	import com.jaycsantos.game.IGameObject;
	import com.jaycsantos.IDisposable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class BigBtn1 extends Pb2Btn
	{
		public static const FADE_SPEED:uint = 100;
		
		
		public function BigBtn1( text:String, style:String='btn1', w:int=120, h:int=24, bg:uint=0x997E00 )
		{
			super();
			_style = style;
			
			var hit:Sprite = new Sprite;
			hit.graphics.beginFill( 0 );
			hit.graphics.drawRect( 0, 0, w, h );
			hit.visible = false;
			addChild( hitArea = hit );
			
			addChild( _bg = new Shape );
			_bg.graphics.beginFill( bg );
			_bg.graphics.drawRect( 2, 2, w-4, h-4 );
			_bg.graphics.endFill();
			_bg.alpha = 0;
			
			addChild( _txf = UIFactory.createTextField(_text = text) );
			_txf.autoSize = TextFieldAutoSize.NONE;
			_txf.width = w; _txf.height = h;
			_txf.htmlText = '<p class="'+ _style +'">'+ text +'</p>';
		}
		
		
		override public function update():void
		{
			if ( _locked ) return;
			
			var t:int = FADE_SPEED - (_timer - getTimer());
			if ( t <= FADE_SPEED ) {
				if ( _isHover )
					_bg.alpha = Sine.easeOut( t, 0, 1, FADE_SPEED );
				else
					_bg.alpha = Sine.easeIn( t, 1, -1, FADE_SPEED );
			} else {
				_bg.alpha = _isHover? 1: 0;
			}
			
		}
		
		
		override public function unlock():void
		{
			_locked = false;
			enable();
			
			if ( _bg.alpha != (_isHover?1:0) )
				_timer = getTimer() +FADE_SPEED;
		}
		
		override public function disable():void
		{
			super.disable();
			
			if ( !_locked )
				_txf.htmlText = '<p class="'+ _style +'"><span class="'+ _style +'_inactive">'+ _text +'</span></p>';
			else
				_txf.htmlText = '<p class="'+ _style +'"><span class="'+ _style +'_down">'+ _text +'</span></p>';
		}
		
		override public function enable():void
		{
			super.enable();
			
			if ( !_locked )
				_txf.htmlText = '<p class="'+ _style +'">'+ _text +'</p>';
			else
				_txf.htmlText = '<p class="'+ _style +'"><span class="'+ _style +'_inactive">'+ _text +'</span></p>';
		}
		
		
		public function applyTextFilter( filters:Array ):void
		{
			_txf.filters = filters;
		}
		
		
			// -- private --
			
			protected var _bg:Shape, _txf:TextField, _text:String, _style:String
			protected var _timer:uint
			
			override protected function _movr( e:Event ):void
			{
				super._movr( e );
				
				if ( !_locked ) {
					_timer = getTimer() +FADE_SPEED;
					_txf.htmlText = '<p class="'+ _style +'"><span class="'+ _style +'_down">'+ _text +'</span></p>';
				}
			}
			
			override protected function _mout( e:Event ):void
			{
				super._mout( e );
				
				if ( !_locked ) {
					_timer = getTimer() +FADE_SPEED;
					_txf.htmlText = '<p class="'+ _style +'">'+ _text +'</p>';
				}
			}
			
			
	}

}