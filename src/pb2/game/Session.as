package pb2.game 
{
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.Joints.*;
	import com.jaycsantos.display.CachedAssets;
	import com.jaycsantos.display.render.GameWorldRender;
	import com.jaycsantos.entity.*;
	import com.jaycsantos.game.*;
	import com.jaycsantos.IDisposable;
	import com.jaycsantos.math.Trigo;
	import com.jaycsantos.sound.*;
	import com.jaycsantos.util.ds.LinkEntity;
	import com.jaycsantos.util.*;
	import com.jaycsantos.util.ns.internalGameloop;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import org.osflash.signals.Signal;
	import pb2.game.ctrl.*;
	import pb2.game.entity.*;
	import pb2.game.entity.args.*;
	import pb2.game.entity.b2.*;
	import pb2.game.entity.misc.*;
	import pb2.game.entity.render.*;
	import pb2.game.entity.tile.*;
	import pb2.*;
	import pb2.screen.*;
	import pb2.screen.ui.*;
	import pb2.screen.window.Window;
	import pb2.util.pb2internal;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Session implements IGameSession 
	{
		public static const instance:Session = new Session
		
		public static function get b2world():b2World
		{
			return instance.b2world;
		}
		
		public static function get world():GameWorld
		{
			return instance.world;
		}
		
		public static function get factory():GameFactory
		{
			return instance.factory;
		}
		
		public static function get isRunning():Boolean
		{
			return instance._flags.isTrue( instance.FLAG_ISRUNNING );
		}
		
		public static function get isBusy():Boolean
		{
			return instance._flags.isTrue( instance.FLAG_ISBUSY );
		}
		
		public static function get isOnEditor():Boolean
		{
			return GameRoot.screen is EditorScreen;
		}
		
		public static function get isOnMenu():Boolean
		{
			return GameRoot.screen is MenuActScreen;
		}
		
		public static function get isOnPlay():Boolean
		{
			return GameRoot.screen is PlayScreen;
		}
		
		public static function getDisplayAsset( linkage:String ):DisplayObject
		{
			if ( instance._tempAssetMap[linkage] != undefined )
				return instance._tempAssetMap[linkage];
			
			return instance._tempAssetMap[linkage] = PuttBase2.assets.createDisplayObject( linkage );
		}
		
		
		public var b2world:b2World, world:GameWorld, factory:GameFactory = GameFactory.instance
		public var ground:Ground, shades:ShadeContainer, floor:FloorTexture, toons:Toons
		public var wallTop:WallEdge, wallBottom:WallEdge, wallLeft:WallEdge, wallRight:WallEdge
		
		public var cols:uint = 14, rows:uint = 8, width:uint, height:uint
		public var tileMap:Vector.<Vector.<b2EntityTile>>
		public var bgColorIdx:int, mode:int, map:MapData
		public var autoLoadLevelId:String
		
		public var pausePhys:Boolean
		public var sun_strength:Number = .2, sun_length:Number = Registry.tileSize /3;
		public var sun_angle:b2Vec2 = new b2Vec2( Trigo.VEC2_45_DEG.x, Trigo.VEC2_45_DEG.y )
		
		public var onEntityMoveStart:Signal=new Signal, onEntitiesMoveStop:Signal=new Signal, onReset:Signal=new Signal, onPutt:Signal=new Signal
		public var movingEntities:Vector.<b2Entity> = new Vector.<b2Entity>
		
		public function Session()
		{
			if ( instance ) throw new Error('[pb2.game.Session] Singleton class, use static property instance');
			
			factory.onSpawn.add( _onFactorySpawn );
			
			factory.registerEntityType( new EntityArgs({ type:'drag_bounds', customClass:DragBounds }) );
			factory.registerEntityType( new EntityArgs({ type:'grid', customClass:Grid, renderClass:GridRender, layer:1, depth:0xffff }) );
			factory.registerEntityType( new EntityArgs({ type:'toons', customClass:Toons, renderClass:ToonsRender, layer:3, depth:0xf0 }) );
			
			factory.registerEntityType( new EntityArgs({ type:'ground', customClass:Ground, renderClass:GroundRender, layer:0, depth:0x0 }) );
			factory.registerEntityType( new EntityArgs({ type:'floor', customClass:FloorTexture, renderClass:FloorTextureRender, layer:1, depth:0x1 }) );
			factory.registerEntityType( new EntityArgs({ type:'shades', customClass:ShadeContainer, renderClass:ShadeRender, layer:1, depth:0xff01 }) );
			
			factory.registerEntityType( new EntityArgs({ type:'wall_top', customClass:WallEdge, renderClass:WallEdgeRender, layer:3 }) );
			factory.registerEntityType( new EntityArgs({ type:'wall_bottom', customClass:WallEdge, renderClass:WallEdgeRender, layer:3 }) );
			factory.registerEntityType( new EntityArgs({ type:'wall_left', customClass:WallEdge, renderClass:WallEdgeRender, layer:3 }) );
			factory.registerEntityType( new EntityArgs({ type:'wall_right', customClass:WallEdge, renderClass:WallEdgeRender, layer:3 }) );
			//factory.registerEntityType( new EntityArgs({ type:'walls', customClass:Walls, renderClass:WallsRender, layer:3, depth:0xffff }) );
			
			factory.registerEntityType( new EntityArgs({ type:Tile.GOLFBALL, customClass:Ball, renderClass:BallRender, layer:2, data:{radius:Registry.BALL_Radius} }) );
			factory.registerEntityType( new EntityArgs({ type:Tile.HOLE, customClass:Hole, renderClass:HoleRender, layer:1, data:{radius:Registry.HOLE_Radius} }) );
			factory.registerEntityType( new EntityArgs({ type:Tile.GLASS, customClass:Glass, renderClass:GlassRender, layer:1, depth:0xff10 }) );
			factory.registerEntityType( new EntityArgs({ type:Tile.GLASSWOOD, customClass:Glass, renderClass:GlassRender, layer:1, depth:0xff10 }) );
			factory.registerEntityType( new EntityArgs({ type:Tile.GLASSRUBBER, customClass:Glass, renderClass:GlassRender, layer:1, depth:0xff10 }) );
			factory.registerEntityType( new EntityArgs({ type:Tile.GLASSWALL, customClass:Glass, renderClass:GlassRender, layer:1, depth:0xff10 }) );
			factory.registerEntityType( new EntityArgs({ type:Tile.BOMB, customClass:Bomb, renderClass:BombRender, layer:1, depth:0xff10 }) );
			
			for each ( var list:Array in Tile.TILE_ALL )
				for each( var k:String in list ) {
					if ( Tile.TILE_WALLS.indexOf(k) > -1 )
						factory.registerEntityType( new EntityArgs({ type:k, customClass:SolidBlock, renderClass:SolidBlkRender, layer:3 }) );
						
					else if ( Tile.TILE_INDEPENDENTS.indexOf(k) == -1 )
						factory.registerEntityType( new EntityArgs({ type:k, customClass:Block, renderClass:BlockRender, layer:2 }) );
				}
			for each( var m:String in [Tile.JELL_SQ, Tile.JELL_HF, Tile.JELL_RTRI, Tile.JELL_ISOTRI, Tile.JELL_HFISOTRI, Tile.JELL_HFRTRI_1, Tile.JELL_HFRTRI_2, Tile.JELL_HFRTRI_3, Tile.JELL_HFRTRI_4] )
				factory.registerEntityType( new EntityArgs({ type:m, customClass:JellyBlock, renderClass:JellyRender, layer:2 }) );
			
			
			factory.registerEntityType( new EntityArgs({ type:Tile.SIGNAL_RELAY, customClass:RelayBlock, renderClass:RelayBlkRender, layer:3 }) );
			
			factory.registerEntityType( new EntityArgs({ type:Tile.SPINFLAPS, customClass:Spinner, renderClass:SpinnerRender, layer:3 }) );
			factory.registerEntityType( new EntityArgs({ type:Tile.SPINFLAPS_BLU, customClass:Spinner, renderClass:SpinnerRender, layer:3 }) );
			factory.registerEntityType( new EntityArgs({ type:Tile.SPINFLAPS_RED, customClass:Spinner, renderClass:SpinnerRender, layer:3 }) );
			factory.registerEntityType( new EntityArgs({ type:Tile.SPINFLAPS_YEL, customClass:Spinner, renderClass:SpinnerRender, layer:3 }) );
			
			factory.registerEntityType( new EntityArgs({ type:Tile.PUNCHER2_SQ, customClass:Puncher2, renderClass:Puncher2Render, layer:2 }) );
			factory.registerEntityType( new EntityArgs({ type:Tile.PPUNCHER_SQ, customClass:PPuncher, renderClass:PPuncherRender, layer:2 }) );
			
			factory.registerEntityType( new EntityArgs({ type:Tile.PUSH_BTN, customClass:PushButton, renderClass:PushBtnRender, layer:2 }) );
			factory.registerEntityType( new EntityArgs({ type:Tile.PUSH_BTN2, customClass:PushButton, renderClass:PushBtnRender, layer:2, data:{isReversed:true} }) );
			factory.registerEntityType( new EntityArgs({ type:Tile.PUSH_BTN3, customClass:PushButton, renderClass:PushBtnRender, layer:2, data:{isToggle:true} }) );
			factory.registerEntityType( new EntityArgs({ type:Tile.GATE_A, customClass:FloorGate, renderClass:FloorGateRender, layer:1, depth:0xff0f }) );
			factory.registerEntityType( new EntityArgs({ type:Tile.GATE_B, customClass:FloorGate, renderClass:FloorGateRender, layer:1, depth:0xff0f, data:{isReversed:true} }) );
			factory.registerEntityType( new EntityArgs({ type:Tile.GATE_C, customClass:FloorGateCD, renderClass:FloorGateCDRender, layer:1, depth:0xff0f }) );
			factory.registerEntityType( new EntityArgs({ type:Tile.GATE_D, customClass:FloorGateCD, renderClass:FloorGateCDRender, layer:1, depth:0xff0f, data:{isReversed:true} }) );
			factory.registerEntityType( new EntityArgs({ type:Tile.GATE_E, customClass:WallGate, renderClass:WallGateRender, layer:1, depth:0xff0f }) );
			factory.registerEntityType( new EntityArgs({ type:Tile.GATE_F, customClass:WallGate, renderClass:WallGateRender, layer:1, depth:0xff0f, data:{isReversed:true} }) );
			
			factory.registerEntityType( new EntityArgs({ type:Tile.FLOORBLOWER, customClass:FloorBlower, renderClass:FloorBlowerRender, layer:1, depth:0xff00 }) );
			factory.registerEntityType( new EntityArgs({ type:Tile.FLOORBLOWER2, customClass:FloorBlower, renderClass:FloorBlowerRender, layer:1, depth:0xff00 }) );
			factory.registerEntityType( new EntityArgs({ type:Tile.PORTAL, customClass:Portal, renderClass:PortalRender, layer:1, depth:0xff00 }) );
			
			
			_worldDebugDraw = new b2DebugDraw();
			with ( _worldDebugDraw ) {
				SetSprite( _debugSprite = new Sprite )
				SetDrawScale( Registry.b2Scale );
				SetFlags( b2DebugDraw.e_shapeBit|b2DebugDraw.e_jointBit );
				SetFillAlpha( .3 );
				SetLineThickness( 1 );
			}
		}
		
		public function clean():void 
		{
			if ( isRunning ) stop();
			_flags.setTrue( FLAG_ISBUSY );
			
			if ( b2world ) {
				
				var i:int = tileMap.length, j:int;
				while ( i-- ) {
					j = tileMap[i].length;
					while ( j-- )
						if ( tileMap[i][j] != null )
							tileMap[i][j].dispose();
					tileMap[i].splice( 0, tileMap[i].length );
				}
				tileMap.splice( 0, tileMap.length ); tileMap = null;
				
				BallCtrl.instance.deactivate();
				//GameAudio.stopMusic( true, 1000 );
				GameSounds.stopGroup( GameSounds.SFX_GROUP );
				Window.removeAllWindows();
				
				factory.resignWorld();
				
				ground = null; shades = null; floor = null;
				wallTop = wallBottom = wallLeft = wallRight = null;
				
				world.dispose();
				world = null;
				
				if ( _debugSprite.parent )
					_debugSprite.parent.removeChild( _debugSprite );
				
				onEntityMoveStart.removeAll();
				onEntitiesMoveStop.removeAll();
				onPutt.removeAll();
				onReset.removeAll();
				movingEntities.splice( 0, movingEntities.length );
				
				var b:b2Body, node:b2Body = b2world.GetBodyList();
				while ( node ) {
					b = node;
					node = node.GetNext();
					b2world.DestroyBody(b);
				}
				b2world = null;
				
				CachedAssets.instance.clearTempCache();
				for each( var k:String in _tempAssetMap )
					delete _tempAssetMap[k];
			}
			_flags.setFalse( FLAG_ISBUSY );
		}
		
		public function create( Cols:uint, Rows:uint, canvas:DisplayObjectContainer, camWidth:uint=0, camHeight:uint=0 ):void
		{
			cols = Cols;
			rows = Rows;
			// add 1 for the walls
			width = (cols +1) * Registry.tileSize;
			height = (rows +1) * Registry.tileSize;
			
			tileMap = new Vector.<Vector.<b2EntityTile>>();
			for ( var i:int; i < cols; i++ )
				tileMap.push( new Vector.<b2EntityTile>(rows) );
			
			b2world = new b2World( new b2Vec2, true );
			b2world.SetContactListener( new ContactCtrl );
			b2world.SetDebugDraw( _worldDebugDraw );
			
			world = new GameWorld( width, height, camWidth? camWidth: PuttBase2.STAGE_WIDTH, camHeight? camHeight: PuttBase2.STAGE_HEIGHT );
			factory.registerWorld( world, new GameWorldRender(world, canvas) );
			
			//world.wrender.addBitmapLayer(); // layer 0
			world.wrender.addLayer(); // layer 1
			world.wrender.addLayer(); // layer 1
			world.wrender.addLayer(); // layer 2
			world.wrender.addLayer(); // layer 2
			//world.wrender.addBitmapLayer(); // layer 3/**/
			/*world.wrender.addLayer(); // layer 0
			world.wrender.addLayer(); // layer 1
			world.wrender.addLayer(); // layer 2
			world.wrender.addLayer(); // layer 3/**/
			world.camera.maxSpeed = 10;
			
			ground = factory.spawnEntity( 'ground' ) as Ground;
			shades = factory.spawnEntity( 'shades' ) as ShadeContainer;
			floor = factory.spawnEntity( 'floor' ) as FloorTexture;
			wallTop = factory.spawnEntity( 'wall_top' ) as WallEdge;
			wallLeft = factory.spawnEntity( 'wall_left' ) as WallEdge;
			wallRight = factory.spawnEntity( 'wall_right' ) as WallEdge;
			wallBottom = factory.spawnEntity( 'wall_bottom' ) as WallEdge;
			toons = factory.spawnEntity( 'toons' ) as Toons;
			
			
			canvas.addChild( _debugSprite );
			_debugSprite.visible = false;
			BallCtrl.instance.activate( canvas );
			CameraFocusCtrl.instance.followMouse();
			
		}
		
		
		public function get isRunning():Boolean
		{
			return _flags.isTrue( FLAG_ISRUNNING );
		}
		
		public function get isBusy():Boolean
		{
			return _flags.isTrue( FLAG_ISBUSY );
		}
		
		public function start():void
		{
			if ( _flags.isFalse(FLAG_ISRUNNING) && b2world && world && !_flags.isTrue(FLAG_ISBUSY) ) {
				GameLoop.instance.internalGameloop::addCallback( _update );
				
				_flags.setTrue( FLAG_ISRUNNING );
				GameSounds.unMute( GameAudio.GROUP_SFX_LOOPED );
				
				trace( '3:session began' );
			}
		}
		
		public function stop():void
		{
			if ( _flags.isTrue(FLAG_ISRUNNING) ) {
				GameLoop.instance.internalGameloop::removeCallback( _update );
				
				_flags.setFalse( FLAG_ISRUNNING );
				GameSounds.stopGroup( GameSounds.SFX_GROUP );
				GameSounds.mute( GameAudio.GROUP_SFX_LOOPED );
				
				trace( '3:session halted' );
			}
		}
		
		public function reset( all:Boolean=false, setDefaultOnly:Boolean=false ):void
		{
			if ( _flags.isTrue(FLAG_ISBUSY) || !b2world ) return;
			_flags.setTrue( FLAG_ISBUSY | FLAG_RESET );
			_flags.setFlag( FLAG_RESETALL, all );
			_flags.setFlag( FLAG_RESET_DEFAULT, setDefaultOnly );
			
			
			if ( _flags.isFalse(FLAG_ISRUNNING) )
				_resetTileMap();
		}
		
		public function toggleDebug():void
		{
			_debugSprite.visible = ! _debugSprite.visible;
		}
		
		public function get movingEntitiesCount():uint
		{
			return movingEntities.length;
		}
		
		
		pb2internal function resize( nCols:uint, nRows:uint, BgColorIdx:int ):void
		{
			var willResize:Boolean = nCols != cols || nRows != rows;
			var willRecolor:Boolean = BgColorIdx != bgColorIdx;
			var i:int, j:int, len:int, tile:b2EntityTile, trashList:Vector.<b2EntityTile> = new Vector.<b2EntityTile>;
			
			if ( willResize ) {
				
				// resize tilemap
				if ( tileMap[0].length > nRows ) {
					for ( i=0; i<tileMap.length; i++ ) {
						len = tileMap[i].length;
						trashList = trashList.concat( tileMap[i].splice(nRows, len-nRows) );
					}
				} else
				if ( tileMap[0].length < nRows ) {
					for ( i=0; i<tileMap.length; i++ )
						tileMap[i].length = nRows;
				}
				
				if ( tileMap.length > nCols ) {
					while ( tileMap.length > nCols )
						trashList = trashList.concat( tileMap.pop() );
				} else
				if ( tileMap.length < nCols ) {
					for ( i=tileMap.length; i<nCols; i++ )
						tileMap.push( new Vector.<b2EntityTile>(nRows) );
				}
				for each( tile in trashList )
					if ( tile ) tile.dispose();
				
				var pCols:uint = cols;
				var pRows:uint = rows;
				cols = nCols;
				rows = nRows;
				
				// add 1 for the walls
				width = (cols +1) * Registry.tileSize;
				height = (rows +1) * Registry.tileSize;
				
				world.resize( width, height );
				
				// recreate walls
				wallTop.dispose();
				wallBottom.dispose();
				wallLeft.dispose();
				wallRight.dispose();
				
				CachedAssets.instance.clearCache( 'shades.wall_x' );
				CachedAssets.instance.clearCache( 'shades.wall_y' );
				
				wallTop = factory.spawnEntity( 'wall_top' ) as WallEdge;
				wallBottom = factory.spawnEntity( 'wall_bottom' ) as WallEdge;
				wallLeft = factory.spawnEntity( 'wall_left' ) as WallEdge;
				wallRight = factory.spawnEntity( 'wall_right' ) as WallEdge;
				floor.resize( nCols, nRows );
				
				
				// ugly redraw solid blocks
				i = Math.min( pCols, nCols ) -1;
				for ( j = 0; j < Math.min(pRows, nRows); j++ ) {
					tile = tileMap[i][j];
					if ( tile ) tile.setDefault( tile.defPx, tile.defPy, tile.defRa );
				}
				j = Math.min( pRows, nRows ) -1;
				for ( i = 0; i < Math.min(pCols, nCols); i++ ) {
					tile = tileMap[i][j];
					if ( tile ) tile.setDefault( tile.defPx, tile.defPy, tile.defRa );
				}
			}
			
			// recreate the ground entity
			if ( willResize || willRecolor ) {
				bgColorIdx = BgColorIdx;
				
				var list:Vector.<DisplayObject> = new Vector.<DisplayObject>(), clip:Sprite = ground.gndRender.clip;
				var d:DisplayObject;
				i = clip.numChildren;
				while ( i-- ) {
					d = clip.removeChildAt( i );
					if ( d.name.substr(0, 3) != '___' )
						list.push( d );
				}
				ground.dispose();
				ground = factory.spawnEntity('ground') as Ground;
				clip = ground.gndRender.clip;
				i = list.length;
				while ( i-- )
					clip.addChild( list[i] );
				//for each( d in list )
					//clip.addChild( d );
				
			}
			
		}
		
		
			// -- private --
			
			private const FLAG_ISRUNNING:uint=2, FLAG_ISBUSY:uint=4, FLAG_RESETALL:uint=8, FLAG_RESET_DEFAULT:uint=16, FLAG_RESET:uint=32;
			
			private var _flags:Flags = new Flags;
			private var _dt:Number = 1 / 30
			
			private var _tempAssetMap:Dictionary = new Dictionary
			private var _debugSprite:Sprite, _worldDebugDraw:b2DebugDraw
			private var _movingEntLastCount:uint, _resetTimer:Timer, _resetIndex:int
			
			private function _update():void
			{
				CONFIG::debug { DOutput.show('loop:', GameLoop.instance.deltaTime ); }
				CONFIG::debug { if ( GameRoot._breakUpdate ) return; }
				
				CONFIG::debug { var t:int = getTimer(); }
				if ( ! pausePhys ) {
					b2world.Step( _dt, 10, 10 );
					b2world.ClearForces();
				}
				CONFIG::debug { DOutput.show('phys:', (getTimer() - t) +'ms'); t = getTimer(); }
				
				if ( _debugSprite.visible )
					b2world.DrawDebugData();
				CONFIG::debug { DOutput.show('phys render:', (getTimer() - t) +'ms'); t = getTimer(); }
				
				world.update();
				
				if ( _debugSprite ) {
					_debugSprite.x = -world.camera.bounds.min.x;
					_debugSprite.y = -world.camera.bounds.min.y;
				}
				
				CONFIG::debug { DOutput.show('moving entitties:', movingEntities.length ); }
				if ( _movingEntLastCount != movingEntities.length ) {
					var b:Ball = BallCtrl.instance.getPrimary();
					if ( movingEntities.length > 0 ) {
						_movingEntLastCount = movingEntities.length;
						onEntityMoveStart.dispatch();
					} else
					if ( !b || (b && b.body && !b.body.IsAwake()) ) {
						_movingEntLastCount = movingEntities.length
						onEntitiesMoveStop.dispatch();
					}
				}
				
				CameraFocusCtrl.instance.update();
				
				if ( _flags.isTrue(FLAG_RESET) ) _resetTileMap();
			}
			
			private function _onFactorySpawn( e:Entity ):void
			{
				if ( !(e is b2Entity) ) return;
				
				var ent:b2Entity = b2Entity(e);
				
				if ( !ent.isFixed ) {
					ent.onMoveStart.add( _onEntityMove );
					ent.onMoveStop.add( _onEntityStop );
				}
				
			}
			
			private function _onEntityMove( ent:b2Entity ):void
			{
				if ( movingEntities.indexOf(ent) == -1 )
					movingEntities.push( ent );
			}
			
			private function _onEntityStop( ent:b2Entity ):void
			{
				var p:int = movingEntities.indexOf( ent );
				if ( p > -1 )
					movingEntities.splice( p, 1 );
			}
			
			
			private function _resetTileMap():void
			{
				if ( _flags.isTrue(FLAG_ISRUNNING) ) stop();
				if ( _flags.isTrue(FLAG_RESET_DEFAULT) ) {
					_resetTilemapDone();
					return;
				}
				
				var b:b2Body, node:b2Body = b2world.GetBodyList();
				while ( node ) {
					b = node;
					node = node.GetNext();
					b2world.DestroyBody(b);
				}
				
				b2world = new b2World( new b2Vec2, true );
				b2world.SetContactListener( new ContactCtrl );
				b2world.SetDebugDraw( _worldDebugDraw );
				
				
				_resetIndex = 0;
				GameLoop.instance.internalGameloop::addCallback( _resetTilemapLoop );
			}
			
			private function _resetTilemapLoop():void
			{
				var tile:b2EntityTile, hud:HudGame = HudGame.instance
				var le:LinkEntity = world.entities;
				var ctr:int=0;
				while ( ctr++ < _resetIndex && le )
					le = le.next;
				
				ctr = 20;
				while ( le && ctr-- ) {
					if ( le.entity is b2Entity ) {
						b2Entity(le.entity).createBody();
						if ( le.entity is b2EntityTile ) {
							tile = b2EntityTile(le.entity);
							tile.setDefault( tile.defPx, tile.defPy, tile.defRa );
						}
					}
					_resetIndex++;
					le = le.next;
				}
				
				if ( ! le )
					_resetTilemapDone();
			}
			
			private function _resetTilemapDone():void
			{
				// update children
				var resetAll:Boolean = _flags.isTrue( FLAG_RESETALL );
				var tile:b2EntityTile, le:LinkEntity = world.entities;
				var hud:HudGame = HudGame.instance;
				while ( le ) {
					if ( le.entity && le.entity is b2EntityTile ) {
						tile = le.entity as b2EntityTile;
						if ( hud && tile.isToolkit && (resetAll || tileMap[tile.defTileX][tile.defTileY]!=tile) ) {
							if ( hud.storeTool(tile as b2EntityTileTool) && tileMap[tile.defTileX][tile.defTileY]==tile )
								tileMap[tile.defTileX][tile.defTileY] = null;
							world.disposeEntity( tile );
							tile.deactivate();
							if ( tile.render ) tile.render.setVisible( false );
						} else
							b2EntityTile(le.entity).useDefault();
					}
					le = le.next;
				}
				
				_flags.setFalse( FLAG_ISBUSY | FLAG_RESET | FLAG_RESETALL | FLAG_RESET_DEFAULT );
				GameLoop.instance.internalGameloop::removeCallback( _resetTilemapLoop );
				start();
				onReset.dispatch();
			}
			
			
	}

}