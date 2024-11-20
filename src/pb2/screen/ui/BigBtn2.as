package pb2.screen.ui 
{
	import com.greensock.easing.Quad;
	import com.greensock.easing.Sine;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class BigBtn2 extends Pb2Btn 
	{
		public static const FADE_DUR:uint = 100
		
		public function BigBtn2( text:String, w:uint=90 ) 
		{
			super();
			
			addChild( _bg = new Shape );
			_bg.graphics.beginFill( 0x191919 );
			_bg.graphics.drawRect( 0, 0, w, 25 );
			_bg.graphics.endFill();
			_bg.graphics.beginFill( 0xB29300 );
			_bg.graphics.drawRect( 2, 2, w -15 -4, 21 );
			
			addChild( _bg2 = new Shape );
			_bg2.x = w -2;
			_bg2.graphics.beginFill( 0xB29300 );
			_bg2.graphics.drawRect( -13, 2, 13, 21 );
			_bg2.graphics.endFill();
			
			addChild( _bgDisabled = new Shape );
			_bgDisabled.graphics.beginFill( 0x666666 );
			_bgDisabled.graphics.drawRect( 0, 0, w, 25 );
			_bgDisabled.graphics.endFill();
			_bgDisabled.graphics.beginFill( 0xB2A98E );
			_bgDisabled.graphics.drawRect( 2, 2, w -15 -4, 21 );
			_bgDisabled.graphics.drawRect( w -13 -2, 2, 13, 21 );
			_bgDisabled.graphics.endFill();
			_bgDisabled.graphics.beginFill( 0x666666 );
			_bgDisabled.graphics.drawTriangles( Vector.<Number>([w-12,7,w-5,13,w-12,19]) );
			_bgDisabled.graphics.endFill();
			_bgDisabled.visible = false;
			
			addChild( _bg3 = new Shape );
			_bg3.graphics.beginFill( 0x191919 );
			_bg3.graphics.drawTriangles( Vector.<Number>([w-12,7,w-5,13,w-12,19]) );
			_bg3.graphics.endFill();
			
			addChild( _txf = UIFactory.createTextField(_text = text, 'btn2', 'none') );
			_txf.x = 5;
			_txf.width = w -27; _txf.height = 25;
		}
		
		override public function update():void
		{
			if ( _locked ) return;
			
			var b:Number, clrXfrm:ColorTransform, t:int = FADE_DUR - (_timer - getTimer());
			if ( t <= FADE_DUR ) {
				b = _isHover? Quad.easeIn(t, 1, -1, FADE_DUR): Quad.easeIn(t, 0, 1, FADE_DUR);
				
				clrXfrm = _bg2.transform.colorTransform;
				clrXfrm.redOffset = clrXfrm.greenOffset = clrXfrm.blueOffset = 25 *(1-b);
				clrXfrm.redMultiplier = clrXfrm.greenMultiplier = clrXfrm.blueMultiplier = b;
				_bg2.transform.colorTransform = clrXfrm;
				_bg2.width = 13 +(_bg.width-13-4)*(1-b);
				
				clrXfrm = _bg3.transform.colorTransform;
				clrXfrm.redOffset = clrXfrm.greenOffset = clrXfrm.blueOffset = 204 *(1-b);
				clrXfrm.redMultiplier = clrXfrm.greenMultiplier = clrXfrm.blueMultiplier = b;
				_bg3.transform.colorTransform = clrXfrm;
				
				_dirty = true;
			} else
			if ( _dirty ) {
				b = _isHover? 0: 1;
				
				clrXfrm = _bg2.transform.colorTransform;
				clrXfrm.redOffset = clrXfrm.greenOffset = clrXfrm.blueOffset = 25 *(1-b);
				clrXfrm.redMultiplier = clrXfrm.greenMultiplier = clrXfrm.blueMultiplier = b;
				_bg2.transform.colorTransform = clrXfrm;
				_bg2.width = 13 +(_bg.width-13-4)*(1-b);
				
				clrXfrm = _bg3.transform.colorTransform;
				clrXfrm.redOffset = clrXfrm.greenOffset = clrXfrm.blueOffset = 204 *(1-b);
				clrXfrm.redMultiplier = clrXfrm.greenMultiplier = clrXfrm.blueMultiplier = b;
				_bg3.transform.colorTransform = clrXfrm;
				
				_dirty = false;
			}
			
		}
		
		
		override public function disable():void 
		{
			super.disable();
			
			if ( _disabled ) {
				_bg.visible = _bg2.visible = _bg3.visible = false;
				_bgDisabled.visible = true;
				_txf.htmlText = '<p class="btn2"><span class="c0x666">'+ _text +'</span></p>';
			} else {
				_bg.visible = _bg2.visible = _bg3.visible = true;
				_bgDisabled.visible = false;
				_txf.htmlText = '<p class="btn2">'+ _text +'</p>';
			}
		}
		
		override public function enable():void 
		{
			super.enable();
			
			_dirty = true;
			_timer = getTimer() -FADE_DUR;
			
			if ( _disabled ) {
				_bg.visible = _bg2.visible = _bg3.visible = false;
				_bgDisabled.visible = true;
				_txf.htmlText = '<p class="btn2"><span class="c0x666">'+ _text +'</span></p>';
			} else {
				_bg.visible = _bg2.visible = _bg3.visible = true;
				_bgDisabled.visible = false;
				_txf.htmlText = '<p class="btn2">'+ _text +'</p>';
			}
		}
		
		
			// -- private --
			
			protected var _bg:Shape, _bg2:Shape, _bg3:Shape, _bgDisabled:Shape, _txf:TextField, _text:String, _dirty:Boolean = true
			protected var _timer:uint
			
			override protected function _movr(e:Event):void 
			{
				super._movr(e);
				if ( !_locked ) {
					_timer = getTimer() +FADE_DUR;
					_txf.htmlText = '<p class="btn2"><span class="c0xCCC">'+ _text +'</span></p>';
				}
			}
			
			override protected function _mout(e:Event):void 
			{
				super._mout(e);
				if ( !_locked ) {
					_timer = getTimer() +FADE_DUR;
					_txf.htmlText = '<p class="btn2">'+ _text +'</p>';
				}
			}
			
			
	}

}