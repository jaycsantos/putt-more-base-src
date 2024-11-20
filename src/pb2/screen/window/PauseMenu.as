package pb2.screen.window 
{
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.util.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import pb2.game.ctrl.*;
	import pb2.game.*;
	import pb2.screen.*;
	import pb2.screen.ui.*;
	import Playtomic.*;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PauseMenu extends FadeWindow
	{
		
		public function PauseMenu() 
		{
			var g:Graphics, sp:Sprite, sp2:Sprite, btn:SimpleButton, shp:Shape, txf:TextField, m:Matrix, i:int, j:int, k:String, a:Array;
			
			{//-- title
				_contents.addChild( sp = PuttBase2.assets.createDisplayObject('screen.window.title') as Sprite );
				sp.x = 197; sp.y = 136;
				sp.mouseEnabled = false;
				sp.addChild( txf = UIFactory.createTextField('<b>GAME</b> PAUSED', 'header2', 'left', 48, 0) );
				sp.addChild( sp2 = PuttBase2.assets.createDisplayObject('screen.ui.ico.golfTee') as Sprite );
				sp2.x = 38; sp2.y = 15;
				
				_contents.addChildAt( txf = UIFactory.createTextField('Game Paused', 'windowHugeText', 'left', 140, 95), 0 );
				txf.alpha = .25;
				
				if ( Session.isOnPlay ) {
					_contents.addChildAt( txf = UIFactory.createTextField(Session.instance.map.name.replace(/\-/g,' '), 'windowHugeText', 'center', 320, 50), 0 );
					txf.alpha = .25;
				}
				
				_canvas.graphics.clear();
				_canvas.graphics.beginFill( 0, .89 );
				_canvas.graphics.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
				_canvas.graphics.beginFill( 0x191919, .67 );
				_canvas.graphics.drawRect( 0, 374, 650, 18 );
				_canvas.graphics.beginFill( 0x191919, .45 );
				_canvas.graphics.drawRect( 0, 392, 650, 8 );
			}
			
			{//-- texts
				_contents.addChild( txf = UIFactory.createFixedTextField('click anywhere else to return to game', 'pauseText', 'none', 197, 165) );
				txf.width = 255; txf.height = 16;
			}
			
			{//-- buttons
				_contents.addChild( _btnLevels = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnList') as SimpleButton );
				_contents.addChild( _btnMore = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnGame') as SimpleButton );
				_contents.addChild( _btnMenu = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnHome') as SimpleButton );
				_btnLevels.x = 267; _btnLevels.visible = GameRoot.screen is PlayScreen; _btnLevels.name = 'browse';
				_btnMore.x = _btnLevels.visible? 327: 297; _btnMore.name = 'games';
				_btnMenu.x = _btnLevels.visible? 387: 357; _btnMenu.name = 'menu';
				_btnMore.y = _btnLevels.y = _btnMenu.y = 211;
				_btnLevels.filters = _btnMenu.filters = _btnMore.filters = [ new GlowFilter(0xffffff, 1, 2, 2, 2) ];
				
				_contents.addChild( _btnFb = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnFb2') as SimpleButton );
				_btnFb.x = 10; _btnFb.y = 374; _btnFb.name = 'share';
				
				_contents.addChild( _btnTwit = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnTwit2') as SimpleButton );
				_btnTwit.x = 80; _btnTwit.y = 374; _btnTwit.name = 'tweet';
				
				_btnFb.visible = _btnTwit.visible = CONFIG::allowLinks && Registry.useDefaultSponsor;
				
				_contents.addChild( _tip = new PopBtnTip );
			}
			
			addChild( _scrollingMsgs = new ScrollingMsgs );
			
			_canvas.mouseEnabled = true;
			_canvas.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
			_canvas.addEventListener( MouseEvent.MOUSE_OVER, _movr, false, 0, true );
			_canvas.addEventListener( MouseEvent.MOUSE_OUT, _mout, false, 0, true );
			
			onPreShow.addOnce( Session.instance.stop );
			onPreShow.addOnce( CameraFocusCtrl.instance.disable );
			onShown.addOnce( _showCustomRating );
			onHidden.add( _onUnpause );
			onHidden.addOnce( Session.instance.start );
			onHidden.addOnce( CameraFocusCtrl.instance.enable );
		}
		
		override public function dispose():void 
		{
			PopPrompt.remove();
			
			removeEventListener( MouseEvent.CLICK, _click );
			removeEventListener( MouseEvent.MOUSE_OVER, _movr );
			removeEventListener( MouseEvent.MOUSE_OUT, _mout );
			
			_tip.dispose(); _tip = null;
			
			super.dispose();
		}
		
		
			// -- private --
			
			private var _btnMenu:SimpleButton, _btnLevels:SimpleButton, _btnMore:SimpleButton, _tip:PopBtnTip
			private var _btnFb:SimpleButton, _btnTwit:SimpleButton, _btnSponsor:SimpleButton
			private var _scrollingMsgs:ScrollingMsgs
			
			
			override protected function _update():void 
			{
				var input:UserInput = UserInput.instance;
				if ( input.isKeyDown(KeyCode.ESC) || input.isKeyReleased(KeyCode.P) || input.isKeyReleased(KeyCode.SPACEBAR) )
					if ( Window.instanceCount() == 1 && !PopPrompt.instance )
						hide();
					
				_scrollingMsgs.update();
			}
			
			
			private function _click( e:MouseEvent ):void
			{
				switch( e.target ) {
					case _btnLevels:
						var win:Window = Session.instance.map.isCustom? new CLevelsWindow(PauseMenu) : new LevelSelect(PauseMenu);
						addChild( win );
						win.show();
						
						Tracker.i.buttonClick( 'openLevels', 'pauseMenu' );
						break;
						
					case _btnMore:
						Link.Open( Registry.SPONSOR_URL, 'more games', 'pauseMenu' );
						break;
						
					case _btnMenu:
						addChild( PopPrompt.create('Are you sure you want to exit to main menu?', 100, {name:'YES', call:_goMainMenu}, {name:'NO'}) );
						break;
					
					case _btnSponsor:
						Link.Open( Registry.SPONSOR_URL, 'sponsor', 'pauseMenu' );
						break;
						
					case _btnFb:
						Link.Open( 'http://www.facebook.com/jaycgames', 'like', 'pauseMenu' );
						break;
					
					case _btnTwit:
						Link.Open( 'http://twitter.com/JaycSantos', 'tweet', 'pauseMenu' );
						break;
						
						
					default:
						if ( DisplayObject(e.target).parent == _canvas || e.target == _canvas )
							hide();
						break;
				}
			}
			
			private function _movr( e:MouseEvent ):void
			{
				switch( e.target ) {
					case _btnLevels:
					case _btnMore:
					case _btnMenu:
						var btn:SimpleButton = e.target as SimpleButton
						_tip.pop( btn.name, btn.x, btn.y );
						break;
						
					default: break;
				}
			}
			
			private function _mout( e:MouseEvent ):void
			{
				switch( e.target ) {
					case _btnLevels:
					case _btnMore:
					case _btnMenu:
						_tip.hide();
						break;
					default: break;
				}
			}
			
			
			private function _onUnpause():void
			{
				Tracker.i.buttonClick( 'upause', 'pauseMenu' );
			}
			
			
			private function _goMainMenu():void
			{
				var map:MapData = Session.instance.map;
				PopPrompt.remove();
				
				if ( GameRoot.screen is EditorScreen )
					new MapExport( '', HudGameEditor.instance.getPar(), _autoSaveEditor ).start();
					
				else {
					Tracker.i.quitLevel( map, 'pauseMenu' );
					Tracker.i.buttonClick( 'mainMenu', 'pauseMenu' );
					
					GameRoot.changeScreen( MenuActScreen );
				}
				
			}
			
			private function _autoSaveEditor( result:String ):void
			{
				var hud:HudGameEditor = HudGameEditor.instance;
				MapDataMngr.instance.saveEditMap( result, hud.getPar(), hud.totalItems, null, hud.releasedItems );
				GameRoot.changeScreen( MenuActScreen );
			}
			
			
			private function _showCustomRating():void
			{
				if ( Session.instance.map.isCustom ) {
					var win:Window = new PopCustomRate;
					addChild( win ); win.show();
					onPreHide.addOnce( win.hide );
				}
			}
			
			
	}

}