package pb2.screen.tutorial 
{
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.sound.GameSounds;
	import flash.display.*;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.ctrl.SaveDataMngr;
	import pb2.game.Session;
	import pb2.GameAudio;
	import pb2.screen.ui.HudGame;
	import pb2.screen.ui.UIFactory;
	import pb2.screen.window.PopWindow;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PopInfoReset extends PopWindow 
	{
		
		public function PopInfoReset() 
		{
			super();
			
			obstrusive = mouseEnabled = mouseChildren = false;
			_overlay.graphics.clear();
			
			{//-- contents
				var txf:TextField;
				_contents.addChild( UIFactory.createFixedTextField('Reset', 'tutHead', 'left', 40, 30) );
				_contents.addChild( txf = UIFactory.createFixedTextField('Miscalculated? Stuck? Or just want to start from scratch?', 'tutText', 'none', 40, 50) );
				txf.wordWrap = true;  txf.width = 85; txf.height = 60;
			}
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.tutorial.popInfoReset') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 9, 1).reverse(), 1, false, _showContents );
				_animator.addSequenceSet( END, MathUtils.intRangeA(1, 9, 1), 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
			}
			
			
			Session.instance.onEntitiesMoveStop.add( _maybeShow );
		}
		
		
		override public function show():void 
		{
			if ( BallCtrl.instance.getPrimary().isOnHole ) return;
			
			GameSounds.play( GameAudio['POP'+ MathUtils.randomInt(1,3)] );
			super.show();
			
			Session.instance.onEntityMoveStart.addOnce( hide );
			if ( HudGame.instance )
				HudGame.instance.onReset.addOnce( hide );
		}
		
			// -- private --
			
			
			private function _maybeShow():void
			{
				var tutFlag:uint = uint(SaveDataMngr.instance.getCustom('tutflag'));
				
				if ( (tutFlag & 4) == 0 ) {
					show();
					SaveDataMngr.instance.saveCustom( 'tutflag', 4 | tutFlag, true );
					Session.instance.onEntitiesMoveStop.remove( _maybeShow );
				} else
				if ( (tutFlag & 16) == 0 && BallCtrl.strokes >= Session.instance.map.par && !BallCtrl.instance.getPrimary().isOnHole ) {
					show();
					SaveDataMngr.instance.saveCustom( 'tutflag', 16 | tutFlag, true );
					Session.instance.onEntitiesMoveStop.remove( _maybeShow );
				}
				
			}
			
			override protected function _showContents():void 
			{
				onShown.dispatch();
				
				_contents.visible = _bgBmp.visible = true;
				_overlay.alpha = 1;
				_clip.filters = [ new GlowFilter(0x191919, 1, 4, 4, 1.5) ];
			}
			
			
			
			
	}

}