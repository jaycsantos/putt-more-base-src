package pb2.screen.window 
{
	import com.demonsters.debugger.MonsterDebugger;
	import com.greensock.easing.*;
	import com.jaycsantos.display.Cache4Bmp;
	import com.jaycsantos.game.IGameObject;
	import com.jaycsantos.util.*;
	import flash.display.*;
	import flash.events.Event;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.*;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import org.osflash.signals.Signal;
	import pb2.util.pb2internal;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Pb2Window2 extends Window
	{
		public static const f_IDLE:uint = 0
		public static const f_ENTERING:uint = 2
		public static const f_EXITING:uint = 4
		public static const f_UPDATING:uint = 1
		
		public static const MARGIN_TOP:uint = 12;
		public static const MARGIN_BOTTOM:uint = 20;
		public static const MARGIN_LEFT:uint = 25;
		public static const MARGIN_RIGHT:uint = 25;
		
		public var fadeEnterDur:uint = 200;
		public var fadeExitDur:uint = 160;
		
		
		public function Pb2Window2()
		{
			super();
			name = 'pb2window2';
			
			addChild( _overlay = new Sprite );
			_overlay.name = 'overlay';
			_overlay.graphics.beginFill( 0, .7 );
			_overlay.graphics.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			_overlay.graphics.endFill();
			
			addChild( _canvas = new Sprite );
			_canvas.name = 'canvas'; _canvas.mouseEnabled = false;
			_canvas.addChild( _bgBmp = new Bitmap );
			_canvas.addChild( _contents = new Sprite );
			
			_contents.name = 'contents';
			_contents.mouseEnabled = _contents.tabEnabled = false;
			
			_bg = new Sprite;
			//_overlay.addChild( _bgClip = new Sprite );
			_bg.addChild( _bgClip = new Sprite );
			_bgClip.addChild( _bg2 = PuttBase2.assets.createDisplayObject('screen.window.bg2') as Sprite );
			_bgClip.filters = [ new GlowFilter(0x191919, 1, 48, 48, 1.5) ];
			
			
			_cache = new Cache4Bmp( true, false, false, true );
			addChild( _cacheBmp = new Bitmap );
			_cacheBmp.name = 'cached bmp';
			
			
			addEventListener( Event.ADDED_TO_STAGE, _init, false, 0, true );
		}
		
		override public function dispose():void
		{
			if ( _bgBmp.bitmapData )
				_bgBmp.bitmapData.dispose();
			
			super.dispose();
		}
		
		
		override public function update():void
		{
			use namespace pb2internal;
			switch( _state ) {
				case f_IDLE:
					break;
				case f_UPDATING:
					_update();
					break;
				case f_EXITING:
					if ( !_doWhileExiting() ) {
						_state = f_IDLE;
						onHidden.dispatch();
					}
					break;
				case f_ENTERING:
					if ( !_doWhileEntering() ) {
						_state = f_UPDATING;
						onShown.dispatch();
					}
			}
		}
		
		override public function show():void
		{
			if ( stage ) stage.focus = stage;
			
			use namespace pb2internal;
			if ( _state == f_IDLE && _onPreEnter() ) {
				_state = f_ENTERING;
			}
			
		}
		
		override public function hide():void
		{
			use namespace pb2internal;
			if ( _state == f_UPDATING ) {
				_onPreExit();
				_state = f_EXITING;
			}
			
		}
		
		
		
		
			protected var _canvas:Sprite, _bg:Sprite, _bgBmp:Bitmap, _bgClip:Sprite, _bg2:Sprite, _contents:Sprite, _overlay:Sprite
			
			protected function _init( e:Event ):void
			{
				removeEventListener( Event.ADDED_TO_STAGE, _init );
			}
			
			protected function _update():void
			{
				
			}
			
			
			//{ -- transition
			pb2internal var _state:uint
			protected var _cache:Cache4Bmp, _timer:uint, _cacheBmp:Bitmap
			
			protected function _onPreEnter():Boolean
			{
				onPreShow.dispatch();
				
				var _empty:Shape = new Shape, _emptyPt:Point = new Point;
				var rect:Rectangle = _bg.getBounds( _empty );
				if ( _bg.stage ) { // use local, this is global
					var loc:Point = _bg.localToGlobal( _emptyPt );
					rect.x -= loc.x; rect.y -= loc.y;
				}
				// HAX to cope with a Filter
				if ( _bgClip.filters.length ) {
					rect.left -= 24; rect.top -= 24;
					rect.right += 24; rect.bottom += 24;
				}
				
				var x:int = Math.max( 0, rect.x >>0 ), y:int = Math.max( 0, rect.y >>0 );
				var w:int = Math.min( Math.ceil(rect.right)-x, PuttBase2.STAGE_WIDTH ), h:int = Math.min( Math.ceil(rect.bottom)-y, PuttBase2.STAGE_HEIGHT );
				var m:Matrix = _bg.transform.matrix.clone();
				m.translate( -x, -y );
				
				_bgBmp.bitmapData = new BitmapData( w, h, true, 0 );
				_bgBmp.bitmapData.draw( _bg, m );
				_bgBmp.x = x; _bgBmp.y = y;
				
				var i:int = _bgClip.numChildren;
				while ( i-- ) _bgClip.removeChildAt( i );
				_bg = null;
				
				_cache.bitmapData = new BitmapData( PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT, true, 0 );
				_cacheBmp.bitmapData = _cache.bitmapData.clone();
				
				_cache.bitmapData.draw( _canvas, _canvas.transform.matrix );
				_canvas.visible = false;
				visible = _cacheBmp.visible = true;
				_overlay.alpha = 0;
				
				_timer = getTimer() +fadeEnterDur;
				
				return true;
			}
			
			protected function _onPreExit():void
			{
				onPreHide.dispatch();
				
				_cache.bitmapData = new BitmapData( PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT, true, 0 );
				_cacheBmp.bitmapData = _cache.bitmapData.clone();
				
				_cache.bitmapData.draw( _canvas, _canvas.transform.matrix );
				_canvas.visible = false;
				_cacheBmp.visible = true;
				_overlay.alpha = 1;
				
				_timer = GameLoop.instance.time +fadeExitDur;
				
			}
			
			protected function _doWhileEntering():Boolean
			{
				var dur:uint = fadeEnterDur;
				var t:int = dur -(_timer -getTimer());
				
				if ( t < dur ) {
					var s:Number = Sine.easeOut( t, -100, 100, dur );
					_cache.colorTrnsfrm.alphaMultiplier = (100+s)/100;
					
					var bmp:BitmapData = _cacheBmp.bitmapData;
					bmp.lock();
					//bmp.applyFilter( _cache.bitmapData, bmp.rect, _cache.point, ColorMatrixUtil.setSaturation(s) );
					bmp.applyFilter( _cache.bitmapData, bmp.rect, _cache.point, new BlurFilter(Linear.easeIn(t,4,-4,dur), Linear.easeIn(t,4,-4,dur), 1) );
					bmp.colorTransform( bmp.rect, _cache.colorTrnsfrm );
					bmp.unlock();
					_overlay.alpha = Sine.easeInOut( t, 0, 1, dur );
					
					return true;
					
				} else {
					_overlay.alpha = 1;
					_canvas.visible = true;
					_cache.bitmapData.dispose();
					_cacheBmp.visible = false;
					_cacheBmp.bitmapData.dispose();
					
					return false;
				}
				
			}
			
			protected function _doWhileExiting():Boolean
			{
				var dur:uint = fadeExitDur;
				var t:int = dur -(_timer -getTimer());
				
				if ( t < dur ) {
					var s:Number = Quad.easeIn( t, 0, -100, dur );
					_cache.colorTrnsfrm.alphaMultiplier = (100+s)/100;
					
					var bmp:BitmapData = _cacheBmp.bitmapData;
					bmp.lock();
					//bmp.applyFilter( _cache.bitmapData, bmp.rect, _cache.point, ColorMatrixUtil.setSaturation(s) );
					bmp.applyFilter( _cache.bitmapData, bmp.rect, _cache.point, new BlurFilter(Linear.easeIn(t,0,4,dur), Linear.easeIn(t,0,4,dur), 1) );
					bmp.colorTransform( bmp.rect, _cache.colorTrnsfrm );
					bmp.unlock();
					_overlay.alpha = Linear.easeIn( t, 1, -1, dur );
					
					return true;
					
				} else {
					_canvas.visible = true;
					_cache.bitmapData.dispose();
					visible = _cacheBmp.visible = false;
					_cacheBmp.bitmapData.dispose();
					_bgBmp.bitmapData.dispose();
					
					return false;
				}
				
			}
			//}
			
			
	}

}