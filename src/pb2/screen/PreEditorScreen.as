package pb2.screen 
{
	import com.demonsters.debugger.MonsterDebugger;
	import com.greensock.easing.Quad;
	import com.jaycsantos.display.Cache4Bmp;
	import com.jaycsantos.display.screen.AbstractScreen;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.util.ColorMatrixUtil;
	import com.jaycsantos.util.GameLoop;
	import flash.display.BitmapData;
	import pb2.game.Registry;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PreEditorScreen extends AbstractScreen 
	{
		
		public function PreEditorScreen( root:GameRoot, data:Object=null )
		{
			super( root, data );
			
			_canvas.visible = false;
			
			_bmpD = new BitmapData( PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT, true, 0 );
			_cache = new Cache4Bmp( true, false, false, true );
			_cache.bitmapData = _bmpD.clone();
			
			
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			
		}
		
		
		override public function update():void 
		{
			super.update();
			
			
		}
		
		
			// -- private --
			
			private var _cache:Cache4Bmp, _timer:uint, _bmpD:BitmapData
			
			override protected function _onPreEnter():Boolean 
			{
				_cache.bitmapData.draw( _canvas, _canvas.transform.matrix, _canvas.transform.colorTransform );
				_canvas.visible = false;
				_timer = GameLoop.instance.time +Registry.PreEditorScreen_ENTER_DUR;
				
				LoadingOverlay.prepare( 0x665D56 );
				LoadingOverlay.instance.bitmap.bitmapData = _bmpD;
				
				return true;
			}
			
			override protected function _onPreExit():void 
			{
				
			}
			
			override protected function _doWhileEntering():Boolean 
			{
				var dur:uint = Registry.PreEditorScreen_ENTER_DUR;
				var t:int = dur - (_timer - GameLoop.instance.time);
				var s:Number = t<dur? Quad.easeIn( t, -100, 100, dur ) :0;
				_cache.colorTrnsfrm.alphaMultiplier = (100+s)/100;
				
				_bmpD.applyFilter( _cache.bitmapData, _bmpD.rect, _cache.point, ColorMatrixUtil.setSaturation(s) );
				_bmpD.colorTransform( _bmpD.rect, _cache.colorTrnsfrm );
				
				if ( t < dur )
					return true;
				
				LoadingOverlay.dismiss();
				_canvas.visible = true;
				
				return false;
			}
			
			override protected function _doWhileExiting():Boolean 
			{
				return super._doWhileExiting();
			}
			
			
			
	}

}