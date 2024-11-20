package pb2.screen.window 
{
	import com.adobe.crypto.MD5;
	import com.adobe.images.PNGEncoder;
	import com.greensock.easing.*;
	import com.jaycsantos.display.animation.AnimationTiming;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.sound.*;
	import com.mindjolt.api.as3.MindJoltAPI;
	import com.newgrounds.API;
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.net.*;
	import flash.text.TextField;
	import flash.utils.*;
	import mx.utils.Base64Encoder;
	import pb2.game.ctrl.*;
	import pb2.game.entity.b2.*;
	import pb2.game.entity.*;
	import pb2.game.*;
	import pb2.*;
	import pb2.screen.*;
	import pb2.screen.tutorial.*;
	import pb2.screen.ui.*;
	import pb2.util.*;
	import Playtomic.*;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PopSuccess extends PopWindow 
	{
		
		public function PopSuccess() 
		{
			super();
			var g:Graphics, sp:Sprite, mc:MovieClip, mc2:MovieClip, shp:Shape, txf:TextField, i:int, j:int, k:String, a:Array, xml:XML;
			var xOff:int = 210, yOff:int = 130;
			
			{//-- init vars
				var map:MapData = Session.instance.map;
				var hud:HudGame = HudGame.instance;
				var strokes:uint = hud.swings;
				var itemsUnused:uint = hud.unusedItems;
				var par:int = strokes -map.par;
				
				var saveMngr:SaveDataMngr = SaveDataMngr.instance;
				var xmlSave:XML = map.isCustom? saveMngr.getPlayerLevelData( map.name, map.customLevel.id ): saveMngr.getLevelData( map.name, map.hash );
				var pscore:uint = xmlSave ? uint(xmlSave.@score) : 0;
				var ppar:int = xmlSave ? int(xmlSave.@par) : 0;
				var mapSet:uint = int( saveMngr.getCustom('lastMapSet') );
				var mapIndex:uint = int( saveMngr.getCustom('lastMap') );
				var open2ndSet:Boolean = int(saveMngr.getCustom('g3')) > 0;
				
				var tile:b2EntityTile, list:Vector.<b2EntityTile>
				var tilemap:Vector.<Vector.<b2EntityTile>> = Session.instance.tileMap;
				var awesome:AwesomenessCtrl = AwesomenessCtrl.i;
				
				if ( strokes != awesome.shot ) {
					GameRoot.changeScreen( MapErrorScreen, new Error('Inconsistent values found',0) );
					return;
				}
				
				if ( strokes <= map.par )
					_score = 2000*(mapSet+1) +1500*(map.par -strokes);
				else
					_score = 2000*(mapSet+1) *1/(par+1) >>0;
				_score += itemsUnused *60;
				_score += awesome.bounce *10;
				_score += awesome.glass *500;
				_score += awesome.spring *30;
				_score += awesome.spin *20;
				_score += awesome.beep *20;
				_score += awesome.warp *100;
				_score += awesome.boom *200;
				_score += strokes == 1?750:0;
				
				saveMngr[map.isCustom?'savePlayerLevelData':'saveLevelData']( map, _score, par, itemsUnused, new Date().toUTCString() );
				_bg.name = MD5.hash( _score +map.hash );
				
				if ( !map.isCustom )
					Tracker.i.levelAverage( 'stroke', map.name, strokes );
				
				if ( !xmlSave || !xmlSave.child('rank_all').length() || !int(xmlSave.rank_all[0].@r) )
					_rankUnSent = true;
				
				if ( !map.isCustom && !open2ndSet && map.group==3 )
					_open2ndSet = true;
			}
			
			
			{//-- stats
				if ( CONFIG::onKong && PuttBase2.kongregate && !map.isCustom ) {
					xml = saveMngr.getGroupTotalData( mapSet );
					if ( mapSet == 0 ) {
						PuttBase2.kongregate.stats.submit( "LevelsCompletedAmateur", uint(xml.@count) );
						PuttBase2.kongregate.stats.submit( "AmateurScore", uint(xml.@score) );
						PuttBase2.kongregate.stats.submit( "TotalParAmateur", int(xml.@par) +100 );
						
					} else if ( mapSet == 1 ) {
						PuttBase2.kongregate.stats.submit( "LevelsCompletedPro", uint(xml.@count) );
						PuttBase2.kongregate.stats.submit( "ProScore", uint(xml.@count) );
						PuttBase2.kongregate.stats.submit( "TotalParPro", int(xml.@par) +100 );
					}
					
					if ( _open2ndSet ) PuttBase2.kongregate.stats.submit( "IsPro", 1 );
					
					
					if ( strokes == 1 ) {
						a = String(saveMngr.getCustom('aces')).split('|');
						if ( a.indexOf(mapIndex + mapSet*12) == -1 )
							a.push( mapIndex + mapSet*12 );
						saveMngr.saveCustom( 'aces', a.join('|'), true );
						PuttBase2.kongregate.stats.submit( "Aces", a.length );
					}
					if ( par < 0 ) {
						a = String(saveMngr.getCustom('underpars')).split('|');
						if ( a.indexOf(mapIndex + mapSet*12) == -1 )
							a.push( mapIndex + mapSet*12 );
						saveMngr.saveCustom( 'underpars', a.join('|'), true );
						PuttBase2.kongregate.stats.submit( "UnderPars", a.length );
					}
					
					trace( 'kong stats reported' );
				}
				
				if ( CONFIG::onNG && PuttBase2.ngApi && API.isNewgrounds && API.isNetworkHost && !map.isCustom ) {
					if ( (_open2ndSet || mapSet==1) && !API.getMedal('I Am Pro').unlocked ) API.unlockMedal( 'I Am Pro' );
					if ( strokes == 1 && !API.getMedal('Aces').unlocked ) API.unlockMedal( 'Aces' );
					
					xml = saveMngr.getTotalData();
					if ( int(xml.@count) >= 6 && !API.getMedal('Smirk').unlocked ) API.unlockMedal( 'Smirk' );
					if ( int(xml.@count) >= 12 && !API.getMedal('Smile').unlocked ) API.unlockMedal( 'Smile' );
					if ( int(xml.@count) >= 24 && !API.getMedal('Glorious').unlocked ) API.unlockMedal( 'Glorious' );
					if ( int(xml.@count) >= 30 && !API.getMedal('End').unlocked ) API.unlockMedal( 'End' );
					
					trace( 'NG medals checked' );
				}
				
			}
			
			
			{//-- par result
				_bgClip.addChild( sp = PuttBase2.assets.createDisplayObject('screen.ui.bg.underpar') as Sprite );
				if ( par < 0 ) sp.alpha = Math.min( Math.abs(par) / 4, 1 );
				else sp.alpha = .01;
				sp.x = 325-xOff; sp.y = 153-yOff;
				
				_bgClip.addChild( mc = PuttBase2.assets.createDisplayObject('screen.ui.number.par') as MovieClip );
				mc.gotoAndStop( 10 );
				mc.x = 325-xOff; mc.y = 153-yOff;
				
				if ( par < -4 ) {
					mc.gotoAndStop( 10 );
					mc.addChild( mc2 = PuttBase2.assets.createDisplayObject('screen.ui.number.impact26') as MovieClip );
					mc2.x = -68;
					mc2.gotoAndStop( -par%10? -par%10: 10 );
					
					if ( par < -9 ) {
						mc.addChild( mc2 = PuttBase2.assets.createDisplayObject('screen.ui.number.impact26') as MovieClip );
						mc2.x = -68 -11;
						mc2.gotoAndStop( -par/10%10? -par/10%10: 10 );
					}
					
				} else if ( par > 3 ) {
					mc.gotoAndStop( 11 );
					mc.addChild( mc2 = PuttBase2.assets.createDisplayObject('screen.ui.number.impact26b') as MovieClip );
					mc2.x = -58;
					mc2.gotoAndStop( par%10? par%10: 10 );
					
					if ( par > 9 ) {
						mc.addChild( mc2 = PuttBase2.assets.createDisplayObject('screen.ui.number.impact26b') as MovieClip );
						mc2.x = -58 -11;
						mc2.gotoAndStop( par/10%10? par/10%10: 10 );
					}
					
				} else {
					mc.gotoAndStop( par+5 );
				}
				
				mc.scaleX = mc.scaleY = 1.25;
				if ( par < 0 )
					mc.filters = [new GlowFilter(0x191919, 1, 4, 4, 10), new GlowFilter(0xFFFF66, 1, 36, 36, 1)];
				else if ( par > 0 )
					mc.filters = [new GlowFilter(0x191919, 1, 4, 4, 10), new DropShadowFilter(3, 60, 0, .3, 0, 0, 6)];
				else
					mc.filters = [new GlowFilter(0x191919, 1, 4, 4, 10), new GlowFilter(0xFFFF66, 1, 24, 24, 1)];
				
			}
			
			{//-- bg
				g = _bgClip.graphics;
				g.beginFill( 0, 0 );
				g.drawRect( 0, 0, 230, 160 );
				
				_bgClip.addChild( txf = UIFactory.createTextField('SCORE', 'successHscoreLbl', 'left', 97, 53) );
				txf.filters = [new GlowFilter(0xFFFFCC, 1, 2, 2, 10)];
				
				k = (par!=0?(par>0?par+' over':Math.abs(par)+' under'):'')+' par';
				k += itemsUnused || strokes==1 || awesome.hasAwesome() ? ' + awesomeness' :'';
				k += '\n<span class="successPrev">'+ map.name.replace(/\-/g,' ') +(pscore>0 ?'\nlast best: '+ MathUtils.toThousands(pscore): '') +'</span>';
				_bgClip.addChild( UIFactory.createTextField(k, 'successPar', 'center', 115, 85) );
				
				_contents.addChild( _scrollingMsgs = new ScrollingMsgs );
			}
			
			{//-- texts
				_contents.addChild( _txfScore = UIFactory.createFixedTextField('0', 'successScore', 'center', 115 +xOff, 59 +yOff) );
				
				_contents.addChild( _loading = PuttBase2.assets.createDisplayObject('screen.ui.ico.iconLoading') as MovieClip );
				_loading.visible = false;
				_loading.stop();
			}
			
			{//-- buttons
				_bg.addChild( _btnFb = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnFb_') as SimpleButton );
				_bg.addChild( _btnTwit = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnTwit_') as SimpleButton );
				_bg.addChild( _btnPic = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnCamera_') as SimpleButton );
				_bg.addChild( _btnHscore = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnHighscore_') as SimpleButton );
				
				_contents.addChild( _btnRetry = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnRestart') as SimpleButton );
				_contents.addChild( _btnBrowse = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnList') as SimpleButton );
				_contents.addChild( _btnMenu = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnHome') as SimpleButton );
				_contents.addChild( _btnGames = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnGame') as SimpleButton );
				_contents.addChild( _btnGo = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnGo') as SimpleButton );
				
				_btnFb.visible = _btnTwit.visible = _btnPic.visible = _btnHscore.visible = false;
				_btnFb.enabled = _btnTwit.enabled = _btnPic.enabled = _btnHscore.enabled = false;
				_btnFb.x = _btnTwit.x = _btnPic.x = 226; 
				_btnFb.y = 180; _btnTwit.y = 210; _btnPic.y = 240;
				_btnHscore.x = 424; _btnHscore.y = 240;
				_btnFb.name = 'share'; _btnTwit.name = 'tweet'; _btnPic.name = 'snapshot'; _btnHscore.name = 'ranking';
				_btnBrowse.visible = !map.isCustom;
				
				_btnRetry.x = 235; _btnMenu.x = 275; _btnBrowse.x = 315; _btnGames.x = 355; _btnGo.x = 410;
				_btnRetry.y = _btnBrowse.y = _btnMenu.y = _btnGo.y = _btnGames.y = 267;
				_btnRetry.name = 'retry'; _btnBrowse.name = 'browse';
				_btnMenu.name = 'menu'; _btnGo.name = 'next'; _btnGames.name = 'games';
				
				_contents.addChild( _tip = new PopBtnTip );
			}
			
			{//-- prepare next level
				if ( !map.isCustom ) {
					xml = MapList.list;
					var xmllist:XMLList = xml.level.(@sett == mapSet);
					
					if ( xmllist != null && mapIndex+1 < xmllist.length() && saveMngr.isLevelOpen(xmllist[mapIndex+1]) )
						_nextMap = new MapData( xmllist[mapIndex+1], null, 1 +mapIndex +mapSet*LevelSelect.PERPAGE );
				}
			}
			
			{//-- pop ani
				_bg.addChildAt( _clipShade = PuttBase2.assets.createDisplayObject('screen.windows.puttSuccessDummy') as Sprite, 0 );
				_clipShade.filters = [ new GlowFilter(0x191919, 1, 48, 48, 2, 1, false, true) ];
				_clipShade.visible = false;
				
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.windows.popSuccess') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.addMovieClip( _clip );
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 47, 1), 1, false );
				_animator.addSequenceSet( LOOP, MathUtils.intRangeA(47, 126, 1), 2, true );
				_animator.addSequenceSet( END, MathUtils.intRangeA(1, 32, 1).reverse(), 1, false, onHidden.dispatch );
				_animator.addIndexScript( 12, _showContents, PLAY );
				_animator.addIndexScript( 32, _showSocialBtns, PLAY );
				_animator.addIndexScript( 15, _startRoll, PLAY );
			}
			
			if ( !CONFIG::onAndkon && Registry.useDefaultSponsor ) {//-- is new highscore?
				if ( _score > pscore && !map.isCustom ) {//&& int(saveMngr.getCustom('g0')) > 2 )
					var b64:Base64Encoder = new Base64Encoder;
					//b64.encode( (new Date().valueOf()/1000 >>0)+'' );
					b64.encode( MathUtils.randomInt(0,131072)+'' );
					saveMngr.saveCustom( 'rankExtra_grp'+ map.sett, b64.toString() );
					
					saveMngr.saveCustom( 'pendScore_grp'+ map.sett, 1, true );
				}
				
				if ( _score >= pscore || _rankUnSent ) {
					if ( !map.isCustom && int(map.xml.@gs) && CONFIG::useGamersafe ) {
						// an already loaded scoreboard of this level was loaded a while ago
						if ( RankMngr.i.lastScoresId == int(map.xml.@gs) && RankMngr.i.lastScoresObj ) {
							_onGsRequestLevelRankEst();
							
						} else {
							CONFIG::useGamersafe {
								if ( GamerSafe.api && GamerSafe.api.loaded ) {
									GamerSafeHelper.i.scoreReceived.addOnce( _onGsRequestLevelRankEst );
									GamerSafeHelper.i.scoreError.addOnce( _onGsError );
									GamerSafeHelper.i.networkError.addOnce( _onGsError );
									GamerSafe.api.requestScoreboardEntries( int(map.xml.@gs) );
								}
							}
						}
						
					} else
					if ( map.isCustom ) {
						_onGsRequestCustomRankEst();
						
					}
				}
			}
			if ( CONFIG::onMbreaker && !Registry.useDefaultSponsor && (_score > pscore || _rankUnSent) && !map.isCustom ) {
				_newHscoreRankStr = ' ';
			}
			
			
			{//-- pop score calc
				_contents.addChild( _popScore = PuttBase2.assets.createDisplayObject('screen.windows.popScoreInfo') as MovieClip );
				_popScore.gotoAndStop( 9 ); _popScore.mouseEnabled = true; _popScore.mouseChildren = false;
				//_popScore.x = -210; _popScore.y = -130;
				
				_popScore.addChild( _txfScore2 = UIFactory.createFixedTextField(MathUtils.toThousands(_score), 'successScore2', 'center', 115 +xOff, 59 +yOff) );
				_txfScore2.visible = false;
				
				_popScore.addChild( _clipCalc = new Sprite );
				_clipCalc.name = 'score calc'; _clipCalc.mouseEnabled = _clipCalc.visible = false;
				//_clipCalc.addChild( txf = UIFactory.createFixedTextField('Score Calculation', 'successScoreCalcH1', 'left', 410, 91) );
				
				{
					k = MathUtils.toThousands(2000*(mapSet+1)) +'\n';
					if ( map.par != strokes ) {
						if ( strokes<map.par ) k += '+'+ MathUtils.toThousands(1500*(map.par-strokes)) +'\n';
						else k += '-'+ MathUtils.toThousands(2000-(2000*1/(par+1) >>0)) +'\n';
					}
					if ( strokes==1 ) k += '+750\n';
					if ( itemsUnused ) k += '+'+ MathUtils.toThousands(60*itemsUnused) +'\n';
					if ( awesome.bounce ) k += '+'+ MathUtils.toThousands(10*awesome.bounce) +'\n';
					if ( awesome.spin ) k += '+'+ MathUtils.toThousands(20*awesome.spin) +'\n';
					if ( awesome.beep ) k += '+'+ MathUtils.toThousands(20*awesome.beep) +'\n';
					if ( awesome.spring ) k += '+'+ MathUtils.toThousands(30*awesome.spring) +'\n';
					if ( awesome.warp ) k += '+'+ MathUtils.toThousands(100*awesome.warp) +'\n';
					if ( awesome.boom ) k += '+'+ MathUtils.toThousands(200*awesome.boom) +'\n';
					if ( awesome.glass ) k += '+'+ MathUtils.toThousands(500*awesome.glass) +'\n';
				}
				_clipCalc.addChild( txf = UIFactory.createFixedTextField(k, 'successScoreCalcL', 'none', 255, 222) );
				txf.width = 45; txf.height = 110;
				
				{
					k = 'putt success\n';
					if ( map.par != strokes ) k += (par!=0?(par>0?par+' over':Math.abs(par)+' under'):'')+' par\n';
					if ( strokes==1 ) k += 'hole in one\n';
					if ( itemsUnused ) k += 'spare item\n';
					if ( awesome.bounce ) k += 'good bounce\n';
					if ( awesome.spin ) k += 'power spin\n';
					if ( awesome.beep ) k += 'button press\n';
					if ( awesome.spring ) k += 'punched\n';
					if ( awesome.warp ) k += 'space warp\n';
					if ( awesome.boom ) k += 'kaboom\n';
					if ( awesome.glass ) k += 'broken glass\n';
				}
				_clipCalc.addChild( txf = UIFactory.createFixedTextField(k, 'successScoreCalcR', 'none', 310, 222) );
				txf.width = 90; txf.height = 110;
				
				_popScoreAni = new AnimationTiming( MathUtils.intRangeA(1,12,1).reverse(), 3, 3, false, _showScoreCalc );
				_popScoreAni.addSequenceSet( 'hide', MathUtils.intRangeA(1,12,1), 3, false );
				_popScoreAni.addMovieClip( _popScore );
			}
			
			Tracker.i.finishLevel( map, {score:_score, stroke:strokes, bounce:awesome.bounce, items:itemsUnused} );
			
			addEventListener( MouseEvent.CLICK, _click, false, 0, true );
			addEventListener( MouseEvent.MOUSE_OVER, _movr, false, 0, true );
			addEventListener( MouseEvent.MOUSE_OUT, _mout, false, 0, true );
		}
		
		override public function dispose():void 
		{
			removeEventListener( MouseEvent.CLICK, _click );
			removeEventListener( MouseEvent.MOUSE_OVER, _movr );
			removeEventListener( MouseEvent.MOUSE_OUT, _mout );
			
			_clipShade = null;
			_popBg = null; _txfScore = _txfScore2 = null;
			_btnFb = _btnTwit = _btnPic = _btnHscore = _btnRetry = _btnBrowse = _btnMenu = _btnGo = _btnGames = null;
			if ( _tip ) _tip.dispose(); _tip = null;
			_clipCalc = null;
			_popScore = null;
			if ( _popScoreAni ) _popScoreAni.dispose(); _popScoreAni = null;			
			
			super.dispose();
		}
		
		
		override public function update():void 
		{
			super.update();
			
			if ( _rolling ) {
				var t:uint = getTimer();
				if ( _rollStart + _rollDur>t ) {
					var k:String = MathUtils.toThousands( Quad.easeOut( t-_rollStart, 0, _score, _rollDur ) >>0 );
					if ( _txfScore.text != k ) {
						_txfScore.text = k;
						GameSounds.play( GameAudio.FLICK, 0, 0, 0.5 );
					}
				}
				else {
					_txfScore.text = MathUtils.toThousands(_score >> 0);
					_rolling = false;
					
					var win:Window;
					if ( Session.instance.map.isCustom ) {
						win = new PopCustomRate;
						addChild( win ); win.show();
						
					}
					
					if ( _newHscoreRankStr )
						_showNewScorePop();
					else
						_showPopSocial();
						
					if ( _open2ndSet )
						_showPopPro();
						//addChild( PopPrompt.create('Professional\'s Courses can now be played!\nClick browse and select Professionals.', 200, {name:'OK'}) );
				}
			}
			else if ( _btnFb && _animator.setName==LOOP ) {
				if ( _popScoreAni && _popScoreAni.isPlaying )
					_popScoreAni.update();
				
				var nx:int, dx:Number;
				
				dx = (nx = (_btnFb.enabled? 196: 206)) -_btnFb.x;
				if ( Math.abs(dx) > 0.1 ) _btnFb.x += dx /6;
				else _btnFb.x = nx;
				
				dx = (nx = (_btnTwit.enabled? 196: 206)) -_btnTwit.x;
				if ( Math.abs(dx) > 0.1 ) _btnTwit.x += dx /6
				else _btnTwit.x = nx;
				
				dx = (nx = (_btnPic.enabled? 196: 206)) -_btnPic.x;
				if ( Math.abs(dx) > 0.1 ) _btnPic.x += dx /6;
				else _btnPic.x = nx;
				
				dx = (nx = (_btnHscore.enabled? 454: 444)) -_btnHscore.x;
				if ( Math.abs(dx) > 0.1 ) _btnHscore.x += dx /6;
				else _btnHscore.x = nx;
				
			}
			
			_scrollingMsgs.update();
		}
		
		
		override public function show():void 
		{
			if ( !_btnFb ) {
				dispose();
				return;
			}
			
			GameAudio.instance.playVictoryMusic( HudGame.instance.swings < Session.instance.map.par );
			
			super.show();
			
			_animator.appendSet( LOOP );
		}
		
		override public function hide():void 
		{
			super.hide();
			
			_btnFb.visible = _btnTwit.visible = _btnPic.visible = _btnHscore.visible = false;
			_clipShade.visible = false;
			_contents.visible = _bgBmp.visible = false;
			_overlay.alpha = 0;
			
			GameAudio.instance.stopVictoryMusic();
		}
		
		
			// -- private --
			
			private static const LOOP:String = 'loop';
			
			private var _clipShade:Sprite, _socialAnimator:AnimationTiming
			private var _popBg:MovieClip, _txfScore:TextField, _txfScore2:TextField, _tip:PopBtnTip, _score:uint
			private var _btnFb:SimpleButton, _btnTwit:SimpleButton, _btnPic:SimpleButton, _btnHscore:SimpleButton, _btnRetry:SimpleButton, _btnBrowse:SimpleButton, _btnMenu:SimpleButton, _btnGo:SimpleButton, _btnGames:SimpleButton
			private var _rolling:Boolean, _rollStart:uint, _rollDur:uint, _loading:MovieClip
			private var _bmpSolution:BitmapData, _bmpResult:BitmapData, _watermarkClip:Sprite, _date:String, _nextMap:MapData, _open2ndSet:Boolean
			private var _scrollingMsgs:ScrollingMsgs
			
			private var _popScore:MovieClip, _clipCalc:Sprite, _popScoreAni:AnimationTiming
			
			private var _newHscoreRankStr:String, _newHscore:PopInfoNewScore, _rankUnSent:Boolean, _rankWin:PopSuccessRanks
			private var _popPic:PopInfoPic, _popSocial:PopInfoSocial, _popPro:PopInfoPro
			
			
			override protected function _init( e:Event ):void 
			{
				_contents.x = 210; _contents.y = 130;
				super._init( e );
				_contents.x = _contents.y = 0;
				
				Session.instance.stop();
				CameraFocusCtrl.instance.disable();
			}
			
			
			private function _click( e:Event ):void
			{
				if ( _rolling ) {
					_rollStart -= _rollDur;
					return;
				}
				
				if ( Session.isBusy ) return;
				
				var map:MapData = Session.instance.map;
				var urlvar:URLVariables, win:Window;
				switch( e.target ) {
					case _btnRetry:
						if ( HudGame(parent).restart() )
							Tracker.i.buttonClick( 'reset', 'success' );
						if ( !map.isCustom )
							Tracker.i.levelCounter( 'retry', map.name );
						
						Tracker.i.startLevel( map, 'success' );
						GameAudio.instance.stopVictoryMusic();
						
						onHidden.addOnce( Session.instance.start );
						onHidden.addOnce( CameraFocusCtrl.instance.enable );
						onHidden.addOnce( function():void { GameAudio.instance.playGameMusic(GameAudio.instance.lastGameMusic); } );
						Window.removeAllWindows();
						break;
						
					case _btnBrowse:
						if ( _popPro ) _popPro.hide(); _popPro = null;
						
						addChild( win = map.isCustom ? new CLevelsWindow(PopSuccess) : new LevelSelect(PopSuccess) );
						win.show();
						break;
						
					case _btnMenu:
						addChild( PopPrompt.create('Are you sure you want to exit to main menu?', 110, {name:'YES', call:_goMainMenu}, {name:'NO'}) );
						break;
						
					case _btnGo:
						var saveMngr:SaveDataMngr = SaveDataMngr.instance;
						if ( _nextMap != null ) {
							if ( !Session.instance.map.isCustom )
								Tracker.i.levelCounter( 'nextlevel', Session.instance.map.name );
							Session.instance.map = _nextMap;
							SaveDataMngr.instance.saveCustom( 'lastMap', int(SaveDataMngr.instance.getCustom('lastMap'))+1, true );
							onHidden.addOnce( function():void { GameRoot.changeScreen( RelayScreen, PlayScreen ); } );
							Window.removeAllWindows();
							
							Tracker.i.startLevel( _nextMap, 'success' );
							
						} else {
							if ( int(saveMngr.getCustom('lastMapSet')) < 2 )
								SaveDataMngr.instance.saveCustom( 'lastMapSet', int(saveMngr.getCustom('lastMapSet')), true );
							addChild( win = map.isCustom ? new CLevelsWindow(PopSuccess) : new LevelSelect(PopSuccess) );
							win.show();
						}
						break;
						
					case _btnFb:
						if ( _popSocial ) _popSocial.hide(); _popSocial = null;
						
						urlvar = new URLVariables();
						if ( map.isCustom ) {
							urlvar.t = 'Putt More Base - '+ map.customLevel.name +' (custom level)';
							urlvar.u = Registry.SPONSOR_GAME_URL_LVLID +map.customLevel.id;
						} else {
							urlvar.t = 'Putt More Base - level: '+ map.name.replace(/\-/g,' ');
							urlvar.u = Registry.SPONSOR_GAME_URL;
						}
						Link.Open( 'http://www.facebook.com/sharer.php?'+ urlvar.toString(), 'CustomLevel_fb', 'success' );
						break;
					
					case _btnTwit:
						if ( _popSocial ) _popSocial.hide(); _popSocial = null;
						
						urlvar = new URLVariables();
						if ( map.isCustom )
							urlvar.status = 'Beat my score '+_score+',play PuttMoreBase level '+ Registry.SPONSOR_GAME_URL_LVLID +map.customLevel.id;
						else
							urlvar.status = 'Beat my score '+_score+',play PuttMoreBase level:'+ map.name.replace(/\-/g,' ') +' '+ Registry.SPONSOR_GAME_URL;
						Link.Open( 'http://twitter.com/?'+ urlvar.toString(), 'CustomLevel_twit', 'success' );
						break;
					
					case _btnPic:
						if ( _popPic ) _popPic.hide(); _popPic = null;
						
						GameSounds.play( GameAudio.PICTURE );
						if ( !_bmpResult && !_bmpSolution ) {
							var txf:TextField, d:Date = new Date();
							
							_watermarkClip = new Sprite;
							_date = d.fullYear+(d.month<10?'0':'')+d.month+(d.date<10?'0':'')+d.date +'-'+ (d.hours<10?'0':'')+d.hours +(d.minutes<10?'0':'')+d.minutes;
							
							if ( map.isCustom )
								_watermarkClip.addChild( txf = UIFactory.createTextField( map.name.replace(/\-/,' ') +'['+ map.customLevel.id +'] - scored '+ _score +' ('+ _date +') \n'+ Registry.SPONSOR_GAME_URL_LVLID +map.customLevel.id, 'watermark', 'left') );
							else
								_watermarkClip.addChild( txf = UIFactory.createTextField( map.name.replace(/\-/,' ') +' - scored '+ _score +' ('+ _date +') \n'+ Registry.SPONSOR_GAME_URL, 'watermark', 'left') );
							txf.x = 4; txf.y = 4;
							_watermarkClip.addChild( txf = UIFactory.createTextField( '<b>Putt More Base</b> \ngame by jaycsantos.com \nsponsored by '+ Registry.SPONSOR_URL_PLAIN, 'watermark2', 'right') );
							txf.x = PuttBase2.STAGE_WIDTH -txf.width-4; txf.y = PuttBase2.STAGE_HEIGHT -txf.height -5;
							_watermarkClip.filters = [new GlowFilter(0x262626,1,2,2,10)]; _watermarkClip.alpha = .5;
							//MonsterDebugger.snapshot( this, new Bitmap(Session.world.wrender.snapShot(sp)) );
							
							_bmpResult = new BitmapData(PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT, false, 0x191919);
							GameRoot.screen.root.addChild( _watermarkClip );
							_bmpResult.draw( GameRoot.screen.root );
							GameRoot.screen.root.removeChild( _watermarkClip );
							
							_watermarkClip.x = -Session.world.camera.bounds.min.x; _watermarkClip.y = -Session.world.camera.bounds.min.y;
							txf = TextField(_watermarkClip.getChildAt(0)); txf.x = 4; txf.y = 4;
							txf = TextField(_watermarkClip.getChildAt(1)); txf.x = Session.world.bounds.width -txf.width-4; txf.y = Session.world.bounds.height -txf.height -5;
							
							Session.instance.onReset.addOnce( _snapPromptSave );
							HudGame(parent).restart();
						} else
							_snapPromptSave();
						
						
						if ( map.isCustom )
							Tracker.i.custom( 'snapshot', 'success' );
						else
							Tracker.i.levelCounter( 'snapshot', map.name );
						break;
					
					case _btnHscore:
						if ( CONFIG::onMbreaker && !Registry.useDefaultSponsor )
							_submitPrivateScore();
						else
							_submitGsLevelScore();
						break;
					
					case _btnGames:
						Link.Open( Registry.SPONSOR_URL, 'sponsor', 'success' );
						break;
				}
				_tip.hide();
			}
			
			private function _movr( e:Event ):void
			{
				var btn:SimpleButton
				switch( e.target ) {
					case _btnRetry:
					case _btnBrowse:
					case _btnMenu:
					case _btnGames:
					case _btnGo:
						btn = e.target as SimpleButton;
						_tip.pop( btn.name, btn.x, btn.y );
						break;
					case _btnFb:
					case _btnTwit:
					case _btnPic:
						btn = e.target as SimpleButton;
						_tip.pop( btn.name, 196, btn.y );
						btn.enabled = true;
						break;
					case _btnHscore:
						_tip.pop( _btnHscore.name, 454, _btnHscore.y );
						_btnHscore.enabled = true;
						break;
					case _popScore:
						if ( !_rolling && _animator.setName == LOOP ) {
							_txfScore2.visible = true;
							_popScoreAni.playSet('default', 12-_popScore.currentFrame);
							if ( _popPro ) _popPro.hide(); _popPro = null;
						}
						break;
				}
			}
			
			private function _mout( e:Event ):void
			{
				switch( e.target ) {
					case _btnRetry:
					case _btnBrowse:
					case _btnMenu:
					case _btnGames:
					case _btnGo:
						_tip.hide();
						break;
					case _btnFb:
					case _btnTwit:
					case _btnPic:
					case _btnHscore:
						_tip.hide();
						SimpleButton( e.target ).enabled = false;
						break;
					case _popScore:
						if ( ! _rolling && _animator.setName == LOOP ) {
							_txfScore2.visible = _clipCalc.visible = false;
							_popScoreAni.playSet( 'hide', _popScore.currentFrame-1 );
						}
						break;
				}
			}
			
			
			override protected function _showContents():void 
			{
				onShown.dispatch();
				
				_contents.visible = _bgBmp.visible = true;
				_overlay.alpha = 1;
			}
			
			private function _showSocialBtns():void
			{
				_btnFb.visible = _btnTwit.visible = _btnPic.visible = true;
				
				_btnHscore.visible = CONFIG::useGamersafe && (uint(Session.instance.map.xml.@gs) || Session.instance.map.isCustom) && !CONFIG::onAndkon;
				if ( CONFIG::onMbreaker && !Registry.useDefaultSponsor )
					_btnHscore.visible = !Session.instance.map.isCustom;
			}
			
			private function _startRoll():void
			{
				_rolling = true;
				_rollStart = getTimer();
				_rollDur = 3500;
				_clipShade.visible = true;
				//_clip.filters = [ new GlowFilter(0x191919, 1, 48, 48, 2) ];
			}
			
			
			private function _goMainMenu():void
			{
				PopPrompt.hide();
				Tracker.i.buttonClick( 'mainMenu', 'success' );
				onHidden.addOnce( _openMainMenu );
				Window.removeAllWindows();
			}
			
			private function _openMainMenu():void
			{
				GameRoot.changeScreen( MenuActScreen );
			}
			
			
			/**
			 * Request an estimation of rank. Score listing can be updated or from a while ago
			 **/
			private function _onGsRequestLevelRankEst( e:Event=null ):void
			{
				GamerSafeHelper.i.scoreReceived.remove( _onGsRequestLevelRankEst );
				GamerSafeHelper.i.scoreError.remove( _onGsError );
				GamerSafeHelper.i.networkError.remove( _onGsError );
				if ( !GameRoot.screen.isReady ) return;
				
				var map:MapData = Session.instance.map;
				if ( e && e.type==GamerSafe.EVT_SCOREBOARD_ENTRIES_RECEIVED ) {
					RankMngr.i.lastScoresId = int(map.xml.@gs);
					RankMngr.i.lastScoresObj = GamerSafe.api.latestScoreboardEntries
				}
				
				var xmlSave:XML = SaveDataMngr.instance.getLevelData( map.name, map.hash );
				var data:Object = RankMngr.i.lastScoresObj;
				
				var a:Array, i:int, len:int, rank:Object = { week:1, month:1, time:1, group:1, all:1 };
				var bestScore:uint = uint( xmlSave.@score );
				
				len = (a = data.weekly).length;
				if ( len && bestScore <= a[len -1].score ) {
					i = a[ len-1 ].score;
					i = Math.round( (i-bestScore)/i *1000 ) +len +1;
					rank.week = i+1;
					
				} else {
					for ( i = 0; i < len; i++ )
						if ( a[i].score < bestScore ) {
							rank.week = i +1;
							break;
						}
				}
				
				len = (a = data.monthly).length;
				if ( len && bestScore <= a[len -1].score ) {
					i = a[ len-1 ].score;
					i = Math.round( (i-bestScore)/i *1000 ) +len +1;
					rank.month = i+1;
					
				} else {
					for ( i = 0; i < len; i++ )
						if ( a[i].score < bestScore ) {
							rank.month = i +1;
							break;
						}
				}
				
				len = (a = data.all).length;
				if ( len && bestScore <= a[len -1].score ) {
					i = a[ len-1 ].score;
					i = Math.round( (i-bestScore)/i *1000 ) +len +1;
					rank.time = i+1;
					
				} else {
					for ( i = 0; i < len; i++ )
						if ( a[i].score < bestScore ) {
							rank.time = i +1;
							break;
						}
				}
				
				if ( rank && rank.time < 20 ) _newHscoreRankStr = MathUtils.toRank(rank.time) +' place on all time rankings';
				else if ( rank && rank.month < 10 ) _newHscoreRankStr = MathUtils.toRank(rank.month) +' place on monthy rankings';
				else _newHscoreRankStr = MathUtils.toRank(rank.week) +' place on weekly rankings';
				
				if ( !_rolling && !_animator.setName==PLAY ) _showNewScorePop();
			}
			
			private function _onGsRequestCustomRankEst( e:Event=null ):void
			{
				if ( !GameRoot.screen.isReady ) return;
				
				var map:MapData = Session.instance.map;
				
				if ( RankMngr.i.lastCustomId != map.customLevel.id || !RankMngr.i.lastCustomRanks )
					RankMngr.i.parseCustomRank();
				var list:Vector.<Array> = RankMngr.i.lastCustomRanks;
				
				var xmlSave:XML = SaveDataMngr.instance.getPlayerLevelData( map.name, map.customLevel.id );
				var score:uint = uint( xmlSave.@score );
				
				var rank:uint = list.length +1;
				for ( var i:int; i<list.length; i++ )
					if ( i < list[i][0] ) {
						rank = i+1;
						break;
					}
				if ( rank > 3 ) {
					i = list[ list.length-1 ][0];
					rank = Math.round( (i-score)/i *Math.min(map.customLevel.wins) ) +4;
				}
				
				_newHscoreRankStr = MathUtils.toRank( rank ) +' place on all time rankings';
			}
			
			/**
			 * Submits score on local hole scoreboard
			 **/
			private function _submitGsLevelScore():void
			{
				if ( !GameRoot.screen.isReady ) return;
				
				_btnHscore.visible = false;
				_loading.visible = true;
				_loading.x = 454;//_btnHscore.x;
				_loading.y = _btnHscore.y;
				_loading.play();
				
				var map:MapData = Session.instance.map;
				if ( !SaveDataMngr.instance.getCustom('highscore_name') ) {
					var win:Window = new GetNameWindow( PopSuccess );
					addChild( win );
					win.onHidden.addOnce( _submitGsLevelScore );
					win.show();
					
				} else {
					if ( GamerSafe.api && GamerSafe.api.loaded ) {
						if ( !map.isCustom ) {
							GamerSafeHelper.i.scoreError.addOnce( _onGsError );
							GamerSafeHelper.i.networkError.addOnce( _onGsError );
							if ( _newHscore ) {
								var xmlSave:XML = SaveDataMngr.instance.getLevelData( map.name, map.hash );
								
								trace( 'GS: submitting scores' );
								GamerSafeHelper.i.scoreSubmitted.addOnce( _onSubmitGsLevelScore );
								GamerSafe.api.saveToScoreboard( uint(xmlSave.@score), xmlSave.@extra, int(map.xml.@gs), SaveDataMngr.instance.getCustom('highscore_name') );
								
								if ( CONFIG::onMJ ) {
									var mapSet:uint = int( saveMngr.getCustom('lastMapSet') );
									xmlSave = SaveDataMngr.instance.getGroupTotalData( mapSet );
									
									//MindJoltAPI.service.
								}
								
							} else {
								trace( 'GS: verify current ranking' );
								_onSubmitGsLevelScore();
							}
							
						} else if ( map.isCustom ) {
							trace( 'GS: request updated custom scoreboard' );
							GamerSafeHelper.i.lvGot1Lvl.addOnce( _newHscore ? _onGsRequestCustomRank : _onGsRequestUpdatedCustomRank );
							GamerSafeHelper.i.lvException.addOnce( _onGsError );
							GamerSafeHelper.i.networkError.addOnce( _onGsError );
							GamerSafe.api.levelVaultFetchLevelByID( int(map.customLevel.id) );
						}
						
					} else
						_onGsError();
					
					if ( _newHscore ) {
						_newHscore.hide();
						_newHscore = null;
						_newHscoreRankStr = null;
					}
					
				}
				
			}
			
			private function _onSubmitGsLevelScore( e:Event=null ):void
			{
				GamerSafeHelper.i.scoreSubmitted.remove( _onSubmitGsLevelScore );
				if ( e ) trace( 'GS: score submitted' );
				if ( !GameRoot.screen.isReady ) return;
				
				var map:MapData = Session.instance.map;
				if ( !map.isCustom ) {
					trace( 'GS: request updated scoreboards' );
					GamerSafeHelper.i.scoreReceived.addOnce( _onGsRequestLevelRank );
					GamerSafe.api.requestScoreboardEntries( int(map.xml.@gs) );
				}
			}
			
			private function _onGsRequestLevelRank( e:Event=null ):void
			{
				GamerSafeHelper.i.scoreReceived.remove( _onGsRequestLevelRank );
				
				trace( 'GS: scoreboards retrieved' );
				if ( !GameRoot.screen.isReady ) return;
				
				trace( 'GS: parsing to get updated rank' );
				
				var map:MapData = Session.instance.map;
				if ( e && e.type==GamerSafe.EVT_SCOREBOARD_ENTRIES_RECEIVED ) {
					RankMngr.i.lastScoresId = int(map.xml.@gs);
					RankMngr.i.lastScoresObj = GamerSafe.api.latestScoreboardEntries;
				}
				RankMngr.i.parseLevelRank( RankMngr.i.lastScoresObj );
				
				_submitGsGroupScore();
				
				_btnHscore.visible = false;
				_loading.visible = false;
				_loading.stop();
				
				_bg.addChildAt( _rankWin = new PopSuccessRanks, 1 );
				_rankWin.show();
				
				_showPopPic();
				
				if ( CONFIG::onNG && PuttBase2.ngApi && API.isNewgrounds && API.isNetworkHost && !map.isCustom ) {
					if ( !API.getMedal('Ranked').unlocked ) API.unlockMedal( 'Ranked' );
				}
			}
			
			/**
			 * Submits total score for group (amateur or pro)
			 */
			private function _submitGsGroupScore():void
			{
				if ( !GameRoot.screen.isReady ) return;
				
				var map:MapData = Session.instance.map;
				var saveMngr:SaveDataMngr = SaveDataMngr.instance;
				
				if ( RankMngr['GROUP_'+ map.sett +'_BOARD_ID'] ) {
					var xml:XML = saveMngr.getGroupTotalData( map.sett );
					
					if ( saveMngr.getCustom('pendScore_grp'+map.sett) ) {
						trace( 'GS: submitting group score' );
						GamerSafeHelper.i.scoreSubmitted.addOnce( _onSubmitGsGroupScore );
						GamerSafe.api.saveToScoreboard( uint(xml.@score), saveMngr.getCustom('rankExtra_grp'+map.sett), RankMngr['GROUP_' + map.sett +'_BOARD_ID'], saveMngr.getCustom('highscore_name') );
						
					} else {
						trace( 'GS: verify current ranking' );
						_onSubmitGsGroupScore();
					}
					
				} else
					_onGsError();
			}
			
			private function _onSubmitGsGroupScore( e:Event=null ):void
			{
				GamerSafeHelper.i.scoreSubmitted.remove( _onSubmitGsGroupScore );
				if ( e ) trace( 'GS: group score submitted' );
				if ( !GameRoot.screen.isReady ) return;
				
				var map:MapData = Session.instance.map;
				var saveMngr:SaveDataMngr = SaveDataMngr.instance;
				if ( !map.isCustom && RankMngr['GROUP_'+ map.sett +'_BOARD_ID'] ) {
					if ( 0&& !saveMngr.getCustom('pendScore_grp'+map.sett) && RankMngr.i.lastScoreGroup==map.sett && RankMngr.i.lastScoreGroupObj ) {
						_onGsRequestGroupRank();
						
					} else {
						trace( 'GS: request updated scoreboards' );
						GamerSafeHelper.i.scoreReceived.addOnce( _onGsRequestGroupRank );
						GamerSafe.api.requestScoreboardEntries( RankMngr['GROUP_'+ map.sett +'_BOARD_ID'] );
					}
					
					if ( e && e.type==GamerSafe.EVT_SCOREBOARD_ENTRY_SUBMITTED )
						saveMngr.saveCustom( 'pendScore_grp'+map.sett, '', true );
					
				} else
					_onGsError();
				
			}
			
			private function _onGsRequestGroupRank( e:Event=null ):void
			{
				GamerSafeHelper.i.scoreReceived.remove( _onGsRequestGroupRank );
				GamerSafeHelper.i.scoreError.remove( _onGsError );
				GamerSafeHelper.i.networkError.remove( _onGsError );
				
				trace( 'GS: scoreboards retrieved' );
				if ( !GameRoot.screen.isReady ) return;
				
				var map:MapData = Session.instance.map;
				if ( e && e.type==GamerSafe.EVT_SCOREBOARD_ENTRIES_RECEIVED ) {
					trace( 'GS: parsing to get updated rank' );
					RankMngr.i.lastScoreGroup = map.sett;
					RankMngr.i.lastScoreGroupObj = GamerSafe.api.latestScoreboardEntries;
					RankMngr.i.parseGroupRank( RankMngr.i.lastScoreGroupObj, map.sett );
				}
				
				if ( _rankWin )
					_rankWin.setGroupRank( RankMngr.i.getParsedGroupRank(map.sett) );
			}
			
			/**
			 * Compares scores on custom levels, swaps if better score
			 * @param	e
			 */
			private function _onGsRequestCustomRank( e:Event ):void
			{
				GamerSafeHelper.i.lvGot1Lvl.remove( _onGsRequestCustomRank );
				if ( !GameRoot.screen.isReady ) return;
				
				trace( 'GS: parsing to get updated rank' );
				var map:MapData = Session.instance.map;
				var data:Object = GamerSafe.api.levelVaultGetLastSelectedLevel();
				map.pb2internal::customLevel = CustomLevel.createFromGamersafe( data );
				RankMngr.i.parseCustomRank();
				var list:Vector.<Array> = RankMngr.i.lastCustomRanks.concat();
				
				var xmlSave:XML = SaveDataMngr.instance.getPlayerLevelData( map.name, map.customLevel.id );
				var extra:String = xmlSave.@extra;
				var score:uint = uint( xmlSave.@score );
				var name:String = SaveDataMngr.instance.getCustom( 'highscore_name' );
				var date:Date = new Date( String(xmlSave.@date) );
				
				var rank:uint = list.length +1;
				for ( var i:int; i<list.length; i++ )
					if ( score > list[i][0] ) {
						if ( list[i][1] == name && list[i][2] == xmlSave.@extra2 )
							list[i] = [ score, name, extra, date.valueOf()/1000/60 >>0 ];
						else
							list.splice( i, 0, [score, name, extra, date.valueOf()/1000/60 >>0] );
						rank = i +1;
						break;
					}
				if ( rank > 3 ) {
					i = list[ list.length-1 ][0];
					rank = Math.round( (i-score)/i *Math.min(map.customLevel.wins) ) +4;
					
					trace( 'GS: no changes, continue' );
					_onGsRequestUpdatedCustomRank();
					//GamerSafeHelper.i.lvGot1Lvl.addOnce( _onGsRequestUpdatedCustomRank );
					//GamerSafe.api.levelVaultFetchLevelByID( int(map.customLevel.id) );
					
				} else {
					if ( !list.length ) list.push( [score, name, extra, date.valueOf()/1000/60 >>0] );
					
					var attr:Object = { };
					for ( i=0; i<list.length && i<3; i++ )
						attr['score'+i] = list[i].join(',');
					
					trace( 'GS: upload newly updated scoreboard' );
					GamerSafeHelper.i.lvStrSet.addOnce( _onGsUpdateCustomRank );
					GamerSafe.api.levelVaultSetAttributes( int(map.customLevel.id), attr );
				}
				
			}
			
			private function _onGsUpdateCustomRank( e:Event=null ):void
			{
				trace( 'GS: request updated custom scoreboard' );
				GamerSafeHelper.i.lvStrSet.remove( _onGsUpdateCustomRank );
				if ( !GameRoot.screen.isReady ) return;
				
				GamerSafeHelper.i.lvGot1Lvl.addOnce( _onGsRequestUpdatedCustomRank );
				GamerSafe.api.levelVaultFetchLevelByID( int(Session.instance.map.customLevel.id) );
			}
			
			/**
			 * Compares scores on custom levels, nothing else
			 * @param	e
			 */
			private function _onGsRequestUpdatedCustomRank( e:Event=null ):void
			{
				GamerSafeHelper.i.lvGot1Lvl.remove( _onGsRequestUpdatedCustomRank );
				GamerSafeHelper.i.lvException.remove( _onGsError );
				GamerSafeHelper.i.networkError.remove( _onGsError );
				if ( !GameRoot.screen.isReady ) return;
				
				var map:MapData = Session.instance.map;
				
				if ( e && e.type == GamerSafe.EVT_LEVELVAULT_GOT_SINGLE_LEVEL ) {
					var data:Object = GamerSafe.api.levelVaultGetLastSelectedLevel();
					map.pb2internal::customLevel = CustomLevel.createFromGamersafe( data );
				}
				RankMngr.i.parseCustomRank();
				var list:Vector.<Array> = RankMngr.i.lastCustomRanks.concat();
				
				var xmlSave:XML = SaveDataMngr.instance.getPlayerLevelData( map.name, map.customLevel.id );
				var extra:String = xmlSave.@extra;
				var score:uint = uint( xmlSave.@score );
				var name:String = SaveDataMngr.instance.getCustom( 'highscore_name' );
				
				var rank:uint = list.length +1;
				for ( var i:int; i<list.length; i++ )
					if ( score > list[i][0] || (score==list[i][0] && name==list[i][1] && extra==list[i][2]) ) {
						rank = i+1;
						break;
					}
				if ( rank > 3 ) {
					i = list[ list.length-1 ][0];
					rank = Math.round( (i-score)/i *Math.min(map.customLevel.wins) ) +4;
				}
				
				var leaders:Array = [];
				for ( i=0; i<list.length && leaders.length<3; i++ )
					if ( list[i][1] != name || list[i][2] != extra )
						leaders.push( list[i][1], list[i][0] );
				SaveDataMngr.instance.savePlayerLevelRank( map.customLevel.id, xmlSave.@date, rank, leaders );
				
				
				_btnHscore.visible = false;
				_loading.visible = false;
				_loading.stop();
				
				var win:Window;
				_bg.addChildAt( win = new PopSuccessRanks2, 1 );
				win.show();
				
				_showPopPic();
			}
			
			
			/**
			 * Error handler
			 * @param	e
			 */
			private function _onGsError( e:*=null ):void
			{
				if ( GamerSafe.api && GamerSafe.api.loaded ) {
					GamerSafeHelper.i.scoreSubmitted.remove( _onSubmitGsLevelScore );
					GamerSafeHelper.i.scoreSubmitted.remove( _onSubmitGsGroupScore );
					GamerSafeHelper.i.scoreReceived.remove( _onGsRequestLevelRankEst );
					GamerSafeHelper.i.scoreReceived.remove( _onGsRequestLevelRank );
					GamerSafeHelper.i.scoreReceived.remove( _onGsRequestGroupRank );
					GamerSafeHelper.i.scoreError.remove( _onGsError );
					GamerSafeHelper.i.lvGot1Lvl.remove( _onGsRequestCustomRank );
					GamerSafeHelper.i.lvGot1Lvl.remove( _onGsRequestUpdatedCustomRank );
					GamerSafeHelper.i.lvStrSet.remove( _onGsUpdateCustomRank );
					GamerSafeHelper.i.lvException.remove( _onGsError );
					GamerSafeHelper.i.networkError.remove( _onGsError );
				}
				if ( !GameRoot.screen.isReady || _rolling || _animator.setName==PLAY ) return;
				
				if ( e && e is Error )
					addChild( PopPrompt.create('Error\n'+Error(e).message, 120, {name:'OK'}) );
				else if ( !GamerSafe.api || !GamerSafe.api.loaded )
					addChild( PopPrompt.create('Cannot establish connection to server. Restart game if it persists.', 120, {name:'OK'}) );
				else
					addChild( PopPrompt.create('Server might be busy or inaccessible. Try again later.', 120, {name:'OK'}) );
				
				_btnHscore.visible = true;
				_loading.visible = false;
				_loading.stop();
				
				_showPopPic();
			}
			
			
			private function _submitPrivateScore():void
			{
				_btnHscore.visible = false;
				_loading.visible = true;
				_loading.x = 454;//_btnHscore.x;
				_loading.y = _btnHscore.y;
				_loading.play();
				
				var map:MapData = Session.instance.map;
				if ( !SaveDataMngr.instance.getCustom('highscore_name') ) {
					var win:Window = new GetNameWindow( PopSuccess );
					addChild( win );
					win.onHidden.addOnce( _submitPrivateScore );
					win.show();
					
				} else
				if ( CONFIG::onMbreaker && !Registry.useDefaultSponsor ) {
					var variables:URLVariables = new URLVariables();
					variables.score = uint(SaveDataMngr.instance.getTotalData().@score);
					variables.username = SaveDataMngr.instance.getCustom('highscore_name');
					
					var reqURL:URLRequest = new URLRequest( "http://www.mousebreaker.com/games/puttmorebase/highscores_puttmorebase.php?" + (Math.random()*100000 >>0) );
					reqURL.data = variables;
					reqURL.method = URLRequestMethod.POST;
					
					var loader:URLLoader = new URLLoader();
					loader.addEventListener( Event.COMPLETE, _onSubmittedPrivateScore, false, 0, true );
					loader.addEventListener( IOErrorEvent.IO_ERROR, _onSubmitPrivateError, false, 0, true );
					loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, _onSubmitPrivateError, false, 0, true );
					loader.dataFormat = URLLoaderDataFormat.VARIABLES;
					loader.load( reqURL );
				}
				
			}
			
			private function _onSubmittedPrivateScore( e:*= null ):void
			{
				_btnHscore.visible = false;
				_loading.visible = false;
				_loading.stop();
				
				addChild( PopPrompt.create('Score ('+ MathUtils.toThousands(uint(SaveDataMngr.instance.getTotalData().@score)) +') Submitted', 110, {name:'OK'}) );
			}
			
			private function _onSubmitPrivateError( e:*= null ):void
			{
				_btnHscore.visible = true;
				_loading.visible = false;
				_loading.stop();
				
				addChild( PopPrompt.create('An error occured while trying to submit your scores. Try again later or report to the web admin or developer.', 110, {name:'OK'}) );
			}
			
			
			private function _showNewScorePop():void
			{
				if ( CONFIG::onMbreaker && !Registry.useDefaultSponsor )
					addChild( _newHscore = new PopInfoNewScore('New Score', 'Submit your score now!') );
				else
					addChild( _newHscore = new PopInfoNewScore('New Score', 'Your best level score can get <span class="tutTextA">'+ _newHscoreRankStr +'</span>! Submit now!') );
				
				_newHscore.show();
				_btnHscore.visible = true;
			}
			
			private function _showPopPic():void
			{
				var tutFlag:uint = uint( SaveDataMngr.instance.getCustom('tutflag') );
				
				// info picture
				if ( (tutFlag & 8192) == 0 ) {
					addChild( _popPic = new PopInfoPic );
					_popPic.show();
					SaveDataMngr.instance.saveCustom( 'tutflag', tutFlag | 8192, true );
				}
				_btnPic.enabled = true;
			}
			
			private function _showPopSocial():void
			{
				var tutFlag:uint = uint( SaveDataMngr.instance.getCustom('tutflag') );
				
				// info social
				if ( (tutFlag & 16384) == 0 ) {
					addChild( _popSocial = new PopInfoSocial );
					_popSocial.show();
					SaveDataMngr.instance.saveCustom( 'tutflag', tutFlag | 16384, true );
					if ( MathUtils.randomInt(0, 2) ) _btnFb.enabled = true;
				}
				if ( MathUtils.randomInt(0,2) ) _btnFb.enabled = true;
				else _btnTwit.enabled = true;
			}
			
			private function _showPopPro():void
			{
				var tutFlag:uint = uint( SaveDataMngr.instance.getCustom('tutflag') );
				
				// info social
				if ( (tutFlag & 32768) == 0 ) {
					addChild( _popPro = new PopInfoPro );
					_popPro.show();
					SaveDataMngr.instance.saveCustom( 'tutflag', tutFlag | 32768, true );
				}
			}
			
			
			private function _snapPromptSave():void
			{
				if ( ! _bmpSolution )
					_bmpSolution = Session.world.wrender.snapShot( _watermarkClip );
				addChild( PopPrompt.create('Take a snapshot:', 350, {name:'SAVE RESULT', call:_snapSaveResult}, {name:'SAVE SOLUTION', call:_snapSaveSolution}, {name:'CANCEL'} ) );
			}
			
			private function _snapSaveSolution():void
			{
				var ba:ByteArray = PNGEncoder.encode( _bmpSolution );
        var file:FileReference = new FileReference();
				var map:MapData = Session.instance.map;
				if ( map.isCustom ) {
					file.save( ba, 'puttmorebase('+ map.customLevel.id +')-'+ _score +'[' + _date +'-solution].png' );
					Tracker.i.custom( 'saveSolutionSnapshot', 'success' );
					
				} else {
					file.save( ba, 'puttmorebase-'+ map.name +'-' + _score +'[' + _date +'-solution].png' );
					Tracker.i.levelCounter( 'saveSolutionSnapshot', map.name );
				}
			}
			
			private function _snapSaveResult():void
			{
				var ba:ByteArray = PNGEncoder.encode( _bmpResult );
				var d:Date = new Date();
        var file:FileReference = new FileReference();
				var map:MapData = Session.instance.map;
				if ( map.isCustom ) {
					file.save( ba, 'puttmorebase('+ map.customLevel.id +')-'+ _score +'[' + _date +'-result].png' );
					Tracker.i.custom( 'saveResultSnapshot', 'success' );
					
				} else {
					file.save( ba, 'puttmorebase-'+ map.name +'-' + _score +'[' + _date +'-result].png' );
					Tracker.i.levelCounter( 'saveResultSnapshot', map.name );
				}
			}
			
			
			private function _showScoreCalc():void
			{
				_clipCalc.visible = true;
			}
			
			
			
	}

}