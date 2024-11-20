package pb2.screen.window 
{
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.sound.GameSounds;
	import com.jaycsantos.util.*;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.geom.*;
	import flash.text.TextField;
	import pb2.game.ctrl.SaveDataMngr;
	import pb2.game.*;
	import pb2.GameAudio;
	import pb2.screen.*;
	import pb2.screen.ui.*;
	import pb2.util.pb2internal;
	import Playtomic.*;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class LevelSelect extends FadeWindow 
	{
		public static const PERPAGE:uint = 18;
		
		
		public function LevelSelect( parentClass:Class ) 
		{
			super();
			var g:Graphics, sp:Sprite, mc:MovieClip, shp:Shape, txf:TextField, i:int, j:int, k:String, a:Array, xml:XML;
			_parentClass = parentClass;
			
			{//-- title
				_contents.addChild( sp = PuttBase2.assets.createDisplayObject('screen.ui.bg.bgLevelSelect') as Sprite );
				sp.mouseEnabled = false;
				_contents.addChild( UIFactory.createFixedTextField('COURSE SELECT', 'lvlsHeader', 'center', 325, 18) );
				
				_canvas.graphics.clear();
				_canvas.graphics.beginFill( 0, .89 );
				_canvas.graphics.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			}
			
			{//-- total score
				var saveMngr:SaveDataMngr = SaveDataMngr.instance;
				
				_contents.addChild( _txfTotal = UIFactory.createTextField('<span class="lvlsTotalScore"></span>\n', 'lvlsTotalPar', 'right', 615, 280) );
				_contents.addChild( _txfTotalTitle = UIFactory.createFixedTextField('Total Score', 'lvlsSubTitle', 'left', 555, 270) );
				_txfTotalTitle.visible = true;
				_txfTotal.multiline = true;
			}
			
			{//-- tab
				_contents.addChild( _btnAmateur = PuttBase2.assets.createDisplayObject('screen.ui.btn.tabAmateur') as MovieClip );
				_btnAmateur.buttonMode = true;
				
				_contents.addChild( _btnPro = PuttBase2.assets.createDisplayObject('screen.ui.btn.tabPro') as MovieClip );
				_btnPro.buttonMode = true;
				
				var pro1:XML = MapList.list.level.(@name=='Pro-1')[0];
				if ( CONFIG::debug || SaveDataMngr.instance.isLevelOpen(pro1) ) {
					_btnPro.gotoAndStop( 2 );
					
					xml = MapList.list;
					if ( xml.level.(@name == 'Pro-1').length() ) {
						xml = xml.level.(@name=='Pro-1')[0];
						if ( !SaveDataMngr.instance.getLevelData(xml.@name, xml.@hash) )
							_contents.addChildAt( _clipNewSetReady = PuttBase2.assets.createDisplayObject('screen.ui.ico.setReadyIco') as Sprite, _contents.numChildren - 2 );
					}
				} else {
					_btnPro.mouseEnabled = false;
					_btnPro.gotoAndStop( 1 );
				}
				
				if ( _setIndex == 1 ) {
					_btnPro.gotoAndStop( 4 );
					_btnPro.mouseEnabled = false;
					_btnAmateur.gotoAndStop( 2 );
				} else {
					_btnAmateur.gotoAndStop( 4 );
					_btnAmateur.mouseEnabled = false;
					if ( _btnPro.currentFrame > 1 )
						_btnPro.gotoAndStop( 2 );
				}
			}
			
			{//-- levels
				xml = MapList.list;
				_lvlsBmps = new Vector.<BitmapData>;
				_colorXform = new ColorTransform;
				_colorXform2 = new ColorTransform( .5, .5, .5, 1, 102, 102, 77, 0 );
				
				_contents.addChild( _lvlsClip = new Sprite );
				with ( _lvlsClip ) {
					name = 'levels list';
					mouseEnabled = false;
				}
				_lvlsBmps = new Vector.<BitmapData>;
				for ( i=0; i<PERPAGE; i++ ) {
					_lvlsClip.addChild( sp = new Sprite );
					sp.buttonMode = true; sp.mouseChildren = false;
					sp.addChild( new Bitmap(new BitmapData(88, 53, true, 0)) );
					sp.x = 25 +100*(i%6);
					sp.y = 85 +65*(i/6>>0);
					
					_lvlsBmps.push( new BitmapData(88, 53, true, 0) );
				}
			}
			
			{//-- buttons
				_contents.addChild( _btnClose = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnClose') as SimpleButton );
				_btnClose.x = 575; _btnClose.y = parentClass==MenuActScreen ? 15 : -15; _btnClose.name = 'close';
				
				_contents.addChild( _btnSubmit = new SmallBtn1('SUBMIT') );
				_btnSubmit.x = 555; _btnSubmit.y = 320 +(parentClass==MenuActScreen?0:15);
				
				k = saveMngr.getCustom('highscore_name');
				_contents.addChild( _txfName = UIFactory.createFixedTextField( k?k:'', 'lvlsScoreName', 'right', 550, 270) );
				
				_contents.addChild( _btnName = new Sprite );
				_btnName.buttonMode = _btnName.mouseEnabled = CONFIG::debug;
				_btnName.x = _txfName.x; _btnName.y = _txfName.y;
				g = _btnName.graphics;
				g.beginFill( 0, 0 );
				g.drawRect( 0, 0, _txfName.textWidth, 16 );
				_btnName.visible = _txfName.length > 2; _btnName.name = 'rename';
				
				
				_contents.addChild( _clipLoading = PuttBase2.assets.createDisplayObject('screen.ui.ico.iconLoading') as MovieClip );
				_clipLoading.x = _btnSubmit.x +30; _clipLoading.y = _btnSubmit.y +7.5;
				_clipLoading.stop(); _clipLoading.visible = false;
				
				CONFIG::onFGL {
					_contents.addChild( _btnFglOpenAll = new SmallBtn1('(FGL) UNLOCK ALL AVAILABLE LEVELS', 200) );
					_btnFglOpenAll.x = 225; _btnFglOpenAll.y = 290;
					//_btnFglOpenAll.visible = uint(saveMngr.getCustom('g0')) < 12;
				}
				
				_contents.addChild( _tip = new PopBtnTip );
			}
			
			
			_contents.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
			_contents.addEventListener( MouseEvent.MOUSE_OVER, _movr, false, 0, true );
			_contents.addEventListener( MouseEvent.MOUSE_OUT, _mout, false, 0, true );
			_contents.y = parentClass==MenuActScreen ? 0 : 30;
			
			onPreShow.addOnce( _populate );
		}
		
		override public function dispose():void 
		{
			_contents.removeEventListener( MouseEvent.CLICK, _click );
			_contents.removeEventListener( MouseEvent.MOUSE_OVER, _movr );
			_contents.removeEventListener( MouseEvent.MOUSE_OUT, _mout );
			
			_lvlsClip = null;
			_btnAmateur = _btnPro = null;
			_tip.dispose(); _tip = null;
			_colorXform = _colorXform2 = null;
			_parentClass = null;
			
			for each ( var bmp:BitmapData in _lvlsBmps ) bmp.dispose();
			_lvlsBmps.splice( 0, _lvlsBmps.length );
			
			super.dispose();
		}
		
		
			// -- private --
			
			private var _tip:PopBtnTip, _lvlsClip:Sprite, _txfTotal:TextField, _txfTotalTitle:TextField, _clipLoading:MovieClip, _clipNewSetReady:Sprite, _lvlsBmps:Vector.<BitmapData>
			private var _btnClose:SimpleButton, _btnAmateur:MovieClip, _btnPro:MovieClip, _btnSubmit:SmallBtn1, _btnName:Sprite, _txfName:TextField
			private var _index:int, _setIndex:int, _parentClass:Class, _colorXform:ColorTransform, _colorXform2:ColorTransform
			
			private var _btnFglOpenAll:SmallBtn1;
			
			
			override protected function _update():void 
			{
				super._update();
			
				if ( _btnSubmit ) _btnSubmit.update();
				if ( _btnFglOpenAll ) _btnFglOpenAll.update();
				
				if ( UserInput.instance.isKeyDown(KeyCode.ESC) )
					hide();
			}
			
			
			private function _populate():void
			{
				var levelIndex:int = Session.isOnPlay? Session.instance.map.levelIndex : -1;
				var saveMngr:SaveDataMngr = SaveDataMngr.instance;
				var xml:XML = MapList.list;
				var xmlSave:XML, xmllist:XMLList = xml.level.(@sett == _setIndex);
				var i:int, j:int, w:uint, txf:TextField, sp:Sprite, g:Graphics;
				
				sp = new Sprite;
				with ( sp.addChild(new Bitmap) ) x = y = 4;
				sp.addChild( new Sprite );
				sp.addChild( UIFactory.createFixedTextField('', 'levelName', 'left') );
				sp.addChild( UIFactory.createTextField('', 'levelScore', 'right', 82, 22) );
				with ( sp.addChild(PuttBase2.assets.createDisplayObject('screen.ui.bg.lockedLvlBg')) ) x = y = 4;
				g = sp.graphics;
				g.beginFill( 0xB9CC72 );
				g.drawRoundRect( 0, 0, 88, 53, 5, 5 );
				
				
				var par:int, bmp:Bitmap, bmp2:Bitmap, pt:Point = new Point;
				for ( i=0; i<PERPAGE; i++ ) {
					bmp = Sprite(_lvlsClip.getChildAt(i)).getChildAt( 0 ) as Bitmap;
					xml = xmllist[i];
					if ( xml != null ) {
						bmp.visible = true;
						bmp.parent.mouseEnabled = false;
						sp.getChildAt(4).visible = false;
						
						if ( !saveMngr.isLevelOpen(xml) ) {
							sp.getChildAt(4).visible = true;
							sp.getChildAt(0).visible = sp.getChildAt(1).visible = sp.getChildAt(2).visible = sp.getChildAt(3).visible = false;
							
							_lvlsBmps[i].fillRect( bmp.bitmapData.rect, 0 );
							_lvlsBmps[i].draw( sp );
							
							with ( bmp.bitmapData ) {
								lock();
								fillRect( rect, 0 );
								applyFilter( _lvlsBmps[i], rect, pt, ColorMatrixUtil.setSaturation(-100) );
								unlock();
							}
							bmp.transform.colorTransform = _colorXform2;
							
						}
						else {
							xmlSave = saveMngr.getLevelData( xml.@name, xml.@hash );
							bmp.parent.mouseEnabled = true;
							sp.getChildAt(0).visible = sp.getChildAt(1).visible = sp.getChildAt(2).visible = sp.getChildAt(3).visible = true;
							sp.name =  xml.@hash;
							g = Sprite(sp.getChildAt(1)).graphics;
							g.clear();
							
							TextField(sp.getChildAt(2)).text = String(xml.@name).replace(/\-/g,' ');
							g.beginFill( 0xB9CC72 );
							g.drawRoundRect( 0, 0, sp.getChildAt(2).width, 15, 5, 5 );
							
							bmp2 = sp.getChildAt(0) as Bitmap;
							
							if ( bmp2.bitmapData ) {
								bmp2.bitmapData.dispose();
								bmp2.bitmapData = null;
							}
							if ( xml.child('clip').length() )
								bmp2.bitmapData = PuttBase2.assets.createBitmapData( xml.clip );
								
							
							if ( int(xmlSave.@score) ) {
								par = int(xmlSave.@par);
								TextField(sp.getChildAt(3)).htmlText = '<p class="levelPar">'+ (par>0?par+' over':(par<0?Math.abs(par)+' under':'')) +' par</p>\n<p class="levelScore">'+ int(xmlSave.@score) +'</p>\n';
								
								g.beginFill( 0x3F3F3F, .5 );
								g.drawRect( 4, 25, 80, 25 );
								
							} else
								TextField(sp.getChildAt(3)).htmlText = '';
							
							_lvlsBmps[i].fillRect( bmp.bitmapData.rect, 0 );
							_lvlsBmps[i].draw( sp );
							
							with ( bmp.bitmapData ) {
								lock();
								fillRect( rect, 0 );
								if ( i+_setIndex*PERPAGE == levelIndex )
									copyPixels( _lvlsBmps[i], rect, pt );
								else
									applyFilter( _lvlsBmps[i], rect, pt, ColorMatrixUtil.setSaturation(-100) );
								unlock();
							}
							if ( i+_setIndex*PERPAGE == levelIndex )
								bmp.transform.colorTransform = _colorXform;
							else
								bmp.transform.colorTransform = _colorXform2;
						}
					}
					else {
						bmp.visible = false;
					}
				}
				
				xml = saveMngr.getGroupTotalData( _setIndex );
				i = uint(xml.@score);
				if ( i ) {
					j = int(xml.@par);
					var parStr:String = (j!=0?(j>0?j+' over':Math.abs(j)+' under'):'') +' par';
					_txfTotal.htmlText = '<span class="lvlsTotalScore">'+ MathUtils.toThousands(i) +'</span><br/>\n<span class="lvlsTotalPar">'+ parStr +'</span>';
				}
				
				_txfTotal.visible = _txfTotalTitle.visible = _txfName.visible = i > 0;
				_btnSubmit.visible = i > 6000 && saveMngr.getCustom('pendHighScoreSubmit');
			}
			
			
			private function _click( e:MouseEvent ):void
			{
				switch ( e.target ) {
					case _btnAmateur:
						SaveDataMngr.instance.saveCustom( 'lastMapSet', _setIndex = 0 );
						_btnAmateur.gotoAndStop( 4 );
						_btnAmateur.mouseEnabled = false;
						_btnPro.gotoAndStop( 2 );
						_btnPro.mouseEnabled = true;
						
						_populate();
						break;
						
					case _btnPro:
						SaveDataMngr.instance.saveCustom( 'lastMapSet', _setIndex = 1 );
						_btnPro.gotoAndStop( 4 );
						_btnPro.mouseEnabled = false;
						_btnAmateur.gotoAndStop( 2 );
						_btnAmateur.mouseEnabled = true;
						
						if ( _clipNewSetReady && _clipNewSetReady.parent ) {
							_clipNewSetReady.parent.removeChild( _clipNewSetReady );
							_clipNewSetReady = null;
						}
						
						_populate();
						break;
						
					case _btnClose:
						hide();
						break;
					
					case _btnName:
						var win:Window = new GetNameWindow( LevelSelect );
						addChild( win );
						win.onHidden.addOnce( _getScoreName );
						win.show();
						break;
						
					case _btnSubmit:
						_submitHighscore();
						break;
					
					case _btnFglOpenAll:
						CONFIG::onFGL {
							SaveDataMngr.instance.saveCustom('g0', 99);
							SaveDataMngr.instance.saveCustom('g1', 99);
							SaveDataMngr.instance.saveCustom('g2', 99);
							SaveDataMngr.instance.saveCustom('g3', 99);
							SaveDataMngr.instance.saveCustom('g4', 99);
							SaveDataMngr.instance.saveCustom('g5', 99);
							_populate();
							SaveDataMngr.instance.saveCustom('g0', 99, true);
							_btnFglOpenAll.visible = false;
							_btnPro.gotoAndStop( 2 );
							_btnPro.mouseEnabled = true;
							addChild( PopPrompt.create('Available levels were unlocked', 110, {name:'OK'}) );
						}
						break;
						
					default:
						if ( DisplayObject(e.target).parent == _lvlsClip ) {
							_index = _lvlsClip.getChildIndex( DisplayObject(e.target) );
							
							if ( _parentClass==PopSuccess ) {
								PopSuccess(parent).onHidden.addOnce( _openLevel );
								Window.removeAllWindows();
								visible = false;
								
							} else {
								_openLevel();
							}
						}
						break;
				}
				
			}
			
			private function _movr( e:MouseEvent ):void
			{
				switch ( e.target ) {
					case _btnAmateur:
						_btnAmateur.gotoAndStop( 3 );
						break;
					case _btnPro:
						_btnPro.gotoAndStop( 3 );
						break;
						
					case _btnClose:
					case _btnName:
						var d:DisplayObject = e.target as DisplayObject;
						_tip.pop( d.name, d.x +(d==_btnName?_btnName.width/2:0), d.y );
						break;
						
					default:
						if ( DisplayObject(e.target).parent != _lvlsClip ) break;
						
						var i:int = _lvlsClip.getChildIndex( DisplayObject(e.target) );
						if ( Session.isOnPlay && i == Session.instance.map.levelIndex ) break;
						
						var bmp:Bitmap = Sprite(e.target).getChildAt( 0 ) as Bitmap;
						with ( bmp.bitmapData ) {
							lock();
							fillRect( rect, 0 );
							copyPixels( _lvlsBmps[i], rect, new Point );
							unlock();
						}
						bmp.transform.colorTransform = _colorXform;
				}
			}
			
			private function _mout( e:MouseEvent ):void
			{
				switch ( e.target ) {
					case _btnAmateur:
						if ( _btnAmateur.mouseEnabled )
							_btnAmateur.gotoAndStop( 2 );
						break;
					case _btnPro:
						if ( _btnPro.mouseEnabled )
							_btnPro.gotoAndStop( 2 );
						break;
						
					case _btnClose:
					case _btnName:
						_tip.hide();
						break;
						
					default:
						if ( DisplayObject(e.target).parent != _lvlsClip ) break;
						
						var i:int = _lvlsClip.getChildIndex( DisplayObject(e.target) );
						if ( Session.isOnPlay && i == Session.instance.map.levelIndex ) break;
						
						var bmp:Bitmap = Sprite(e.target).getChildAt( 0 ) as Bitmap;
						with ( bmp.bitmapData ) {
							lock();
							fillRect( rect, 0 );
							applyFilter( _lvlsBmps[i], rect, new Point, ColorMatrixUtil.setSaturation(-100) );
							unlock();
						}
						bmp.transform.colorTransform = _colorXform2;
						break;
				}
			}
			
			
			private function _openLevel():void
			{
				var xml:XML = MapList.list;
				var data:XML = xml.level.(@sett == _setIndex)[_index];
				
				var saveMngr:SaveDataMngr = SaveDataMngr.instance;
				if ( !saveMngr.isLevelOpen(data) ) return;
				
				saveMngr.saveCustom( 'lastMap', _index, false );
				saveMngr.saveCustom( 'lastMapSet', _setIndex, true );
				
				var ses:Session = Session.instance;
				var oldMap:MapData = ses.map;
				ses.map = new MapData( data, null, _index+_setIndex*PERPAGE );
				
				switch ( _parentClass ) {
					case MenuActScreen: Tracker.i.startLevel( ses.map, 'mainmenu' ); break;
					case PopSuccess:
						Tracker.i.startLevel( ses.map, 'success' ); 
						if ( !oldMap.isCustom )
							Tracker.i.levelCounter( 'changelevel', oldMap.name );
						break;
					case PopFail:
						Tracker.i.startLevel( ses.map, 'fail' );
						if ( !oldMap.isCustom )
							Tracker.i.levelCounter( 'fail_changelevel', oldMap.name );
						break;
					case PauseMenu:
						Tracker.i.quitLevel( oldMap, 'pauseMenu' );
						Tracker.i.startLevel( ses.map, 'pauseMenu' );
						if ( !oldMap.isCustom )
							Tracker.i.levelCounter( 'pause_changelevel', oldMap.name );
						break;
				}
				
				CONFIG::debug {
					GameRoot.changeScreen( RelayScreen, UserInput.instance.isKeyDown(KeyCode.SPACEBAR)? EditorScreen: PlayScreen ); }
				CONFIG::release {
					GameRoot.changeScreen( RelayScreen, PlayScreen ); }
			}
			
			
			private function _getScoreName():void
			{
				var k:String = SaveDataMngr.instance.getCustom('highscore_name');
				_txfName.text = k?k:'';
				
				var g:Graphics = _btnName.graphics;
				g.clear();
				g.beginFill( 0, 0 );
				g.drawRect( 0, 0, _txfName.textWidth, 16 );
				
				_btnName.x = _txfName.x; _btnName.y = _txfName.y;
			}
			
			private function _submitHighscore():void
			{
				if ( !SaveDataMngr.instance.getCustom('highscore_name') ) {
					var win:Window = new GetNameWindow( LevelSelect );
					addChild( win );
					win.onHidden.addOnce( _submitHighscore );
					win.show();
					return;
					
				} else {
					_txfName.text = SaveDataMngr.instance.getCustom('highscore_name');
					var data:PlayerScore = new PlayerScore( _txfName.text, int(SaveDataMngr.instance.getTotalData().@score) );
					Leaderboards.SaveAndList( data, Registry.PLAYTOMIC_LEADERBOARDS, _submitted, {global:Registry.PLAYTOMIC_GLOBAL_LEADERBOARD, perpage:1} );
					
					_clipLoading.visible = true;
					_clipLoading.play();
					_btnSubmit.visible = _btnName.visible = false;
				}
			}
			
			private function _submitted( scores:Array, numscores:int, response:Object ):void
			{
				if ( !parent || !visible ) return;
				
				if ( response.Success && scores.length ) {
					SaveDataMngr.instance.saveCustom( 'pendHighScoreSubmit', '', true );
					
					var data:PlayerScore, total:int = int(SaveDataMngr.instance.getTotalData().@score);
					for each( data in scores )
						if ( data.Name == SaveDataMngr.instance.getCustom('highscore_name') && data.Points == total )
							break;
					
					_txfName.appendText( ' (rank: '+ MathUtils.toRank(data.Rank+int(Registry.PLAYTOMIC_VARS.HighscoreRankOffset)).toUpperCase() +')' );
					
					if ( Session.isOnMenu )
						MenuActScreen(GameRoot.screen).pb2internal::reloadLeaderboard();
				} else {
					_btnSubmit.visible = _btnName.visible = true;
					
					CONFIG::debug {
						addChild( new PopPrompt('Error Code '+ response.ErrorCode +' returned', 110, [{name:'OK'}]) ); }
					CONFIG::release {
						addChild( new PopPrompt('Server might be busy. Try again later. (@FGL Er#' + response.ErrorCode +' '+ Registry.PLAYTOMIC_ERR_MSG[response.ErrorCode] +')', 160, [ { name:'OK' } ]) );
					}
				}
				
				_clipLoading.visible = false;
				_clipLoading.stop();
			}
			
			
			
	}

}