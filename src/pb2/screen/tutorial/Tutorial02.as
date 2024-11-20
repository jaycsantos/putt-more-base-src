package pb2.screen.tutorial 
{
	import com.jaycsantos.display.animation.AnimationTiming;
	import com.jaycsantos.display.animation.SimpleAnimationTiming;
	import com.jaycsantos.math.MathUtils;
	import flash.display.*;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.entity.Ball;
	import pb2.game.Session;
	import pb2.screen.ui.HudGame;
	import pb2.screen.window.Window;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Tutorial02 extends ATutorial 
	{
		
		public function Tutorial02() 
		{
			mouseEnabled = mouseChildren = false;
			
			addChild( _clip = PuttBase2.assets.createDisplayObject('screen.tutorial.02Extras') as MovieClip );
			_clip.gotoAndStop( 411 );
			_clip.visible = _clip.mouseEnabled = _clip.mouseChildren = false;
			_mouse = _clip.getChildByName( '_clipMouse' ) as MovieClip;
			_showMouseNormal();
			
			_animator = new AnimationTiming( MathUtils.intRangeA(400, 411, 1).reverse(), 1, 1, false );
			_animator.addSequenceSet( 'loop', MathUtils.intRangeA(1, 400, 1), 2, true );
			_animator.addSequenceSet( 'end', MathUtils.intRangeA(400, 411, 1), 1, false );
			_animator.addMovieClip( _clip );
			
			_animator.addIndexScript( 0, _showMouseNormal, 'loop' );
			_animator.addIndexScript( 23, _showMousePointer, 'loop' );
			_animator.addIndexScript( 29, _showMouseClick, 'loop' );
			_animator.addIndexScript( 106, _showMousePointer, 'loop' );
			_animator.addIndexScript( 135, _showMouseClick, 'loop' );
			_animator.addIndexScript( 140, _showMousePointer, 'loop' );
			_animator.addIndexScript( 154, _showMouseClick, 'loop' );
			_animator.addIndexScript( 159, _showMousePointer, 'loop' );
			_animator.addIndexScript( 186, _showMouseClick, 'loop' );
			_animator.addIndexScript( 192, _showMousePointer, 'loop' );
			_animator.addIndexScript( 254, _showMouseClick, 'loop' );
			_animator.addIndexScript( 292, _showMousePointer, 'loop' );
			_animator.addIndexScript( 311, _showMouseNormal, 'loop' );
			_animator.addIndexScript( 348, _showMousePointer, 'loop' );
			_animator.addIndexScript( 361, _showMouseClick, 'loop' );
			_animator.addIndexScript( 364, _showMouseNormal, 'loop' );
			
			
			//HudGame.instance.onBallRelease.addOnce( _hideAnimation );
			Session.instance.onPutt.addOnce( _hideAnimation );
		}
		
		override public function dispose():void 
		{
			_animator.dispose(); _animator = null;
			_clip = _mouse = null;
			super.dispose();
		}
		
		
		override public function update():void 
		{
			if ( _animator.isPlaying && !Window.instanceCount() )
				_animator.update();
		}
		
		
		override public function show():void 
		{
			_clip.gotoAndStop( 411 );
			_clip.visible = true;
			_animator.playAt();
			_animator.appendSet( 'loop' );
		}
		
		
		
			// -- private --
			
			private var _clip:MovieClip, _mouse:MovieClip
			private var _animator:AnimationTiming
			
			
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
			
			
			private function _hideAnimation():void
			{
				_animator.playSet( 'end' );
			}
			
			
			
	}

}