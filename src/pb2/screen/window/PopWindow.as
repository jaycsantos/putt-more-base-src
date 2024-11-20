package pb2.screen.window 
{
	import com.jaycsantos.display.animation.AnimationTiming;
	import com.jaycsantos.game.IGameObject;
	import com.jaycsantos.util.DisplayKit;
	import com.jaycsantos.util.GameLoop;
	import com.jaycsantos.util.ns.internalGameloop;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.osflash.signals.Signal;
	import pb2.util.pb2internal;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PopWindow extends Window
	{
		public static const PLAY:String = 'play', END:String = 'end'
		
		public function PopWindow() 
		{
			name = 'PopWindow';
			
			addChild( _overlay = new Sprite );
			_overlay.name = 'overlay';
			_overlay.graphics.beginFill( 0, .8 );
			_overlay.graphics.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			_overlay.graphics.endFill();
			
			addChild( _bg = new Sprite );
			addChild( _bgBmp = new Bitmap );
			addChild( _contents = new Sprite );
			_bgClip = new Sprite;
			
			_animator = new AnimationTiming( [1], 1, 1, false );
			
			addEventListener( Event.ADDED_TO_STAGE, _init, false, 0, true );
		}
		
		override public function update():void
		{
			if ( _animator.isPlaying ) {
				_animator.update();
				if ( _animator.setName == PLAY )
					_overlay.alpha = _animator.index/_animator.length;
				else if ( _animator.setName == END )
					_overlay.alpha = 1 -_animator.index/_animator.length;
			}
			
		}
		
		override public function show():void
		{
			if ( stage ) stage.focus = stage;
			onPreShow.dispatch();
			
			visible = true;
			_overlay.alpha = 0;
			_contents.visible = _bgBmp.visible = false;
			_animator.playSet( PLAY );
		}
		
		override public function hide():void
		{
			if ( !visible ) return;
			
			onPreHide.dispatch();
			
			_contents.visible = _bgBmp.visible = false;
			_clip.filters = [];
			_animator.playSet( END );
		}
		
			// -- private --
			
			protected var _bg:Sprite, _bgClip:Sprite, _bgBmp:Bitmap, _contents:Sprite, _overlay:Sprite
			protected var _clip:MovieClip, _animator:AnimationTiming
			
			protected function _init( e:Event ):void
			{
				removeEventListener( Event.ADDED_TO_STAGE, _init );
				
				{//-- draw
					var rect:Rectangle = _bgClip.getBounds( this );
					// use local, this is global
					if ( _bgClip.stage ) {
						var loc:Point = _bgClip.localToGlobal( new Point );
						rect.x -= loc.x;
						rect.y -= loc.y;
					}
					
					var x:int = Math.floor(rect.x), y:int = Math.floor(rect.y);
					var w:int = Math.ceil(rect.right)-x, h:int = Math.ceil(rect.bottom)-y;
					
					if ( _bgClip.numChildren && w && h ) {
						var bd:BitmapData = _bgBmp.bitmapData = new BitmapData( w, h, true, 0 );
						var m:Matrix = _bgClip.transform.matrix.clone();
						m.translate( -x, -y );
						bd.draw( _bgClip, m, _bgClip.transform.colorTransform, _bgClip.blendMode );
						_bgBmp.x = _contents.x +x; _bgBmp.y = _contents.y +y;
						
					} else {
						_bgBmp.parent.removeChild( _bgBmp );
					}
				}
				
			}
			
			protected function _showContents():void
			{
				onShown.dispatch();
				
				_contents.visible = _bgBmp.visible = true;
				_overlay.alpha = 1;
				_clip.filters = [ new GlowFilter(0x191919, 1, 48, 48, 1.5) ];
			}
			
		
		
	}

}