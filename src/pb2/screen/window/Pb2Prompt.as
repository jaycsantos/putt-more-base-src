package pb2.screen.window 
{
	import com.jaycsantos.game.IGameObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import pb2.screen.ui.SmallBtn1;
	import pb2.screen.ui.UIFactory;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Pb2Prompt extends Sprite implements IGameObject
	{
		
		public function Pb2Prompt( msg:String, width:uint, height:uint, btn1Txt:String, btn1Width:uint, onBtn1:Function, btn2Txt:String='', btn2Width:uint=0, onBtn2:Function=null )
		{
			addChild( _txf = UIFactory.createTextField(msg, 'promptText', 'left', 7, 4) );
			_txf.wordWrap = true;
			_txf.width = width;
			_txf.height = _txf.textHeight;
			
			addChild( _btn1 = new SmallBtn1(btn1Txt, btn1Width) );
			_btn1.addEventListener( MouseEvent.CLICK, _onBtn1 = onBtn1, false, 0, true );
			_btn1.y = _txf.y +_txf.height;
			
			if ( btn2Txt && btn2Width && onBtn2 != null ) {
				addChild( _btn2 = new SmallBtn1(btn2Txt, btn2Width) );
				_btn2.addEventListener( MouseEvent.CLICK, _onBtn2 = onBtn2, false, 0, true );
				_btn2.y = _btn1.y;
				
				if ( _txf.width > _btn1.width +_btn2.width +14 ) {
					_btn1.x = _txf.x +(_txf.width -_btn1.width -_btn2.width -14)/2;
					_btn2.x = _btn1.x +_btn1.width +14;
					
				} else {
					_btn1.x = _txf.x;
					_btn2.x = _btn1.x +_btn1.width +14;
				}
			} else {
				_btn1.x = _txf.x +(_txf.width -_btn1.width)/2;
				
			}
			
			graphics.beginFill( 0xE5E5E5 );
			graphics.lineStyle( 1.5, 0x0093B2 );
			graphics.drawRoundRect( 0, 0, _txf.x*2 +_txf.width, this.height +12, 10, 10 );
			graphics.endFill();
			filters = [new GlowFilter(0x0093B2,1,12,12,1)];
			
			x = (PuttBase2.STAGE_WIDTH -width) /2;
			y = (PuttBase2.STAGE_HEIGHT -height) /2;
			
			var overlay:Sprite;
			addChildAt( overlay = new Sprite, 0 );
			overlay.graphics.beginFill( 0, 0 );
			overlay.graphics.drawRect( -x, -y, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			overlay.mouseEnabled = true;
		}
		
		public function dispose():void
		{
			if ( parent ) parent.removeChild( this );
			
			_btn1.removeEventListener( MouseEvent.CLICK, _onBtn1 );
			if ( _btn2 )
				_btn2.removeEventListener( MouseEvent.CLICK, _onBtn2 );
		}
		
		
		public function update():void
		{
			_btn1.update();
			if ( _btn2 )
				_btn2.update();
			
		}
		
		
			// -- private --
			
			protected var _txf:TextField, _btn1:SmallBtn1, _btn2:SmallBtn1
			protected var _onBtn1:Function, _onBtn2:Function
			
	}

}