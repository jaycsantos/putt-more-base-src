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
	public class PopInfoSpare extends PopWindow 
	{
		
		public function PopInfoSpare() 
		{
			super();
			
			obstrusive = mouseEnabled = mouseChildren = false;
			
			_overlay.graphics.clear();
			_overlay.graphics.beginFill( 0, .5 );
			_overlay.graphics.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			_overlay.graphics.endFill();
			
			{//-- contents
				var txf:TextField;
				_contents.addChild( UIFactory.createFixedTextField('Spare Items', 'tutHead', 'left', 75, 103) );
				_contents.addChild( txf = UIFactory.createFixedTextField('Items not used adds to your score.\n\nItems bumped or moved are counted as used.', 'tutText', 'none', 75, 123) );
				txf.wordWrap = true;  txf.width = 110; txf.height = 85;
			}
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.tutorial.popInfoSpares') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 9, 1).reverse(), 1, false, _showContents );
				_animator.addSequenceSet( END, MathUtils.intRangeA(1, 9, 1), 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
			}
			
		}
		
		
		override public function show():void 
		{
			GameSounds.play( GameAudio['POP'+ MathUtils.randomInt(1,3)] );
			super.show();
			
			SaveDataMngr.instance.saveCustom( 'tutflag', 64 | uint(SaveDataMngr.instance.getCustom('tutflag')), true );
		}
		
		
			// -- private --
			
			override protected function _showContents():void 
			{
				onShown.dispatch();
				
				_contents.visible = _bgBmp.visible = true;
				_overlay.alpha = 1;
				_clip.filters = [ new GlowFilter(0x191919, 1, 4, 4, 1.5) ];
			}
			
			
			
	}

}