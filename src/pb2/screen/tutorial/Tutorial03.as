package pb2.screen.tutorial 
{
	import com.jaycsantos.display.animation.AnimationTiming;
	import com.jaycsantos.math.MathUtils;
	import flash.display.MovieClip;
	import pb2.game.Session;
	import pb2.screen.ui.HudGame;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Tutorial03 extends ATutorial 
	{
		
		public function Tutorial03() 
		{
			mouseEnabled = mouseChildren = false;
			
			addChild( _clipTip1 = PuttBase2.assets.createDisplayObject('screen.tutorial.06Accuracy') as MovieClip );
			_clipTip1.gotoAndStop( 1 );
			_clipTip1.visible = _clipTip1.mouseEnabled = _clipTip1.mouseChildren = false;
			addChild( _clipTip2 = PuttBase2.assets.createDisplayObject('screen.tutorial.07Accuracy2') as MovieClip );
			_clipTip2.gotoAndStop( 1 );
			_clipTip2.visible = _clipTip2.mouseEnabled = _clipTip2.mouseChildren = false;
			addChild( _clipTip3 = PuttBase2.assets.createDisplayObject('screen.tutorial.05Extra2') as MovieClip );
			_clipTip3.gotoAndStop( 1 );
			_clipTip3.visible = _clipTip3.mouseEnabled = _clipTip3.mouseChildren = false;
			
			_animator = new AnimationTiming( MathUtils.intRangeA(1, 10, 1), 1, 1 );
			_animator.addSequenceSet( 'hide', MathUtils.intRangeA(10, 20, 1), 1, false, _hideTip2 );
			
			_animator2 = new AnimationTiming( MathUtils.intRangeA(1, 10, 1), 1, 1 );
			_animator2.addSequenceSet( 'hide', MathUtils.intRangeA(10, 20, 1), 1, false, _hideTip3 );
			
			HudGame.instance.onBallRelease.addOnce( _showTip1 );
			Session.instance.onPutt.addOnce( _hideTip );
			Session.instance.onPutt.addOnce( _showTip3 );
		}
		
		override public function dispose():void 
		{
			_clipTip1 = _clipTip2 = null;
			_animator.dispose(); _animator = null;
			super.dispose();
		}
		
		
		override public function update():void 
		{
			if ( _animator.isPlaying )
				_animator.update();
			
			if ( _animator2.isPlaying )
				_animator2.update();
		}
		
		
		override public function hide():void 
		{
			_animator2.playSet( 'hide' );
		}
		
			// -- private --
			
			private var _clipTip1:MovieClip, _clipTip2:MovieClip, _clipTip3:MovieClip
			private var _animator:AnimationTiming, _animator2:AnimationTiming;
			
			
			private function _showTip1():void
			{
				_animator.playSet();
				_animator.addMovieClip( _clipTip1 );
				_clipTip1.visible = true;
				
				HudGame.instance.onBallRelease.addOnce( _showTip2 );
			}
			
			private function _showTip2():void
			{
				_animator.removeMovieClip( _clipTip1 );
				_animator.playSet();
				_animator.addMovieClip( _clipTip2 );
				_clipTip2.visible = true;
			}
			
			private function _showTip3():void
			{
				_animator2.playSet();
				_animator2.addMovieClip( _clipTip3 );
				_clipTip3.visible = true;
			}
			
			private function _hideTip():void
			{
				_animator.playSet('hide');
				_animator.addMovieClip( _clipTip1 );
				_animator.addMovieClip( _clipTip2 );
			}
			private function _hideTip2():void
			{
				_animator.removeMovieClip( _clipTip1 );
				_animator.removeMovieClip( _clipTip2 );
				_clipTip1.visible = false;
				_clipTip2.visible = false;
			}
			
			private function _hideTip3():void
			{
				_animator2.stop();
				_animator2.removeMovieClip( _clipTip3 );
				_clipTip3.visible = false;
			}
			
	}

}