package pb2.screen.tutorial 
{
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.sound.GameSounds;
	import flash.display.*;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import pb2.game.ctrl.SaveDataMngr;
	import pb2.GameAudio;
	import pb2.screen.ui.HudGame;
	import pb2.screen.ui.UIFactory;
	import pb2.screen.window.PopWindow;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PopInfoPedia extends PopWindow 
	{
		
		public function PopInfoPedia() 
		{
			super();
			
			obstrusive = mouseEnabled = mouseChildren = false;
			_overlay.graphics.clear();
			
			{//-- contents
				var txf:TextField;
				_contents.addChild( UIFactory.createFixedTextField('Encyclopedia', 'tutHead', 'left', 505, 33) );
				_contents.addChild( txf = UIFactory.createFixedTextField('There will be a lot of different kinds of blocks, tiles and stuff. Keep track of details here.', 'tutText', 'none', 505, 53) );
				txf.wordWrap = true;  txf.width = 110; txf.height = 72;
			}
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.tutorial.popInfoPedia') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 8, 1).reverse(), 1, false, _showContents );
				_animator.addSequenceSet( END, MathUtils.intRangeA(1, 8, 1), 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
			}
			
			
			HudGame.instance.onButtonClick.add( _hideAnimation );
		}
		
		override public function dispose():void 
		{
			HudGame.instance.onButtonClick.remove( _hideAnimation );
			super.dispose();
		}
		
		
		override public function show():void 
		{
			GameSounds.play( GameAudio['POP'+ MathUtils.randomInt(1,3)] );
			super.show();
		}
		
			// -- private --
			
			private function _hideAnimation( val:String ):void
			{
				if ( val == 'pedia' ) {
					HudGame.instance.onButtonClick.remove( _hideAnimation );
					SaveDataMngr.instance.saveCustom( 'tutflag', 32 | uint(SaveDataMngr.instance.getCustom('tutflag')), true );
					hide();
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