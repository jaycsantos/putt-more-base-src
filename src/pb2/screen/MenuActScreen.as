package pb2.screen 
{
	import apparat.math.FastMath;
	import Box2D.Common.Math.b2Vec2;
	import com.demonsters.debugger.MonsterDebugger;
	import com.greensock.easing.*;
	import com.jaycsantos.display.Cache4Bmp;
	import com.jaycsantos.display.screen.AbstractScreen;
	import com.jaycsantos.entity.GameCamera;
	import com.jaycsantos.game.*;
	import com.jaycsantos.math.*;
	import com.jaycsantos.sound.FadeSoundEffect;
	import com.jaycsantos.sound.GameSounds;
	import com.jaycsantos.util.*;
	import com.newgrounds.API;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.*;
	import flash.geom.ColorTransform;
	import flash.net.URLVariables;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import pb2.game.ctrl.*;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.*;
	import pb2.game.entity.tile.Ground;
	import pb2.GameAudio;
	import pb2.screen.ui.*;
	import pb2.screen.window.*;
	import pb2.util.*;
	import Playtomic.*;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MenuActScreen extends AbstractScreen 
	{
		private static const MAPSTR:String = 'JRvCL8F4dQ8YdB+5-oudV_7I7CWqZt6I1CDU3qFyxg3g3GHoqmIDb_MwyLIVXiM2aaIujL8Xy_Oe3ML-yvX9cl5Zgm+_9WXFPBeR+k8_W_TNnGMR5g8ZjJMiywOP3MyDfBwwHMmCYgQwcM2zt_-0-87D+_KIeMQDohFIwMvHg1Tke5w6ghQUMY4mMBDgM4C-E-h3LPYXoheW+69c2lbm0W0KfE8Qv18_C_5AYA';
		
		public static const FADE_ENTER_DUR:uint = 300
		public static const FADE_EXIT_DUR:uint = 800
		
		
		public var hudAudio:HudAudio
		
		public function MenuActScreen( root:GameRoot, data:Object=null )
		{
			super( root, data );
			
			/*CONFIG::debug {
				SaveDataMngr.instance.saveCustom('encyclopedia', '');
				SaveDataMngr.instance.saveCustom('tutflag', 0);
				SaveDataMngr.instance.saveCustom('editorTutFlags', 0, true);
			}/**/
			
			_canvas.addChild( _worldContainer = new Sprite );
			_canvas.addChild( _overlay = new Sprite );
			_canvas.addChild( hudAudio = new HudAudio );
			_canvas.addChild( _clipButtons = new Sprite );
			_canvas.addChild( _scrollMsgs = new ScrollingMsgs );
			_scrollMsgs.visible = int(SaveDataMngr.instance.getCustom('g0')) > 0;
			
			_worldContainer.name = 'world container';
			_overlay.name = 'overlay';
			_worldContainer.mouseEnabled = _overlay.mouseEnabled = false;
			
			_overlay.graphics.beginFill( 0x191919, .92 );
			_overlay.graphics.drawRect( 0, 350, 650, 24 );
			_overlay.graphics.beginFill( 0x191919, .67 );
			_overlay.graphics.drawRect( 0, 374, 650, 18 );
			_overlay.graphics.beginFill( 0x191919, .45 );
			_overlay.graphics.drawRect( 0, 392, 650, 8 );
			
			_overlay.addChild( UIFactory.createTextField('v'+Registry.VERSION+' (c) Jayc Santos 2012', 'subMenuBarText2', 'right', 645, 388) );
			
			_clipButtons.mouseEnabled = true;
			_clipButtons.addEventListener( MouseEvent.CLICK, _clickBtn, false, 0, true );
			_clipButtons.addEventListener( MouseEvent.MOUSE_OVER, _movrBtn, false, 0, true );
			
			_clipButtons.addChild( _btnShowMenu = new BigBtn1('','btn1_shwmenu',28) );
			_btnShowMenu.x = 10; _btnShowMenu.y = 350;
			
			
			_clipButtons.addChild( _btnLvlEditor = new BigBtn1('Editor') );
			_btnLvlEditor.x = PuttBase2.STAGE_WIDTH -140; _btnLvlEditor.y = 350;
			
			_clipButtons.addChild( _btnCustom = new BigBtn1('Pub Courses') );
			_btnCustom.x = _btnLvlEditor.x -140; _btnCustom.y = 350;
			
			_clipButtons.addChild( _btnPlay = new BigBtn1('Start Putt','btn1') );
			_btnPlay.x = _btnCustom.x -140; _btnPlay.y = 350;
			_btnPlay.applyTextFilter( [new GlowFilter(0xFF9900, 1, 16, 16, 3)] );
			
			
			_clipButtons.addChild( _btnCredits = new BigBtn1('Credits','btn1b',86,18,0x7E9900) );
			_btnCredits.x = PuttBase2.STAGE_WIDTH -110; _btnCredits.y = 374; _btnCredits.alpha = .9;
			
			_clipButtons.addChild( _btnMoreGames = new BigBtn1(CONFIG::onAndkon?'Andkon Arcade':'More Games','btn1b',100,18,0x7E9900) );
			_btnMoreGames.x = _btnCredits.x -110; _btnMoreGames.y = 374; _btnMoreGames.alpha = .9;
			
			_clipButtons.addChild( _btnScores = new BigBtn1('Leader Boards','btn1b',100,18,0x7E9900) );
			_btnScores.x = _btnMoreGames.x -110; _btnScores.y = 374; _btnScores.alpha = .9;
			_btnScores.visible = Registry.useDefaultSponsor && !CONFIG::onAndkon;
			
			_clipButtons.addChild( _btnAddWeb = new BigBtn1('Add to Website','btn1b',100,18,0x7E9900) );
			_btnAddWeb.x = _btnScores.x -110; _btnAddWeb.y = 374; _btnAddWeb.alpha = .9;
			_btnAddWeb.visible = Registry.useDefaultSponsor && !CONFIG::onAndkon;
			
			_clipButtons.addChild( _btnFb = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnFb3') as SimpleButton );
			_btnFb.x = 10; _btnFb.y = 374;
			
			_clipButtons.addChild( _btnTwit = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnTwit3') as SimpleButton );
			_btnTwit.x = 65; _btnTwit.y = 374;
			
			
			
			if ( CONFIG::onAndkon )
				_clipButtons.addChild( _btnSponsor = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnAndkon_menu') as SimpleButton );
			else if ( CONFIG::onMbreaker && !Registry.useDefaultSponsor )
				_clipButtons.addChild( _btnSponsor = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnMbreaker') as SimpleButton );
			else
				_clipButtons.addChild( _btnSponsor = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnTurboNuke_menu') as SimpleButton );
			_btnSponsor.x = 100; _btnSponsor.y = 348;
			
			
			// this is placed inside shades layer of game world
			//_titleShade = PuttBase2.assets.createDisplayObject( 'screen.ui.bg.titleShade' ) as Sprite;
			//_titleShade.transform.colorTransform = new ColorTransform( 0, 0, 0, 1, 0, 0, 0, 0 );
			//_titleShade.x = (PuttBase2.STAGE_WIDTH - _titleShade.width) /2 >>0;
			//_titleShade.y = 150;
			
			_txfHscoreA = UIFactory.createFixedTextField( '', 'hscore1', 'left', 0, 0 );
			_txfHscoreB = UIFactory.createFixedTextField( '', 'hscore2', 'left', 0, 14 );
			_txfHscoreC = UIFactory.createFixedTextField( '', 'hscore3', 'left', 0, 27 );
			_txfHscoreD = UIFactory.createFixedTextField( '', 'hscore4', 'left', 0, 30 );
			_txfHscoreE = UIFactory.createFixedTextField( '', 'hscore4', 'left', 480, 195 );
			_txfHscoreA.cacheAsBitmap = _txfHscoreB.cacheAsBitmap = _txfHscoreC.cacheAsBitmap = _txfHscoreD.cacheAsBitmap = _txfHscoreE.cacheAsBitmap = true;
			
			
			_reset();
		}
		
		override public function dispose():void 
		{
			_clipButtons.removeEventListener( MouseEvent.CLICK, _clickBtn );
			_clipButtons.removeEventListener( MouseEvent.MOUSE_OVER, _movrBtn );
			
			for each( var o:IGameObject in [_btnShowMenu, _btnMoreGames, _btnCustom, _btnPlay, _btnLvlEditor, _btnCredits] )
				o.dispose();
			
			super.dispose();
			
			if ( _txfHscoreA.parent ) _txfHscoreA.parent.removeChild( _txfHscoreA );
			if ( _txfHscoreB.parent ) _txfHscoreB.parent.removeChild( _txfHscoreB );
			//if ( _titleShade.parent ) _titleShade.parent.removeChild( _titleShade );
			
			_txfHscoreA = _txfHscoreB = null; //_titleShade = null;
			_btnShowMenu = _btnLvlEditor = _btnCustom = _btnPlay = _btnMoreGames = _btnCredits = _btnScores = null;
			hudAudio.dispose(); hudAudio = null;
			_scrollMsgs.dispose(); _scrollMsgs = null;
			
			_cache.bitmapData.dispose(); _cache = null;
			_bmpD.dispose(); _bmpD = null;
			
			Window.disposeAllWindows();
		}
		
		
		override public function update():void 
		{
			BallCtrl.instance.update();
			
			_scrollMsgs.update();
			
			for each( var o:IGameObject in [_btnShowMenu, _btnMoreGames, _btnCustom, _btnPlay, _btnLvlEditor, _btnCredits, _btnScores, _btnAddWeb] )
				o.update();
			
			if ( UserInput.instance.isKeyPressed(KeyCode.R) )
				Session.instance.reset();
		}
		
		
		pb2internal function reloadLeaderboard():void
		{
			CONFIG::usePlaytomicLvls {
				Leaderboards.List( Registry.PLAYTOMIC_LEADERBOARDS, _listScores, {global:Registry.PLAYTOMIC_GLOBAL_LEADERBOARD, perpage:10} );
			}
			
		}
		
		
			// -- private --
			
			protected var _worldContainer:Sprite, _overlay:Sprite, _scrollMsgs:ScrollingMsgs//, _titleShade:Sprite
			protected var _txfHscoreA:TextField, _txfHscoreB:TextField, _txfHscoreC:TextField, _txfHscoreD:TextField, _txfHscoreE:TextField
			
			
			private function _reset():void
			{
				_btnPlay.unlock();
				_btnCustom.unlock();
				_btnLvlEditor.unlock();
				_btnCredits.unlock();
				_btnMoreGames.unlock();
				_btnScores.unlock();
				
				Window.removeAllWindows();
				
				if ( BallCtrl.instance.getPrimary() && BallCtrl.instance.getPrimary().isOnHole )
					Session.instance.reset();
				
				if ( Session.world ) Session.instance.start();
			}
			
			
			//{ -- main buttons
			protected var _clipButtons:Sprite
			protected var _btnShowMenu:BigBtn1, _btnCustom:BigBtn1, _btnPlay:BigBtn1, _btnLvlEditor:BigBtn1
			protected var _btnCredits:BigBtn1, _btnMoreGames:BigBtn1, _btnSponsor:SimpleButton, _btnScores:BigBtn1, _btnAddWeb:BigBtn1
			protected var _btnFb:SimpleButton, _btnTwit:SimpleButton
			
			
			private function _clickBtn( e:MouseEvent ):void
			{
				var win:Window, urlvar:URLVariables;
				
				switch( e.target ) {
					case _btnShowMenu:
						_reset();
						Session.instance.reset();
						Tracker.i.buttonClick( 'reset', 'mainmenu' );
						break;
					
					case _btnPlay:
						_reset();
						_btnPlay.lock();
						
						if ( ! int(SaveDataMngr.instance.getCustom('g0')) ) {
							var xmllist:XMLList = MapList.list.level.(@sett == 0);
							if ( xmllist != null && xmllist.length() ) {
								Session.instance.map = new MapData( xmllist[0], null, 0 );
								Tracker.i.startLevel( Session.instance.map, 'mainmenu' );
								SaveDataMngr.instance.saveCustom( 'lastMap', 0, true );
								GameRoot.changeScreen( RelayScreen, PlayScreen );
								return;
							}
						}
						//_overlay.addChild( win = new PopLevels(MenuActScreen) );
						//_overlay.addChild( win = new LevelsWindow(MenuActScreen) );
						_overlay.addChild( win = new LevelSelect(MenuActScreen) );
						win.onShown.addOnce( Session.instance.stop );
						win.onHidden.addOnce( Session.instance.start );
						win.onHidden.addOnce( _btnPlay.unlock );
						win.show();
						
						Tracker.i.buttonClick( 'playPutt', 'mainmenu' );
						break;
					
					case _btnCustom:
						_reset();
						_btnCustom.lock();
						
						_overlay.addChild( win = new CLevelsWindow(MenuActScreen) );
						win.onShown.addOnce( Session.instance.stop );
						win.onHidden.addOnce( Session.instance.start );
						win.onHidden.addOnce( _btnCustom.unlock );
						win.show();
						
						//GamerSafe.api.levelVaultSetAttributes( 477418, {'score0':'30,Johnny,A,10', 'score1':'20,Sassy,C,10', 'score2':'10,Mark,B,10' } );
						Tracker.i.buttonClick( 'pubCourses', 'mainmenu' );
						break;
					
					case _btnLvlEditor:
						_btnLvlEditor.lock();
						
						var ses:Session = Session.instance;
						var xml:XML = MapDataMngr.instance.getEditMap();
						if ( xml != null ) {
							ses.map = new MapData( xml );
						} else {
							ses.cols = 14; ses.rows = 8;
							ses.bgColorIdx = MathUtils.randomInt( 0, Ground.COLORS.length-1 );
							ses.map = null;
						}
						GameRoot.changeScreen( EditorScreen );
						
						Tracker.i.buttonClick( 'editor', 'mainmenu' );
						break;
					
					case _btnCredits:
						_reset();
						_btnCredits.lock();
						
						_overlay.addChild( win = new Credits );
						win.onPreShow.addOnce( Session.instance.stop );
						win.onShown.addOnce( Session.instance.stop );
						win.onPreHide.addOnce( Session.instance.start );
						win.onHidden.addOnce( _btnCredits.unlock );
						win.show();
						
						Tracker.i.buttonClick( 'credits', 'mainmenu' );
						break;
					
					case _btnScores:
						_reset();
						_btnScores.lock();
						
						_overlay.addChild( win = new PopLeaderboards );
						win.onPreShow.addOnce( Session.instance.stop );
						win.onShown.addOnce( Session.instance.stop );
						win.onPreHide.addOnce( Session.instance.start );
						win.onHidden.addOnce( _btnScores.unlock );
						win.show();
						
						Tracker.i.buttonClick( 'scores', 'mainmenu' );
						break;
					
					case _btnSponsor:
						Link.Open( Registry.SPONSOR_URL, 'sponsor', 'mainmenu' );
						break;
						
					case _btnMoreGames:
						Link.Open( Registry.SPONSOR_URL, 'more games', 'mainmenu' );
						break;
					
					case _btnAddWeb:
						Link.Open( Registry.SPONSOR_URL_ADDWEB, 'add web', 'mainmenu' );
						break;
					
					case _btnFb:
						urlvar = new URLVariables();
						urlvar.u = Registry.SPONSOR_GAME_URL;
						Link.Open( 'http://www.facebook.com/sharer.php?'+ urlvar.toString(), 'fb', 'mainmenu' );
						break;
					
					case _btnTwit:
						urlvar = new URLVariables();
						urlvar.status = 'Play PuttMoreBase, puzzle physics golf game '+ Registry.SPONSOR_GAME_URL;
						Link.Open( 'http://twitter.com/?'+ urlvar.toString(), 'twit', 'mainmenu' );
						break;
					
					default: break;
				}
			}
			
			private function _movrBtn( e:MouseEvent ):void
			{
				if ( 0&& e.target == _btnPlay && !SaveDataMngr.instance.getCustom('menuPutt') ) {
					if ( !BallCtrl.strokes ) {
						BallCtrl.angle = 321.5;//MathUtils.randomInt( -179, 180 );
						BallCtrl.power = 100;
						BallCtrl.instance.release();
					}
					SaveDataMngr.instance.saveCustom('menuPutt', 1, true );
				}
				
			}
			//}
			
			private function _onPutt():void
			{
				_btnPlay.lock();
				
				if ( CONFIG::onNG && PuttBase2.ngApi && API.isNewgrounds && API.isNetworkHost ) {
					if ( !API.getMedal('Hole OCD').unlocked ) API.unlockMedal( 'Hole OCD' );
				}
				
				if ( ! int(SaveDataMngr.instance.getCustom('g0')) ) {
					var xmllist:XMLList = MapList.list.level.(@sett == 0);
					if ( xmllist != null && xmllist.length() ) {
						Session.instance.map = new MapData( xmllist[0], null, 0 );
						SaveDataMngr.instance.saveCustom( 'lastMap', 0, true );
						Tracker.i.startLevel( Session.instance.map, 'putt_mainmenu' );
						GameRoot.changeScreen( RelayScreen, PlayScreen );
						return;
					}
				}
				//_overlay.addChild( win = new PopLevels(MenuActScreen) );
				//_overlay.addChild( win = new LevelsWindow(MenuActScreen) );
				var win:Window;
				_overlay.addChild( win = new LevelSelect(MenuActScreen) );
				win.onShown.addOnce( Session.instance.stop );
				win.onHidden.addOnce( Session.instance.start );
				win.onHidden.addOnce( _btnPlay.unlock );
				win.onHidden.addOnce( Session.instance.reset );
				win.show();
				
				Tracker.i.buttonClick( 'onPutt', 'mainmenu' );
			}
			
			
			//{ -- import
			private var _waitImport:Boolean = true
			
			private function _importInit( cols:int, rows:int ):void
			{
				var ses:Session = Session.instance;
				
				ses.sun_angle.Set( Trigo.VEC2_60_DEG.x, Trigo.VEC2_60_DEG.y );
				ses.sun_length = 38;
				ses.sun_strength = .28;
				
				ses.create( cols, rows, _worldContainer, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
				ses.start();
				
				var cam:GameCamera = Session.world.camera;
				cam.stopFollow( new Vector2D(PuttBase2.STAGE_WIDTH/2 +Registry.tileSize/2 -1 >>0, PuttBase2.STAGE_HEIGHT/2 +Registry.tileSize/2 -2 >>0) );
				//cam.signalMove.dispatch( cam.p.x, cam.p.y );
				
				
				var sp:Sprite = new Sprite;
				sp.addChild( _txfHscoreA );
				sp.addChild( _txfHscoreB );
				sp.addChild( _txfHscoreC );
				sp.addChild( _txfHscoreD );
				sp.rotation = 4;
				_txfHscoreE.rotation = -16;
				//sp.x = 345; sp.y = 195;
				sp.x = 525; sp.y = 125;
				
				ses.shades.addShade( PuttBase2.assets.createDisplayObject('screen.tutorial.menuControls') as Sprite );
				ses.shades.addShade( PuttBase2.assets.createDisplayObject('screen.ui.bg.titleShade') as Sprite );
				//ses.shades.addShade( _titleShade );
				ses.shades.addShade( sp );
				ses.shades.addShade( _txfHscoreE );
			}
			
			private function _importComplete():void
			{
				_waitImport = false;
				_forceEnter();
				
				Session.instance.onPutt.add( _onPutt );
				_reset();
				Session.instance.reset( false, true );
				
				Session.instance.wallLeft.render.redraw();
				Session.instance.wallLeft.render.update();
				Session.instance.wallRight.render.redraw();
				Session.instance.wallRight.render.update();
				Session.instance.wallTop.render.redraw();
				Session.instance.wallTop.render.update();
				Session.instance.wallBottom.render.redraw();
				Session.instance.wallBottom.render.update();
				
				trace( 'import complete [menu screen map]' );
			}
			
			private function _importError( e:Error ):void
			{
				changeScreen( MapErrorScreen, e );
			}
			
			private function _listScores( scores:Array, numscores:int, response:Object ):void
			{
				if ( !_txfHscoreA ) return;
				
				if ( response.Success ) {
					_txfHscoreE.text = '';
					for ( var i:int = 0; i < scores.length; i++ ) {
						var score:PlayerScore = scores[i];
						if ( i == 0 )
							_txfHscoreA.text = (i+1) +'.  '+ MathUtils.toThousands(score.Points) +' - '+ score.Name;
						else if ( i == 1 )
							_txfHscoreB.text = (i+1) +'.  '+ MathUtils.toThousands(score.Points) +' - '+ score.Name;
						else if ( i == 2 )
							_txfHscoreC.text = (i+1) +'.  '+ MathUtils.toThousands(score.Points) +' - '+ score.Name;
						//else if ( i < 5 )
							//_txfHscoreD.appendText( '\n'+ (i+1) +'.  '+ score.Points +' - '+ score.Name );
						else
							_txfHscoreE.appendText( '\n'+ (i+1) +'.  '+ MathUtils.toThousands(score.Points) +' - '+ score.Name );
					}
				} else {
					_txfHscoreE.text = '...';
				}
			}
			//}
			
			
			//{ -- transitions
			private var _cache:Cache4Bmp, _timer:uint, _bmpD:BitmapData
			
			override protected function _onPreEnter():Boolean 
			{
				if ( ! _cache ) {
					_bmpD = new BitmapData( PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT, true, 0 );
					_cache = new Cache4Bmp( true, false, false, true );
					_cache.bitmapData = _bmpD.clone();
				}
				
				_cache.bitmapData.draw( _canvas, _canvas.transform.matrix, _canvas.transform.colorTransform );
				_canvas.visible = false;
				_timer = GameLoop.instance.time +FADE_ENTER_DUR;
				
				_bmpD.fillRect( _bmpD.rect, 0x191919 );
				LoadingOverlay.prepare( 0x191919 );
				LoadingOverlay.instance.bitmap.bitmapData = _bmpD;
				
				if ( _waitImport ) {
					Session.instance.map = new MapData( new XML(<level id="0" hash="" group="0" name="custom"><par>10</par><item>0</item><extra>0</extra><map></map></level>) );
					Session.instance.map.loaded();
					new MapImport( MAPSTR, _importInit, _importComplete, _importError, Math.random().toString(36) ).start();
					
					pb2internal::reloadLeaderboard();
					GameAudio.instance.playMenuMusic();
					
					
					CONFIG::onFGL {
						Registry.FGL_TRACKER.customMsg( 'main menu', 0 ); }
				}
				
				return !_waitImport;
			}
			
			override protected function _onPreExit():void 
			{
				_bmpD = new BitmapData( PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT, true, 0 );
				_cache.bitmapData = _bmpD.clone();
				_cache.bitmapData.draw( _canvas, _canvas.transform.matrix, _canvas.transform.colorTransform );
				_canvas.visible = false;
				_timer = GameLoop.instance.time +FADE_EXIT_DUR;
				
				_bmpD.fillRect( _bmpD.rect, 0x191919 );
				LoadingOverlay.prepare( 0x191919 );
				LoadingOverlay.instance.bitmap.bitmapData = _bmpD;
				
				Session.instance.clean();
				GameAudio.instance.stopMusic( FADE_EXIT_DUR*.9 >> 0 );
				
				Tracker.i.trackFGL( 'ballStrikes', 'menu', BallCtrl.strokes +', '+ ((getTimer()-_timer)/1000 >>0) +'s' );
			}
			
			override protected function _doWhileEntering():Boolean 
			{
				var dur:uint = FADE_ENTER_DUR;
				var t:int = dur - (_timer - GameLoop.instance.time);
				var s:Number = t<dur? Quad.easeIn( t, -100, 100, dur ) :0;
				_cache.colorTrnsfrm.alphaMultiplier = (100+s)/100;
				
				_bmpD.lock();
				//_bmpD.applyFilter( _cache.bitmapData, _bmpD.rect, _cache.point, ColorMatrixUtil.setSaturation(s) );
				_bmpD.applyFilter( _cache.bitmapData, _bmpD.rect, _cache.point, new BlurFilter(Linear.easeIn(t,24,-24,dur), Linear.easeIn(t,8,-8,dur), 1) );
				_bmpD.colorTransform( _bmpD.rect, _cache.colorTrnsfrm );
				_bmpD.unlock();
				
				if ( t < dur )
					return true;
				
				LoadingOverlay.dismiss();
				_canvas.visible = true;
				_cache.bitmapData.dispose();
				_bmpD.dispose(); _bmpD = null;
				
				if ( Session.instance.autoLoadLevelId )
					_canvas.addChild( new PopAutoloadLevel(Session.instance.autoLoadLevelId) );
				Session.instance.autoLoadLevelId = null;
				
				return false;
			}
			
			override protected function _doWhileExiting():Boolean 
			{
				var dur:uint = FADE_EXIT_DUR;
				var t:int = dur - (_timer - GameLoop.instance.time);
				var s:Number = t<dur? Quad.easeOut( t, 0, -100, dur ) :-100;
				_cache.colorTrnsfrm.alphaMultiplier = (100+s)/100;
				
				_bmpD.lock();
				//_bmpD.applyFilter( _cache.bitmapData, _bmpD.rect, _cache.point, ColorMatrixUtil.setSaturation(s) );
				_bmpD.applyFilter( _cache.bitmapData, _bmpD.rect, _cache.point, new BlurFilter(Linear.easeIn(t,0,24,dur), Linear.easeIn(t,0,8,dur), 1) );
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