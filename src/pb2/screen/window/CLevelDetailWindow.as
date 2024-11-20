package pb2.screen.window 
{
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.util.UserInput;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.net.URLVariables;
	import flash.system.System;
	import flash.text.TextField;
	import pb2.game.ctrl.GamerSafeHelper;
	import pb2.game.ctrl.SaveDataMngr;
	import pb2.game.*;
	import pb2.screen.*;
	import pb2.screen.ui.UIFactory;
	import pb2.util.CustomLevel;
	import Playtomic.*;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class CLevelDetailWindow extends PopWindow
	{
		
		public function CLevelDetailWindow( level:CustomLevel, parentClass:Class ) 
		{
			var g:Graphics, sp:Sprite, sp2:Sprite, shp:Shape, txf:TextField, i:int, j:int, k:String, a:Array;
			_lvl = level;
			_parentClass = parentClass;
			
			super();
			
			{//-- basic window
				g = _overlay.graphics;
				g.clear();
				g.beginFill( 0, Window.instanceCount()? .5: .9 );
				g.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
				
				g = _contents.graphics;
				g.beginFill( 0, 0 );
				g.drawRect( 0, 0, 280, 145 );
				_contents.mouseEnabled = true;
			}
			
			{//-- bg
				_bgClip.addChild( UIFactory.createTextField('click anywhere else to close', 'clevel2ExitTxt', 'center', 140, 143) );
				
				_bgClip.addChild( sp = PuttBase2.assets.createDisplayObject('screen.ui.ico.golfTee') as Sprite );
				sp.x = 26; sp.y = 24;
				_bgClip.addChild( txf = UIFactory.createTextField(_lvl.name, 'header', 'none', 33, 7) );
				txf.width = 225; txf.height = 35;
				
				_bgClip.addChild( txf = UIFactory.createTextField('by '+ _lvl.author, 'clevel2Author', 'none', 28, 30) );
				txf.width = 220; txf.height = 18;
				_bgClip.addChild( txf = UIFactory.createTextField( (_lvl.plays?_lvl.plays+' play':'unplayed')+(_lvl.plays>1?'s':'') +' | '+ (_lvl.votes>=3? 'rated '+ Number(_lvl.rating/20).toFixed(1) +' ('+ _lvl.votes +')': 'unrated ('+_lvl.votes+'/3)') +' | '+ _lvl.RDate.replace(/\shour/g, 'hr').replace(/\sminute/g, 'min'), 'clevel2Detail', 'none', 14, 43) );
				txf.width = 245; txf.height = 18;
				
				_bgClip.addChild( UIFactory.createTextField('Course Link', 'clevel2Share', 'left', 22, 57.5) );
				_bgClip.addChild( UIFactory.createTextField('Course ID', 'clevel2Share', 'left', 22, 87.5) );
				_bgClip.addChild( UIFactory.createTextField('your highscore', 'clevel2Share', 'left', 199, 55) );
				
				var xmlSave:XML = SaveDataMngr.instance.getPlayerLevelData( _lvl.name.replace(/\s/g, '-'), _lvl.id );
				if ( xmlSave != null && uint(xmlSave.@score) ) {
					_lastScore = uint(xmlSave.@score);
					_bgClip.addChild( UIFactory.createTextField( MathUtils.toThousands(_lastScore), 'clevel2Hscore', 'center', 230, 64) );
				} else
					_bgClip.addChild( UIFactory.createTextField('0', 'clevel2Hscore', 'center', 230, 64) );
			}
			
			{//-- texts
				_contents.addChild( _txfURL = UIFactory.createTextField(Registry.SPONSOR_GAME_URL_LVLID +_lvl.id, 'clevel2URL', 'none', 22, 71) );
				_txfURL.width = 170; _txfURL.height = 18;
				_txfURL.selectable = true; _txfURL.wordWrap = false;
				_txfURL.mouseEnabled = true;
				
				_contents.addChild( _txfLvlid = UIFactory.createTextField(_lvl.id, 'clevel2URL', 'none', 22, 101) );
				_txfLvlid.width = 130; _txfLvlid.height = 18;
				_txfLvlid.selectable = true; _txfLvlid.wordWrap = false;
				_txfLvlid.mouseEnabled = true;
			}
			
			{//-- button
				_contents.addChild( _btnFb = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnFb') as SimpleButton );
				_contents.addChild( _btnTwit = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnTwit') as SimpleButton );
				_contents.addChild( _btnGo = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnGo') as SimpleButton );
				
				_btnFb.x = 175; _btnTwit.x = 205; _btnGo.x = 245;
				_btnFb.y = _btnTwit.y = _btnGo.y = 110;
				_btnFb.name = 'share';
				_btnTwit.name = 'tweet';
				_btnGo.name = 'play';
				
				_contents.addChild( _clipLoad = PuttBase2.assets.createDisplayObject('screen.ui.ico.iconLoading') as MovieClip );
				_clipLoad.stop(); _clipLoad.visible = false;
				_clipLoad.x = _btnGo.x; _clipLoad.y = _btnGo.y;
				
				_contents.addChild( _tip = new PopBtnTip );
			}
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.windows.popCLevelDetails') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.fixedStep = true; _animator.step = 3;
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 11, 1), 2, false, _showContents );
				_animator.addSequenceSet( END, MathUtils.intRangeA(11, 21, 1), 2, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
			}
			
			onShown.add( _onShown );
			onPreHide.addOnce( PopPrompt.hide );
		}
		
		override public function dispose():void 
		{
			removeEventListener( MouseEvent.CLICK, _click );
			removeEventListener( MouseEvent.MOUSE_OVER, _movr );
			removeEventListener( MouseEvent.MOUSE_OUT, _mout );
			
			_parentClass = null;
			
			_txfURL = _txfLvlid = null;
			_btnFb = _btnGo = _btnTwit = null;
			_tip.dispose(); _tip = null;
			
			super.dispose();
		}
		
		
		
			// -- private --
			
			private var _txfURL:TextField, _txfLvlid:TextField, _tip:PopBtnTip
			private var _btnFb:SimpleButton, _btnTwit:SimpleButton, _btnGo:SimpleButton, _lvl:CustomLevel, _clipLoad:MovieClip
			private var _lastScore:uint, _parentClass:Class
			
			override protected function _init(e:Event):void 
			{
				_contents.x = 185; _contents.y = 127;
				
				super._init(e);
			}
			
			override protected function _showContents():void 
			{
				onShown.dispatch();
				
				_contents.visible = _bgBmp.visible = true;
				_overlay.alpha = 1;
				_clip.filters = [ new GlowFilter(0x191919, 1, 8, 8, 1) ];
			}
			
			
			private function _click( e:MouseEvent ):void
			{
				if ( _clipLoad.visible ) return;
				
				var urlvar:URLVariables;
				
				switch ( e.target ) {
					case _btnGo:
						if ( _lvl.data.length ) {
							_playLevel();
							
						} else {
							_clipLoad.visible = true;
							_clipLoad.play();
							_btnFb.enabled = _btnTwit.enabled = _btnGo.visible = false;
							
							CONFIG::useGamersafe {
								if ( GamerSafe.api && GamerSafe.api.loaded ) {
									GamerSafeHelper.i.lvGotLvls.addOnce( _keyLoadedGs );
									GamerSafeHelper.i.lvException.addOnce( _gsError );
									GamerSafe.api.levelVaultFetchLevelByID( int(_lvl.id) );
								} else {
									_keyLoadedGs();
								}
							}
							CONFIG::usePlaytomicLvls { PlayerLevels.Load( _lvl.id, _keyLoaded ); }
						}
						break;
						
					case _btnFb:
						urlvar = new URLVariables();
						urlvar.t = 'Putt More Base - '+ _lvl.name +' (custom level)';
						urlvar.u = Registry.SPONSOR_GAME_URL_LVLID +_lvl.id;
						Link.Open( 'http://www.facebook.com/sharer.php?'+ urlvar.toString(), 'CustomLevel_fb', 'share' );
						break;
						
					case _btnTwit:
						urlvar = new URLVariables();
						if ( _lastScore )
							urlvar.status = 'Beat my score '+ _lastScore +',play PuttMoreBase level '+ Registry.SPONSOR_GAME_URL_LVLID +_lvl.id;
						else
							urlvar.status = 'Play this PuttMoreBase level '+ Registry.SPONSOR_GAME_URL_LVLID +_lvl.id;
						Link.Open( 'http://twitter.com/?'+ urlvar.toString(), 'CustomLevel_twit', 'share' );
						break;
						
					case _txfURL:
						_txfURL.setSelection( 0, _txfURL.text.length );
						System.setClipboard( _txfURL.text );
						break;
					case _txfLvlid:
						_txfLvlid.setSelection( 0, _txfLvlid.text.length );
						System.setClipboard( _txfLvlid.text );
						break;
						
					case _overlay:
						hide();
						break;
					default: break;
				}
			}
			
			private function _movr( e:MouseEvent ):void
			{
				switch( e.target ) {
					case _btnGo:
					case _btnFb:
					case _btnTwit:
						var d:DisplayObject = e.target as DisplayObject;
						_tip.pop( d.name, d.x, d.y );
						break;
					
					case _txfLvlid:
					case _txfURL:
						var txf:TextField = e.target as TextField;
						_tip.pop( 'copy', txf.x +txf.width/2, txf.y );
						break;
						
					default:
						break;
				}
			}
			
			private function _mout( e:MouseEvent ):void
			{
				switch( e.target ) {
					case _btnGo:
					case _btnFb:
					case _btnTwit:
					case _txfLvlid:
					case _txfURL:
						_tip.hide();
						break;
						
					default:
						break;
				}
			}
			
			
			private function _keyLoaded( level:PlayerLevel, response:Object ):void
			{
				if ( response.Success ) {
					_lvl = CustomLevel.createFromPlaytomic( level );
					_playLevel();
					
				} 
				else {
					if ( stage == null ) return;
					var sp:CLevelsWindow = CLevelsWindow(parent);
					
					CONFIG::debug {
						sp.addChild( PopPrompt.create('Error ('+ response.ErrorCode +'): \n'+ Registry.PLAYTOMIC_ERR_MSG[response.ErrorCode], 120, {name:'OK'}) ); }
					CONFIG::release {
						sp.addChild( PopPrompt.create('Server might be busy or inaccessible. Try again later. ('+ response.ErrorCode +')', 120, {name:'OK'}) ); }
					
					_clipLoad.visible = false;
					_clipLoad.stop();
					_btnFb.enabled = _btnTwit.enabled = _btnGo.visible = true;
				}
			}
			
			private function _keyLoadedGs( e:Event=null ):void
			{
				GamerSafeHelper.i.lvGotLvls.remove( _keyLoadedGs );
				GamerSafeHelper.i.lvException.remove( _gsError );
				
				if ( e && e.type == GamerSafe.EVT_LEVELVAULT_GOT_SINGLE_LEVEL ) {
					_lvl = CustomLevel.createFromGamersafe( GamerSafe.api.levelVaultGetLastSelectedLevel() );
					_playLevel();
					
				} else {
					_gsError();
				}
				
			}
			
			private function _gsError( e:Error=null ):void
			{
				if ( GamerSafe.api && GamerSafe.api.loaded ) {
					GamerSafeHelper.i.lvGotLvls.remove( _keyLoadedGs );
					GamerSafeHelper.i.lvException.remove( _gsError );
				}
				
				if ( stage == null ) return;
				
				var sp:CLevelsWindow = CLevelsWindow(parent);
				sp.addChild( PopPrompt.create('Server might be busy or inaccessible. Try again later or restart the game.', 120, {name:'OK'}) );
				
				_clipLoad.visible = false;
				_clipLoad.stop();
				_btnFb.enabled = _btnTwit.enabled = _btnGo.visible = true;
			}
			
			
			private function _playLevel():void
			{
				var xml:XML = XML(<level sett="9999" group="-1"><map></map><par></par><item></item></level>);
				xml.@name = _lvl.name.replace(/\s/g, '-');
				xml.@author = _lvl.author.replace(/\s/g, '-');
				xml.map = _lvl.data;
				xml.par = _lvl.par;
				xml.item = _lvl.item;
				
				var ses:Session = Session.instance;
				var oldMap:MapData = ses.map;
				ses.map = new MapData( xml, _lvl );
				
				switch ( _parentClass ) {
					case MenuActScreen: Tracker.i.startLevel( ses.map, 'mainmenu' ); break;
					case PopSuccess: Tracker.i.startLevel( ses.map, 'success' ); break;
					case PopFail: Tracker.i.startLevel( ses.map, 'fail' ); break;
					case PauseMenu:
						Tracker.i.quitLevel( oldMap, 'pauseMenu' );
						Tracker.i.startLevel( ses.map, 'pauseMenu' ); break;
				}
				
				CONFIG::debug {
					GameRoot.changeScreen( RelayScreen, UserInput.instance.isKeyDown(32)? EditorScreen: PlayScreen ); }
				CONFIG::release {
					GameRoot.changeScreen( RelayScreen, PlayScreen ); }
			}
			
			
			private function _onShown():void
			{
				addEventListener( MouseEvent.CLICK, _click, false, 0, true );
				addEventListener( MouseEvent.MOUSE_OVER, _movr, false, 0, true );
				addEventListener( MouseEvent.MOUSE_OUT, _mout, false, 0, true );
			}
		
	}

}