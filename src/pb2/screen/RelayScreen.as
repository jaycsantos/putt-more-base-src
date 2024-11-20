package pb2.screen 
{
	import com.greensock.easing.Quad;
	import com.jaycsantos.display.Cache4Bmp;
	import com.jaycsantos.display.screen.AbstractScreen;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.util.ColorMatrixUtil;
	import com.jaycsantos.util.GameLoop;
	import flash.display.BitmapData;
	import pb2.game.ctrl.MapImport;
	import pb2.game.Session;
	import pb2.util.pb2internal;
	
	/**
	 * ...
	 * @author ...
	 */
	public class RelayScreen extends AbstractScreen 
	{
		public static const FADE_ENTER_DUR:uint = 200
		public static const FADE_EXIT_DUR:uint = 200
		
		public var nextScreen:Class
		
		
		public function RelayScreen( root:GameRoot, data:Object=null ) 
		{
			super( root, data );
			
			_bmpD = new BitmapData( PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT, true, 0 );
			_cache = new Cache4Bmp( true, false, false, true );
			_cache.bitmapData = _bmpD.clone();
			
			_canvas.graphics.beginFill( 0x191919 );
			_canvas.graphics.drawRect( 0, 0, _bmpD.width, _bmpD.height );
			
			if ( data )
				nextScreen = data as Class;
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			_cache.bitmapData.dispose(); _cache = null;
			_bmpD.dispose(); _bmpD = null;
		}
		
		
			// -- private --
			
			//{ -- transitions
			private var _cache:Cache4Bmp, _timer:uint, _bmpD:BitmapData
			
			override protected function _onPreEnter():Boolean 
			{
				_cache.bitmapData.draw( _canvas, _canvas.transform.matrix, _canvas.transform.colorTransform );
				_canvas.visible = false;
				_timer = GameLoop.instance.time +FADE_ENTER_DUR;
				
				_bmpD.fillRect( _bmpD.rect, 0x191919 );
				LoadingOverlay.prepare( 0x191919 );
				LoadingOverlay.instance.bitmap.bitmapData = _bmpD;
				
				return true;
			}
			
			override protected function _onPreExit():void 
			{
				_cache.bitmapData.draw( _canvas, _canvas.transform.matrix, _canvas.transform.colorTransform );
				_canvas.visible = false;
				_timer = GameLoop.instance.time +FADE_EXIT_DUR;
				
				_bmpD.fillRect( _bmpD.rect, 0x191919 );
				LoadingOverlay.prepare( 0x191919 );
				LoadingOverlay.instance.bitmap.bitmapData = _bmpD;
				
				Session.instance.clean();
			}
			
			override protected function _doWhileEntering():Boolean 
			{
				var dur:uint = FADE_ENTER_DUR;
				var t:int = dur - (_timer - GameLoop.instance.time);
				var s:Number = t<dur? Quad.easeIn( t, -100, 100, dur ) :0;
				_cache.colorTrnsfrm.alphaMultiplier = (100+s)/100;
				
				_bmpD.lock();
				_bmpD.applyFilter( _cache.bitmapData, _bmpD.rect, _cache.point, ColorMatrixUtil.setSaturation(s) );
				_bmpD.colorTransform( _bmpD.rect, _cache.colorTrnsfrm );
				//LoadingOverlay.instance.bitmap.filters = [new BlurFilter(
				_bmpD.unlock();
				
				if ( t < dur )
					return true;
				
				LoadingOverlay.dismiss();
				_canvas.visible = true;
				
				if ( nextScreen )
					GameRoot.changeScreen( nextScreen );
				
				return false;
			}
			
			override protected function _doWhileExiting():Boolean 
			{
				var dur:uint = FADE_EXIT_DUR;
				var t:int = dur - (_timer - GameLoop.instance.time);
				var s:Number = t<dur? Quad.easeOut( t, 0, -100, dur ) :-100;
				_cache.colorTrnsfrm.alphaMultiplier = (100+s)/100;
				
				_bmpD.lock();
				_bmpD.applyFilter( _cache.bitmapData, _bmpD.rect, _cache.point, ColorMatrixUtil.setSaturation(s) );
				_bmpD.colorTransform( _bmpD.rect, _cache.colorTrnsfrm );
				_bmpD.unlock();
				
				if ( t < dur )
					return true;
				
				return false;
			}
			//}
			
	}

}