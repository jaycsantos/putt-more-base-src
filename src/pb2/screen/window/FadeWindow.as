package pb2.screen.window 
{
	import com.demonsters.debugger.MonsterDebugger;
	import com.greensock.easing.*;
	import com.jaycsantos.display.Cache4Bmp;
	import com.jaycsantos.util.ColorMatrixUtil;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class FadeWindow extends Window 
	{
		
		public function FadeWindow() 
		{
			super();
			
			addChild( _bmp = new Bitmap );
			addChild( _canvas = new Sprite );
			
			_canvas.name = 'canvas'; _canvas.visible = false;
			_canvas.addChild( _contents = new Sprite );
			_contents.name = 'contents';
			_canvas.graphics.beginFill( 0, .8 );
			_canvas.graphics.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			
			_cache = new Cache4Bmp( true, false, false, true );
		}
		
		
		override public function update():void 
		{
			switch( _state ) {
				case f_IDLE:
					break;
				case f_UPDATING:
					_update();
					break;
				case f_ENTERING:
					if ( !_entering() ) {
						_state = f_UPDATING;
						onShown.dispatch();
					}
					break;
				case f_EXITING:
					if ( !_exiting() ) {
						_state = f_IDLE;
						onHidden.dispatch();
					}
					break;
			}
		}
		
		
		override public function show():void 
		{
			if ( stage ) stage.focus = stage;
			onPreShow.dispatch();
			
			visible = true;
			_startTime = getTimer() +_fadeEnterDur;
			_state = f_ENTERING;
			
			_cache.bitmapData = new BitmapData( PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT, true, 0 );
			_cache.bitmapData.draw( _canvas );
			
			_bmp.bitmapData = _cache.bitmapData.clone();
			_bmp.visible = true;
		}
		
		override public function hide():void 
		{
			onPreHide.dispatch();
			
			_startTime = getTimer() +_fadeExitDur;
			_state = f_EXITING;
			
			_canvas.visible = false;
			_cache.bitmapData = new BitmapData( PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT, true, 0 );
			_cache.bitmapData.draw( _canvas );
			
			_bmp.bitmapData = _cache.bitmapData.clone();
			_bmp.visible = true;
		}
		
		
			// -- private --
			
			private static const f_IDLE:uint=0, f_ENTERING:uint=2, f_EXITING:uint=4, f_UPDATING:uint=1
			
			protected var _fadeEnterDur:uint = 200;
			protected var _fadeExitDur:uint = 180;
			
			protected var _canvas:Sprite, _contents:Sprite
			private var _state:uint, _startTime:uint, _cache:Cache4Bmp, _bmp:Bitmap
			
			
			protected function _update():void
			{
				
			}
			
			
			protected function _entering():Boolean
			{
				var dur:uint = _fadeEnterDur;
				var t:int = dur -(_startTime -getTimer());
				
				if ( t < dur ) {
					var s:Number = Sine.easeOut( t, -100, 100, dur );
					_cache.colorTrnsfrm.alphaMultiplier = Sine.easeIn( t, 0, 1, dur );
					
					var bmp:BitmapData = _bmp.bitmapData;
					bmp.lock();
					bmp.applyFilter( _cache.bitmapData, bmp.rect, _cache.point, ColorMatrixUtil.setSaturation(s) );
					bmp.colorTransform( bmp.rect, _cache.colorTrnsfrm );
					bmp.unlock();
					
					return true;
				}
				
				_canvas.visible = true;
				
				_bmp.visible = false;
				_bmp.bitmapData.dispose(); _bmp.bitmapData = null;
				_cache.bitmapData.dispose(); _cache.bitmapData = null;
				
				return false;
			}
			
			protected function _exiting():Boolean
			{
				var dur:uint = _fadeEnterDur;
				var t:int = dur -(_startTime -getTimer());
				
				if ( t < dur ) {
					var s:Number = Sine.easeIn( t, 0, 100, dur );
					_cache.colorTrnsfrm.alphaMultiplier = Sine.easeOut( t, 1, -1, dur );
					
					var bmp:BitmapData = _bmp.bitmapData;
					bmp.lock();
					bmp.applyFilter( _cache.bitmapData, bmp.rect, _cache.point, ColorMatrixUtil.setSaturation(s) );
					bmp.colorTransform( bmp.rect, _cache.colorTrnsfrm );
					bmp.unlock();
					
					return true;
				}
				
				_bmp.visible = false;
				_bmp.bitmapData.dispose(); _bmp.bitmapData = null;
				_cache.bitmapData.dispose(); _cache.bitmapData = null;
				
				return false;
			}
			
			
	}

}