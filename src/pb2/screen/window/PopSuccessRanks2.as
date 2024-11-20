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
	public class PopSuccessRanks2 extends PopWindow 
	{
		
		public function PopSuccessRanks2() 
		{
			super();
			
			obstrusive = mouseEnabled = mouseChildren = false;
			_overlay.graphics.clear();
			
			{//-- contents
				var map:MapData = Session.instance.map;
				var saveMngr:SaveDataMngr = SaveDataMngr.instance;
				var xmlSave:XML = saveMngr.getPlayerLevelData( map.name, map.customLevel.id );
				var username:String = SaveDataMngr.instance.getCustom('highscore_name');
				
				var sp:Sprite, txf:TextField, k:String, w:int, w2:int, a:Array;
				var score:uint = xmlSave ? uint(xmlSave.@score) : 0;
				var par:int = xmlSave ? int(xmlSave.@par) : 0;
				
				_contents.addChild( sp = PuttBase2.assets.createDisplayObject('screen.ui.ico.trophy') as Sprite );
				sp.x = 455; sp.y = 223;
				/*var mo:Array = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
				var d:Date = new Date( String(xmlSave.@date) );
				_contents.addChild( UIFactory.createFixedTextField(d.dateUTC +' '+ mo[d.monthUTC] +' '+ d.fullYearUTC, 'successRankDate', 'right', 560, 167) );/**/
				_contents.addChild( UIFactory.createFixedTextField('Pub Course', 'successRankLvl', 'left', 462, 207) );
				_contents.addChild( UIFactory.createFixedTextField('Ranking', 'successRankHead', 'left', 467, 213) );
				
				
				_contents.addChild( _rankClip = new Sprite );
				_rankClip.name = 'rank container';
				_rankClip.graphics.beginFill( 0xE5E572 );
				_rankClip.x = 448; _rankClip.y = 233;
				
				var ranks:Array;
				if ( xmlSave.child('rank_all').length ) {
					ranks = [ int(xmlSave.rank_all[0].@r) ];
					
					if ( int(xmlSave.rank_all[0].lead[0].@score) )
						ranks.push( String(xmlSave.rank_all[0].lead[0]), int(xmlSave.rank_all[0].lead[0].@score) );
					if ( int(xmlSave.rank_all[0].lead[1].@score) )
						ranks.push( String(xmlSave.rank_all[0].lead[1]), int(xmlSave.rank_all[0].lead[1].@score) );
				}
				
				// all time rank
				if ( ranks ) {
					_populateContexts( ranks, score, 0 );
					
				} else {
					_rankClip.addChild( txf = UIFactory.createFixedTextField('#? - '+ MathUtils.toThousands(score) +' - '+ username, 'successRankEntryA', 'none', 2, 0) );
					txf.width = 112; txf.height = 17;
					_rankClip.graphics.drawRect( 0, 3, 115, 12 );
				}
				
			}
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.windows.popSuccess.highscores2') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 9, 1).reverse(), 1, false, _showContents );
				_animator.addSequenceSet( END, MathUtils.intRangeA(1, 9, 1), 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
			}
			
			
		}
		
			// -- private --
			
			private var _rankClip:Sprite
			
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
			
			
	}

}