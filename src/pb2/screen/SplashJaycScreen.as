package pb2.screen 
{
	import com.greensock.easing.Quad;
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
	public class SplashJaycScreen extends AbstractScreen 
	{
		
		public function SplashJaycScreen( root:GameRoot, data:Object=null ) 
		{
			super( root, data );
			
			if ( !CONFIG::onAndkon )
				GameSounds.play( GameAudio.POP );
			GameAudio.instance.playMenuMusic();
			//FadeSoundEffect.fadeIn( GameAudio.MAIN_MUSIC, Quad.easeIn, 1000, MathUtils.randomInt(0,75)*1000, int.MAX_VALUE );
			
			_canvas.graphics.beginFill( 0, 0 );
			_canvas.graphics.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			CONFIG::allowLinks {
				_canvas.buttonMode = _canvas.mouseEnabled = true; _canvas.mouseChildren = false;
				_canvas.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
			}
			
			_canvas.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.splash.jayc') as MovieClip );
			_clip.play();
			_clip.addFrameScript( 120, _frame120 );
			
			//CONFIG::release {
				_clip.addFrameScript( 60, _frame60 );
			// }
		}
		
			// -- private --
			
			private var _clip:MovieClip
			
			
			private function _click( e:MouseEvent ):void
			{
				Link.Open( 'http://jaycsantos.com/', 'jayc', 'splash' );
			}
			
			private function _frame60():void
			{
				var url:String = _canvas.loaderInfo.url;
				//CONFIG::debug { 
				//url = 'http://www.mousebreaker.com/games/puttmorebase/';// }
				url = url.toLowerCase().split("://")[1].split("/")[0];
				var a:Array, i:int
				
				a = String(CONFIG::siteFilter).toLowerCase().split(',').concat( String(Registry.PLAYTOMIC_VARS.BlackListUrl).toLowerCase().split(',') );
				i = a.length;
				while ( i-- )
					if ( String(a[i]).length && url.indexOf(a[i]) > -1 ) {
						_clip.stop();
						_clip = null;
						return;
						Link.Open( 'http://jaycsantos.com/games/putt-more-base/?play', 'blacklist_'+a[i], 'splash', false, '_parent' );
					}
				
				
				a = String(CONFIG::sitelock).toLowerCase().split(',');
				i = a.length;
				while ( i-- )
					if ( String(a[i]).length && url.indexOf(a[i]) > -1 )
						return;
				
				if ( CONFIG::onAndkon ) {
					_clip.stop();
					_clip = null;
					return;
				}
				
				Registry.useDefaultSponsor = true;
				Registry.SPONSOR_NAME = 'Turbo Nuke'
				Registry.SPONSOR_URL = 'http://www.turbonuke.com/?gamereferal=puttmorebase';
				Registry.SPONSOR_URL_PLAIN = 'http://turbonuke.com';
				Registry.SPONSOR_URL_ADDWEB = 'http://www.turbonuke.com/addgame.php?gamereferal=puttmorebase';
				Registry.SPONSOR_GAME_URL = 'http://www.turbonuke.com/games.php?game=puttmorebase';
				Registry.SPONSOR_GAME_URL_LVLID = 'http://www.turbonuke.com/games.php?game=puttmorebase&pb_';
				if ( !a.length ) return;
				
				/*_clip.stop();
				_clip = null;
				
				Link.Open( 'http://jaycsantos.com/games/putt-more-base/?play', 'forceplay', 'splash', false, '_self' );*/
			}
			
			private function _frame120():void
			{
				if ( _clip ) {
					changeScreen( MenuActScreen );
					_clip.stop();
				}
				
			}
			
		
	}

}