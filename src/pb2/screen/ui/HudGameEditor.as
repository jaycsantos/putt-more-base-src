package pb2.screen.ui 
{
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.util.UserInput;
	import flash.events.MouseEvent;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.entity.b2.b2EntityTileTool;
	import pb2.game.Session;
	import pb2.game.Tile;
	import pb2.screen.EditorScreen;
	import pb2.screen.tutorial.PopInfoEditor;
	import pb2.screen.ui.toolbox.ToolBoxNode;
	import pb2.screen.window.Pb2Prompt;
	import pb2.util.pb2internal;
	/**
	 * ...
	 * @author ...
	 */
	public class HudGameEditor extends HudGame 
	{
		public static var instance:HudGameEditor
		
		use namespace pb2internal
		
		public var par:Vector.<uint> = new Vector.<uint>
		
		
		public function HudGameEditor() 
		{
			instance = this;
		}
		
		override public function init( data:Object = null ):void 
		{
			super.init( data );
			
			Session.instance.onPutt.add( _onPutt );
			Session.instance.onEntitiesMoveStop.addOnce( _openEditorInfo_putt );
			EditorScreen( GameRoot.screen ).toolBar.onSelectType.add( _onSelectTileType );
			EditorScreen.onTileAdded.add( _onAddTile );
			EditorScreen.onTileAddLimit.addOnce( _onAddTileLimit );
			EditorScreen.onModeChange.add( _openEditorInfo_test );
			EditorScreen.onMapAlter.add( _openEditorInfo_mapalter );
			
			addChild( new PopInfoEditor );
		}
		
		override public function dispose():void 
		{
			if ( instance == this ) instance = null;
			
			super.dispose();
		}
		
		
		public function addTile( tile:b2EntityTile ):Boolean
		{
			if ( !(tile is b2EntityTileTool) ) return false;
			
			var n:ToolBoxNode, type:String = tile.type;
			for each ( n in _nodeList )
				if ( n.type == type ) {
					if ( n.plus(tile as b2EntityTileTool) ) {
						tile.onDispose.add( removeTile );
						return true;
					}
					return false;
				}
			
			n = new ToolBoxNode( type, 0 );
			if ( n.plus(tile as b2EntityTileTool) ) {
				_nodeList.push( _clipToolbox.addChild(n) );
				n.y = _nodeList.length *NODE_GAP;
				
				tile.onDispose.add( removeTile );
				_makeDirty();
				return true;
			}
			
			return false;
		}
		
		public function removeTile( tile:b2EntityTile ):Boolean
		{
			if ( !(tile is b2EntityTileTool) ) return false;
			
			var n:ToolBoxNode, type:String = tile.type;
			for each ( n in _nodeList )
				if ( n.type == type ) {
					if ( n.minus(tile as b2EntityTileTool) ) {
						if ( !n.total ) {
							_nodeList.splice( _nodeList.indexOf(n), 1 );
							n.dispose();
							_clipToolbox.removeChild( n );
							_makeDirty();
						}
						return true;
					}
					break;
				}
			
			return false;
		}
		
		
		override public function releaseTool( type:String ):b2EntityTileTool 
		{
			var ent:b2EntityTileTool = super.releaseTool( type );
			if ( ent )
				ent.onDispose.add( removeTile );
			else if ( ent == null )
				PopInfoEditor.open( 12 );
			
			return ent;
		}
		
		// nodes list
		pb2internal function getNodes():Vector.<ToolBoxNode>
		{
			return _nodeList;
		}
		
		public function getPar():uint
		{
			return uint(_txfPar.text.substr(4));
		}
		
		pb2internal function alterPar( n:uint ):void
		{
			_txfPar.text = 'par '+ n;
		}
		
		public function mapAltered():void
		{
			_txfPar.htmlText = '<p class="hudPar">par 0</p>';
			par.splice( 0, par.length );
		}
		
		
		pb2internal function setVisibleGhost( value:Boolean ):void
		{
			_clipGhost.visible = value;
		}
		
		
			// -- private --
			
			protected function _start( e:MouseEvent ):void 
			{
				if ( EditorScreen.editMode )
					EditorScreen(GameRoot.screen).toolBar.test();
				else
					BallCtrl.instance.release();
			}
			
			private function _onPutt():void
			{
				_txfPar.text = 'par '+ _strokes;// + (_strokes + Math.max(Math.ceil(_strokes / 4), 2));
				
				/*par.push( _swings );
				
				use namespace pb2internal;
				
				if ( par.length == 1 ) {
					EditorScreen(GameRoot.screen)._hudParPuttPrompt( '1st out of 4 required putts completed.<br/>\n<br/>\nMake 4 consecutive putts to be eligible for sharing. Any editing will reset the putt requirements.<br/>\n<br/>\nThe par variation from the 4 putts will determine the difficulty of this hole.', 200, 130, 'CONTINUE', 80, _onPuttContinue );
					
				} else if ( par.length >= 4 ) {
					EditorScreen(GameRoot.screen)._hudParPuttPrompt( par.length +'/4 putts completed.<br/>\n<br/>\nThis hole is now eligible for sharing.', 120, 60, 'SHARE', 80, _onPuttContinue );
					
					var p:uint = 0, i:int = par.length;
					while ( i-- ) p = Math.max(par[i], p); p += 2;
					_txfPar.htmlText = '<p class="hudPar">par ' + p +'</p>';
					
				} else {
					EditorScreen(GameRoot.screen)._hudParPuttPrompt( par.length +'/4 putts completed.', 120, 30, 'CONTINUE', 80, _onPuttContinue );
				}*/
			}
			
			private function _onPuttContinue( e:MouseEvent ):void
			{
				restart();
				//if ( par.length >= 3 )
				//	EditorScreen(GameRoot.screen).toolBar.
			}
			
			
			private function _onSelectTileType( type:String ):void
			{
				switch( type ) {
					case Tile.PUSH_BTN:
					case Tile.PUSH_BTN2:
					case Tile.PUSH_BTN3:
					case Tile.GATE_E:
					case Tile.GATE_F:
					case Tile.PUNCHER2_SQ:
						PopInfoEditor.open( 20 );
						break;
					
					case Tile.FLOOR_NORMAL:
					case Tile.FLOOR_CARPET:
					case Tile.FLOOR_SAND:
					case Tile.FLOOR_WATER:
						PopInfoEditor.open( 18 );
						break;
					
					default: break;
				}
			}
			
			private function _onAddTile( type:String ):void
			{
				switch( type ) {
					case Tile.PUSH_BTN:
					case Tile.PUSH_BTN2:
					case Tile.PUSH_BTN3:
					case Tile.SIGNAL_RELAY:
					case Tile.GATE_A:
					case Tile.GATE_B:
						PopInfoEditor.open( 14 );
						break;
					
					case Tile.PORTAL:
						PopInfoEditor.open( 16 );
						break;
					
					default:
						if ( Tile.TILE_TOOLKITS.indexOf(type) > -1 && type!=Tile.GOLFBALL )
							if ( !PopInfoEditor.open(8) )
								PopInfoEditor.open( 10 );
				}
			}
			
			private function _onAddTileLimit( type:String ):void
			{
				PopInfoEditor.open( 12 );
			}
			
			
			private function _openEditorInfo_test():void
			{
				if ( !EditorScreen.editMode && (!BallCtrl.instance.getPrimary() || !BallCtrl.instance.getHole()) ) {
					PopInfoEditor.open( 2 );
					EditorScreen.onModeChange.remove( _openEditorInfo_test );
				}
			}
			
			private function _openEditorInfo_putt():void
			{
				PopInfoEditor.open( 6 );
			}
			
			private function _openEditorInfo_mapalter():void
			{
				EditorScreen.onMapSaved.addOnce( _openEditorInfo_save );
			}
			
			private function _openEditorInfo_save():void
			{
				if ( !UserInput.instance.isMouseDown && !PopInfoEditor.i.visible && EditorScreen.editMode ) {
					PopInfoEditor.open( 4 );
					EditorScreen.onMapAlter.remove( _openEditorInfo_mapalter );
				}
			}
			
			
	}

}