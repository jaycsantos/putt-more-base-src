package pb2.screen.window 
{
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.util.UserInput;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.Timer;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.ctrl.CameraFocusCtrl;
	import pb2.game.ctrl.SaveDataMngr;
	import pb2.game.MapData;
	import pb2.game.Session;
	import pb2.screen.ui.UIFactory;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PopIntro extends PopWindow 
	{
		
		public function PopIntro() 
		{
			super();
			
			mouseChildren = false;
			obstrusive = mouseEnabled = true;
			
			{//-- contents
				var txf:TextField, map:MapData = Session.instance.map;
				_contents.addChild( txf = UIFactory.createFixedTextField(map.name.replace(/\-/g,' '), 'introHead', 'none', 210, 175) );
				txf.width = 230; txf.height = 23;
				_contents.addChild( UIFactory.createTextField('<span class="introPar">Par '+map.par +'</span><br/>\n<span class="introTxt">Try to putt within '+ map.par +' strokes or less</span>', '', 'center', 325, 185) );
			}
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.windows.popIntro') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 22, 1).reverse(), 1, false, onShown.dispatch );
				_animator.addSequenceSet( END, MathUtils.intRangeA(1, 22, 1), 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
				_animator.addIndexScript( 11, _showContents, PLAY );
				_animator.addIndexScript( 11, _hideContents, END );
			}
			
			_timer = new Timer( int(SaveDataMngr.instance.getCustom('g0')) ? 1500 : 3000, 1 );
			_timer.addEventListener( TimerEvent.TIMER_COMPLETE, _hideAnimation );
			onShown.addOnce( _timer.start );
		}
		
		override public function dispose():void 
		{
			_timer.removeEventListener( TimerEvent.TIMER_COMPLETE, _hideAnimation );
			_timer = null;
			
			super.dispose();
		}
		
		
		override public function show():void 
		{
			super.show();
			Session.world.camera.maxSpeed = 4;
			CameraFocusCtrl.followBall( BallCtrl.instance.getPrimary() );
			onHidden.addOnce( CameraFocusCtrl.followMouse );
		}
		
		override public function hide():void 
		{
			if ( !visible ) return;
			
			onPreHide.dispatch();
			_animator.playSet( END );
			Session.world.camera.maxSpeed = 10;
		}
		
			// -- private --
			
			private var _timer:Timer
			
			override protected function _showContents():void 
			{
				_contents.visible = _bgBmp.visible = true;
				_overlay.alpha = 1;
				_clip.filters = [ new GlowFilter(0x191919, 1, 48, 48, 2) ];
			}
			
			private function _hideContents():void
			{
				_contents.visible = _bgBmp.visible = false;
				_clip.filters = [];
			}
			
			
			private function _hideAnimation( e:Event ):void
			{
				hide();
			}
			
			
	}

}