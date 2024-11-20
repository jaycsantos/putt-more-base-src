package pb2 
{
	import com.greensock.easing.Quad;
	import com.jaycsantos.AssetFactory;
	import com.jaycsantos.ExternalAssetFactory;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.sound.*;
	import com.jaycsantos.util.GameLoop;
	import com.jaycsantos.util.ns.internalGameloop;
	import flash.display.Stage;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import pb2.game.Session;
	/**
	 * ...
	 * @author ...
	 */
	
	public class GameAudio 
	{
		public static const instance:GameAudio = new GameAudio
		
		CONFIG::release {
			private static const assets:AssetFactory = new AssetFactory; }
		CONFIG::debug {
			private static const assets:AssetFactory = ExternalAssetFactory.instance; }
		
		
		public static const GROUP_TAUNT:uint = 8
		public static const GROUP_AMBIENCE:uint = 16
		public static const GROUP_SFX_LOOPED:uint = 32
		
		public static const
			AMBIENCE_FOREST:String = 'forest',
			MUSIC_HOW_IT_BEGINS:String = 'hib',
			MUSIC_HOW_IT_BEGINS_LOOP:String = 'hib-loop',
			MUSIC_PLAIN_LOAFER:String = 'pl-loop',
			MUSIC_BASS_VIBES:String = 'bv-loop',
			MUSIC_BASS_SOLI:String = 'bs-loop',
			MUSIC_WALKING_ALONG:String = 'wa-loop',
			MUSIC_HAPPY_ALLEY:String = 'ha',
			MUSIC_HAPPY_ALLEY_LOOP:String = 'ha-loop',
			MUSIC_HAPPY_ALLEY_END:String = 'ha-end';
		
		public static const
			POP:String = 'sillyfun2',
			VICTORY_A:String = 'victoryA',
			VICTORY_B:String = 'victoryB';
		
		public static const
			DRIVE1:String = 'drive1',
			DRIVE2:String = 'drive2',
			DRIVE3:String = 'drive3',
			BALL_ROLL:String = 'ballroll',
			BALL_HOLE:String = 'ballhole',
			WALL_TAP1:String = 'walltap1',
			WALL_TAP2:String = 'walltap2',
			WALL_TAP3:String = 'walltap3',
			WOOD_TAP1:String = 'woodtap1',
			WOOD_TAP2:String = 'woodtap2',
			WOOD_TAP3:String = 'woodtap3',
			RUBBER_TAP:String = 'rubbertap',
			JELLY_TAP:String = 'jellytap',
			SPRING_TAP:String = 'springtap',
			SQUISH_TAP:String = 'squishtap',
			FLICK:String = 'flick',
			CONVEYOR:String = 'conveyor',
			FLOORWIND:String = 'floorwind',
			GLASSBREAK:String = 'glassbreak',
			GLASSTAP:String = 'glasstap',
			WARP:String = 'warp',
			GATE:String = 'gate',
			KISS:String = 'kiss',
			BEEP1:String = 'beep1',
			BOMB:String = 'bomb',
			SPIN:String = 'spin',
			PICTURE:String = 'picture',
			BUZZ:String = 'buzz',
			POP1:String = 'pop1',
			POP2:String = 'pop2',
			POP3:String = 'pop1',
			POP4:String = 'pop3';
		
		public var lastGameMusic:String
		
		
		public function GameAudio() 
		{
			if ( instance ) throw new Error('[pb2.GameAudio] Singleton class, use static property instance');
		}
		
		public function init( onInit:Function=null ):void
		{
			_onInit = onInit;
			_playPoints = new Dictionary;
			
			CONFIG::release {
				assets.activate( Cargo, _init );
			}
			CONFIG::debug {
				_init();
			}
			
			GameLoop.instance.internalGameloop::addCallback( _update );
		}
		
		
		public function playMenuMusic():void
		{
			if ( !GameSounds.instance.isPlaying(MUSIC_HOW_IT_BEGINS) && !GameSounds.instance.isPlaying(MUSIC_HOW_IT_BEGINS_LOOP) ) {
				/*lastGameMusic = MUSIC_HOW_IT_BEGINS;
				FadeSoundEffect.fadeIn( MUSIC_HOW_IT_BEGINS, Quad.easeIn, 4000, 6000, 0, function(snd:GameSoundObj):void {
					if ( Session.isOnMenu && GameRoot.screen.isReady ) {
						lastGameMusic = MUSIC_HOW_IT_BEGINS_LOOP;
						GameSounds.play(MUSIC_HOW_IT_BEGINS_LOOP, 0, int.MAX_VALUE);
					}
				} );*/
				lastGameMusic = MUSIC_HOW_IT_BEGINS_LOOP;
				FadeSoundEffect.fadeIn( MUSIC_HOW_IT_BEGINS_LOOP, Quad.easeIn, Session.isOnMenu?2000:5000, 0, int.MAX_VALUE );
			}
			
		}
		
		public function playGameMusic( name:String=null ):void
		{
			stopMusic();
			
			if ( !name ) {
				var i:int, k:String, total:Number=0, n:Number=0, random:Number = Math.random();
				
				var min:int = int.MAX_VALUE;
				for each ( i in _playPoints ) min = Math.min( i-1, min );
				if ( min > 50 )
					for ( k in _playPoints ) _playPoints[k] -= min;
				
				for each ( i in _playPoints )
					total += 1/i;
				
				for ( k in _playPoints ) {
					n += 1 /_playPoints[k] /total;
					if ( random < n ) {
						name = k;
						break;
					}
				}
				if ( random < 1/_playPoints[MUSIC_PLAIN_LOAFER]/total )
					name = MUSIC_PLAIN_LOAFER;
			}
			
			lastGameMusic = name;
			FadeSoundEffect.fadeIn( name, Quad.easeIn, 4000, 0, 3 );
			FadeSoundEffect.fadeOutAtEnd( name, Quad.easeOut, 4000, _prepNext );
			GameSounds.instance.getSoundObj( name ).onEnd.addOnce( _prepNext );
			if ( _playPoints[name] != undefined )
				_playPoints[name] = uint(_playPoints[name] +5);
			playAmbience( 2500 );
		}
		
		public function stopMusic( fadeLength:uint=0 ):void
		{
			if ( fadeLength )
				FadeSoundEffect.fadeOut( lastGameMusic, Quad.easeOut, fadeLength );
			else
				GameSounds.stop( lastGameMusic );
		}
		
		
		public function playVictoryMusic( win:Boolean=false ):void
		{
			GameSounds.play( win? VICTORY_A : VICTORY_B );
			
			/*GameSounds.play( MUSIC_HAPPY_ALLEY, 0, 0, 1, function(snd:GameSoundObj):void { 
				GameSounds.play(MUSIC_HAPPY_ALLEY_LOOP, 0, int.MAX_VALUE);
				//GameSounds.play( MUSIC_HAPPY_ALLEY_END );
			} );*/
		}
		
		public function stopVictoryMusic():void
		{
			FadeSoundEffect.fadeOut( VICTORY_A, Quad.easeOut, 800 );
			FadeSoundEffect.fadeOut( VICTORY_B, Quad.easeOut, 800 );
			//FadeSoundEffect.fadeOut( MUSIC_HAPPY_ALLEY, Quad.easeOut, 800 );
			//FadeSoundEffect.fadeOut( MUSIC_HAPPY_ALLEY_LOOP, Quad.easeOut, 800 );
		}
		
		
		public function playAmbience( fadeLength:uint=0 ):void
		{
			if ( GameSounds.instance.isPlaying(AMBIENCE_FOREST) )
				stopAmbience();
			
			if ( fadeLength )
				FadeSoundEffect.fadeIn( AMBIENCE_FOREST, Quad.easeIn, fadeLength, 0, int.MAX_VALUE );
			else
				GameSounds.play( AMBIENCE_FOREST, 0, int.MAX_VALUE );
		}
		
		public function stopAmbience( fadeLength:uint=0 ):void
		{
			if ( fadeLength )
				FadeSoundEffect.fadeOut( AMBIENCE_FOREST, Quad.easeOut, fadeLength );
			else
				GameSounds.stop( AMBIENCE_FOREST );
		}
		
		
		public function resetPlayPoints():void
		{
			_playPoints[ MUSIC_PLAIN_LOAFER ] = 1;
			_playPoints[ MUSIC_BASS_VIBES ] = 1;
			_playPoints[ MUSIC_BASS_SOLI ] = 1;
			_playPoints[ MUSIC_WALKING_ALONG ] = 1;
		}
		
		
		
			// -- private --
			
			CONFIG::release
			{
				//[Embed(source="/../../lib/pb2.audio.swf", mimeType="application/octet-stream")]
				[Embed(source="../../lib/pb2.audio.swf", mimeType="application/octet-stream")]
				private static const Cargo:Class;
			}
			
			private var _onInit:Function, _timer:Timer
			private var _playPoints:Dictionary
			
			
			private function _init():void
			{
				var sndGrp:GameSoundGroup, list:Array;
				var gs:GameSounds = GameSounds.instance;
				GameSounds.poolDelayGap = 100;
				
				{// -- menu music
					list = [
						assets.createSound('pb2.audio.music.hibIntro'),
						assets.createSound('pb2.audio.music.hibSetA'),
						assets.createSound('pb2.audio.music.hibSetB'),
						assets.createSound('pb2.audio.music.hibSetC'),
						assets.createSound('pb2.audio.music.hibSetD'),
						assets.createSound('pb2.audio.music.hibVerseA'),
						assets.createSound('pb2.audio.music.hibVerseB'),
						assets.createSound('pb2.audio.music.hibChorusA')
					];
					gs.add( sndGrp = new GameSoundGroup(MUSIC_HOW_IT_BEGINS, 100, GameSounds.MUSIC_GROUP) );
					sndGrp.queue( list, [0] );
					
					gs.add( sndGrp = new GameSoundGroup(MUSIC_HOW_IT_BEGINS_LOOP, 100, GameSounds.MUSIC_GROUP) );
					sndGrp.queue( list, [1,5,2,7,3,6,4,7,6] );
				}
				
				{// -- game music
					list = [
						assets.createSound('pb2.audio.music.plChorusA'),
						assets.createSound('pb2.audio.music.plVerseA'),
						assets.createSound('pb2.audio.music.plBridge')
					];
					gs.add( sndGrp = new GameSoundGroup(MUSIC_PLAIN_LOAFER, 100, GameSounds.MUSIC_GROUP) );
					sndGrp.queue( list, [0,0,1,1,2,0,0,0,1,1,1,1,2] );
					
					gs.add( sndGrp = new GameSoundGroup(MUSIC_BASS_VIBES, 100, GameSounds.MUSIC_GROUP) );
					sndGrp.queue( [assets.createSound('pb2.audio.music.bvLoop')], [0] );
					
					gs.add( sndGrp = new GameSoundGroup(MUSIC_BASS_SOLI, 100, GameSounds.MUSIC_GROUP) );
					sndGrp.queue( [assets.createSound('pb2.audio.music.bsLoop')], [0] );
					
					gs.add( sndGrp = new GameSoundGroup(MUSIC_WALKING_ALONG, 100, GameSounds.MUSIC_GROUP) );
					sndGrp.queue( [assets.createSound('pb2.audio.music.waLoop')], [0] );
					
					resetPlayPoints();
					
				}
				
				{// -- victory music
					/*gs.add( new GameSoundObj(MUSIC_HAPPY_ALLEY, assets.createSound('pb2.audio.music.haIntro'), 100, GameSounds.MUSIC_GROUP) );
					gs.add( new GameSoundObj(MUSIC_HAPPY_ALLEY_LOOP, assets.createSound('pb2.audio.music.haLoop'), 100, GameSounds.MUSIC_GROUP) );
					gs.add( new GameSoundObj(MUSIC_HAPPY_ALLEY_END, assets.createSound('pb2.audio.music.haEnd'), 100, GameSounds.MUSIC_GROUP) );
					*/
					
					gs.add( new GameSoundObj(VICTORY_A, assets.createSound('pb2.audio.music.victoryA'), 100, GameSounds.MUSIC_GROUP) );
					gs.add( new GameSoundObj(VICTORY_B, assets.createSound('pb2.audio.music.victoryB'), 100, GameSounds.MUSIC_GROUP) );
				}
				
				{// -- ambience
					gs.add( new GameSoundObj(AMBIENCE_FOREST, assets.createSound('pb2.audio.music.forest'), 100, GROUP_AMBIENCE | GameSounds.MUSIC_GROUP) );
				}
				
				{// sfx
					gs.add( new GameSoundObj(POP, assets.createSound('pb2.audio.music.sillyfun2'), 100, GameSounds.SFX_GROUP) );
					
					gs.add( new GameSoundObj(DRIVE1, assets.createSound('pb2.audio.sfx.drive1'), 80, GameSounds.SFX_GROUP) );
					gs.add( new GameSoundObj(DRIVE2, assets.createSound('pb2.audio.sfx.drive2'), 80, GameSounds.SFX_GROUP) );
					gs.add( new GameSoundObj(DRIVE3, assets.createSound('pb2.audio.sfx.drive3'), 80, GameSounds.SFX_GROUP) );
					
					gs.add( new GameSoundObj(BALL_ROLL, assets.createSound('pb2.audio.sfx.BallRoll'), 60, GROUP_SFX_LOOPED | GameSounds.SFX_GROUP) );
					gs.add( new GameSoundObj(BALL_HOLE, assets.createSound('pb2.audio.sfx.BallHole'), 80) );
					gs.add( new GameSoundObj(CONVEYOR, assets.createSound('pb2.audio.sfx.Conveyor'), 60, GROUP_SFX_LOOPED | GameSounds.SFX_GROUP) );
					gs.add( new GameSoundObj(FLOORWIND, assets.createSound('pb2.audio.sfx.Floorwind'), 60, GROUP_SFX_LOOPED | GameSounds.SFX_GROUP) );
					gs.add( new GameSoundObj(KISS, assets.createSound('pb2.audio.sfx.Kiss'), 80) );
					gs.add( new GameSoundObj(GATE, assets.createSound('pb2.audio.sfx.Gate'), 55) );
					gs.add( new GameSoundObj(POP1, assets.createSound('pb2.audio.sfx.Pop1')) );
					gs.add( new GameSoundObj(POP2, assets.createSound('pb2.audio.sfx.Pop2')) );
					gs.add( new GameSoundObj(PICTURE, assets.createSound('pb2.audio.sfx.Picture'), 60) );
					gs.add( new GameSoundObj(BUZZ, assets.createSound('pb2.audio.sfx.error'), 60) );
					
					var i:int = 2;
					while( i-- ) {
						gs.addPool( new GameSoundObj(GLASSTAP, assets.createSound('pb2.audio.sfx.Glasstap')) );
						gs.addPool( new GameSoundObj(WOOD_TAP1, assets.createSound('pb2.audio.sfx.WoodTap1')) );
						gs.addPool( new GameSoundObj(WOOD_TAP2, assets.createSound('pb2.audio.sfx.WoodTap2')) );
						gs.addPool( new GameSoundObj(WOOD_TAP3, assets.createSound('pb2.audio.sfx.WoodTap3')) );
						gs.addPool( new GameSoundObj(WALL_TAP1, assets.createSound('pb2.audio.sfx.WallTap1')) );
						gs.addPool( new GameSoundObj(WALL_TAP2, assets.createSound('pb2.audio.sfx.WallTap2')) );
						gs.addPool( new GameSoundObj(WALL_TAP3, assets.createSound('pb2.audio.sfx.WallTap3')) );
						gs.addPool( new GameSoundObj(JELLY_TAP, assets.createSound('pb2.audio.sfx.JellyTap')) );
						gs.addPool( new GameSoundObj(RUBBER_TAP, assets.createSound('pb2.audio.sfx.RubberTap')) );
						gs.addPool( new GameSoundObj(SPRING_TAP, assets.createSound('pb2.audio.sfx.SpringTap'), 60) );
						gs.addPool( new GameSoundObj(BEEP1, assets.createSound('pb2.audio.sfx.Beep1'), 60) );
						gs.addPool( new GameSoundObj(SQUISH_TAP, assets.createSound('pb2.audio.sfx.SquishTap')) );
					}
					i = 4;
					while ( i-- ) {
						gs.addPool( new GameSoundObj(GLASSBREAK, assets.createSound('pb2.audio.sfx.Glassbreak'), 80) );
						gs.addPool( new GameSoundObj(WARP, assets.createSound('pb2.audio.sfx.Warp'), 60) );
						gs.addPool( new GameSoundObj(FLICK, assets.createSound('pb2.audio.sfx.Flick')) );
						gs.addPool( new GameSoundObj(FLICK, assets.createSound('pb2.audio.sfx.Flick')) );
						gs.addPool( new GameSoundObj(BOMB, assets.createSound('pb2.audio.sfx.explode'), 60) );
						gs.addPool( new GameSoundObj(POP4, assets.createSound('pb2.audio.sfx.Pop3')) );
					}
					
				}
				
				
				trace( '[audio assets initiated]' );
				if ( _onInit != null ) _onInit.call();
			}
			
			private function _update():void
			{
				FadeSoundEffect.update();
				
				// all play request are cleared on session stop
				PlayRequestPriority.update();
			}
			
			
			private function _prepNext( snd:GameSoundObj ):void
			{
				snd.onEnd.remove( _prepNext );
				_timer = new Timer( 5000, 1 );
				_timer.addEventListener( TimerEvent.TIMER_COMPLETE, _playNext, false, 0, true );
				_timer.start();
			}
			
			private function _playNext( e:TimerEvent ):void
			{
				if ( GameRoot.screen.isReady )
					playGameMusic();
				_timer.removeEventListener( TimerEvent.TIMER_COMPLETE, _playNext );
				_timer = null;
			}
			
			
	}

}