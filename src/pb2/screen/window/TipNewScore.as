package pb2.screen.window 
{
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.sound.GameSounds;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import pb2.game.ctrl.SaveDataMngr;
	import pb2.game.Registry;
	import pb2.GameAudio;
	import pb2.screen.ui.UIFactory;
	import Playtomic.*;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class TipNewScore extends TipWindow 
	{
		
		public function TipNewScore( x:uint, y:uint, total:uint )
		{
			var g:Graphics, mc:MovieClip, sp:Sprite, shp:Shape, txf:TextField, i:int, j:int, k:String, a:Array;
			
			super( x, y );
			
			_bg.width = 90; _bg.height = 52;
			
			addChild( _loading = PuttBase2.assets.createDisplayObject('screen.ui.ico.iconLoading') as MovieClip );
			_loading.stop();
			_loading.visible = false;
			_loading.x = 45; _loading.y = 26;
			
			addChild( _puff = PuttBase2.assets.createDisplayObject('screen.ui.ani.puff2') as MovieClip );
			_puff.stop();
			_puff.name = total.toString();
			_puff.addFrameScript( 6, _puffFrame6 );
			_puff.addFrameScript( 29, _puffFrame29 );
			
			_contents.addChild( sp = PuttBase2.assets.createDisplayObject('screen.ui.bg.newHscore') as Sprite );
			sp.x = -142; sp.y = -36;
			_contents.addChild( _text = UIFactory.createTextField('<p class="tipNscore1">NEW TOTAL\nSCORE</p>\n<p class="tipNscore2">'+ MathUtils.toThousands(total) +'</p>\n<p class="tipNscore3">SUBMIT NOW</p>', '', 'center', 42, 0) );
			_contents.visible = _bg.visible = false;
			
			buttonMode = true;
			mouseChildren = false;
			
			addEventListener( MouseEvent.CLICK, _click, false, 0, true );
		}
		
		override public function dispose():void 
		{
			removeEventListener( MouseEvent.CLICK, _click );
		}
		
		
		public function start():void
		{
			_puff.gotoAndPlay( 1 );
			GameSounds.play( GameAudio.POP );
			
			
			CONFIG::onFGL {
				Registry.FGL_TRACKER.customMsg( 'new highscore', int(_puff.name) ); }
		}
		
			// -- private --
			
			private var _puff:MovieClip, _loading:MovieClip, _text:TextField
			
			
			private function _click( e:MouseEvent ):void
			{
				if ( !SaveDataMngr.instance.getCustom('highscore_name') )
					with ( SuccessWindow(parent) ) {
						addChild( window = new GetNameWindow );
						window.onHidden.addOnce( removeWindow );
						window.onHidden.addOnce( _submitHighscore );
						window.show();
					}
				else
					_submitHighscore();
			}
			
			private function _submitHighscore():void
			{
				var data:PlayerScore = new PlayerScore( SaveDataMngr.instance.getCustom('highscore_name'), uint(_puff.name) );
				
				Leaderboards.SaveAndList( data, Registry.PLAYTOMIC_LEADERBOARDS, _submitted, {global:Registry.PLAYTOMIC_GLOBAL_LEADERBOARD, perpage:1} );
				
				_loading.visible = true;
				_loading.play();
				_contents.visible = false;
				
				buttonMode = mouseEnabled = false;
				removeEventListener( MouseEvent.CLICK, _click );
			}
			
			private function _submitted( scores:Array, numscores:int, response:Object ):void
			{
				if ( response.Success && scores.length ) {
					SaveDataMngr.instance.saveCustom( 'pendHighScoreSubmit', '', true );
					
					var data:PlayerScore
					for each( data in scores )
						if ( data.Name == SaveDataMngr.instance.getCustom('highscore_name') && data.Points == uint(_puff.name) )
							break;
					
					_text.htmlText = '<p class="tipNscore1">SUBMITTED</p>\n<p class="tipNscore3">RANK:\n'+ MathUtils.toRank(data.Rank+int(Registry.PLAYTOMIC_VARS.HighscoreRankOffset)).toUpperCase() +'</p>\n<p class="tipNscore2">'+ MathUtils.toThousands(uint(_puff.name)) +'</p>'
					
				} else {
					buttonMode = mouseEnabled = true;
					addEventListener( MouseEvent.CLICK, _click, false, 0, true );
					
					CONFIG::debug {
						parent.addChild( parent['prompt'] = new Pb2Prompt2('Error Code '+ response.ErrorCode +' returned', 140, { name:'OK', call:parent['removePrompt'] } ) ); }
					CONFIG::release {
						parent.addChild( parent['prompt'] = new Pb2Prompt2('Server might be busy. Try again later. (Er#'+ response.ErrorCode +')', 140, { name:'OK', call:parent['removePrompt'] } ) ); }
				}
				
				_loading.visible = false;
				_loading.stop();
				_contents.visible = true;
			}
			
			
			private function _puffFrame6():void
			{
				_contents.visible = _bg.visible = true;
			}
			
			private function _puffFrame29():void
			{
				_puff.stop();
			}
			
			
	}

}