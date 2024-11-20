package pb2.screen.tutorial 
{
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.sound.GameSounds;
	import flash.display.*;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import pb2.game.ctrl.SaveDataMngr;
	import pb2.GameAudio;
	import pb2.screen.ui.UIFactory;
	import pb2.screen.window.PopWindow;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PopInfoAwesome extends PopWindow 
	{
		
		public function PopInfoAwesome() 
		{
			super();
			
			obstrusive = mouseEnabled = mouseChildren = false;
			
			_overlay.graphics.clear();
			_overlay.graphics.beginFill( 0, .5 );
			_overlay.graphics.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			_overlay.graphics.endFill();
			
			{//-- contents
				var txf:TextField;
				_contents.addChild( UIFactory.createFixedTextField('Awesomeness', 'tutHead', 'left', 260, 155) );
				_contents.addChild( txf = UIFactory.createFixedTextField('Interacting and using different blocks adds to awesomeness score.', 'tutText', 'none', 260, 175) );
				txf.wordWrap = true; txf.width = 130; txf.height = 45;
			}
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.tutorial.popInfoAwesome') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 8, 1).reverse(), 1, false, _showContents );
				_animator.addSequenceSet( END, MathUtils.intRangeA(1, 8, 1), 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
			}
			
		}
		
		override public function show():void 
		{
			super.show();
			GameSounds.play( GameAudio['POP'+ MathUtils.randomInt(1,3)] );
			
			SaveDataMngr.instance.saveCustom( 'tutflag', 128 | uint(SaveDataMngr.instance.getCustom('tutflag')), true );
		}
		
		
			// -- private --
			
			override protected function _showContents():void 
			{
				onShown.dispatch();
				
				_contents.visible = _bgBmp.visible = true;
				_overlay.alpha = 1;
				_clip.filters = [ new GlowFilter(0x191919, 1, 12, 12, 1.5) ];
			}
		
	}

}