package pb2.screen.window 
{
	import com.jaycsantos.game.IGameObject;
	import com.jaycsantos.util.DisplayKit;
	import com.jaycsantos.util.GameLoop;
	import com.jaycsantos.util.ns.internalGameloop;
	import flash.display.Sprite;
	import flash.events.Event;
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Window extends Sprite implements IGameObject 
	{
		
		public var onPreShow:Signal, onPreHide:Signal
		public var onShown:Signal, onHidden:Signal
		public var obstrusive:Boolean
		
		public function Window() 
		{
			visible = tabEnabled = mouseEnabled = false;
			onShown = new Signal; onPreShow = new Signal;
			onHidden = new Signal; onPreHide = new Signal;
			obstrusive = true;
			
			onHidden.addOnce( dispose );
			popWindow( this );
		}
		
		public function dispose():void 
		{
			if ( stage ) stage.focus = stage;
			if ( parent ) parent.removeChild( this );
			
			if ( onPreShow ) {
				onPreShow.removeAll(); onPreShow = null;
				onPreHide.removeAll(); onPreHide = null;
				onShown.removeAll(); onShown = null;
				onHidden.removeAll(); onHidden = null;
			}
			removeWindow( this );
			visible = false;
			
			DisplayKit.removeAllChildren( this, 3 );
		}
		
		
		public function update():void 
		{
			
		}
		
		
		public function show():void
		{
			if ( stage ) stage.focus = stage;
		}
		
		public function hide():void
		{
			
		}
		
			// -- private --
			
		
		
			// -- private static
			
			public static function instanceCount():uint
			{
				var n:int = 0;
				for each ( var w:Window in _popWinMap )
					if ( w.obstrusive ) n++;
				
				return n;
			}
			
			public static function removeAllWindows():void
			{
				for each ( var p:Window in _popWinMap ) p.hide();
			}
			
			public static function disposeAllWindows():void
			{
				var i:int = _popWinMap.length;
				while ( i-- ) _popWinMap[i].dispose();
			}
			
			
			
			private static var _popWinMap:Vector.<Window> = new Vector.<Window>;
			
			internal static function popWindow( win:Window ):Window
			{
				if ( !_popWinMap.length )
					GameLoop.instance.internalGameloop::addCallback( updateWindows );
				
				_popWinMap.push( win );
				return win;
			}
			
			internal static function removeWindow( win:Window ):void
			{
				var p:int = _popWinMap.indexOf( win );
				if ( p > -1 ) _popWinMap.splice( p, 1 );
				
				if ( !_popWinMap.length )
					GameLoop.instance.internalGameloop::removeCallback( updateWindows );
			}
			
			internal static function updateWindows():void
			{
				for each ( var w:Window in _popWinMap )
					if ( w.visible ) w.update();
			}
			
			
			
	}

}