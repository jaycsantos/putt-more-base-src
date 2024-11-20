package pb2.screen.window 
{
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.math.MathUtils;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import pb2.game.ctrl.SaveDataMngr;
	import pb2.game.Registry;
	import pb2.screen.ui.SmallBtn1;
	import pb2.screen.ui.UIFactory;
	import Playtomic.*;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PopNewTotal extends PopWindow 
	{
		
		public function PopNewTotal() 
		{
			super();
			
			var g:Graphics, mc:MovieClip, sp:Sprite, sp2:Sprite, shp:Shape, txf:TextField, i:int, j:int, k:String, a:Array;
			var xml:XML = SaveDataMngr.instance.getTotalData();
			
			_overlay.graphics.clear();
			
			{//-- contents
				k = '<p class="newTotalHeader">NEW <b>TOTAL</b></p>\n';
				k += '<p class="newTotalScore">'+ MathUtils.toThousands(xml.@score) +'</p>\n';
				_contents.addChild( _txf = UIFactory.createTextField(k, '', 'none' ) );
				_txf.width = 140; _txf.height = 80;
				
				_contents.addChild( _btnSubmit = new SmallBtn1('SUBMIT') );
				_btnSubmit.x = 35; _btnSubmit.y = 58;
				
				_contents.addChild( _clipLoading = PuttBase2.assets.createDisplayObject('screen.ui.ico.iconLoading') as MovieClip );
				_clipLoading.stop(); _clipLoading.visible = false;
				_clipLoading.x = 70; _clipLoading.y = 65;
			}
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.windows.popNewTotal') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 7, 1), 1, false, _showContents );
				_animator.addSequenceSet( END, MathUtils.intRangeA(7, 14, 1), 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
			}
			
			_btnSubmit.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
		}
		
		override public function dispose():void 
		{
			_btnSubmit.removeEventListener( MouseEvent.CLICK, _click );
			_btnSubmit.dispose();
			_btnSubmit = null;
			
			super.dispose();
		}
		
		
		override public function update():void 
		{
			if ( _btnSubmit ) _btnSubmit.update();
			super.update();
		}
		
		
			// -- private --
			
			private var _btnSubmit:SmallBtn1, _clipLoading:MovieClip, _txf:TextField
			
			
			override protected function _init(e:Event):void 
			{
				_contents.x = 260; _contents.y = 300;
				super._init(e);
			}
			
			
			private function _click( e:MouseEvent ):void
			{
				if ( !SaveDataMngr.instance.getCustom('highscore_name') ) {
					var win:Window = new GetNameWindow;
					addChild( win );
					win.onHidden.addOnce( _submitHighscore );
					win.show();
				} else
					_submitHighscore();
			}
			
			private function _submitHighscore():void
			{
				var data:PlayerScore = new PlayerScore( SaveDataMngr.instance.getCustom('highscore_name'), int(SaveDataMngr.instance.getTotalData().@score) );
				
				Leaderboards.SaveAndList( data, Registry.PLAYTOMIC_LEADERBOARDS, _submitted, {global:Registry.PLAYTOMIC_GLOBAL_LEADERBOARD, perpage:1} );
				
				_clipLoading.visible = true;
				_clipLoading.play();
				_btnSubmit.visible = false;
			}
			
			private function _submitted( scores:Array, numscores:int, response:Object ):void
			{
				if ( response.Success && scores.length ) {
					SaveDataMngr.instance.saveCustom( 'pendHighScoreSubmit', '', true );
					
					var data:PlayerScore, total:int = int(SaveDataMngr.instance.getTotalData().@score);
					for each( data in scores )
						if ( data.Name == SaveDataMngr.instance.getCustom('highscore_name') && data.Points == total )
							break;
					
					var k:String = '<p class="newTotalHeader">TOTAL <b>SCORE</b></p>\n';
					k += '<p class="newTotalScore">'+ MathUtils.toThousands(total) +'</p>\n';
					k += '<p class="newTotalRank">current rank: <b>'+ MathUtils.toRank(data.Rank+int(Registry.PLAYTOMIC_VARS.HighscoreRankOffset)).toUpperCase() +'</b></p>\n';
					_txf.htmlText = k;
					
				} else {
					_btnSubmit.visible = true;
					
					CONFIG::debug {
						addChild( new PopPrompt('Error Code '+ response.ErrorCode +' returned', 110, [{name:'OK'}]) ); }
					CONFIG::release {
						addChild( new PopPrompt('Server might be busy. Try again later. (Er#'+ response.ErrorCode +')', 110, [{name:'OK'}]) ); }
				}
				
				_clipLoading.visible = false;
				_clipLoading.stop();
			}
			
			
	}

}