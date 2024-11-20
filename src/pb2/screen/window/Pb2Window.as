package pb2.screen.window 
{
	import com.jaycsantos.game.IGameObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import org.osflash.signals.Signal;
	import pb2.screen.ui.UIFactory;
	import pb2.util.pb2internal;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Pb2Window extends Sprite implements IGameObject
	{
		use namespace pb2internal
		
		public static const f_IDLE:uint = 0
		public static const f_ENTERING:uint = 2
		public static const f_EXITING:uint = 4
		public static const f_UPDATING:uint = 1
		
		public var onShown:Signal, onHidden:Signal
		
		
		public function Pb2Window( title:String ) 
		{
			name = 'pb2window';
			visible = tabEnabled = mouseEnabled = false;
			
			addChild( _overlay = new Sprite );
			addChild( _bgClip = PuttBase2.assets.createDisplayObject('screen.window.bg') as Sprite );
			addChild( _title = UIFactory.createTextField(title, 'windowTitle', 'left') );
			addChild( _icon = new Sprite );
			addChild( _contents = new Sprite );
			
			
			_bgClip.name = 'bgClip';
			_bgClip.mouseEnabled = _bgClip.tabEnabled = false;
			
			_overlay.name = 'back overlay';
			_overlay.graphics.beginFill( 0, .25 );
			_overlay.graphics.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			_overlay.graphics.endFill();
			
			_title.name = 'title';
			_title.mouseEnabled = _title.tabEnabled = false;
			
			_icon.name = 'icon';
			_icon.visible = false;
			
			_contents.name = 'contents';
			_contents.x = 10; _contents.y = 17;
			_contents.mouseEnabled = _contents.tabEnabled = false;
			
			onShown = new Signal;
			onHidden = new Signal;
		}
		
		public function dispose():void
		{
			mouseChildren = tabChildren = false;
		}
		
		
		final public function update():void
		{
			if ( _state == f_IDLE ) {
			
			} else
			if ( _state == f_UPDATING ) {
				_update();
			} else
			if ( _state == f_EXITING ) {
				if ( !_doWhileExiting() ) {
					_state = f_IDLE;
					onHidden.dispatch();
				}
			} else
			if ( _state == f_ENTERING ) {
				if ( !_doWhileEntering() ) {
					_state = f_UPDATING;
					onShown.dispatch();
				}
			}
			
		}
		
		final public function show():Boolean
		{
			if ( _state == f_IDLE && _onPreEnter() )
				return Boolean( _state = f_ENTERING );
			else if ( _state == f_EXITING )
				onHidden.addOnce( show );
				
			return false;
		}
		
		final public function hide():Boolean
		{
			if ( _state == f_UPDATING ) {
				_onPreExit();
				return Boolean( _state = f_EXITING );
			} else if ( _state == f_ENTERING )
				onShown.addOnce( hide );
			
			return false;
		}
		
		
			// -- private --
			
			pb2internal var _bgClip:Sprite, _title:TextField, _contents:Sprite, _overlay:Sprite, _icon:Sprite
			private var _state:uint
			
			protected function _update():void
			{
				
			}
			
			protected function _resize():void
			{
				_overlay.x = -x;
				_overlay.y = -y;
				
				_bgClip.width = Math.max(_contents.width +20, _icon.width +_title.width) <<0;
				_bgClip.height = _contents.height +25 <<0;
				
				_icon.x = 5;
				_title.x = _icon.x +_icon.width;
			}
			
			
			protected function _onPreEnter():Boolean
			{
				return true;
			}
			
			protected function _onPreExit():void
			{
				
			}
			
			protected function _doWhileEntering():Boolean
			{
				visible = true;
				return false;
			}
			
			protected function _doWhileExiting():Boolean
			{
				visible = false;
				return false;
			}
			
			
	}

}