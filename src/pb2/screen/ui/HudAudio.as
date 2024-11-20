package pb2.screen.ui 
{
	import com.greensock.easing.Quad;
	import com.jaycsantos.IDisposable;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.sound.FadeSoundEffect;
	import com.jaycsantos.sound.GameSounds;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import pb2.game.ctrl.SaveDataMngr;
	import pb2.game.Session;
	import pb2.game.Tracker;
	import pb2.GameAudio;
	
	/**
	 * ...
	 * @author ...
	 */
	public class HudAudio extends Sprite implements IDisposable
	{
		public var mute:MovieClip, music:MovieClip
		
		public function HudAudio() 
		{
			mouseEnabled = tabChildren = tabEnabled = false;
			
			addChild( music = PuttBase2.assets.createDisplayObject('screen.ui.hud.btnMuteMusic') as MovieClip );
			addChild( mute = PuttBase2.assets.createDisplayObject('screen.ui.hud.btnMute') as MovieClip );
			
			music.stop(); mute.stop();
			music.x = 600; music.y = 15;
			music.buttonMode = mute.buttonMode = true;
			mute.x = 625; mute.y = 15;
			
			addEventListener( MouseEvent.MOUSE_OVER, _ovr, false, 0, true );
			addEventListener( MouseEvent.MOUSE_OUT, _out, false, 0, true );
			addEventListener( MouseEvent.CLICK, _click, false, 0, true );
			
			var save:SaveDataMngr = SaveDataMngr.instance;
			if ( int(save.getCustom('music')) == 0 ) {
				music.gotoAndStop( 2 );
				GameSounds.mute( GameSounds.MUSIC_GROUP );
			}
			if ( int(save.getCustom('sounds')) == 0 ) {
				mute.gotoAndStop( 2 );
				GameSounds.mute( GameSounds.SFX_GROUP );
			}
		}
		
		public function dispose():void
		{
			removeEventListener( MouseEvent.MOUSE_OVER, _ovr );
			removeEventListener( MouseEvent.MOUSE_OUT, _out );
			removeEventListener( MouseEvent.CLICK, _click );
			
			if ( music.parent ) removeChild( music );
			if ( mute.parent ) removeChild( mute );
			music = mute = null;
		}
		
		
			// -- private --
			
			private function _click( e:MouseEvent ):void
			{
				var save:SaveDataMngr = SaveDataMngr.instance;
				if ( e.target == music ) {
					music.gotoAndStop( music.currentFrame==1? 2: 1 );
					save.saveCustom( 'music', music.currentFrame %2 );
					if ( music.currentFrame % 2 ) {
						Tracker.i.buttonClick( 'unMuteMusic' );
						GameSounds.unMute( GameSounds.MUSIC_GROUP );
						
						if ( Session.isOnMenu )
							GameAudio.instance.playMenuMusic();
						else if ( Session.isOnPlay )
							GameAudio.instance.playGameMusic();
						else if ( Session.isOnEditor )
							GameAudio.instance.playAmbience();
						
					} else {
						Tracker.i.buttonClick( 'muteMusic' );
						GameSounds.mute( GameSounds.MUSIC_GROUP );
					}
					
				} else {
					mute.gotoAndStop( mute.currentFrame==1? 2: 1 );
					save.saveCustom( 'sounds', mute.currentFrame %2 );
					
					if ( mute.currentFrame %2 ) {
						Tracker.i.buttonClick( 'unMuteSfx' );
						GameSounds.unMute( GameSounds.SFX_GROUP );
					} else {
						Tracker.i.buttonClick( 'muteSfx' );
						GameSounds.mute( GameSounds.SFX_GROUP );
					}
				}
				
			}
			
			private function _ovr( e:MouseEvent ):void
			{
				MovieClip( e.target ).scaleX = MovieClip( e.target ).scaleY = 1.2;
			}
			
			private function _out( e:MouseEvent ):void
			{
				MovieClip( e.target ).scaleX = MovieClip( e.target ).scaleY = 1;
			}
			
			
			
	}

}