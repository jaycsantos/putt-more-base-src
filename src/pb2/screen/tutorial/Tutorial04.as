package pb2.screen.tutorial 
{
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Contacts.b2Contact;
	import com.jaycsantos.display.animation.AnimationTiming;
	import com.jaycsantos.math.MathUtils;
	import flash.display.MovieClip;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.Session;
	import pb2.screen.ui.HudGame;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Tutorial04 extends ATutorial 
	{
		
		public function Tutorial04() 
		{
			mouseEnabled = mouseChildren = false;
			
			addChild( _clip = PuttBase2.assets.createDisplayObject('screen.tutorial.08Bounce') as MovieClip );
			_clip.gotoAndStop( 1 );
			_clip.visible = _clip.mouseEnabled = _clip.mouseChildren = false;
			
			_animator = new AnimationTiming( MathUtils.intRangeA(1, 10, 1), 1, 1 );
			_animator.addSequenceSet( 'hide', MathUtils.intRangeA(10, 20, 1), 1, false, _hideTip2 );
		}
		
		override public function dispose():void 
		{
			_clip = null;
			_animator.dispose(); _animator = null;
			super.dispose();
		}
		
		
		override public function update():void 
		{
			if ( _animator.isPlaying )
				_animator.update();
		}
		
		
		override public function show():void 
		{
			BallCtrl.instance.getPrimary().onContact.addOnce( _showTip1 );
			Session.instance.onPutt.addOnce( _hideTip );
		}
		
		
			// -- private --
			
			private var _clip:MovieClip, _animator:AnimationTiming;
			
			private function _showTip1( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture ):void
			{
				if ( contact.IsSensor() ) {
					BallCtrl.instance.getPrimary().onContact.addOnce( _showTip1 );
					return;
				}
				
				_animator.playSet();
				_animator.addMovieClip( _clip );
				_clip.visible = true;
			}
			
			
			private function _hideTip():void
			{
				_animator.playSet('hide');
				_animator.addMovieClip( _clip );
			}
			private function _hideTip2():void
			{
				_animator.removeMovieClip( _clip );
				_clip.visible = false;
			}
			
			
	}

}