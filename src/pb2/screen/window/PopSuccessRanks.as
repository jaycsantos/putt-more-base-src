package pb2.screen.window 
{
	import com.jaycsantos.math.MathUtils;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import pb2.game.ctrl.RankMngr;
	import pb2.game.ctrl.SaveDataMngr;
	import pb2.game.MapData;
	import pb2.game.Session;
	import pb2.screen.ui.UIFactory;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PopSuccessRanks extends PopWindow 
	{
		
		public function PopSuccessRanks() 
		{
			super();
			
			obstrusive = mouseEnabled = false;
			_overlay.graphics.clear();
			
			{//-- contents
				var map:MapData = Session.instance.map;
				var saveMngr:SaveDataMngr = SaveDataMngr.instance;
				var xmlSave:XML = saveMngr.getLevelData( map.name, map.hash );
				var username:String = SaveDataMngr.instance.getCustom('highscore_name');
				
				var sp:Sprite, txf:TextField, k:String, w:int, w2:int, a:Array;
				var score:uint = xmlSave ? uint(xmlSave.@score) : 0;
				var par:int = xmlSave ? int(xmlSave.@par) : 0;
				
				_contents.addChild( sp = PuttBase2.assets.createDisplayObject('screen.ui.ico.trophy') as Sprite );
				sp.x = 455; sp.y = 183;
				var mo:Array = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
				var d:Date = new Date( String(xmlSave.@date) );
				_contents.addChild( UIFactory.createFixedTextField(d.dateUTC +' '+ mo[d.monthUTC] +' '+ d.fullYearUTC, 'successRankDate', 'right', 560, 167) );
				_contents.addChild( UIFactory.createFixedTextField(map.name.replace(/\-/g,' '), 'successRankLvl', 'left', 462, 167) );
				_contents.addChild( UIFactory.createFixedTextField('Ranking', 'successRankHead', 'left', 467, 173) );
				
				
				_contents.addChild( _rankClip = new Sprite );
				_rankClip.name = 'rank container';
				_rankClip.graphics.beginFill( 0xE5E572 );
				_rankClip.x = 448; _rankClip.y = 208;
				_rankClip.scrollRect = new Rectangle( 0, 0, 115, 40 );
				
				var ranks:Object = RankMngr.i.getParsedLevelRank();
				if ( ranks ) { // ranks
					//week
					if ( ranks.week ) {
						_populateContexts( ranks.week, score );
						
					} else {
						_rankClip.addChild( txf = UIFactory.createFixedTextField('#? - '+ MathUtils.toThousands(score) +' - '+ username, 'successRankEntryA', 'none', 2, 0) );
						txf.width = 112; txf.height = 17;
						_rankClip.graphics.drawRect( 0, 3, 115, 12 );
					}
					
					//month
					if ( ranks.month ) {
						_populateContexts( ranks.month, score, 100 );
						
					} else {
						_rankClip.addChild( txf = UIFactory.createFixedTextField('#? - '+ MathUtils.toThousands(score) +' - '+ username, 'successRankEntryA', 'none', 2, 100) );
						txf.width = 112; txf.height = 17;
						_rankClip.graphics.drawRect( 0, 3, 115, 12 );
					}
					
					//all
					if ( ranks.all ) {
						_populateContexts( ranks.all, score, 200 );
						
					} else {
						_rankClip.addChild( txf = UIFactory.createFixedTextField('#? - '+ MathUtils.toThousands(score) +' - '+ username, 'successRankEntryA', 'none', 2, 200) );
						txf.width = 112; txf.height = 17;
						_rankClip.graphics.drawRect( 0, 3, 115, 12 );
					}
				}
				
				
				_contents.graphics.lineStyle( 1.5, 0x4C4C4C, 1 );
				_contents.graphics.moveTo( 416, 253 );
				_contents.graphics.lineTo( 566, 253 );
				
				_contents.addChild( _txfGroup = UIFactory.createTextField((map.sett?'Pro':'Amateur') +': <span class="successRankGroupRank">- - -</span>', 'successRankGroup', 'none', 450, 255) );
				_txfGroup.width = 110; _txfGroup.height = 17;
			}
			
			{//-- tabs
				_contents.addChild( _btnClip = new Sprite );
				_btnClip.name = 'button container';
				_btnClip.mouseEnabled = false;
				_btnClip.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
				_btnClip.addEventListener( MouseEvent.MOUSE_OVER, _movr, false, 0, true );
				_btnClip.addEventListener( MouseEvent.MOUSE_OUT, _mout, false, 0, true );
				
				_btnClip.addChild( _btnWk = PuttBase2.assets.createDisplayObject('screen.ui.btn.tabWeek') as MovieClip );
				_btnClip.addChild( _btnMo = PuttBase2.assets.createDisplayObject('screen.ui.btn.tabMonth') as MovieClip );
				_btnClip.addChild( _btnAll = PuttBase2.assets.createDisplayObject('screen.ui.btn.tabAllTime') as MovieClip );
				
				_btnWk.y = _btnMo.y = _btnAll.y = 195;
				_btnWk.buttonMode = _btnMo.buttonMode = _btnAll.buttonMode = true;
				_btnWk.x = 446; _btnWk.gotoAndStop(4); _btnWk.name = 'weekly';
				_btnMo.x = 481; _btnMo.gotoAndStop(1); _btnMo.name = 'monthly';
				_btnAll.x = 516; _btnAll.gotoAndStop(1); _btnAll.name = 'all time';
				
				_contents.addChild( _tip = new PopBtnTip );
			}
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.windows.popSuccess.highscores') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 9, 1).reverse(), 1, false, _showContents );
				_animator.addSequenceSet( END, MathUtils.intRangeA(1, 9, 1), 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
			}
			
		}
		
		override public function dispose():void 
		{
			_btnClip.removeEventListener( MouseEvent.CLICK, _click );
			_btnClip.removeEventListener( MouseEvent.MOUSE_OVER, _movr );
			_btnClip.removeEventListener( MouseEvent.MOUSE_OUT, _mout );
			
			super.dispose();
		}
		
		
		public function setGroupRank( rank:Object ):void
		{
			_groupRank = rank;
			_swapGroupRank();
		}
		
		
			// -- private --
			
			private var _rankClip:Sprite, _btnClip:Sprite, _txfGroup:TextField, _groupRank:Object
			private var _btnWk:MovieClip, _btnMo:MovieClip, _btnAll:MovieClip, _tip:PopBtnTip
			
			override protected function _showContents():void 
			{
				onShown.dispatch();
				
				_contents.visible = _bgBmp.visible = true;
				_overlay.alpha = 1;
				_clip.filters = [ new GlowFilter(0x191919, 1, 24, 24, 1, 1) ];
			}
			
			
			private function _populateContexts( a:Array, score:uint, offY:uint=0 ):void
			{
				var txf:TextField
				var username:String = SaveDataMngr.instance.getCustom('highscore_name');
				switch( true ) {
					case a.length == 1:
						_rankClip.addChild( txf = UIFactory.createFixedTextField('#'+ a[0] +' - '+ MathUtils.toThousands(score) +' - '+ username, 'successRankEntryA', 'none', 2, 0+offY) );
						txf.width = 112; txf.height = 17;
						_rankClip.graphics.drawRect( 0, 3+offY, 115, 12 );
						break;
						
					case a.length == 3:
						if ( score > a[2] ) {
							_rankClip.addChild( txf = UIFactory.createFixedTextField('#1 - '+ MathUtils.toThousands(score) +' - '+ username, 'successRankEntryA', 'none', 2, 0+offY) );
							txf.width = 112; txf.height = 17;
							_rankClip.graphics.drawRect( 0, 3+offY, 115, 12 );
							
							_rankClip.addChild( txf = UIFactory.createFixedTextField('#2 - '+ MathUtils.toThousands(a[2]) +' - '+ a[1], 'successRankEntry', 'none', 2, 12+offY) );
							txf.width = 112; txf.height = 17;
							
						} else {
							_rankClip.addChild( txf = UIFactory.createFixedTextField('#1 - '+ MathUtils.toThousands(a[2]) +' - '+ a[1], 'successRankEntry', 'none', 2, 0+offY) );
							txf.width = 112; txf.height = 17;
							
							_rankClip.addChild( txf = UIFactory.createFixedTextField('#2 - '+ MathUtils.toThousands(score) +' - '+ username, 'successRankEntryA', 'none', 2, 12+offY) );
							txf.width = 112; txf.height = 17;
							_rankClip.graphics.drawRect( 0, 15+offY, 115, 12 );
						}
						break;
						
					case a.length == 5:
						if ( score > a[2] ) {
							_rankClip.addChild( txf = UIFactory.createFixedTextField('#1 - '+ MathUtils.toThousands(score) +' - '+ username, 'successRankEntryA', 'none', 2, 0+offY) );
							txf.width = 112; txf.height = 17;
							_rankClip.graphics.drawRect( 0, 3+offY, 115, 12 );
							
							_rankClip.addChild( txf = UIFactory.createFixedTextField('#2 - '+ MathUtils.toThousands(a[2]) +' - '+ a[1], 'successRankEntry', 'none', 2, 12+offY) );
							txf.width = 112; txf.height = 17;
							_rankClip.addChild( txf = UIFactory.createFixedTextField('#3 - '+ MathUtils.toThousands(a[4]) +' - '+ a[3], 'successRankEntry', 'none', 2, 24+offY) );
							txf.width = 112; txf.height = 17;
							
						} else if ( score > a[4] ) {
							_rankClip.addChild( txf = UIFactory.createFixedTextField('#1 - '+ MathUtils.toThousands(a[2]) +' - '+ a[1], 'successRankEntry', 'none', 2, 0+offY) );
							txf.width = 112; txf.height = 17;
							
							_rankClip.addChild( txf = UIFactory.createFixedTextField('#2 - '+ MathUtils.toThousands(score) +' - '+ username, 'successRankEntryA', 'none', 2, 12+offY) );
							txf.width = 112; txf.height = 17;
							_rankClip.graphics.drawRect( 0, 15+offY, 115, 12 );
							
							_rankClip.addChild( txf = UIFactory.createFixedTextField('#3 - '+ MathUtils.toThousands(a[4]) +' - '+ a[3], 'successRankEntry', 'none', 2, 24+offY) );
							txf.width = 112; txf.height = 17;
							
						} else {
							_rankClip.addChild( txf = UIFactory.createFixedTextField('#1 - '+ MathUtils.toThousands(a[2]) +' - '+ a[1], 'successRankEntry', 'none', 2, 0+offY) );
							txf.width = 112; txf.height = 17;
							_rankClip.addChild( txf = UIFactory.createFixedTextField('#2 - '+ MathUtils.toThousands(a[4]) +' - '+ a[3], 'successRankEntry', 'none', 2, 12+offY) );
							txf.width = 112; txf.height = 17;
							
							_rankClip.addChild( txf = UIFactory.createFixedTextField('#'+ a[0] +' - '+ MathUtils.toThousands(score) +' - '+ username, 'successRankEntryA', 'none', 2, 24+offY) );
							txf.width = 112; txf.height = 17;
							_rankClip.graphics.drawRect( 0, 27+offY, 115, 12 );
						}
						break;
				}
			}
			
			private function _swapGroupRank():void
			{
				if ( !_groupRank ) return;
				
				var map:MapData = Session.instance.map;
				switch( true ) {
					case _btnWk.currentFrame == 4:
						_txfGroup.htmlText = '<p class="successRankGroup">'+ (map.sett?'Pro':'Amateur') +': <span class="successRankGroupRank">'+ (_groupRank.week? MathUtils.toThousands(_groupRank.week)+MathUtils.rankSuffix(_groupRank.week) : '- - -') +'</span></p>';
						break;
					case _btnMo.currentFrame == 4:
						_txfGroup.htmlText = '<p class="successRankGroup">'+ (map.sett?'Pro':'Amateur') +': <span class="successRankGroupRank">'+ (_groupRank.month? MathUtils.toThousands(_groupRank.month)+MathUtils.rankSuffix(_groupRank.month) : '- - -') +'</span></p>';
						break;
					case _btnAll.currentFrame == 4:
						_txfGroup.htmlText = '<p class="successRankGroup">'+ (map.sett?'Pro':'Amateur') +': <span class="successRankGroupRank">'+ (_groupRank.all? MathUtils.toThousands(_groupRank.all)+MathUtils.rankSuffix(_groupRank.all) : '- - -') +'</span></p>';
						break;
				}
			}
			
			
			private function _click( e:MouseEvent ):void
			{
				_btnWk.gotoAndStop( 1 );
				_btnMo.gotoAndStop( 1 );
				_btnAll.gotoAndStop( 1 );
				
				var rect:Rectangle = _rankClip.scrollRect;
				switch( e.target ) {
					case _btnWk:
						_btnWk.gotoAndStop( 4 );
						rect.y = 0;
						_rankClip.scrollRect = rect;
						_swapGroupRank();
						break;
					case _btnMo:
						_btnMo.gotoAndStop( 4 );
						rect.y = 100;
						_rankClip.scrollRect = rect;
						_swapGroupRank();
						break;
					case _btnAll:
						_btnAll.gotoAndStop( 4 );
						rect.y = 200;
						_rankClip.scrollRect = rect;
						_swapGroupRank();
						break;
				}
			}
			
			private function _movr( e:MouseEvent ):void
			{
				switch( e.target ) {
					case _btnWk:
					case _btnMo:
					case _btnAll:
						var mc:MovieClip = MovieClip(e.target);
						if ( mc.currentFrame == 1 )
							mc.gotoAndStop( 3 );
						_tip.pop( mc.name, mc.x+18, mc.y );
						break;
				}
			}
			
			private function _mout( e:MouseEvent ):void
			{
				switch( e.target ) {
					case _btnWk:
					case _btnMo:
					case _btnAll:
						var mc:MovieClip = MovieClip(e.target);
						if ( mc.currentFrame == 3 )
							mc.gotoAndStop( 1 );
						_tip.hide();
						break;
				}
			}
			
			
			
	}

}