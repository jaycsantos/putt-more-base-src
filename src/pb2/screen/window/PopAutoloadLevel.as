package pb2.screen.window 
{
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.math.MathUtils;
	import flash.display.MovieClip;
	import flash.events.Event;
	import pb2.game.ctrl.GamerSafeHelper;
	import pb2.game.*;
	import pb2.screen.*;
	import pb2.util.CustomLevel;
	import Playtomic.*;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PopAutoloadLevel extends PopWindow 
	{
		
		public function PopAutoloadLevel( lvlid:String ) 
		{
			obstrusive = mouseEnabled = true;
			mouseChildren = false;
			
			_lvlid = lvlid;
			_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 12, 1), 1, false, onShown.dispatch );
			_animator.addSequenceSet( END, MathUtils.intRangeA(1, 2, 1), 1, false, onHidden.dispatch );
			
			
			var mc:MovieClip;
			addChild( mc = PuttBase2.assets.createDisplayObject('screen.ui.ico.iconLoading') as MovieClip );
			mc.x = PuttBase2.STAGE_WIDTH / 2;
			mc.y = PuttBase2.STAGE_HEIGHT / 2;
			mc.play();
			
			show();
			onShown.addOnce( _load );
		}
		
		
			// -- private --
			
			private var _lvlid:String
			
			private function _load():void
			{
				
				CONFIG::useGamersafe {
					if ( GamerSafe.api && GamerSafe.api.loaded ) {
						GamerSafeHelper.i.lvGot1Lvl.add( _onGsLoaded );
						GamerSafeHelper.i.lvException.addOnce( _onGsLoaded );
						GamerSafeHelper.i.lvError.addOnce( _onGsLoaded );
						GamerSafeHelper.i.networkError.addOnce( _onGsLoaded );
						GamerSafe.api.levelVaultFetchLevelByID( int(_lvlid) );
					} else
						_onGsLoaded();
				}
				CONFIG::usePlaytomicLvls {
					PlayerLevels.Load( lvlid, _onPlaytomicLoaded );
				}
				
			}
			
			
			private function _onPlaytomicLoaded( level:PlayerLevel, response:Object ):void
			{
				//if ( !_canvas.stage ) return;
				if ( response.Success ) {
					/*var win:Window = new CLevelDetailWindow( level, MenuActScreen );
					_canvas.addChild( win );
					win.show();*/
					//_canvas.stage.focus = _canvas.stage;
					
					Tracker.i.custom( 'autoLoadedCustomLevel' );
					
				} else {
					//if ( !_canvas.stage ) return;
					/*CONFIG::debug {
						_canvas.addChild( PopPrompt.create('Error ('+ response.ErrorCode +'): \n'+ Registry.PLAYTOMIC_ERR_MSG[response.ErrorCode], 100, {name:'OK'}) ); }
					CONFIG::release {
						_canvas.addChild( PopPrompt.create('Server might be busy. Try again later. ('+ response.ErrorCode +')', 100, {name:'OK'}) ); }
					*/
					//_canvas.stage.focus = _canvas.stage;
					Tracker.i.custom( 'autoLoadedCustomLevel_fail' );
				}
			}
			
			private function _onGsLoaded( e:*=null ):void
			{
				GamerSafeHelper.i.lvGot1Lvl.remove( _onGsLoaded );
				GamerSafeHelper.i.lvException.remove( _onGsLoaded );
				GamerSafeHelper.i.lvError.remove( _onGsLoaded );
				GamerSafeHelper.i.networkError.remove( _onGsLoaded );
				
				if ( !stage ) return;
				if ( e && e is Event && Event(e).type == GamerSafe.EVT_LEVELVAULT_GOT_SINGLE_LEVEL ) {
					var lvl:CustomLevel = CustomLevel.createFromGamersafe( GamerSafe.api.levelVaultGetLastSelectedLevel() );
					
					var xml:XML = XML(<level sett="9999" group="-1"><map></map><par></par><item></item></level>);
					xml.@name = lvl.name.replace(/\s/g, '-');
					xml.@author = lvl.author.replace(/\s/g, '-');
					xml.map = lvl.data;
					xml.par = lvl.par;
					xml.item = lvl.item;
					
					var ses:Session = Session.instance;
					ses.map = new MapData( xml, lvl );
					
					GameRoot.changeScreen( RelayScreen, PlayScreen );
					
					Tracker.i.startLevel( ses.map, 'mainmenu_autoload' );
					Tracker.i.custom( 'autoLoadedCustomLevel' );
					
				} else
				if ( e && e is Error )
					parent.addChild( PopPrompt.create('Error\n'+Error(e).message, 120, {name:'OK'}) );
				else if ( !GamerSafe.api.loaded )
					parent.addChild( PopPrompt.create('Cannot establish connection to server. Restart game if it persists.', 120, {name:'OK'}) );
				
				dispose();
				
				Tracker.i.custom( 'autoLoadedCustomLevel_fail' );
			}
			
			
			
	}

}