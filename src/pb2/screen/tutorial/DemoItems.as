package pb2.screen.tutorial 
{
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.math.Trigo;
	import flash.display.*;
	import pb2.game.Session;
	import pb2.screen.window.PopWindow;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class DemoItems extends PopWindow 
	{
		
		public function DemoItems() 
		{
			super();
			
			obstrusive = mouseEnabled = mouseChildren = false;
			_overlay.graphics.clear();
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.tutorial.demoItems') as MovieClip );
				_clip.gotoAndStop( 1 );
				_mouse = _clip.getChildByName( '_clipMouse' ) as MovieClip;
				_showMouseNormal();
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 400, 1), 2, true );
				_animator.addSequenceSet( END, [401], 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
				
				_animator.addIndexScript( 0, _showMouseNormal, PLAY );
				_animator.addIndexScript( 23, _showMousePointer, PLAY );
				_animator.addIndexScript( 29, _showMouseClick, PLAY );
				_animator.addIndexScript( 106, _showMousePointer, PLAY );
				_animator.addIndexScript( 135, _showMouseClick, PLAY );
				_animator.addIndexScript( 140, _showMousePointer, PLAY );
				_animator.addIndexScript( 154, _showMouseClick, PLAY );
				_animator.addIndexScript( 159, _showMousePointer, PLAY );
				_animator.addIndexScript( 186, _showMouseClick, PLAY );
				_animator.addIndexScript( 192, _showMousePointer, PLAY );
				_animator.addIndexScript( 254, _showMouseClick, PLAY );
				_animator.addIndexScript( 292, _showMousePointer, PLAY );
				_animator.addIndexScript( 311, _showMouseNormal, PLAY );
				_animator.addIndexScript( 348, _showMousePointer, PLAY );
				_animator.addIndexScript( 361, _showMouseClick, PLAY );
				_animator.addIndexScript( 364, _showMouseNormal, PLAY );
			}
			
		}
		
		override public function dispose():void 
		{
			_mouse = null;
			super.dispose();
		}
		
		
		override public function show():void 
		{
			super.show();
			
			Session.instance.onPutt.addOnce( hide );
		}
		
		
			// -- private --
			
			private var _mouse:MovieClip
			
			// -- private --
			
			override protected function _showContents():void 
			{
				onShown.dispatch();
				
				_contents.visible = _bgBmp.visible = true;
				_overlay.alpha = 1;
			}
			
			
			private function _showMouseNormal():void
			{
				_mouse.gotoAndStop( 5 );
			}
			
			private function _showMousePointer():void
			{
				_mouse.gotoAndStop( 6 );
			}
			
			private function _showMouseClick():void
			{
				_mouse.gotoAndStop( 7 );
			}
			
			
	}

}