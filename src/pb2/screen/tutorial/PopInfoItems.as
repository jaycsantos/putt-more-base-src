package pb2.screen.tutorial 
{
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.sound.GameSounds;
	import flash.display.*;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import pb2.GameAudio;
	import pb2.screen.ui.UIFactory;
	import pb2.screen.window.PopWindow;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PopInfoItems extends PopWindow 
	{
		
		public function PopInfoItems() 
		{
			super();
			
			obstrusive = mouseEnabled = mouseChildren = false;
			_overlay.graphics.clear();
			
			{//-- contents
				var txf:TextField;
				_contents.addChild( UIFactory.createFixedTextField('Extra Items', 'tutHead', 'left', 60, 100) );
				_contents.addChild( txf = UIFactory.createFixedTextField('Drag & drop onto course to help get less strokes.\n\nDropped item snaps on grid.', 'tutText', 'none', 58, 120) );
				txf.wordWrap = true;  txf.width = 100; txf.height = 83;
			}
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.tutorial.popInfoItems') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 8, 1).reverse(), 1, false, _showContents );
				_animator.addSequenceSet( END, MathUtils.intRangeA(1, 8, 1), 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
			}
			
		}
		
		override public function show():void 
		{
			GameSounds.play( GameAudio['POP'+ MathUtils.randomInt(1,3)] );
			super.show();
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