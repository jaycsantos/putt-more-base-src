package pb2.screen.ui 
{
	import com.jaycsantos.game.IGameObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Pb2Btn extends Sprite implements IGameObject
	{
		
		public function Pb2Btn() 
		{
			buttonMode = true;
			mouseChildren = false;
			tabEnabled = tabChildren = false;
			
			addEventListener( FocusEvent.FOCUS_IN, _movr, false, 0, true );
			addEventListener( MouseEvent.MOUSE_OVER, _movr, false, 0 , true );
			addEventListener( FocusEvent.FOCUS_OUT, _mout, false, 0, true );
			addEventListener( MouseEvent.MOUSE_OUT, _mout, false, 0 , true );
			
			addEventListener( MouseEvent.MOUSE_DOWN, _md, false, 0 , true );
			addEventListener( MouseEvent.MOUSE_UP, _mu, false, 0 , true );
		}
		
		public function dispose():void
		{
			if ( parent ) parent.removeChild( this );
			
			removeEventListener( FocusEvent.FOCUS_IN, _movr );
			removeEventListener( MouseEvent.MOUSE_OVER, _movr );
			removeEventListener( FocusEvent.FOCUS_OUT, _mout );
			removeEventListener( MouseEvent.MOUSE_OUT, _mout );
			removeEventListener( MouseEvent.MOUSE_DOWN, _md );
			removeEventListener( MouseEvent.MOUSE_UP, _mu );
		}
		
		
		public function update():void
		{
			
		}
		
		
		public function lock():void
		{
			_locked = true;
			disable();
		}
		
		public function unlock():void
		{
			_locked = false;
			enable();
		}
		
		public function disable():void
		{
			_disabled = true;
			_isHover = _isDown = mouseEnabled = !_disabled;
			
		}
		
		public function enable():void
		{
			_disabled = _locked;
			mouseEnabled = !_disabled;
		}
		
		
		public function get isHovered():Boolean
		{
			return _isHover;
		}
		
		
			// -- private --
			
			protected var _isHover:Boolean, _isDown:Boolean, _locked:Boolean, _disabled:Boolean
			
			protected function _movr( e:Event ):void
			{
				_isHover = true;
			}
			
			protected function _mout( e:Event ):void
			{
				_isHover = false;
			}
			
			protected function _md( e:Event ):void
			{
				_isDown = true;
			}
			
			protected function _mu( e:Event ):void
			{
				_isDown = false;
			}
			
	}

}