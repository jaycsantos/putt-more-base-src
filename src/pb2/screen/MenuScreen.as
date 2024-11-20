package pb2.screen 
{
	import com.demonsters.debugger.MonsterDebugger;
	import com.greensock.easing.*;
	import com.jaycsantos.display.Cache4Bmp;
	import com.jaycsantos.display.screen.AbstractScreen;
	import com.jaycsantos.display.SimplierButton;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.game.IGameObject;
	import com.jaycsantos.util.*;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import pb2.game.Registry;
	import pb2.screen.transitioned.FadeBlurBlackScreen;
	import pb2.screen.ui.BigBtn1;
	import pb2.screen.ui.UIFactory;
	import pb2.screen.window.CustomHoleDiag;
	import pb2.screen.window.LevelSelectWin;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class MenuScreen extends AbstractScreen
	{
		public static const FADE_ENTER_DUR:uint = 300;
		public static const FADE_EXIT_DUR:uint = 600;
		
		
		public function MenuScreen( root:GameRoot, data:Object = null )
		{
			super( root, data );
			
			_bmpD = new BitmapData( PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT, true, 0 );
			_cache = new Cache4Bmp( true, false, false, true );
			_cache.bitmapData = _bmpD.clone();
			
			
			_canvas.addChild( _bgClip = PuttBase2.assets.createDisplayObject('screen.mainmenu.bg') as Sprite );
			_bgClip.mouseChildren = _bgClip.mouseEnabled = false;
			
			
			_canvas.addChild( _btnShowMenu = new BigBtn1('','btn1_shwmenu',28) );
			_btnShowMenu.addEventListener( MouseEvent.CLICK, _onShowMenu, false, 0, true );
			_btnShowMenu.x = 30; _btnShowMenu.y = 350;
			
			_canvas.addChild( _btnMoreGames = new BigBtn1('More Games') );
			_btnMoreGames.addEventListener( MouseEvent.CLICK, _onMoreGames, false, 0, true );
			_btnMoreGames.x = 80; _btnMoreGames.y = 350;
			
			_canvas.addChild( _btnStats = new BigBtn1('My Account') );
			_btnStats.addEventListener( MouseEvent.CLICK, _showStats, false, 0, true );
			_btnStats.x = _btnMoreGames.x +140; _btnStats.y = 350;
			
			_canvas.addChild( _btnPlay = new BigBtn1('Start Putt','btn1_special') );
			_btnPlay.addEventListener( MouseEvent.CLICK, _playGame, false, 0, true );
			_btnPlay.x = _btnStats.x +140; _btnPlay.y = 350;
			
			_canvas.addChild( _btnLvlEditor = new BigBtn1('Hole Editor') );
			_btnLvlEditor.addEventListener( MouseEvent.CLICK, _openEditor, false, 0, true );
			_btnLvlEditor.x = _btnPlay.x +140; _btnLvlEditor.y = 350;
			
			
			_canvas.addChild( _winLevelSelect = new LevelSelectWin );
			_canvas.addChild( _diagNewHole = new CustomHoleDiag(this) );
			
			
			_reset();
			_canvas.visible = false;
			
			/*var startBtn:TextField = new TextField;
			startBtn.text = "Start";
			startBtn.selectable = false;
			startBtn.x = PuttBase2.STAGE_WIDTH / 2 - startBtn.width / 2;
			startBtn.y = PuttBase2.STAGE_HEIGHT / 2 - startBtn.height / 2;
			
			var shape:Shape = new Shape;
			shape.graphics.beginFill( 0, 0.5 );
			shape.graphics.drawRect( 20, 20, PuttBase2.STAGE_WIDTH -40, PuttBase2.STAGE_HEIGHT -40 );
			shape.graphics.endFill();
			
			_canvas.addChild( startBtn );
			_canvas.addChild( shape );
			
			
			_canvas.buttonMode = true;
			_canvas.mouseEnabled = true;
			_canvas.useHandCursor = true;
			_canvas.addEventListener( MouseEvent.CLICK, _startGame );
			
			MovieClip(_canvas.addChild( PuttBase2.assets.createDisplayObject('testfield') )).stop();*/
		}
		
		override public function dispose():void 
		{
			_diagNewHole.dispose();
			_canvas.removeChild( _diagNewHole );
			_diagNewHole = null;
			
			
			_btnShowMenu.removeEventListener( MouseEvent.CLICK, _onShowMenu );
			_btnMoreGames.removeEventListener( MouseEvent.CLICK, _onMoreGames );
			_btnStats.removeEventListener( MouseEvent.CLICK, _showStats );
			_btnPlay.removeEventListener( MouseEvent.CLICK, _playGame );
			_btnLvlEditor.removeEventListener( MouseEvent.CLICK, _openEditor );
			
			
			super.dispose();
			
			_cache.bitmapData.dispose();
			_cache = null;
			_bmpD.dispose();
			_bmpD = null;
		}
		
		
		override public function update():void 
		{
			var t:uint = getTimer();
			
			for each( var o:IGameObject in [_btnShowMenu, _btnMoreGames, _btnStats, _btnPlay, _btnLvlEditor, _diagNewHole, _winLevelSelect] )
				o.update();
			
			
			DOutput.show( 'logic', getTimer() -t );
		}
		
		
			// -- private --
			
			protected var _bgClip:Sprite
			protected var _btnShowMenu:BigBtn1, _btnMoreGames:BigBtn1, _btnStats:BigBtn1, _btnPlay:BigBtn1, _btnLvlEditor:BigBtn1
			protected var _winLevelSelect:LevelSelectWin, _diagNewHole:CustomHoleDiag
			
			
			private function _onShowMenu( e:MouseEvent ):void
			{
				_reset();
			}
			
			private function _onMoreGames( e:MouseEvent ):void
			{
				//_reset();
				//_btnMoreGames.locked = true;
				
				
			}
			
			private function _showStats( e:MouseEvent ):void
			{
				_reset();
				_btnStats.lock();
				
			}
			
			private function _playGame( e:MouseEvent ):void
			{
				_reset();
				_btnPlay.lock();
				
				_winLevelSelect.onHidden.addOnce( _btnPlay.unlock );
				_winLevelSelect.show();
			}
			
			private function _openEditor( e:MouseEvent ):void
			{
				_reset();
				_btnLvlEditor.lock();
				
				_diagNewHole.onHidden.addOnce( _btnLvlEditor.unlock );
				_diagNewHole.show();
				
				//changeScreen( PreEditorScreen );
			}
			
			
			private function _reset():void
			{
				_btnMoreGames.unlock();
				_btnStats.unlock();
				_btnPlay.unlock();
				_btnLvlEditor.unlock();
				
				// flag this!
				_btnStats.disable();
				//_btnLvlEditor.disable();
				
				_winLevelSelect.hide()
				_diagNewHole.hide();
				
			}
			
			
			// -- transitions --
			
			private var _cache:Cache4Bmp, _timer:uint, _bmpD:BitmapData
			
			override protected function _onPreEnter():Boolean 
			{
				_cache.bitmapData.draw( _canvas, _canvas.transform.matrix, _canvas.transform.colorTransform );
				_canvas.visible = false;
				_timer = GameLoop.instance.time +FADE_ENTER_DUR;
				
				LoadingOverlay.prepare( 0xCCCCCC );
				LoadingOverlay.instance.bitmap.bitmapData = _bmpD;
				
				return true;
			}
			
			override protected function _onPreExit():void 
			{
				_cache.bitmapData.draw( _canvas, _canvas.transform.matrix, _canvas.transform.colorTransform );
				_canvas.visible = false;
				_timer = GameLoop.instance.time +FADE_EXIT_DUR;
				
				if ( _root.nextScreenClass == EditorScreen )
					LoadingOverlay.prepare( 0x191919 );
				else
					LoadingOverlay.prepare( 0xCCCCCC );
				LoadingOverlay.instance.bitmap.bitmapData = _bmpD;
			}
			
			override protected function _doWhileEntering():Boolean 
			{
				var dur:uint = FADE_ENTER_DUR;
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
				var dur:uint = FADE_EXIT_DUR;
				var t:int = dur - (_timer - GameLoop.instance.time);
				var s:Number = t<dur/2? Quad.easeIn(t, 0, -100, dur/2) :-100;
				var b:Number = t<dur/2? 0: t>dur/2? Quad.easeIn(t-dur/2, 0, -100, dur/2) :-100
				
				_cache.colorTrnsfrm.alphaMultiplier = (100+b)/100;
				
				_bmpD.applyFilter( _cache.bitmapData, _bmpD.rect, _cache.point, ColorMatrixUtil.setSaturation(s) );
				_bmpD.colorTransform( _bmpD.rect, _cache.colorTrnsfrm );
				
				if ( t < dur )
					return true;
				
				return false;
			}
		
	}

}