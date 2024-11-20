package pb2.screen 
{
	import com.greensock.easing.Quad;
	import com.jaycsantos.display.Cache4Bmp;
	import com.jaycsantos.display.screen.AbstractScreen;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.util.ColorMatrixUtil;
	import com.jaycsantos.util.GameLoop;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import mx.utils.Base64Encoder;
	import pb2.game.MapData;
	import pb2.game.Session;
	import pb2.screen.window.MapErrorWindow;
	import pb2.util.Short;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class MapErrorScreen extends AbstractScreen 
	{
		public static const FADE_EXIT_DUR:uint = 1200
		
		public function MapErrorScreen( root:GameRoot, data:Object ) 
		{
			super( root, data );
			
			_canvas.graphics.beginFill( 0x191919 );
			_canvas.graphics.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			
			var s:String, error:Error = data as Error;
			var map:MapData = Session.instance.map;
			var ba:ByteArray = new ByteArray();
			var b64:Base64Encoder =  new Base64Encoder();
			
			ba.writeUTF( s = 'hash:'+ map.hash +'\nhash:'+ map.name +'\ncustom:'+ (map.isCustom?1:0) +'\n\n'+ error.getStackTrace() );
			
			CONFIG::release {
				ba.deflate();
				b64.encode( ba.toString() );
				
				erStr = error.name +'[' + error.errorID +'] '+ map.hash + b64.toString().replace(RegExp(/-/g), '/').replace(RegExp(/A/g), '=').replace(RegExp(/_/g), 'A');
			}
			CONFIG::debug {
				erStr = s;
			}
			
			_bmpD = new BitmapData( PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT, true, 0 );
			_cache = new Cache4Bmp( true, false, false, true );
			_cache.bitmapData = _bmpD.clone();
		}
		
		override public function dispose():void 
		{
			if ( _erWin ) _erWin.dispose();
			_erWin = null;
			
			super.dispose();
		}
		
		override public function update():void 
		{
			if ( _erWin ) _erWin.update();
		}
		
		
			// -- private --
			
			private var erStr:String, _erWin:MapErrorWindow
			private var _cache:Cache4Bmp, _timer:uint, _bmpD:BitmapData
			
			override protected function _doWhileEntering():Boolean 
			{
				LoadingOverlay.dismiss();
				_canvas.visible = true;
				_canvas.addChild( _erWin = new MapErrorWindow(erStr) );
				_erWin.show();
				
				return super._doWhileEntering();
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
			
			
	}

}