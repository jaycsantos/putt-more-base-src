package pb2.screen 
{
	import com.demonsters.debugger.MonsterDebugger;
	import com.greensock.easing.Quad;
	import com.jaycsantos.display.Cache4Bmp;
	import com.jaycsantos.display.screen.AbstractScreen;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.util.ColorMatrixUtil;
	import com.jaycsantos.util.GameLoop;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.ctrl.MapImport;
	import pb2.game.Session;
	import pb2.screen.ui.UIFactory;
	import pb2.screen.window.ToolBox;
	import pb2.util.pb2internal;
	
	/**
	 * ...
	 * @author ...
	 */
	public class PlayScreen extends AbstractScreen 
	{
		public static const FADE_ENTER_DUR:uint = 400
		public static const FADE_EXIT_DUR:uint = 600
		
		public var toolBox:ToolBox
		
		public function PlayScreen( root:GameRoot, data:Object=null )
		{
			super( root, data );
			
			_canvas.addChild( _worldContainer = new Sprite );
			_canvas.addChild( _overlay = new Sprite );
			_canvas.addChild( _ctrlContainer = new Sprite );	
			
			
			_overlay.addChild( toolBox = new ToolBox );
			toolBox.x = 30; toolBox.y = 30;		
			
			_overlay.addChild( _hudParTtlTxf = UIFactory.createTextField('', 'hudParTtl', 'center') );
			_hudParTtlTxf.x = 620; _hudParTtlTxf.y = 375;
			_hudParTtlTxf.htmlText = '<p class="hudParTtl">par 4</p>';
			
			_overlay.addChild( _hudParTxf = UIFactory.createTextField('', 'hudPar', 'center') );
			_hudParTxf.x = 620; _hudParTxf.y = 350;
			_hudParTxf.htmlText = '<p class="hudPar">3</p>';
			
			_hudParTtlTxf.filters = _hudParTxf.filters = [new DropShadowFilter(2, 45, 0, 1, 0, 0, 6)];
			
			
			_overlay.addChild( _restartOverlay = new Sprite );
			_restartOverlay.name = 'restart overlay';
			_restartOverlay.visible = false;
			_restartOverlay.graphics.beginFill( 0, .5 );
			_restartOverlay.graphics.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			_restartOverlay.addChild( _restartLoadBar = PuttBase2.assets.createDisplayObject('screen.ui.loadingBar') as MovieClip );
			_restartLoadBar.name = 'restart loading bar';
			_restartLoadBar.x = PuttBase2.STAGE_WIDTH / 2; _restartLoadBar.y = PuttBase2.STAGE_HEIGHT / 2;
			
			
			_ctrlContainer.addChild( _btnRestart = PuttBase2.assets.createDisplayObject('screen.ui.ico.btnRestart') as SimpleButton );
			_ctrlContainer.addChild( _btnPause = PuttBase2.assets.createDisplayObject('screen.ui.ico.btnPause') as SimpleButton );
			_ctrlContainer.addChild( _btnMuteMusic = PuttBase2.assets.createDisplayObject('screen.ui.ico.btnMuteMusic') as SimpleButton );
			_ctrlContainer.addChild( _btnUnmuteMusic = PuttBase2.assets.createDisplayObject('screen.ui.ico.btnUnmuteMusic') as SimpleButton );
			_ctrlContainer.addChild( _btnMute = PuttBase2.assets.createDisplayObject('screen.ui.ico.btnMute') as SimpleButton );
			_ctrlContainer.addChild( _btnUnmute = PuttBase2.assets.createDisplayObject('screen.ui.ico.btnUnmute') as SimpleButton );
			
			
			_btnMute.x = _btnUnmute.x = 615;
			_btnUnmute.visible = false;
			
			_btnMuteMusic.x = _btnUnmuteMusic.x = 585;
			_btnUnmuteMusic.visible = false;
			
			_btnPause.x = 515;
			_btnRestart.x = 440;
			
			
			_worldContainer.name = 'world container';
			_overlay.name = 'overlay';
			_ctrlContainer.name = 'controls container';
			
			_bmpD = new BitmapData( PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT, true, 0 );
			_cache = new Cache4Bmp( true, false, false, true );
			_cache.bitmapData = _bmpD.clone();
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			toolBox.dispose();
			toolBox = null;
		}
		
		
		override public function update():void 
		{
			BallCtrl.instance.update();
			
			toolBox.update();
			
		}
		
		
			// -- private --
			
			protected var _worldContainer:Sprite, _overlay:Sprite, _ctrlContainer:Sprite
			protected var _btnRestart:SimpleButton, _btnPause:SimpleButton, _btnMuteMusic:SimpleButton, _btnMute:SimpleButton, _btnUnmuteMusic:SimpleButton, _btnUnmute:SimpleButton
			protected var _hudParTtlTxf:TextField, _hudParTxf:TextField, _hudParContainer:Sprite
			
			protected var _restartOverlay:Sprite, _restartLoadBar:MovieClip
			
			private var _waitImport:Boolean = true
			
			
			//{ -- import
			private function _importInit( cols:int, rows:int ):void
			{
				Session.instance.create( cols, rows, _worldContainer, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
				Session.instance.start();
			}
			
			private function _importComplete():void
			{
				_waitImport = false;
				_forceEnter();
			}
			
			private function _importError():void
			{
				
			}
			//}
			
			
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
					
				if ( _waitImport )
					new MapImport( Session.instance.mapStr, _importInit, _importComplete, _importError, Math.random().toString(36) ).start();
				
				return !_waitImport;
			}
			
			override protected function _onPreExit():void 
			{
				_cache.bitmapData.draw( _canvas, _canvas.transform.matrix, _canvas.transform.colorTransform );
				_canvas.visible = false;
				_timer = GameLoop.instance.time +FADE_EXIT_DUR;
				
				_bmpD.fillRect( _bmpD.rect, 0x191919 );
				LoadingOverlay.prepare( 0x191919 );
				LoadingOverlay.instance.bitmap.bitmapData = _bmpD;
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
				_bmpD.unlock();
				
				MonsterDebugger.snapshot( this, new Bitmap(_bmpD) );
				
				if ( t < dur )
					return true;
				
				LoadingOverlay.dismiss();
				_canvas.visible = true;
				toolBox.show();
				
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
			/**/
			
	}

}