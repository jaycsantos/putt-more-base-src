package pb2.game.ctrl 
{
	import flash.events.Event;
	import org.osflash.signals.natives.NativeSignal;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class GamerSafeHelper 
	{
		public static const i:GamerSafeHelper = new GamerSafeHelper;
		
		public var lvGotLvlRank:NativeSignal, lvGotLvls:NativeSignal, lvGotNumLvls:NativeSignal, lvGot1Lvl:NativeSignal
		public var lvCreated:NativeSignal, lvDeleted:NativeSignal, lvEdited:NativeSignal, lvFlagged:NativeSignal
		public var lvNumIncr:NativeSignal, lvNumSet:NativeSignal, lvRated:NativeSignal, lvStrSet:NativeSignal
		public var lvCallback:Signal, lvError:Signal, lvException:Signal
		public var scoreError:NativeSignal, scoreReceived:NativeSignal, scoreSubmitted:NativeSignal
		public var getUnregName:NativeSignal
		public var networkError:NativeSignal
		
		public function GamerSafeHelper() 
		{
			if ( i ) throw new Error('[pb2.game.ctrl.GamerSafeHelper] Singleton class, use static property instance');
			
		}
		
		public function init():void
		{
			if ( lvGotLvlRank ) return;
			
			var api:GamerSafe = GamerSafe.api;
			
			networkError = new NativeSignal( api, GamerSafe.EVT_NETWORKING_ERROR );
			lvGotLvlRank = new NativeSignal( api, GamerSafe.EVT_LEVELVAULT_GOT_LEVEL_RANKING );
			lvGotLvls = new NativeSignal( api, GamerSafe.EVT_LEVELVAULT_GOT_LEVELS );
			lvGotNumLvls = new NativeSignal( api, GamerSafe.EVT_LEVELVAULT_GOT_NUM_LEVELS );
			lvGot1Lvl = new NativeSignal( api, GamerSafe.EVT_LEVELVAULT_GOT_SINGLE_LEVEL );
			lvCreated = new NativeSignal( api, GamerSafe.EVT_LEVELVAULT_LEVEL_CREATED );
			lvDeleted = new NativeSignal( api, GamerSafe.EVT_LEVELVAULT_LEVEL_DELETED );
			lvEdited = new NativeSignal( api, GamerSafe.EVT_LEVELVAULT_LEVEL_EDITED );
			lvFlagged = new NativeSignal( api, GamerSafe.EVT_LEVELVAULT_LEVEL_FLAGGED );
			lvNumIncr = new NativeSignal( api, GamerSafe.EVT_LEVELVAULT_LEVEL_NUMERICS_INCREMENTED );
			lvNumSet = new NativeSignal( api, GamerSafe.EVT_LEVELVAULT_LEVEL_NUMERICS_SET );
			lvRated = new NativeSignal( api, GamerSafe.EVT_LEVELVAULT_LEVEL_RATED );
			lvStrSet = new NativeSignal( api, GamerSafe.EVT_LEVELVAULT_LEVEL_STRINGS_SET );
			
			scoreError = new NativeSignal( api, GamerSafe.EVT_SCOREBOARD_ENTRIES_ERROR );
			scoreReceived = new NativeSignal( api, GamerSafe.EVT_SCOREBOARD_ENTRIES_RECEIVED );
			scoreSubmitted = new NativeSignal( api, GamerSafe.EVT_SCOREBOARD_ENTRY_SUBMITTED );
			getUnregName = new NativeSignal( api, GamerSafe.EVT_UNREGISTERED_NAME );
			
			
			lvCallback = new Signal();
			lvError = new Signal( Error );
			lvException = new Signal( Error );
			api.levelVaultRegisterCallback( lvCallback.dispatch );
			api.levelVaultRegisterErrorCallback( lvError.dispatch );
			api.levelVaultRegisterPersistentErrorCallback( lvException.dispatch );
			//api.onLevelVaultLevelAttributesChanged = lvEdited.dispatch;
		}
		
		
			// -- private --
			
		
	}

}