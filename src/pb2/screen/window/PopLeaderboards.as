package pb2.screen.window 
{
	import com.jaycsantos.math.MathUtils;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import pb2.game.ctrl.GamerSafeHelper;
	import pb2.game.ctrl.RankMngr;
	import pb2.game.ctrl.SaveDataMngr;
	import pb2.game.MapData;
	import pb2.game.Session;
	import pb2.screen.ui.SmallBtn1;
	import pb2.screen.ui.UIFactory;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PopLeaderboards extends PopWindow 
	{
		
		public function PopLeaderboards() 
		{
			super();
			var txf:TextField, sp:Sprite, g:Graphics, i:int, j:int;
			
			{//-- bg
				_bgClip.addChild( UIFactory.createTextField('LEADER BOARDS', 'leaderHead', 'center', 180, 8) );
				
				g = _bgClip.graphics;
				g.beginFill( 0xCCC199, .75 );
				g.lineStyle( 1, 0x8C8C8C );
				g.drawRect( 33, 58, 300, 20 );
				g.endFill();
				
				_bgClip.addChild( UIFactory.createTextField('name', 'leaderTh', 'left', 50, 58) );
				_bgClip.addChild( UIFactory.createTextField('score', 'leaderTh', 'left', 280, 58) );
			}
			
			{//-- contents
				_contents.parent.addChild( _loading = PuttBase2.assets.createDisplayObject('screen.ui.ico.iconLoading') as MovieClip );
				_loading.visible = false; _loading.stop();
				_loading.x = 325; _loading.y = 200;
				
				
				_contents.addChild( _txfTime = UIFactory.createFixedTextField('weekly', 'leaderTh', 'left', 355, 158) );
				
				_contents.addChild( _txfClip = new Sprite );
				_txfClip.x = _txfClip.y = 178;
				
				for ( i=0; i<6; i++ ) {
					_txfClip.addChild( txf = UIFactory.createTextField('', 'leaderLi', 'none', 12, i*15) );
					txf.width = 150; txf.height = 18;
					
					_txfClip.addChild( txf = UIFactory.createTextField('', 'leaderLiCenter', 'none', 172, i*15) );
					txf.width = 50; txf.height = 18;
					
					_txfClip.addChild( txf = UIFactory.createTextField('', 'leaderLiCenter', 'none', 232, i*15) );
					txf.width = 60; txf.height = 18;
				}
				
				_contents.addChild( _btnClose = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnClose') as SimpleButton );
				_btnClose.x = 485; _btnClose.y = 120;
			}
			
			{//-- tabs
				_contents.addChild( _tabAmateur = PuttBase2.assets.createDisplayObject('screen.ui.btn.tabAmateur') as MovieClip );
				_contents.addChild( _tabPro = PuttBase2.assets.createDisplayObject('screen.ui.btn.tabPro') as MovieClip );
				_tabAmateur.y = _tabPro.y = 85;
				_tabAmateur.buttonMode = _tabPro.buttonMode = true;
				_tabAmateur.gotoAndStop(2); _tabPro.gotoAndStop(2);
				
				_contents.addChild( _tabWk = PuttBase2.assets.createDisplayObject('screen.ui.btn.tabWeek') as MovieClip );
				_contents.addChild( _tabMo = PuttBase2.assets.createDisplayObject('screen.ui.btn.tabMonth') as MovieClip );
				_contents.addChild( _tabAll = PuttBase2.assets.createDisplayObject('screen.ui.btn.tabAllTime') as MovieClip );
				_tabWk.y = _tabMo.y = _tabAll.y = 275;
				_tabWk.buttonMode = _tabMo.buttonMode = _tabAll.buttonMode = true;
				_tabWk.x = 270; _tabWk.name = 'weekly'; _tabWk.gotoAndStop(2);
				_tabMo.x = 310; _tabMo.name = 'monthly'; _tabMo.gotoAndStop(2);
				_tabAll.x = 350; _tabAll.name = 'all time'; _tabAll.gotoAndStop(2);
				
				_contents.addChild( _tip = new PopBtnTip );
				
				_contents.addChild( _btnSubmit = new SmallBtn1('SUBMIT') );
				_btnSubmit.x = 425; _btnSubmit.y = 274;
				_btnSubmit.visible = false;
			}
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.windows.popLeaderboards') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(8, 12, 1).reverse(), 1, false, _loadScores );
				_animator.addSequenceSet( SHOW, MathUtils.intRangeA(1, 8, 1).reverse(), 1, false, _showContents );
				_animator.addSequenceSet( SUBMIT, MathUtils.intRangeA(1, 8, 1), 1, false, _submitScores );
				_animator.addSequenceSet( END, MathUtils.intRangeA(1, 12, 1), 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
			}
			
			
			_contents.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
			_contents.addEventListener( MouseEvent.MOUSE_OVER, _movr, false, 0, true );
			_contents.addEventListener( MouseEvent.MOUSE_OUT, _mout, false, 0, true );
			_scores = new Vector.<Object>;
		}
		
		override public function dispose():void 
		{
			_contents.removeEventListener( MouseEvent.CLICK, _click );
			_contents.removeEventListener( MouseEvent.MOUSE_OVER, _movr );
			_contents.removeEventListener( MouseEvent.MOUSE_OUT, _mout );
			
			_txfTime = null;
			_txfClip = null;
			_btnClose = null;
			_tabAmateur = _tabPro = _tabWk = _tabMo = _tabAll = _loading = null;
			_scores.splice( 0, _scores.length );
			_scores = null;
			
			_btnSubmit.dispose(); _btnSubmit = null;
			
			super.dispose();
		}
		
		
		override public function hide():void 
		{
			PopPrompt.remove();
			if ( !visible ) return;
			
			onPreHide.dispatch();
			
			_contents.visible = _bgBmp.visible = false;
			_clip.filters = [];
			_animator.playSet( END, _clip.currentFrame-1 );
		}
		
		override public function update():void 
		{
			super.update();
			
			if ( _btnSubmit ) _btnSubmit.update();
		}
		
			// -- private --
			
			private static const SHOW:String = 'show', SUBMIT:String = 'submit';
			
			private var _txfTime:TextField, _txfClip:Sprite, _btnClose:SimpleButton, _tip:PopBtnTip, _btnSubmit:SmallBtn1
			private var _tabAmateur:MovieClip, _tabPro:MovieClip, _tabWk:MovieClip, _tabMo:MovieClip, _tabAll:MovieClip
			private var _loading:MovieClip, _sett:uint, _time:uint, _scores:Vector.<Object>
			
			
			override protected function _init(e:Event):void 
			{
				_contents.x = 145; _contents.y = 100;
				super._init(e);
				_contents.x = _contents.y = 0;
			}
			
			override protected function _showContents():void 
			{
				super._showContents();
				
				var i:int = uint(SaveDataMngr.instance.getCustom('lastMapSet'));
				if ( _sett ) _tabPro.gotoAndStop( 4 );
				else _tabAmateur.gotoAndStop( 4 );
				_tabWk.gotoAndStop( 4 );
				
				_populate( _sett, _time );
			}
			
			
			private function _populate( index:uint, time:uint ):void
			{
				CONFIG::useGamersafe {
					var extra:String = SaveDataMngr.instance.getCustom('rankExtra');
					var list:Array, rank:int, txf:TextField, i:int, j:int, mark:Boolean;
					var ranks:Object = RankMngr.i.getParsedGroupRank( index );
					switch( time ) {
						case 0: // weekly
							rank = ranks.week;
							list = _scores[ index ].weekly;
							break;
						case 1: // month
							rank = ranks.month;
							list = _scores[ index ].monthly;
							break;
						case 2: // all
							rank = ranks.all;
							list = _scores[ index ].all;
							break;
					}
					
					var name:String = SaveDataMngr.instance.getCustom('highscore_name');
					var xml:XML = SaveDataMngr.instance.getGroupTotalData( index );
					var score:uint = uint( xml.@score );
					_txfClip.graphics.clear();
					if ( !name ) name = '** you **';
					
					for ( i=0; i<6; i++ ) {
						if ( rank == i+1 || (i==5 && (!ranks.all || rank > Math.min(6, list.length)) && score) ) {
							mark = true;
							_txfClip.graphics.beginFill( 0xE5E572 );
							_txfClip.graphics.drawRect( 5, 2 +i*15, 290, 13 );
							_txfClip.graphics.endFill();
						} else
							mark = false;
						
						if ( i >= list.length && !mark ) {
							TextField(_txfClip.getChildAt( i*3 )).htmlText = '<p class="leaderLiEmpty">- - empty - -</p>';
							TextField(_txfClip.getChildAt( i*3 +1 )).htmlText = '<p class="leaderLiCenter">#'+ (i+1) +'</p>';
							TextField(_txfClip.getChildAt( i*3 +2 )).text = '';
							
						} else {
							txf = TextField(_txfClip.getChildAt( i*3 )); txf.visible = true;
							txf.htmlText = '<p class="leaderLi"><span class="'+(mark?'leaderLiMarked':'')+'">'+ (mark ? name : list[i].username) +'</span></p>';
							
							txf = TextField(_txfClip.getChildAt( i*3 +1 )); txf.visible = true;
							txf.htmlText = '<p class="leaderLiCenter"><span class="'+(mark?'leaderLiMarked':'')+'">#'+ (mark? (rank ? MathUtils.toThousands(rank) : '?') : (i+1)) +'</span></p>';
							
							txf = TextField(_txfClip.getChildAt( i*3 +2 )); txf.visible = true;
							txf.htmlText = '<p class="leaderLiCenter"><span class="'+(mark?'leaderLiMarked':'')+'">'+ MathUtils.toThousands(mark ? score : list[i].score) +'</span></p>';
						}
					}
					
					_btnSubmit.visible = (SaveDataMngr.instance.getCustom('pendScore_grp'+_sett) || !ranks.all) && score && CONFIG::useGamersafe;
				}
				
			}
			
			
			private function _loadScores():void
			{
				_overlay.visible = true;
				
				_loading.visible = true;
				_loading.play();
				_scores.splice( 0, _scores.length );
				
				CONFIG::useGamersafe {
					if ( GamerSafe.api && GamerSafe.api.loaded ) {
						trace( 'GS: requesting scores (amateur)' );
						GamerSafeHelper.i.scoreReceived.addOnce( _onGsReceiveScores );
						GamerSafeHelper.i.scoreError.addOnce( _onGsError );
						GamerSafeHelper.i.networkError.addOnce( _onGsError );
						GamerSafe.api.requestScoreboardEntries( GamerSafeConstants.SCOREBOARD_AMATEUR_LEADERS );
						
					} else {
						_onGsError();
					}
				}
				
			}
			
			private function _onGsReceiveScores( e:Event ):void
			{
				if ( !stage ) return;
				trace( 'GS: scores retrieved' );
				
				_scores.push( GamerSafe.api.latestScoreboardEntries );
				RankMngr.i.parseGroupRank( GamerSafe.api.latestScoreboardEntries, _scores.length-1 );
				
				if ( _scores.length == 1 ) {
					trace( 'GS: requesting scores (pro)' );
					GamerSafeHelper.i.scoreReceived.addOnce( _onGsReceiveScores );
					GamerSafe.api.requestScoreboardEntries( GamerSafeConstants.SCOREBOARD_PROFESSIONAL_LEADERS );
					
				} else {
					GamerSafeHelper.i.scoreReceived.remove( _onGsReceiveScores );
					GamerSafeHelper.i.scoreError.remove( _onGsError );
					GamerSafeHelper.i.networkError.remove( _onGsError );
					
					_animator.playSet( SHOW );
					_loading.visible = false;
					_loading.stop();
				}
			}
			
			
			private function _preSubmitScores():void
			{
				if ( !SaveDataMngr.instance.getCustom('highscore_name') ) {
					var win:Window = new GetNameWindow( PopLeaderboards );
					addChild( win );
					win.onHidden.addOnce( _preSubmitScores );
					win.show();
					
				} else {
					_contents.visible = _bgBmp.visible = false;
					_clip.filters = [];
					_animator.playSet( SUBMIT, _clip.currentFrame-1 );
				}
				
			}
			
			private function _submitScores():void
			{
				var map:MapData = Session.instance.map;
				var saveMngr:SaveDataMngr = SaveDataMngr.instance;
				var name:String = saveMngr.getCustom('highscore_name');
				
				CONFIG::useGamersafe {
					// no need to check if api is loaded, submit button not shown eitherwise
					var index:int = _sett;// 2 -_scores.length;
					//_scores.shift();
					
					var xml:XML = saveMngr.getGroupTotalData( index );
					var extra:String = saveMngr.getCustom( 'rankExtra_grp'+ index );
					
					if ( uint(xml.@score) ) {
						trace( 'GS: sending scores ('+index+')' );
						GamerSafeHelper.i.scoreSubmitted.add( _onGsSubmitScores );
						GamerSafeHelper.i.scoreError.addOnce( _onGsError );
						GamerSafeHelper.i.networkError.addOnce( _onGsError );
						GamerSafe.api.saveToScoreboard( uint(xml.@score), extra, RankMngr['GROUP_'+ index +'_BOARD_ID'], name );
						
					} else {
						trace( 'GS: skip sending scores ('+index+')' );
						_onGsSubmitScores();
					}
				}
				_loading.visible = true;
				_loading.play();
			}
			
			private function _onGsSubmitScores( e:Event=null ):void
			{
				trace( 'GS: score submitted' );
				//SaveDataMngr.instance.saveCustom( 'pendScore_grp'+ (1-_scores.length), '', true )
				SaveDataMngr.instance.saveCustom( 'pendScore_grp'+ _sett, '', true )
				
				/*if ( _scores.length ) {
					_sumbmitScores();
					
				} else {*/
					GamerSafeHelper.i.scoreSubmitted.remove( _onGsSubmitScores );
					GamerSafeHelper.i.scoreError.remove( _onGsError );
					GamerSafeHelper.i.networkError.remove( _onGsError );
					
					_loadScores();
				/*}*/
				
			}
			
			
			private function _onGsError( e:*= null ):void
			{
				if ( GamerSafe.api && GamerSafe.api.loaded ) {
					GamerSafeHelper.i.scoreReceived.remove( _onGsReceiveScores );
					GamerSafeHelper.i.scoreSubmitted.remove( _onGsSubmitScores );
					GamerSafeHelper.i.scoreError.remove( _onGsError );
					GamerSafeHelper.i.networkError.remove( _onGsError );
				}
				
				if ( !stage ) return;
				
				if ( e && e is Error )
					addChild( PopPrompt.create('Error\n'+Error(e).message, 120, {name:'OK', call:hide}) );
				else if ( !GamerSafe.api || !GamerSafe.api.loaded )
					addChild( PopPrompt.create('Cannot establish connection to server. Restart game if it persists.', 120, {name:'OK', call:hide}) );
				else
					addChild( PopPrompt.create('Server might be busy or inaccessible. Try again later.', 120, {name:'OK', call:hide}) );
				
				_loading.visible = false;
				_loading.stop();
			}
			
			
			private function _click( e:MouseEvent ):void
			{
				switch( e.target ) {
					case _tabAmateur:
						if ( _tabAmateur.currentFrame != 4 ) {
							_tabAmateur.gotoAndStop( 4 );
							_populate( _sett=0, _time );
							_tabPro.gotoAndStop( 2 );
						}
						break;
						
					case _tabPro:
						if ( _tabPro.currentFrame != 4 ) {
							_tabPro.gotoAndStop( 4 );
							_populate( _sett=1, _time );
							_tabAmateur.gotoAndStop( 2 );
						}
						break;
					
					case _tabWk:
						if ( _tabWk.currentFrame != 4 ) {
							_tabWk.gotoAndStop( 4 );
							_populate( _sett, _time=0 );
							_tabMo.gotoAndStop( 2 );
							_tabAll.gotoAndStop( 2 );
							_txfTime.text = 'weekly';
							_tip.hide();
						}
						break;
					
					case _tabMo:
						if ( _tabMo.currentFrame != 4 ) {
							_tabMo.gotoAndStop( 4 );
							_populate( _sett, _time=1 );
							_tabWk.gotoAndStop( 2 );
							_tabAll.gotoAndStop( 2 );
							_txfTime.text = 'monthly';
							_tip.hide();
						}
						break;
					
					case _tabAll:
						if ( _tabAll.currentFrame != 4 ) {
							_tabAll.gotoAndStop( 4 );
							_populate( _sett, _time=2 );
							_tabWk.gotoAndStop( 2 );
							_tabMo.gotoAndStop( 2 );
							_txfTime.text = 'all time';
							_tip.hide();
						}
						break;
					
					case _btnClose:
						hide();
						break;
					
					case _btnSubmit:
						_preSubmitScores();
						break;
				}
			}
			
			private function _movr( e:MouseEvent ):void
			{
				switch( e.target ) {
					case _tabAmateur:
					case _tabPro:
					case _tabWk:
					case _tabMo:
					case _tabAll:
						var mc:MovieClip = e.target as MovieClip;
						if ( mc.currentFrame == 2 ) {
							mc.gotoAndStop( 3 );
							if ( mc.y > 100 )
								_tip.pop( mc.name, mc.x +mc.width/2 >>0, mc.y );
						}
						break;
				}
			}
			
			private function _mout( e:MouseEvent ):void
			{
				switch( e.target ) {
					case _tabAmateur:
					case _tabPro:
					case _tabWk:
					case _tabMo:
					case _tabAll:
						var mc:MovieClip = e.target as MovieClip;
						if ( mc.currentFrame != 4 ) {
							mc.gotoAndStop( 2 );
							if ( mc.y > 100 ) _tip.hide();
						}
						break;
				}
			}
			
			
	}

}