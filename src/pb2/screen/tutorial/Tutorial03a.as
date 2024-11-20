package pb2.screen.tutorial 
{
	import com.jaycsantos.display.animation.AnimationTiming;
	import flash.display.MovieClip;
	import pb2.game.Session;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Tutorial03a extends ATutorial 
	{
		
		public function Tutorial03a() 
		{
			mouseEnabled = mouseChildren = false;
			
			addChild( _tip2 = PuttBase2.assets.createDisplayObject('screen.tutorial.04Par') as MovieClip );
			_tip2.stop(); _tip2.visible = false;
			
			_animator2 = new AnimationTiming( MathUtils.intRangeA(1, 11, 1), 1, 1 );
			_animator2.addSequenceSet( 'hide', MathUtils.intRangeA(11, 21, 1), 1, false, _hideTip2 );
			_animator2.addMovieClip( _tip2 );
		}
		
		override public function dispose():void 
		{
			_animator2.dispose(); _animator2 = null;
			_tip2 = null;
			super.dispose();
		}
		
		
		override public function update():void 
		{
			if ( _animator2.isPlaying )
				_animator2.update();
		}
		
		
		override public function show():void 
		{
			Session.instance.onPutt.addOnce( _showTip2 );
		}
		
		override public function hide():void 
		{
			if ( _tip2.visible )
				_animator2.playSet( 'hide' );
		}
		
			// -- private --
			private var _tip2:MovieClip, _animator2:AnimationTiming
			
			
			private function _showTip2():void
			{
				_tip2.visible = true;
				_animator2.playSet();
			}
			
			private function _hideTip2():void
			{
				_tip2.visible = false;
			}
			
		
	}

}