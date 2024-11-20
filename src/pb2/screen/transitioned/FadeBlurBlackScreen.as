package pb2.screen.transitioned 
{
	import com.demonsters.debugger.MonsterDebugger;
	import com.greensock.easing.*;
	import com.jaycsantos.display.screen.AbstractScreen;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.util.ColorMatrixUtil;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import pb2.screen.LoadingOverlay;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class FadeBlurBlackScreen extends AbstractScreen 
	{
		
		public function FadeBlurBlackScreen( root:GameRoot, data:Object=null )
		{
			super( root, data );
			
			
			_canvas.visible = false;
			
			_colorTransform = new ColorTransform;
			_pt = new Point;
			_bmp = new BitmapData( PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT, false, 0 );
			_snap = _bmp.clone();
			_temp1 = _bmp.clone(); _temp2 = _bmp.clone();
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			_bmp.dispose();
			_snap.dispose();
			_temp1.dispose();
			_temp2.dispose();
		}
		
		
			// -- private --
			
			private static const _stepTotal:uint = 12;
			
			private var _bmp:BitmapData, _snap:BitmapData, _step:int, _pt:Point, _colorTransform:ColorTransform
			private var _temp1:BitmapData, _temp2:BitmapData
			
			
			override protected function _onPreEnter():Boolean 
			{
				_snap.draw( _canvas, _canvas.transform.matrix, _canvas.transform.colorTransform );
				_canvas.visible = false;
				_step = 0;
				
				LoadingOverlay.prepare();
				LoadingOverlay.instance.bitmap.bitmapData = _bmp;
				
				return true;
			}
			
			override protected function _doWhileEntering():Boolean 
			{
				if ( _step % 2 == 0 ) {
					var b:Number = Sine.easeIn( Math.min(_step, _stepTotal/2), 0, 1, _stepTotal/2 );
					var s:Number = Sine.easeOut( Math.max(0, _step -_stepTotal /2), -100, 100, _stepTotal /2 );
					
					_temp1.applyFilter( _snap, _bmp.rect, _pt, new BlurFilter(100-b*100,100-b*100) );
					_temp2.applyFilter( _temp1, _bmp.rect, _pt, ColorMatrixUtil.setSaturation(s) );
					_temp2.colorTransform( _bmp.rect, new ColorTransform(b,b,b,1) );
					
					_bmp.lock();
					_bmp.copyPixels( _temp2, _bmp.rect, _pt );
					_bmp.unlock();
				}
				if ( _step++ < _stepTotal )
					return false;
				
				_canvas.visible = true;
				LoadingOverlay.dismiss();
				
				return true;
			}
			
			override protected function _onPreExit():void 
			{
				_onPreEnter();
			}
			
			override protected function _doWhileExiting():Boolean 
			{
				if ( _step %4 == 0 ) {
					var b:Number = Sine.easeOut( Math.max(0, _step -_stepTotal /2), 1, -1, _stepTotal/2 );
					//b = Sine.easeOut( _step, 1, -1, _stepTotal );
					var s:Number = Sine.easeOut( _step, 0, -100, _stepTotal );
					
					_temp1.applyFilter( _snap, _bmp.rect, _pt, new BlurFilter(-s,-s) );
					_temp2.applyFilter( _temp1, _bmp.rect, _pt, ColorMatrixUtil.setSaturation(s) );
					_temp2.colorTransform( _bmp.rect, new ColorTransform(b,b,b,1) );
					
					_bmp.lock();
					_bmp.copyPixels( _temp2, _bmp.rect, _pt );
					_bmp.unlock();
				}
				_step += 2;
				if ( _step < _stepTotal )
					return false;
				
				return true;
			}
		
	}

}