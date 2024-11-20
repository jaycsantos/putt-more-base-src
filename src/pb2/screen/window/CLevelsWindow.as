package pb2.screen.window 
{
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.util.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.net.URLVariables;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import pb2.game.ctrl.GamerSafeHelper;
	import pb2.game.ctrl.SaveDataMngr;
	import pb2.game.Registry;
	import pb2.screen.*;
	import pb2.screen.ui.UIFactory;
	import pb2.util.CustomLevel;
	import Playtomic.*;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class CLevelsWindow extends Pb2Window2 
	{
		public static var lastLevel:PlayerLevel, lastResult:Array, lastTotalPages:uint=1, lastCount:uint=1, lastParam:Object={mode:'newest',page:1,perpage:10,customfilters:{replay:''}}
		public static var lastParamGs:Array=[0,0,10,0], sortNewestGs:Array=[], sortPopularGs:Array=[];
		
		public function CLevelsWindow( parentClass:Class ) 
		{
			_parentClass = parentClass;
			var g:Graphics, sp:Sprite, sp2:Sprite, shp:Shape, txf:TextField, m:Matrix, i:int, j:int, k:String, a:Array, showPlays:Boolean;
			
			{//-- title && bg
				_bgClip.addChild( shp = new Shape );
				g = shp.graphics;
				g.lineStyle( 1, 0xB2B2B2, 1, true );
				g.beginFill( 0xCCCCCC );
				g.drawRoundRect( 240, 24, 126, 17, 8, 8 );
				
				_bgClip.addChild( txf = UIFactory.createTextField('pub courses', 'windowHugeText', 'left', 150, 0) );
				txf.alpha = .10;
				
				_bgClip.addChild( UIFactory.createTextField('PUB <b>COURSES</b>', 'header2', 'left', 42, 10) );
				_bgClip.addChild( sp = PuttBase2.assets.createDisplayObject('screen.ui.ico.holeFlag') as Sprite );
				sp.x = 35; sp.y = 28;
				
				_bgClip.addChild( UIFactory.createTextField('page', 'clevelPageLbl', 'left', 430, 4) );
				_bgClip.addChild( UIFactory.createTextField('custom course ID\n or course link', 'clevelKeyLbl', 'right', 150, 282) );
				_bgClip.addChild( UIFactory.createTextField('then hit\n enter', 'clevelKeyLbl2', 'left', 395, 282) );
				
				_bgClip.addChild( shp = new Shape );
				g = shp.graphics;
				g.lineStyle( 1, 0x8C8C8C );
				g.beginFill( 0xCCC199, .75 );
				g.drawRect( 56, 48, 418, 20 );
				
				_bgClip.addChild( UIFactory.createTextField('name - author - score', 'clevelHead', 'left', 59, 50) );
				_bgClip.addChild( txf = UIFactory.createTextField('plays', 'clevelHead', 'center', 310, 50) );
				_bgClip.addChild( UIFactory.createTextField('ratings - votes', 'clevelHead', 'center', 367, 50) );
				_bgClip.addChild( UIFactory.createTextField('date', 'clevelHead', 'center', 430, 50) );
				
				showPlays = txf.visible = CONFIG::useGamersafe || (Boolean( int(Registry.PLAYTOMIC_VARS.ShowPlayerLvlPlays) ));
			}
			
			{//-- tabs
				a = [L10n.t('Newest'), L10n.t('Popular')];
				_contents.addChild( _tabsClip = new Sprite );
				with( _tabsClip ) {
					mouseEnabled = false;
					x = 230; y = 12;
				}
				
				for each ( k in a ) {
					i = _tabsClip.numChildren;
					_tabsClip.addChild( sp = new Sprite );
					sp.buttonMode = true; sp.mouseChildren = false; sp.tabEnabled = false;
					sp.addChild( txf = UIFactory.createTextField(sp.name = k, 'levelsTabTxt', 'left', 0, 1) );
					sp.name = k.toLowerCase();
					g = sp.graphics;
					
					j = txf.width+10 >>0;
					if ( i > 0 ) {
						sp2 = _tabsClip.getChildAt( i-1 ) as Sprite;
						sp.x = sp2.x +(sp2.width>>0) -1;
						g.beginFill( 0, 0 );
						g.drawRect( -5, 0, j, 17 );
						
					} else {
						sp.buttonMode = sp.mouseEnabled = false;
						g.lineStyle( 1, 0xB2B2B2, 1 );
						g.beginFill( 0xD8D8D8 );
						g.drawRect( -5, 0, j, 17 );
					}
				}
				
			}
			
			{//-- list
				_contents.addChild( _clipList = new Sprite );
				_clipList.buttonMode = true; _clipList.mouseChildren = false;
				_clipList.x = 40; _clipList.y = 58; _clipList.name = 'list';
				_clipList.visible = false;
				
				for ( i=0; i<10; i++ ) {
					_clipList.addChild( sp = new Sprite );
					sp.y = i * 20;
					sp.addChild( UIFactory.createTextField('hole '+ (i+1), 'clevelName', 'left', 0, 2) );
					sp.addChild( txf = UIFactory.createFixedTextField(''+MathUtils.randomInt(0, 1000), 'clevelOther', 'center', 247, 2) );
					sp.addChild( UIFactory.createFixedTextField(MathUtils.randomInt(0,10)+' (232)', 'clevelOther', 'center', 300, 2) );
					sp.addChild( UIFactory.createFixedTextField('10 mins ago', 'clevelOther', 'center', 365, 2) );
					txf.visible = showPlays;
					g = sp.graphics;
					g.beginFill( 0, 0 );
					g.drawRect( -5, 0, 410, 20 );
					g.endFill();
				}
				
				_contents.addChild( _clipLoad = PuttBase2.assets.createDisplayObject('screen.ui.ico.iconLoading') as MovieClip );
				_clipLoad.stop(); _clipLoad.visible = false;
				_clipLoad.x = 240;
			}
			
			{//-- form
				_contents.addChild( _txfPage = UIFactory.createInputField('page', 'clevelPage') );
				_txfPage.x = 355; _txfPage.y = 0;
				_txfPage.width = 50; _txfPage.height = 32; _txfPage.text = lastParam.page +'';
				_txfPage.wordWrap = false; _txfPage.restrict = '1234567890'; _txfPage.maxChars = 7;
				_txfPage.addEventListener( FocusEvent.FOCUS_OUT, _pageChange, false, 0, true );
				
				_contents.addChild( _txfPage2 = UIFactory.createFixedTextField('/-', 'clevelPage2', 'left', 405, 0) );
				
				_contents.addChild( _txfKey = UIFactory.createInputField('key', 'clevelKey') );
				_txfKey.x = 130; _txfKey.y = 270;
				_txfKey.width = 240; _txfKey.height = 25;
				_txfKey.wordWrap = false; _txfKey.text = '';
				_txfKey.mouseEnabled = true;
			}
			
			{//-- buttons
				_contents.addChild( _btnPrev = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnCustomNext') as SimpleButton );
				_btnPrev.x = 15; _btnPrev.y = 148;
				
				_contents.addChild( _btnNext = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnCustomNext') as SimpleButton );
				_btnNext.x = 465; _btnNext.y = 148; _btnNext.rotation = 180;
				
				_contents.addChild( _btnClose = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnClose') as SimpleButton );
				_btnClose.x = 487; _btnClose.y = 3;
				
				_btnNext.visible = _btnPrev.visible = false;
			}
			
			
			lastParamGs[0] = [];
			lastParamGs[0]['isLevel'] = 1;
			sortNewestGs = ['modified desc', 'avg_rating desc', 'plays desc', 'num_ratings desc'];
			sortPopularGs = ['avg_rating desc', 'plays desc', 'num_ratings desc', 'modified desc'];
			
			_contents.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
			_contents.addEventListener( MouseEvent.MOUSE_OVER, _movr, false, 0, true );
			_contents.addEventListener( MouseEvent.MOUSE_OUT, _mout, false, 0, true );
			
			onShown.addOnce( _getListCount );
			onPreHide.addOnce( PopPrompt.remove );
			
			fadeEnterDur = 250;
		}
		
		override public function dispose():void 
		{
			_txfPage.removeEventListener( FocusEvent.FOCUS_OUT, _pageChange );
			_contents.removeEventListener( MouseEvent.CLICK, _click );
			_contents.removeEventListener( MouseEvent.MOUSE_OVER, _movr );
			_contents.removeEventListener( MouseEvent.MOUSE_OUT, _mout );
			
			super.dispose();
		}
		
		
		public function populate():void
		{
			var lvl:CustomLevel, sp:Sprite, txf:TextField, s:String, xml:XML
			var saveMngr:SaveDataMngr = SaveDataMngr.instance;
			
			for ( var i:int; i < 10; i++ ) {
				if ( i < lastResult.length ) {
					lvl = lastResult[i];
					sp = _clipList.getChildAt(i) as Sprite;
					sp.visible = true;
					
					xml = saveMngr.getPlayerLevelData( lvl.name.replace(/\s/g, '-'), lvl.id );
					txf = TextField(sp.getChildAt(0));
					txf.htmlText = '<p class="clevelName">'+ lvl.name +'</p><p class="clevelAuthor">&nbsp;&nbsp;by '+ lvl.author +(xml!=null?' ('+xml.@score+')':'')+'</p>';
					if ( txf.textWidth > 225 ) {
						txf.htmlText = '<p class="clevelName">'+ lvl.name.substr(0, lvl.name.length*225/txf.textWidth >>0) +'..</p><p class="clevelAuthor">&nbsp;&nbsp;by '+ lvl.author +'</p>';
						txf.autoSize = 'none'; txf.width = 225; txf.height = 18;
					} else
						txf.autoSize = 'left';
					
					TextField(sp.getChildAt(1)).text = lvl.plays +'';
					TextField(sp.getChildAt(2)).text = lvl.votes>=3 ? Number(lvl.rating/20).toFixed(1) +' (' + lvl.votes +')' : '- - -';
					
					txf = TextField(sp.getChildAt(3))
					txf.text = s = lvl.RDate;
					if ( txf.textWidth > 70 )
						txf.text = s.substr( 0, s.length*65/txf.textWidth >>0 ) +'..';
					
				} else {
					_clipList.getChildAt(i).visible = false;
					
				}
			}
			
			_clipList.visible = true;
			_clipLoad.visible = false;
			_clipLoad.stop();
			_txfPage.type = _txfKey.type = 'input';
			_txfPage2.text = '/'+ lastTotalPages;
			
			_btnPrev.visible = Boolean(lastParam.page > 1);
			_btnNext.visible = Boolean(lastParam.page < lastTotalPages);
		}
		
		
			// -- private --
			
			private static var _lastLoad:uint;
			
			private var _parentClass:Class
			private var _btnPrev:SimpleButton, _btnNext:SimpleButton, _btnClose:SimpleButton
			private var _tabsClip:Sprite, _clipList:Sprite, _listOvr:Boolean, _listIndex:int, _clipLoad:MovieClip
			private var _txfPage:TextField, _txfPage2:TextField, _txfKey:TextField
			
			override protected function _init( e:Event ):void 
			{
				super._init( e );
				
				_bg2.width = 530; _bg2.height = 320;
				_bgClip.x = (PuttBase2.STAGE_WIDTH -_bgClip.width)/2 >>0;
				_bgClip.y = (PuttBase2.STAGE_HEIGHT -_bgClip.height)/2 -(_parentClass==MenuActScreen?25:0) >>0;
				
				_contents.x = _bgClip.x +25; //margin left
				_contents.y = _bgClip.y +12; //margin right
				
			}
			
			override protected function _update():void 
			{
				if ( _listOvr ) {
					var i:int = _clipList.mouseY/20 >>0;
					var g:Graphics;
					if ( _listIndex>=0 && _listIndex != i ) {
						g = Sprite(_clipList.getChildAt(_listIndex)).graphics;
						g.clear();
						g.beginFill( 0, 0 );
						g.drawRect( -5, 0, 410, 20 );
						g.endFill();
					}
					_listIndex = i;
					
					g = Sprite(_clipList.getChildAt(i)).graphics;
					g.clear();
					g.beginFill( 0xD8D8D8 );
					g.drawRect( -5, 0, 410, 20 );
					g.endFill();
				}
				else if ( stage && stage.focus == _txfKey && UserInput.instance.isKeyDown(KeyCode.ENTER) ) {
					_getFrKey();
				}
				else if ( stage && stage.focus == _txfPage && UserInput.instance.isKeyDown(KeyCode.ENTER) ) {
					_pageChange();
				}
				
				
				if ( UserInput.instance.isKeyDown(KeyCode.ESC) )
					hide();
			}
			
			
			private function _click( e:MouseEvent ):void
			{
				switch ( e.target ) {
					case _clipList:
						var win:Window = new CLevelDetailWindow( lastResult[_listIndex], _parentClass );
						addChild( win );
						win.show();
						break;
						
					case _btnClose:
						hide();
						break;
						
					case _btnPrev:
						if ( _btnPrev.enabled ) {
							_lastLoad = 0;
							lastParam.page--;
							_getList();
						}
						break;
						
					case _btnNext:
						if ( _btnNext.visible ) {
							_lastLoad = 0;
							lastParam.page++;
							_getList();
						}
						break;
						
					case _txfKey:
						_txfKey.setSelection( 0, _txfKey.length );
						break;
						
					default:
						if ( DisplayObject(e.target).parent == _tabsClip ) {
							lastParam.mode = Sprite(e.target).name;
							lastParam.page = 1; _lastLoad = 0;
							_getList();
							
							var g:Graphics, sp:Sprite, w:int, i:int, j:int = _tabsClip.numChildren;
							for ( i=0; i<j; i++ ) {
								sp = _tabsClip.getChildAt(i) as Sprite;
								sp.buttonMode = sp.mouseEnabled = true;
								g = sp.graphics;
								g.clear();
								w = TextField(sp.getChildAt(0)).width+10 >>0;
								if ( sp.name == lastParam.mode ) {
									sp.buttonMode = sp.mouseEnabled = false;
									g.lineStyle( 1, 0xB2B2B2, 1 );
									g.beginFill( 0xD8D8D8 );
									g.drawRect( -5, 0, w, 17 );
								} else {
									g.beginFill( 0, 0 );
									g.drawRect( -5, 0, w, 17 );
								}
							}
						}
						break;
				}
			}
			
			private function _movr( e:MouseEvent ):void
			{
				if ( e.target == _clipList )
					_listOvr = true; 
					
				else if ( DisplayObject(e.target).parent == _tabsClip ) {
					var sp:Sprite = Sprite( e.target );
					var w:uint = TextField(sp.getChildAt(0)).width +10 >>0;
					if ( sp.name != lastParam.mode )
						with ( sp.graphics ) {
							clear();
							lineStyle( 1, 0xB2B2B2, 1 );
							beginFill( 0xDDDDDD );
							drawRect( -5, 0, w, 17 );
						}
				}
			}
			
			private function _mout( e:MouseEvent ):void
			{
				if ( e.target == _clipList ) {
					_listOvr = false;
					if ( _listIndex >= 0 )
						with ( Sprite(_clipList.getChildAt(_listIndex)).graphics ) {
							clear();
							beginFill( 0, 0 );
							drawRect( -5, 0, 410, 20 );
							endFill();
						}
				} else
				if ( DisplayObject(e.target).parent == _tabsClip ) {
					var sp:Sprite = Sprite( e.target );
					var w:uint = TextField(sp.getChildAt(0)).width +10 >>0;
					if ( sp.name != lastParam.mode )
						with ( sp.graphics ) {
							clear();
							beginFill( 0, 0 );
							drawRect( -5, 0, w, 17 );
						}
				}
			}
			
			private function _pageChange( e:Event=null ):void
			{
				var p:int = MathUtils.limit( int(_txfPage.text), 1, lastTotalPages );
				if ( lastParam.page != p ) {
					lastParam.page = p;
					_lastLoad = 0;
					_getList();
				}
				_txfPage.text = lastParam.page = p;
			}
			
			
			private function _getListCount():void
			{
				_clipList.visible = false;
				_clipLoad.y = 148;
				_clipLoad.visible = true;
				_clipLoad.play();
				_btnPrev.visible = _btnNext.visible = false;
				
				CONFIG::useGamersafe {
					if ( GamerSafe.api && GamerSafe.api.loaded ) {
						GamerSafeHelper.i.lvGotNumLvls.addOnce( _listCountLoaded );
						GamerSafe.api.levelVaultGetNumLevels();
						
					} else {
						_gsError();
					}
				}
				
				
			}
			
			private function _listCountLoaded( e:Event ):void
			{
				GamerSafeHelper.i.lvGotNumLvls.remove( _listCountLoaded );
				if ( e.type == GamerSafe.EVT_LEVELVAULT_GOT_NUM_LEVELS ) {
					lastTotalPages = Math.ceil( GamerSafe.api.levelVaultGetLastNumLevels() / lastParam.perpage );
					_getList();
					
				} else
					_gsError();
			}
			
			
			private function _getList():void
			{
				if ( !lastResult || _lastLoad < getTimer() ) {
					_clipList.visible = false;
					_clipLoad.y = 148;
					_clipLoad.visible = true;
					_clipLoad.play();
					_btnPrev.visible = _btnNext.visible = false;
					_txfPage.type = _txfKey.type = 'dynamic';
					_txfPage.text = lastParam.page;
					
					lastParamGs[1] = lastParam.mode=='newest'? sortNewestGs : sortPopularGs;
					lastParamGs[2] = lastParam.perpage;
					lastParamGs[3] = (lastParam.page-1)*int(lastParamGs[2]);
					
					CONFIG::useGamersafe {
						if ( GamerSafe.api && GamerSafe.api.loaded ) {
							GamerSafeHelper.i.lvGotLvls.addOnce( _listLoadedGs );
							GamerSafeHelper.i.lvException.addOnce( _gsError );
							GamerSafeHelper.i.lvError.addOnce( _gsError );
							GamerSafeHelper.i.networkError.addOnce( _gsError );
							GamerSafe.api.levelVaultGetLevelsAdvanced.apply( this, lastParamGs );
							
						} else {
							_gsError();
						}
					}/**/
					CONFIG::usePlaytomicLvls {
						PlayerLevels.List( _listLoaded, lastParam );
					}
					
				} else {
					populate();
				}
			}
			
			private function _listLoaded( levels:Array, count:int, response:Object ):void
			{
				if ( response.Success ) {
					_lastLoad = getTimer() +60000;
					lastResult = [];
					for ( var i:int; i < count; i++ )
						lastResult.push( CustomLevel.createFromPlaytomic(levels[i] as PlayerLevel) );
					lastTotalPages = (lastCount = count)/lastParam.perpage >>0;
					if ( stage )
						populate();
					
				} else {
					if ( !stage )
						return;
					CONFIG::debug {
						addChild( PopPrompt.create('Error ('+ response.ErrorCode +'): \n'+ Registry.PLAYTOMIC_ERR_MSG[response.ErrorCode], 100, {name:'OK'}) ); }
					CONFIG::release {
						addChild( PopPrompt.create('Server might be busy. Try again later. ('+ response.ErrorCode +')', 100, {name:'OK'}) ); }
					
					stage.focus = stage;
					_clipLoad.visible = false;
					_clipLoad.stop();
					_btnPrev.visible = lastParam.page > 1;
					_btnNext.visible = lastParam.page < lastTotalPages;
					_txfPage.type = _txfKey.type = 'input'; _txfKey.alpha = 1;
				}
			}
			
			private function _listLoadedGs( e:Event=null ):void
			{
				GamerSafeHelper.i.lvGotLvls.remove( _listLoadedGs );
				GamerSafeHelper.i.lvException.remove( _gsError );
				GamerSafeHelper.i.lvError.remove( _gsError );
				GamerSafeHelper.i.networkError.remove( _gsError );
				
				if ( e && e.type == GamerSafe.EVT_LEVELVAULT_GOT_LEVELS ) {
					//lastCount = GamerSafe.api.levelVaultGetNumLevels();
					var list:Array = GamerSafe.api.levelVaultGetLastSelectedLevels();
						
					_lastLoad = getTimer() +60000;
					lastResult = [];
					for ( var i:int; i < list.length; i++ )
						lastResult.push( CustomLevel.createFromGamersafe(list[i]) );
					if ( stage ) populate();
					
				} else {
					_gsError();
				}
				
			}
			
			private function _gsError( e:*=null ):void
			{
				if ( GamerSafe.api && GamerSafe.api.loaded ) {
					GamerSafeHelper.i.lvGotLvls.remove( _listLoadedGs );
					GamerSafeHelper.i.lvException.remove( _gsError );
					GamerSafeHelper.i.lvError.remove( _gsError );
					GamerSafeHelper.i.networkError.remove( _gsError );
				}
				
				if ( !stage )
					return;
				addChild( PopPrompt.create('Server might be busy or inaccessible. Try again later or restart the game.', 120, {name:'OK', call:_hideWithPrompt}) );
				
				stage.focus = stage;
				_clipLoad.visible = false;
				_clipLoad.stop();
				_btnPrev.visible = lastParam.page > 1;
				_btnNext.visible = lastParam.page < lastTotalPages;
				_txfPage.type = _txfKey.type = 'input'; _txfKey.alpha = 1;
			}
			
			
			private function _getFrKey():void
			{
				if ( _clipLoad.visible ) return;
				if ( !lastLevel || _txfKey.text != lastLevel.LevelId ) {
					var str:String = _txfKey.text;
					var limit:uint = CONFIG::useGamersafe ? 6 : ( CONFIG::usePlaytomicLvls ? 24 : 4 );
					if ( str.length < limit ) {
						addChild( PopPrompt.create('Error retrieving course ID', 100, {name:'OK'}) );
						_txfKey.setSelection( 0, _txfKey.length );
						return;
						
					} else if ( str.length > limit ) {
						if ( str.indexOf('pb_') > -1 ) {
							str = str.substring( str.indexOf("pb_") + 3 );
							if ( str.indexOf("&") > -1 )
								str = str.substring( 0, str.indexOf("&") );
							if ( str.indexOf("/") > -1 )
								str = str.substring( 0, str.indexOf("/") );
							if( str.indexOf("#") > -1 )
								str = str.substring( 0, str.indexOf("#") );
							trace( '3:key:', str );
						} else {
							addChild( PopPrompt.create('Error retrieving course ID', 100, {name:'OK'}) );
							return;
						}
					}
					if ( CONFIG::useGamersafe && int(str)+'' != str ) {
						addChild( PopPrompt.create('Error retrieving course ID', 100, { name:'OK' } ) );
						return;
					}
					
					_clipLoad.y = 283;
					_clipLoad.visible = true;
					_clipLoad.play();
					_btnPrev.visible = _btnNext.visible = false;
					_txfPage.type = _txfKey.type = 'dynamic'; _txfKey.alpha = .25;
					
					CONFIG::useGamersafe {
						if ( GamerSafe.api && GamerSafe.api.loaded ) {
							GamerSafeHelper.i.lvGot1Lvl.addOnce( _keyLoadedGs );
							GamerSafeHelper.i.lvException.addOnce( _gsKeyError );
							GamerSafeHelper.i.lvError.addOnce( _gsKeyError );
							GamerSafeHelper.i.networkError.addOnce( _gsKeyError );
							GamerSafe.api.levelVaultFetchLevelByID( int(str) );
						} else
							_gsKeyError();
					}
					CONFIG::usePlaytomicLvls { PlayerLevels.Load( str, _keyLoaded ); }
					
				} else {
					_keyLoaded( lastLevel, {Success:true} );
				}
				stage.focus = stage;
			}
			
			private function _keyLoaded( level:PlayerLevel, response:Object ):void
			{
				if ( response.Success ) {
					lastLevel = level;
					if ( !stage )
						return;
					
					var win:Window = new CLevelDetailWindow( CustomLevel.createFromPlaytomic(level), _parentClass );
					addChild( win );
					win.show();
					
					stage.focus = stage;
					_clipLoad.visible = false;
					_clipLoad.stop();
					_btnPrev.visible = lastParam.page > 1;
					_btnNext.visible = lastParam.page < lastTotalPages;
					_txfPage.type = _txfKey.type = 'input'; _txfKey.alpha = 1;
					
					
				} else {
					if ( !stage )
						return;
					CONFIG::debug {
						addChild( PopPrompt.create('Error ('+ response.ErrorCode +'): \n'+ Registry.PLAYTOMIC_ERR_MSG[response.ErrorCode], 100, {name:'OK'}) ); }
					CONFIG::release {
						addChild( PopPrompt.create('Server might be busy. Try again later. ('+ response.ErrorCode +')', 100, {name:'OK'}) ); }
					
					stage.focus = stage;
					_clipLoad.visible = false;
					_clipLoad.stop();
						_btnPrev.visible = lastParam.page > 1;
						_btnNext.visible = lastParam.page < lastTotalPages;
					_txfPage.type = _txfKey.type = 'input'; _txfKey.alpha = 1;
					
				}
			}
			
			private function _keyLoadedGs( e:Event ):void
			{
				GamerSafeHelper.i.lvGot1Lvl.remove( _keyLoadedGs );
				GamerSafeHelper.i.lvException.remove( _gsKeyError );
				GamerSafeHelper.i.lvError.remove( _gsKeyError );
				GamerSafeHelper.i.networkError.remove( _gsKeyError );
				
				if ( e.type == GamerSafe.EVT_LEVELVAULT_GOT_SINGLE_LEVEL ) {
					if ( !stage )
						return;
					
					var win:Window = new CLevelDetailWindow( CustomLevel.createFromGamersafe(GamerSafe.api.levelVaultGetLastSelectedLevel()), _parentClass );
					addChild( win );
					win.show();
					
					stage.focus = stage;
					_clipLoad.visible = false;
					_clipLoad.stop();
					_btnPrev.visible = lastParam.page > 1;
					_btnNext.visible = lastParam.page < lastTotalPages;
					_txfPage.type = _txfKey.type = 'input'; _txfKey.alpha = 1;
					
				} else
					_gsKeyError( e );
			}
			
			private function _gsKeyError( e:*=null ):void
			{
				GamerSafeHelper.i.lvGot1Lvl.remove( _keyLoadedGs );
				GamerSafeHelper.i.lvException.remove( _gsKeyError );
				GamerSafeHelper.i.lvError.remove( _gsKeyError );
				GamerSafeHelper.i.networkError.remove( _gsKeyError );
				
				if ( !stage ) return;
				
				if ( e && e is Error )
					addChild( PopPrompt.create(Error(e).message, 120, {name:'OK'}) );
				else
					addChild( PopPrompt.create('Server might be busy or inaccessible.', 120, {name:'OK'}) );
				
				stage.focus = stage;
				_clipLoad.visible = false;
				_clipLoad.stop();
				_btnPrev.visible = lastParam.page > 1;
				_btnNext.visible = lastParam.page < lastTotalPages;
				_txfPage.type = _txfKey.type = 'input'; _txfKey.alpha = 1;
				
			}
			
			
			private function _hideWithPrompt():void
			{
				PopPrompt.remove();
				hide();
			}
			
			
	}

}