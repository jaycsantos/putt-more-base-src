package pb2.screen 
{
	import com.greensock.easing.Quad;
	import com.jaycsantos.display.animation.SimpleAnimationTiming;
	import com.jaycsantos.display.screen.AbstractScreen;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.sound.FadeSoundEffect;
	import com.jaycsantos.sound.GameSoundObj;
	import com.jaycsantos.sound.GameSounds;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import pb2.game.Registry;
	import pb2.GameAudio;
	import Playtomic.Link;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class SplashAndkonScreen extends AbstractScreen 
	{
		
		public function SplashAndkonScreen( root:GameRoot, data:Object=null ) 
		{
			super( root, data );
			
			_canvas.graphics.beginFill( 0, 0 );
			_canvas.graphics.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			_canvas.buttonMode = _canvas.mouseEnabled = true; _canvas.mouseChildren = false;
			_canvas.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
			
			_canvas.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.splash.andkon') as MovieClip );
			_clip.x = PuttBase2.STAGE_WIDTH / 2;
			_clip.y = PuttBase2.STAGE_HEIGHT / 2;
			
			_animator = new SimpleAnimationTiming( MathUtils.intRangeA(0,100,1), 4, false, _frame100, 4 );
			_animator.addMovieClip( _clip );
			_animator.playAt();
			
			Registry.SPONSOR_NAME = 'Andkon Arcade';
			Registry.SPONSOR_URL = 'http://www.andkon.com/arcade/';
			Registry.SPONSOR_URL_PLAIN = 'http://www.andkon.com/arcade/';
			//Registry.SPONSOR_URL_ADDWEB = 'http://www.turbonuke.com/addgame.php?gamereferal=puttmorebase';
			Registry.SPONSOR_GAME_URL = 'http://www.andkon.com/arcade/sport/puttmorebase/';
			Registry.SPONSOR_GAME_URL_LVLID = 'http://www.andkon.com/arcade/sport/puttmorebase/?pb_';
		}
		
		override public function update():void 
		{
			_animator.update();
			super.update();
		}
		
			// -- private --
			
			private var _clip:MovieClip, _animator:SimpleAnimationTiming
			
			
			private function _click( e:MouseEvent ):void
			{
				Link.Open( 'http://www.andkon.com/arcade/', 'andkon', 'splash' );
			}
			
			private function _frame100():void
			{
				if ( _clip ) {
					changeScreen( SplashJaycScreen );
					_clip.stop();
					_animator.dispose();
					_animator = null;
				}
				
			}
			
		
	}

}