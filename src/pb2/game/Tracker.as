package pb2.game 
{
	import flash.display.DisplayObjectContainer;
	import mochi.as3.*;
	import pb2.screen.ui.HudGame;
	import Playtomic.*;
	
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Tracker 
	{
		public static const i:Tracker = new Tracker;
		
		public function Tracker() 
		{
			if ( i ) throw new Error('[pb2.game.Tracker] Singleton class, use static property i');
		}
		
		public function init( clip:DisplayObjectContainer ):void
		{
			CONFIG::usePlaytomic {
				Log.View( 6206, '67f8bd51ab3b4a66', '9036eda2c5304c67b523afbc9835f5', clip.loaderInfo.loaderURL );
				Log.CustomMetric( 'v'+ Registry.VERSION, 'versions', true );
			}
			
			CONFIG::useMochi { MochiServices.connect( '5a1caa8830352ec4', clip ); }
		}
		
		
		public function startLevel( map:MapData, from:String=null ):void
		{
			CONFIG::usePlaytomic {
				Log.Play();
				Log.ForceSend();
			}
			
			if ( map.isCustom ) {
				CONFIG::usePlaytomic {
					PlayerLevels.LogStart( map.customLevel.id );
					Log.CustomMetric( 'startCustomLevel', from );
				}
				CONFIG::useGamersafe { GamerSafe.api.levelVaultIncrementNumeric( int(map.customLevel.id), 'plays' ); }
				
				CONFIG::useMochi {
					MochiEvents.startPlay( 'startCustomLevel' );
					MochiEvents.trackEvent( 'startCustomLevel', map.customLevel.id );
				}
				CONFIG::onFGL {
					Registry.FGL_TRACKER.beginLevel( -1, 0, 'startCustomLevel', map.customLevel.id );
					Registry.FGL_TRACKER.customMsg( 'startCustomLevel', 0, 'startCustomLevel', map.customLevel.id );
				}
				
			} else {
				CONFIG::usePlaytomic {
					Log.CustomMetric( 'startLevelFrom', from );
					Log.LevelCounterMetric( 'startLevel', map.name );
				}
				
				CONFIG::useMochi {
					MochiEvents.startPlay( 'startLevel' );
					MochiEvents.trackEvent( 'startLevel', map.name );
				}
				CONFIG::onFGL {
					Registry.FGL_TRACKER.beginLevel( map.levelIndex, 0, 'startLevel', map.name );
					Registry.FGL_TRACKER.customMsg( 'startLevel', 0, 'startLevel', map.name );
				}
			}
		}
		
		public function quitLevel( map:MapData, from:String=null ):void
		{
			if ( map.isCustom ) {
				CONFIG::usePlaytomic {
					PlayerLevels.LogQuit( map.customLevel.id );
					Log.CustomMetric( 'quitCustomLevelFrom', from );
				}
				CONFIG::useGamersafe { GamerSafe.api.levelVaultIncrementNumeric( int(map.customLevel.id), 'quits' ); }
				
				CONFIG::useMochi { MochiEvents.trackEvent( 'quitCustomLevelFrom', from ); }
				CONFIG::onFGL {
					Registry.FGL_TRACKER.endLevel( 0, 'quitCustomLevel', map.customLevel.id +', '+ from );
					Registry.FGL_TRACKER.customMsg( 'endLevel', 0, 'quitCustomLevelFrom', map.customLevel.id +', '+ from ); }
				
			} else {
				CONFIG::usePlaytomic {
					Log.CustomMetric( 'quitLevelFrom', from );
					Log.LevelCounterMetric( 'quitLevel', map.name );
					if ( HudGame.instance )
						Log.LevelAverageMetric( 'resetsBeforeQuit', map.name, HudGame.instance.resets );
				}
				
				CONFIG::useMochi { MochiEvents.trackEvent( 'quitLevel', from ); }
				CONFIG::onFGL {
					Registry.FGL_TRACKER.endLevel( 0, 'quitLevel '+ map.name, from );
					Registry.FGL_TRACKER.customMsg( 'endLevel', 0, 'quitLevelFrom'+ map.name, from ); }
			}
			CONFIG::useMochi { MochiEvents.endPlay(); }
		}
		
		public function finishLevel( map:MapData, data:Object ):void
		{
			if ( map.isCustom ) {
				CONFIG::usePlaytomic {
					PlayerLevels.LogWin( map.customLevel.id );
					Log.CustomMetric( 'finishCustomLevel' );
				}
				CONFIG::useGamersafe { GamerSafe.api.levelVaultIncrementNumeric( int(map.customLevel.id), 'wins' ); }
				CONFIG::useMochi { MochiEvents.trackEvent( 'finishCustomLevel', objToStr(data) ); }
				
				CONFIG::onFGL {
					Registry.FGL_TRACKER.customMsg( 'endLevel', uint(data.score), 'finishCustomLevel', map.customLevel.id +', '+ objToStr(data) ); }
					Registry.FGL_TRACKER.endLevel( uint(data.score), 'finishCustomLevel', map.customLevel.id +', '+ objToStr(data) );
				
			} else {
				CONFIG::usePlaytomic {
					Log.LevelCounterMetric( 'finishLevel', map.name );
					Log.LevelAverageMetric( 'score', map.name, data.score );
					Log.LevelRangedMetric( 'stroke', map.name, data.strokes );
					Log.LevelRangedMetric( 'bounce', map.name, data.bounces );
					Log.LevelRangedMetric( 'unusedItems', map.name, data.itemsUnused );
					if ( HudGame.instance )
						Log.LevelAverageMetric( 'resets', map.name, HudGame.instance.resets );
				}
				CONFIG::useMochi { MochiEvents.trackEvent( 'finishLevel', objToStr(data) ); }
				
				CONFIG::onFGL {
					Registry.FGL_TRACKER.customMsg( 'endLevel', uint(data.score), 'finishLevel', map.name +', '+ objToStr(data) );
					Registry.FGL_TRACKER.endLevel( uint(data.score), 'finishLevel', map.name +', '+ objToStr(data) ); }
			}
			CONFIG::useMochi { MochiEvents.endPlay(); }
		}
		
		
		public function buttonClick( name:String, from:String=null, misc:String=null ):void
		{
			CONFIG::usePlaytomic { Log.CustomMetric( 'btnClick_'+ name, from ); }
			CONFIG::useMochi { MochiEvents.trackEvent( 'btnClick', name +'@'+ from ); }
			CONFIG::onFGL { Registry.FGL_TRACKER.customMsg( 'btnClick', 0, name +'@'+ from, misc ); }
		}
		
		public function custom( name:String, from:String=null ):void
		{
			CONFIG::usePlaytomic { Log.CustomMetric( name, from ); }
			CONFIG::useMochi { MochiEvents.trackEvent( from +'_'+ name ); }
			CONFIG::onFGL { Registry.FGL_TRACKER.customMsg( 'custom', 0, from, name ); }
		}
		
		
		public function trackFGL( type:String, state:String, msg:String ):void
		{
			CONFIG::onFGL { Registry.FGL_TRACKER.customMsg( type, 0, state, msg ); }
		}
		
		
		public function levelAverage( name:String, level:String, value:int ):void
		{
			CONFIG::usePlaytomic { Log.LevelAverageMetric( name, level, value ); }
		}
		
		public function levelRanged( name:String, level:String, value:int ):void
		{
			CONFIG::usePlaytomic { Log.LevelRangedMetric( name, level, value ); }
		}
		
		public function levelCounter( name:String, level:String ):void
		{
			CONFIG::usePlaytomic {Log.LevelCounterMetric( name, level ); }
			CONFIG::useMochi { MochiEvents.trackEvent( name +'_'+ level ); }
		}
		
		
		public function customLevelAverage( name:String, value:int ):void
		{
			CONFIG::usePlaytomic { Log.LevelAverageMetric( name, 'custom', value ); }
		}
		
		public function customLevelRanged( name:String, value:int ):void
		{
			CONFIG::usePlaytomic { Log.LevelRangedMetric( name, 'custom', value ); }
		}
		
		
			// -- private --
			
			private function objToStr( obj:Object ):String
			{
				var s:String = '';
				for ( var k:String in obj )
					s += k+':'+ String(obj[k]) +',';
				return s;
			}
			
		
	}

}