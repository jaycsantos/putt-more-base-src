package pb2.screen 
{
	import apparat.math.FastMath;
	import com.demonsters.debugger.MonsterDebugger;
	import com.greensock.easing.*;
	import com.jaycsantos.sound.GameSounds;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import org.osflash.signals.Signal;
	import pb2.game.entity.misc.Grid;
	import pb2.game.entity.misc.MoreTexture;
	import pb2.GameAudio;
	
	import com.jaycsantos.display.Cache4Bmp;
	import com.jaycsantos.display.render.*;
	import com.jaycsantos.display.screen.AbstractScreen;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.math.*;
	import com.jaycsantos.util.*;
	
	import flash.filters.*;
	import flash.geom.ColorTransform;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import pb2.game.ctrl.*;
	import pb2.game.entity.*;
	import pb2.game.entity.b2.*;
	import pb2.game.entity.tile.*;
	import pb2.game.entity.render.*;
	import pb2.game.*;
	import pb2.screen.*;
	import pb2.screen.ui.*;
	import pb2.screen.window.*;
	import pb2.util.*;
	
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class EditorScreen extends AbstractScreen
	{
		public static const FADE_ENTER_DUR:uint = 300, FADE_EXIT_DUR:uint = 700
		
		private static const TILE_BTN_OFF:uint = 14
		
		public static var editMode:Boolean = true
		public static var onModeChange:Signal=new Signal, onMapAlter:Signal=new Signal, onMapSaved:Signal=new Signal
		public static var onTileAdded:Signal=new Signal(String), onTileAddLimit:Signal=new Signal(String)
		
		public var ses:Session = Session.instance
		
		// dialogues
		
		public var hud:HudGameEditor, hudAudio:HudAudio
		public var toolBar:EditorToolBar, grid:Grid
		
		
		public function EditorScreen( root:GameRoot, data:Object = null )
		{
			var i:int, j:int, k:String, txf:TextField, ts:Number = Registry.tileSize, session:Session = Session.instance;
			editMode = true;
			
			super( root, data );
			
			{// layers
				_bmpD = new BitmapData( PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT, true, 0 );
				_cache = new Cache4Bmp( true, false, false, true );
				_cache.bitmapData = _bmpD.clone();
				
				_canvas.visible = false;
				_canvas.graphics.beginFill( 0x333333 );
				_canvas.graphics.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
				_canvas.graphics.endFill();
				
				// ---
				_canvas.addChild( _world_canvas = new Sprite );
				_canvas.addChild( _edit_overlay = new Sprite );
				_canvas.addChild( _ctrlbar = new Sprite );
				
				_canvas.addChild( _overlay = new Sprite );
				_canvas.addChild( hudAudio = new HudAudio );
				
				// ---
				_overlay.name = 'screen overlay';
				_overlay.mouseEnabled = false;
				_overlay.addChild( toolBar = new EditorToolBar );
				_overlay.addChild( hud = new HudGameEditor );
				_overlay.addChild( _dragBmp = new Bitmap(new BitmapData(ts*1.2, ts*1.2)) );
				_overlay.addChild( _mouseClip = PuttBase2.assets.createDisplayObject('mouse.pointer.helper') as MovieClip );
				//_overlay.addChild( diagSettings = new CustomHoleDiag(this) );
				_dragBmp.visible = false;
				
				// --
				hud.releaseCallback = _dragToolbox;
				toolBar.x = 80; toolBar.y = 15;
				CameraFocusCtrl.instance.enable();
				onMapAlter.add( hud.mapAltered );
				_mouseClip.gotoAndStop( 1 ); _mouseClip.mouseEnabled = false;
			}
			
			{// edit overlay
				// ---
				_edit_overlay.name = 'edit overlay';
				_edit_overlay.tabChildren = false;
				_edit_overlay.addChild( _edit_overlayCanvas = new Shape );
				_edit_overlay.addEventListener( MouseEvent.CLICK, _editClick, false, 0, true );
				_edit_overlay.addEventListener( MouseEvent.MOUSE_DOWN, _editMd, false, 0, true );
				//_edit_overlay.addEventListener( MouseEvent.MOUSE_UP, _editMu, false, 0, true );
				
				for each( k in ['btnTrash', 'btnRotate', 'btnUnTool', 'btnAddTool', 'btnCopy', 'btnLink', 'btnUnlink', 'btnPrimeBall'] ) {
					_edit_overlay.addChild( this['_edit_'+k] = PuttBase2.assets.createDisplayObject('screen.editor.'+k) );
					this['_edit_'+k].visible = false; this['_edit_'+k].name = k +'(edit)';
				}
				_edit_overlayCanvas.x = HudGame.HUD_WIDTH;
			}
			
			{// world overlay
				// ---
				_world_canvas.name = 'world canvas';
				_world_canvas.x = HudGame.HUD_WIDTH;
				//_world_canvas.mouseEnabled = false;
				_world_canvas.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
				_world_canvas.addEventListener( MouseEvent.MOUSE_DOWN, _md, false, 0, true );
				//_world_canvas.addEventListener( MouseEvent.MOUSE_UP, _mu, false, 0, true );
				
				_world_canvas.addChild( _test_btnTrash = PuttBase2.assets.createDisplayObject('screen.editor.btnTrash') as SimpleButton );
				_world_canvas.addChild( _test_btnRotate = PuttBase2.assets.createDisplayObject('screen.editor.btnRotate') as SimpleButton );
				_test_btnTrash.name = 'btnTrash (test)';
				_test_btnRotate.name = 'btnRotate (test)';
				_test_btnTrash.visible = _test_btnRotate.visible = false;
			}
			
			{// auto save
				_timer2 = new Timer( 8000, 1 );
				_timer2.addEventListener( TimerEvent.TIMER, _autoSave, false, 0, true );
				//_timer2.start();
				onMapAlter.add( _mapAltered );
				
				_overlay.addChild( _clipSaved = new Sprite );
				_clipSaved.addChild( txf = UIFactory.createFixedTextField(L10n.t('..saved'), 'hudASave', 'left', 0, 0) );
				with ( _clipSaved ) {
					name = 'saved';
					graphics.beginFill( 0xffff00, .3 );
					graphics.drawRoundRect( 0, 0, txf.width, txf.height, 4, 4 );
					x = PuttBase2.STAGE_WIDTH -_clipSaved.width -5;
					y = PuttBase2.STAGE_HEIGHT -_clipSaved.height -5;
					visible = mouseEnabled = mouseChildren = false;
				}
			}
			
			{// start session
				var r:Number = (MathUtils.randomNumber(10, 80) +90*MathUtils.randomInt(0, 3)) *Trigo.DEG_TO_RAD;
				session.sun_angle.Set( Math.cos(r), Math.sin(r) );
				session.sun_length = MathUtils.randomNumber( Registry.tileSize/4, Registry.tileSize );
				session.sun_strength = MathUtils.randomNumber( .1, .25 );
				if ( session.map && !session.map.isLoaded ) {
					_isImporting = true;
					
				} else {
					session.map = new MapData( new XML('<level hash="" group="0" name="unnamed"><map></map><par>0</par><item>0</item><extra>0</extra></level>') );
					session.map.loaded();
					session.create( session.cols, session.rows, _world_canvas, PuttBase2.STAGE_WIDTH -HudGame.HUD_WIDTH, PuttBase2.STAGE_HEIGHT );
					session.start();
					
					session.onPutt.add( _autoSave );
					session.world.signalResize.add( _initEditOverlay );
					_initEditOverlay();
					_initWorldCanvas();
					
					GameAudio.instance.stopMusic();
					GameAudio.instance.playAmbience( 3000 );
				}
				toolBar.selectTile( 'wall_sq' );
			}
			
		}
		
		override public function dispose():void 
		{
			_edit_overlay.removeEventListener( MouseEvent.CLICK, _editClick );
			_edit_overlay.removeEventListener( MouseEvent.MOUSE_DOWN, _editMd );
			_world_canvas.removeEventListener( MouseEvent.CLICK, _click );
			_world_canvas.removeEventListener( MouseEvent.MOUSE_DOWN, _md );
			_timer2.removeEventListener( TimerEvent.TIMER, _autoSave );
			
			super.dispose();
			
			onModeChange.removeAll();
			onMapAlter.removeAll();
			
			hud.dispose(); hud = null;
			hudAudio.dispose(); hudAudio = null;
			toolBar.dispose(); toolBar = null;
			
			Window.disposeAllWindows();
		}
		
		
		override public function update():void 
		{
			if ( ! Session.instance.world ) return;
			
			toolBar.update();
			hud.update();
			BallCtrl.instance.update();
			
			if ( Session.isRunning )
				_process();
			
			if ( _clipSaved.visible ) {
				var t:uint = getTimer() -_lastSave;
				if ( t < 5000 )
					_clipSaved.alpha = Quint.easeIn( t, 1, -1, 5000 );
				else
					_clipSaved.visible = false;
			}
			
			var input:UserInput = UserInput.instance;
			
			//if ( input.isFocusLost )
				//__mu();
			DOutput.show( 'tile:', _mtx, _mty );
			
			if ( CONFIG::debug && input.isKeyPressed(KeyCode.ZERO) )
				Session.instance.toggleDebug();
		}
		
		
		public function simulate():void
		{
			editMode = false;
			hud.restart();
			
			_process = _updateSimulator;
			_edit_overlay.visible = false;
			_dragBounds.activate();
			
			onModeChange.dispatch();
			
			grid.render.setVisible( false );
		}
		
		public function edit():void
		{
			editMode = true;
			hud.restart();
			//Session.instance.reset( false, true );
			
			/*var tile:b2EntityTile, tileMap:Vector.<Vector.<b2EntityTile>> = Session.instance.tileMap;
			for each ( var list:Vector.<b2EntityTile> in tileMap )
				for each ( tile in list )
					if ( tile ) tile.useDefault();*/
			
			_process = _updateEditor;
			_edit_overlay.visible = true;
			_dragBounds.deactivate();
			
			onModeChange.dispatch();
			grid.render.setVisible( true );
		}
		
		
			// -- private --
			
			// layers
			private var _world_canvas:Sprite
			private var _edit_overlay:Sprite, _edit_overlayCanvas:Shape
			private var _overlay:Sprite, _test_overlay:Sprite
			
			// global variables
			private var _mtx:int, _mty:int, _ptx:int, _pty:int
			private var _process:Function = _updateEditor
			private var _isImporting:Boolean
			
			// editing variables
			private var _tempMap:Vector.<b2EntityTile>
			private var _tileMap:Vector.<Vector.<b2EntityTile>>
			private var _tileType:String, _tileAngle:Number
			private var _isTileAdd:Boolean, _isTileTrashing:Boolean, _isTileLinking:Boolean
			
			// drag/link variables
			private var _dragTile:b2EntityTile, _dragBmp:Bitmap, _dragFrToolbox:Boolean, _dragBounds:DragBounds, _dragLastX:int, _dragLastY:int, _dragTime:uint, _dragDrop:Boolean
			private var _linkTile:b2EntityTile, _linkTileValid:Boolean
			
			// edit overlay buttons
			private var _edit_btnTrash:SimpleButton, _edit_btnRotate:SimpleButton, _edit_btnCopy:SimpleButton, _edit_btnPrimeBall:SimpleButton,
				_edit_btnAddTool:SimpleButton, _edit_btnUnTool:SimpleButton, _edit_btnLink:SimpleButton, _edit_btnUnlink:SimpleButton, _mouseClip:MovieClip
			
			// world canvas buttons
			private var _test_btnTrash:SimpleButton, _test_btnRotate:SimpleButton
			private var _ctrlbar:Sprite
			private var _ctrl_testBtn:Sprite, _ctrl_editBtn:Sprite, _ctrl_resetBtn:Sprite, _ctrl_tileBtn:Sprite, _ctrl_exportBtn:Sprite, _ctrl_importBtn:Sprite
			private var _ctrl_tileBtn_bmp:BitmapData, _ctrl_tileBox:Sprite
			
			// auto save
			private var _timer2:Timer, _lastSave:uint, _alterTime:uint, _clipSaved:Sprite
			
			
			//{ -- initializations
			private function _initEditOverlay( W:uint=0, H:uint=0 ):void
			{
				var g:Graphics = _edit_overlay.graphics;
				g.clear();
				g.beginFill( 0, 0 );
				g.drawRect( 0, 0, Session.instance.width, Session.instance.height );
				g.endFill();
				
				// get reference to session tile map
				_tileMap = Session.instance.tileMap;
				_tempMap = new Vector.<b2EntityTile>;
				Session.instance.onReset.add( _onSessionReset );
			}
			
			private function _initWorldCanvas():void
			{
				hud.clean();
				
				_dragBounds = Session.factory.spawnEntity('drag_bounds') as DragBounds;
				_dragBounds.deactivate();
				_dragBounds.onHasContact.add( _dragBoundsHasContact );
				/*Session.instance.onEntityMoveStart.add( _dragBounds.deactivate );
				Session.instance.onEntitiesMoveStop.add( _dragBounds.activate );*/
				grid = Session.factory.spawnEntity('grid') as Grid;
			}
			
			private function _onSessionReset():void
			{
				_tempMap.splice( 0, _tempMap.length );
			}
			//}
			
			
			//{ -- global process loops
			private function _updateEditor():void
			{
				if ( !Session.isRunning || Session.isBusy ) return;
				
				var input:UserInput = UserInput.instance, camEdge:Vector2D = Session.world.camera.bounds.min;
				var ts:Number = Registry.tileSize, ts2:Number = ts / 2;
				var mx:uint, my:uint, validTile:Boolean, tile:b2EntityTile, g:Graphics;
				_mtx = Math.floor( (_world_canvas.mouseX +camEdge.x) /ts -.5 );
				_mty = Math.floor( (_world_canvas.mouseY +camEdge.y) /ts -.5 );
				
				var dirty:Boolean = _mtx != _ptx || _mty != _pty;
				_ptx = _mtx; _pty = _mty;
				
				if ( input.isMouseReleased && _dragTile && _world_canvas.mouseX < 0 )
					if ( _dragTile.isToolkit && hud.storeTool(_dragTile as b2EntityTileTool) ) {
						if ( _dragTile.defTileX>-1 && _dragTile.defTileY>-1 )
							_tileMap[ _dragTile.defTileX ][ _dragTile.defTileY ] = null;
						Session.world.disposeEntity( _dragTile );
						_dragTile = null;
						_dragBmp.visible = false;
						_mouseClip.gotoAndStop( 1 );
					}
				
				
				if ( _dragTile ) {
					var inRange:Boolean = _world_canvas.mouseX >= 0; //Session.world.camera.bounds.isContaining( _world_canvas.mouseX, _world_canvas.mouseY );
					var dx:Number = !inRange? _overlay.mouseX -_dragBmp.x -15: (ts*(_mtx+.5) -camEdge.x -_dragBmp.x +1 +HudGame.HUD_WIDTH); _dragBmp.x += Math.abs(dx)>.1? dx/8: dx;
					var dy:Number = !inRange? _overlay.mouseY -_dragBmp.y -15: (ts*(_mty+.5) -camEdge.y -_dragBmp.y +1); _dragBmp.y += Math.abs(dy)>.1? dy/8: dy;
					if ( dirty ) {
						if ( _mtx >= 0 && _mty >= 0 && _mtx < Session.instance.cols && _mty < Session.instance.rows && (_tileMap[_mtx][_mty] == undefined || _tileMap[_mtx][_mty] == _dragTile) ) {
							// check push button requirements
							if ( _dragTile is PushButton || _dragTile is Puncher2 || _dragTile is WallGate ) {
								var requireSide:uint;
								
								// check left
								if ( _mtx > 0 ) {
									tile = _tileMap[_mtx-1][_mty];
									if ( tile != null && tile is ISolidWall && tile.shapeName == 'sq' )
										requireSide |= 1;
								} else requireSide |= 1;
								
								// check right
								if ( _mtx+1 < _tileMap.length ) {
									tile = _tileMap[_mtx+1][_mty];
									if ( tile != null && tile is ISolidWall && tile.shapeName == 'sq' )
										requireSide |= 2;
								} else requireSide |= 2;
								
								// check above
								if ( _mty > 0 ) {
									tile = _tileMap[_mtx][_mty-1];
									if ( tile != null && tile is ISolidWall && tile.shapeName == 'sq' )
										requireSide |= 4;
								} else requireSide |= 4;
								
								// check below
								if ( _mty+1 < _tileMap[0].length ) {
									tile = _tileMap[_mtx][_mty+1];
									if ( tile != null && tile is ISolidWall && tile.shapeName == 'sq' )
										requireSide |= 8;
								} else requireSide |= 8;
								
								if ( !requireSide ) {
									_dragBmp.alpha = .5;
									_mouseClip.gotoAndStop( 32 );
								} else {
									_dragBmp.alpha = 1;
									_mouseClip.gotoAndStop( 2 );
								}
								
							} else {
								_dragBmp.alpha = 1;
								_mouseClip.gotoAndStop( 2 );
							}
							
						} else {
							_dragBmp.alpha = .5;
							_mouseClip.gotoAndStop( 3 );
						}
					}
					if ( input.isMouseReleased || input.isFocusLost )
						_dragEnd();
					
					_mouseClip.x = _overlay.mouseX;
					_mouseClip.y = _overlay.mouseY;
					
				} else
				if ( _linkTile ) {
					if ( input.isMouseReleased || input.isFocusLost ) {
						tile = _tileMap[_mtx][_mty] as b2EntityTile;
						if ( _linkTileValid && tile != _linkTile ) {
							if ( tile is Ib2SignalNode && _linkTile is Ib2SignalRelay )
								Ib2SignalNode( tile ).relayTo( _linkTile as Ib2SignalRelay );
							else if ( tile is Ib2SignalRelay && _linkTile is Ib2SignalNode )
								Ib2SignalNode( _linkTile ).relayTo( tile as Ib2SignalRelay );
							_drawLinks( tile );
						}
						_edit_overlayCanvas.graphics.clear();
						_linkTile = null; _linkTileValid = false;
						_ptx = _pty = -1;
						
					} else
					if ( dirty ) {
						g = _edit_overlayCanvas.graphics;
						g.clear();
						g.lineStyle( 1, 0xffffff );
						validTile = _mtx >= 0 && _mty >= 0 && _mtx < Session.instance.cols && _mty < Session.instance.rows && _tileMap[_mtx][_mty] != undefined;
						_linkTileValid = false;
						
						if ( validTile ) {
							if ( _linkTile != _tileMap[_mtx][_mty] ) {
								tile = _tileMap[_mtx][_mty] as b2EntityTile;
								
								if ( (_linkTile is Ib2SignalRelay && tile is Ib2SignalTransmitter) || 
											(_linkTile is Ib2SignalReceiver && tile is Ib2SignalRelay) || 
											(_linkTile is Ib2SignalRelay && tile is Ib2SignalReceiver) || 
											(_linkTile is Ib2SignalTransmitter && tile is Ib2SignalRelay) ) {
									
									g.moveTo( _linkTile.p.x -HudGame.HUD_WIDTH, _linkTile.p.y );
									g.lineTo( tile.p.x -HudGame.HUD_WIDTH, tile.p.y );
									
									g.beginFill( 0xffff00 ); g.drawCircle( tile.p.x -HudGame.HUD_WIDTH, tile.p.y, 4 ); g.endFill();
									_linkTileValid = true;
									
								} else {
									g.moveTo( _linkTile.p.x -HudGame.HUD_WIDTH, _linkTile.p.y );
									g.lineTo( tile.p.x -HudGame.HUD_WIDTH, tile.p.y );
									g.beginFill( 0xff3300 ); g.drawCircle( tile.p.x -HudGame.HUD_WIDTH, tile.p.y, 4 ); g.endFill();
								}
							}
						} else {
							g.moveTo( _linkTile.p.x -HudGame.HUD_WIDTH, _linkTile.p.y );
							g.lineTo( (_mtx+1)*ts -HudGame.HUD_WIDTH, (_mty+1)*ts );
							g.beginFill( 0xff3300 ); g.drawCircle( (_mtx+1)*ts -HudGame.HUD_WIDTH, (_mty+1)*ts, 4 ); g.endFill();
						}
						
					}
					
				} else
				if ( dirty ) {
					validTile = _mtx >= 0 && _mty >= 0 && _mtx < Session.instance.cols && _mty < Session.instance.rows;
					for each( var b:SimpleButton in [_edit_btnTrash, _edit_btnRotate, _edit_btnCopy, _edit_btnLink, _edit_btnUnlink, _edit_btnUnTool, _edit_btnAddTool, _edit_btnPrimeBall] )
						b.visible = false;
					
					g = _edit_overlayCanvas.graphics;
					g.clear();
					
					if ( input.isMouseDown ) {
						if ( validTile ) {
							if ( _isTileTrashing  )
								_trashTile();
							else if ( _isTileAdd )
								_addTile();
						}
					} else 
					if ( validTile ) {
						mx = (_mtx +1)*ts; my = (_mty +1) *ts;
						tile = _tileMap[_mtx][_mty];
						var isRequired:Boolean
						
						if ( tile is ISolidWall && tile.shapeName == 'sq' )
							if ( (_mtx>0 && _tileMap[_mtx-1][_mty] != undefined && _tileMap[_mtx-1][_mty].requiresTile == tile) ||
								(_mtx+1 < _tileMap.length && _tileMap[_mtx+1][_mty] != undefined && _tileMap[_mtx+1][_mty].requiresTile == tile) ||
								(_mty>0 && _tileMap[_mtx][_mty-1] != undefined && _tileMap[_mtx][_mty-1].requiresTile == tile) ||
								(_mty+1 < _tileMap[0].length && _tileMap[_mtx][_mty+1] != undefined && _tileMap[_mtx][_mty+1].requiresTile == tile) )
									isRequired = true;
						
						if ( tile ) {
							if ( ! isRequired ) {
								if ( Tile.TILE_NONROTATES.indexOf(tile.type) == -1 ) {
									_edit_btnRotate.x = mx +TILE_BTN_OFF; _edit_btnRotate.y = my +TILE_BTN_OFF;
									_edit_btnRotate.visible = true;
								}
								
								_edit_btnTrash.x = mx -TILE_BTN_OFF; _edit_btnTrash.y = my -TILE_BTN_OFF;
								_edit_btnTrash.visible = true;
								
								if ( Tile.TILE_TOOLKITS.indexOf(tile.type) != -1 && tile is b2EntityTileTool ) {
									_edit_btnAddTool.x = _edit_btnUnTool.x = mx -TILE_BTN_OFF;
									_edit_btnAddTool.y = _edit_btnUnTool.y = my +TILE_BTN_OFF;
									
									if ( tile.isToolkit )
										_edit_btnUnTool.visible = true;
									else
										_edit_btnAddTool.visible = true;
									
									if ( tile.type == 'golfball' ) {
										if ( !BallCtrl.instance.isPrimary(tile) ) {
											_edit_btnPrimeBall.x = mx +TILE_BTN_OFF; _edit_btnPrimeBall.y = my +TILE_BTN_OFF;
											_edit_btnPrimeBall.visible = true;
										} else
											_edit_btnUnTool.visible = _edit_btnAddTool.visible = false;
									}
									
								}
							}
							if ( toolBar.tileType != tile.type || toolBar.tileAngle != tile.defRa ) {
								_edit_btnCopy.x = mx +TILE_BTN_OFF; _edit_btnCopy.y = my -TILE_BTN_OFF;
								_edit_btnCopy.visible = true;
							}
							
							if ( tile is Ib2SignalNode || tile is Ib2SignalRelay ) {
								_edit_btnLink.x = mx -TILE_BTN_OFF; _edit_btnLink.y = my +TILE_BTN_OFF;
								_edit_btnUnlink.y = mx; _edit_btnUnlink.y = my +TILE_BTN_OFF;
								_edit_btnLink.visible = true;
								
								if ( tile is Ib2SignalNode )
									_edit_btnUnlink.visible = Ib2SignalNode( tile ).getRelay() as Boolean;
								
								_drawLinks( tile );
							} else
							if ( tile is Portal && Portal(tile).isLinked ) {
								_drawLinks( tile );
							}
							
						}
					}
					
				}
				
				if ( input.isMouseReleased || input.isFocusLost )
					_isTileAdd = _isTileTrashing = _isTileLinking = false;
				
				with( Session.world.camera.bounds.min ) {
					_edit_overlay.x = -x +HudGame.HUD_WIDTH;
					_edit_overlay.y = -y;
				}
			}
			
			private function _updateSimulator():void
			{
				if ( Session.instance.movingEntitiesCount > 0 || Session.isBusy ) return;
				
				var tile:b2EntityTile, input:UserInput = UserInput.instance, camEdge:Vector2D = Session.world.camera.bounds.min;;
				var ts:Number = Registry.tileSize, ts2:Number = ts /2;
				
				_mtx = Math.floor( (_world_canvas.mouseX +camEdge.x) /ts -.5 );
				_mty = Math.floor( (_world_canvas.mouseY +camEdge.y) /ts -.5 );
				
				var dirty:Boolean = _mtx != _ptx || _mty != _pty;
				_ptx = _mtx; _pty = _mty;
				
				if ( dirty && _dragBounds.isActive ) {
					_dragBounds.deactivate();
					_dragBounds.filterTile = null;
				}
				
				if ( input.isMouseReleased && _dragTile && _world_canvas.mouseX < 0 )
					if ( _dragTile.isToolkit && hud.storeTool(_dragTile as b2EntityTileTool) ) {
						if ( _dragTile.defTileX>-1 && _dragTile.defTileY>-1 )
							_tileMap[ _dragTile.defTileX ][ _dragTile.defTileY ] = null;
						Session.world.disposeEntity( _dragTile );
						_dragTile = null;
						_dragBmp.visible = false;
						grid.render.setVisible( false );
						_mouseClip.gotoAndStop( 1 );
					}
				
				
				if ( _dragTile ) {
					var inRange:Boolean = _world_canvas.mouseX >= 0;
					var dx:Number = !inRange? _overlay.mouseX -_dragBmp.x -_dragBmp.width/2: (ts*(_mtx+.5) -camEdge.x -_dragBmp.x +1 +HudGame.HUD_WIDTH); _dragBmp.x += Math.abs(dx)>.1? dx/8: dx;
					var dy:Number = !inRange? _overlay.mouseY -_dragBmp.y -_dragBmp.height/2: (ts*(_mty+.5) -camEdge.y -_dragBmp.y +1); _dragBmp.y += Math.abs(dy)>.1? dy/8: dy;
					if ( dirty ) {
						_dragBounds.activate();
						_dragBounds.setDefault( (_mtx +1)*ts, (_mty +1)*ts );
						
						if ( _mtx >= 0 && _mty >= 0 && _mtx < Session.instance.cols && _mty < Session.instance.rows && !_dragBounds.contactsCount && (_tileMap[_mtx][_mty] == undefined || _tileMap[_mtx][_mty] == _dragTile || (_dragTile.isToolkit && _tileMap[_mtx][_mty] && _tileMap[_mtx][_mty].wasMoved)) ) {
							_dragBmp.alpha = 1
							_mouseClip.gotoAndStop( 2 );
						} else {
							_dragBmp.alpha = .5;
							_mouseClip.gotoAndStop( 3 );
						}
					} else if ( _dragDrop ) {
						_dragEnd();
						_dragDrop = false;
					}
					if ( _dragBounds.contactsCount && _mouseClip.currentFrame==2 ) {
						_dragBmp.alpha = .5;
						_mouseClip.gotoAndStop( 3 );
					}
					if ( input.isMouseReleased || input.isFocusLost )
						_dragDrop	= true;
					//_dragEnd();
					
					_mouseClip.x = _overlay.mouseX;
					_mouseClip.y = _overlay.mouseY;
					
				} else
				if ( dirty && !input.isMouseDown ) {
					_test_btnTrash.visible = _test_btnRotate.visible = false;
					if ( _mtx >= 0 && _mty >= 0 && _mtx < Session.instance.cols && _mty < Session.instance.rows && _tileMap[_mtx][_mty] != undefined ) {
						tile = _tileMap[_mtx][_mty];
						if ( tile && tile.wasMoved )
							for ( var k:String in _tempMap )
								if ( _tempMap[k].defTileX == _mtx && _tempMap[k].defTileY == _mty && !_tempMap[k].wasMoved ) {
									tile = _tempMap[k]; break;
								}
						
						if ( tile && tile.isToolkit && !tile.wasMoved ) {
							var mx:uint = (_mtx +1) *ts -camEdge.x, my:uint = (_mty +1) *ts -camEdge.y;
							_dragBounds.activate();
							_dragBounds.setDefault( (_mtx +1)*ts, (_mty +1)*ts );
							_dragBounds.filterTile = tile;
							
							if ( Tile.TILE_NONROTATES.indexOf(tile.type) == -1 ) {
								_test_btnRotate.x = mx +TILE_BTN_OFF; _test_btnRotate.y = my +TILE_BTN_OFF;
								_test_btnRotate.visible = true;
							}
							
							_test_btnTrash.x = mx -TILE_BTN_OFF; _test_btnTrash.y = my -TILE_BTN_OFF;
							_test_btnTrash.visible = true;
						}
					}
					
				}
				
			}
			//}
			
			
			//{ -- click/drag actions
			private function _addTile( e:Event = null ):void
			{
				var tile:b2EntityTile, tileClass:Class, radian:Number, requireSide:uint = 0;
				// refresh mouseover values
				_ptx = -1; _pty = -1;
				
				if ( _mtx < 0 || _mty < 0 || _mtx > Session.instance.cols || _mty > Session.instance.rows ) return;
				if ( _isTileTrashing || _isTileLinking ) return;
				
				// H4X for floor texture
				if ( toolBar.tileType.substr(0, 6) == 'floor_' ) {
					var i:int
					switch( toolBar.tileType ) {
						case 'floor_normal': i = 0; break;
						case 'floor_water': i = 1; break;
						case 'floor_sand': i = 2; break;
						case 'floor_carpet': i = 3; break;
					}
					if ( _tileMap[_mtx][_mty] is Hole || _tileMap[_mtx][_mty] is Portal ) {
						GameSounds.play( GameAudio.BUZZ );
						return;
					}
					Session.instance.floor.setTexture( _mtx, _mty, i );
					onMapAlter.dispatch();
					return;
				}
				
				if ( _tileMap[_mtx][_mty] != undefined ) return;
				
				radian = toolBar.tileAngle;
				tileClass = Session.factory.getEntityArguments(toolBar.tileType).customClass;
				// check push button requirements
				if ( tileClass == PushButton || tileClass == Puncher2 || tileClass == WallGate ) {
					
					// check left
					if ( _mtx > 0 ) {
						tile = _tileMap[_mtx-1][_mty];
						if ( tile != null && tile is ISolidWall && tile.shapeName == 'sq' )
							requireSide |= 1;
					} else
						requireSide |= 1;
					
					// check right
					if ( _mtx+1 < _tileMap.length ) {
						tile = _tileMap[_mtx+1][_mty];
						if ( tile != null && tile is ISolidWall && tile.shapeName == 'sq' )
							requireSide |= 2;
					} else
						requireSide |= 2;
					
					// check above
					if ( _mty > 0 ) {
						tile = _tileMap[_mtx][_mty-1];
						if ( tile != null && tile is ISolidWall && tile.shapeName == 'sq' )
							requireSide |= 4;
					} else
						requireSide |= 4;
					
					// check below
					if ( _mty+1 < _tileMap[0].length ) {
						tile = _tileMap[_mtx][_mty+1];
						if ( tile != null && tile is ISolidWall && tile.shapeName == 'sq' )
							requireSide |= 8;
					} else
						requireSide |= 8;
					
					if ( !requireSide ) { GameSounds.play( GameAudio.BUZZ ); return; }
					else if ( requireSide & 1 ) { radian = 0; }
					else if ( requireSide & 2 ) { radian = Math.PI; }
					else if ( requireSide & 4 ) { radian = Trigo.HALF_PI; }
					else if ( requireSide & 8 ) { radian = Math.PI +Trigo.HALF_PI; }
				}
				
				if ( ! toolBar.requestTile(toolBar.tileType) ) { 
					onTileAddLimit.dispatch( toolBar.tileType );
					GameSounds.play( GameAudio.BUZZ );
					return;
				}
				
				_tileMap[_mtx][_mty] = tile = Session.factory.spawnEntity( toolBar.tileType ) as b2EntityTile;
				tile.setDefault( (_mtx +1) *Registry.tileSize, (_mty +1) *Registry.tileSize, radian );
				
				if ( tileClass == PushButton || tileClass == Puncher2 || tileClass == WallGate ) {
					if ( _mtx>0 && requireSide & 1 ) tile.requiresTile = _tileMap[_mtx-1][_mty];
					else if ( _mtx+1 < _tileMap.length && requireSide & 2 ) tile.requiresTile = _tileMap[_mtx+1][_mty];
					else if ( _mty>0 && requireSide & 4 ) tile.requiresTile = _tileMap[_mtx][_mty-1];
					else if ( _mty+1 < _tileMap[0].length && requireSide & 8 ) tile.requiresTile = _tileMap[_mtx][_mty+1];
				}
				
				tile.onDispose.addOnce( toolBar.returnTileWgt );
				
				if ( UserInput.instance.isKeyDown(KeyCode.SHIFT) && Tile.TILE_TOOLKITS.indexOf(tile.type) > -1 )
					hud.addTile( tile );
				
				if ( !tile.isToolkit )
					onMapAlter.dispatch();
				
				if ( tile.type == 'golfball' && !BallCtrl.instance.getPrimary() )
					BallCtrl.instance.setPrimary( tile as Ball );
				else if ( tile is Portal )
					toolBar.addPortal( tile as Portal );
				
				onTileAdded.dispatch( tile.type );
			}
			
			private function _trashTile( e:Event = null ):void
			{
				// refresh mouseover values
				_ptx = -1; _pty = -1;
				
				var tile:b2EntityTile = _tileMap[_mtx][_mty];
				if ( !tile ) return;
				
				if ( (_mtx>0 && _tileMap[_mtx-1][_mty] != undefined && _tileMap[_mtx-1][_mty].requiresTile == tile) ||
					(_mtx+1 < _tileMap.length && _tileMap[_mtx+1][_mty] != undefined && _tileMap[_mtx+1][_mty].requiresTile == tile) ||
					(_mty>0 && _tileMap[_mtx][_mty-1] != undefined && _tileMap[_mtx][_mty-1].requiresTile == tile) ||
					(_mty+1 < _tileMap[0].length && _tileMap[_mtx][_mty+1] != undefined && _tileMap[_mtx][_mty+1].requiresTile == tile) )
						return;
				
				tile.deactivate();
				if ( tile.render is Ib2TileFaceLinkedRender )
					Ib2TileFaceLinkedRender(tile.render).redrawAndNeighbors();
				Session.world.disposeEntity( tile );
				if ( editMode ) {
					//toolBar.returnTileWgt( tile );
					onMapAlter.dispatch();
				}
				
				_isTileTrashing = true;
				_edit_btnTrash.visible = true;
				_edit_btnTrash.x = (_mtx +1) *Registry.tileSize -12;
				_edit_btnTrash.y = (_mty +1) *Registry.tileSize -12;
				_edit_btnRotate.visible = _edit_btnCopy.visible = _edit_btnLink.visible = _edit_btnPrimeBall.visible = _edit_btnUnTool.visible = _edit_btnAddTool.visible = false;
				_test_btnRotate.visible = _test_btnTrash.visible = false;
				_tileMap[_mtx][_mty] = null;
			}
			//}
			
			
			//{ -- edit mode mouse down/up action
			private function _editClick( e:MouseEvent ):void
			{
				if ( !Session.isRunning || Session.isBusy ) return;
				
				if ( _mtx >= 0 && _mty >= 0 && _mtx < Session.instance.cols && _mty < Session.instance.rows && _tileMap[_mtx][_mty] != undefined ) {
					var p:int, tile:b2EntityTile = _tileMap[_mtx][_mty] as b2EntityTile;
					
					switch( e.target ) {
						case _edit_btnTrash:
							if ( ! editMode ) _trashTile( e ); break;
						case _edit_btnCopy:
							toolBar.selectTile( tile.type, tile.defRa );
							_isTileAdd = true;
							_edit_btnCopy.visible = false;
							break;
						case _edit_btnLink: break;
						case _edit_btnUnlink:
							if ( tile is Ib2SignalNode )
								Ib2SignalNode( tile ).relayTo( null );
							break;
						case _edit_btnUnTool:
							hud.removeTile( tile );
							_edit_btnAddTool.visible = true;
							_edit_btnUnTool.visible = false;
							onMapAlter.dispatch();
							break;
						case _edit_btnAddTool:
							if ( hud.addTile(tile) ) {
								_edit_btnUnTool.visible = true;
								_edit_btnAddTool.visible = false;
								onMapAlter.dispatch();
							}
							break;
						case _edit_btnPrimeBall:
							if ( tile.type == 'golfball' ) {
								BallCtrl.instance.setPrimary( tile as Ball );
								onMapAlter.dispatch();
							}
							//_edit_btnAddTool.visible = false;
							break;
						case _edit_btnRotate:
						default:
							if ( _edit_btnRotate != e.target ) {
								if ( _dragLastX!=_mtx || _dragLastY!=_mty || _dragTime<getTimer() ) break;
								if ( _isTileAdd || Tile.TILE_NONROTATES.indexOf(tile.type) > -1 ) break;
							}
							var requireSide:uint, t2:b2EntityTile;
							// check push button requirements
							if ( tile is PushButton || tile is Puncher2 || tile is WallGate ) {
								
								// check left
								if ( _mtx > 0 ) {
									t2 = _tileMap[_mtx-1][_mty];
									if ( t2 != null && t2 is ISolidWall && t2.shapeName == 'sq' )
										requireSide |= 1;
								} else
									requireSide |= 1;
								
								// check right
								if ( _mtx+1 < _tileMap.length ) {
									t2 = _tileMap[_mtx+1][_mty];
									if ( t2 != null && t2 is ISolidWall && t2.shapeName == 'sq' )
										requireSide |= 2;
								} else
									requireSide |= 2;
								
								// check above
								if ( _mty > 0 ) {
									t2 = _tileMap[_mtx][_mty-1];
									if ( t2 != null && t2 is ISolidWall && t2.shapeName == 'sq' )
										requireSide |= 4;
								} else
									requireSide |= 4;
								
								// check below
								if ( _mty+1 < _tileMap[0].length ) {
									t2 = _tileMap[_mtx][_mty+1];
									if ( t2 != null && t2 is ISolidWall && t2.shapeName == 'sq' )
										requireSide |= 8;
								} else
									requireSide |= 8;
								
								
								if ( !requireSide ) return;
								else {
									var rads:Array = [];
									if ( requireSide & 1 ) rads.push(0);
									if ( requireSide & 4 ) rads.push(Trigo.HALF_PI);
									if ( requireSide & 2 ) rads.push(Math.PI);
									if ( requireSide & 8 ) rads.push(-Trigo.HALF_PI);
									
									tile.setDefault( tile.defPx, tile.defPy, rads[ (rads.indexOf(tile.defRa)+1) %rads.length ] );
									
									if ( tile.defRa == 0 && _mtx>0 ) tile.requiresTile = _tileMap[_mtx-1][_mty];
									else if ( tile.defRa == Trigo.HALF_PI && _mty>0 ) tile.requiresTile = _tileMap[_mtx][_mty-1];
									else if ( tile.defRa == Math.PI && _mtx+1<_tileMap.length ) tile.requiresTile = _tileMap[_mtx+1][_mty];
									else if ( tile.defRa == -Trigo.HALF_PI && _mty+1<_tileMap[0].length ) tile.requiresTile = _tileMap[_mtx][_mty+1];
								}
								
							}
							else {
								tile.setDefault( tile.defPx, tile.defPy, tile.defRa +Trigo.HALF_PI );
								_edit_btnCopy.x = (_mtx +1) * Registry.tileSize +TILE_BTN_OFF;
								_edit_btnCopy.y = (_mty +1) *Registry.tileSize -TILE_BTN_OFF;
								_edit_btnCopy.visible = true;
							}
						break;
					}
					
				}
			}
			private function _editMd( e:MouseEvent ):void
			{
				if ( !Session.isRunning || Session.isBusy ) return;
				
				if ( _mtx >= 0 && _mty >= 0 && _mtx < Session.instance.cols && _mty < Session.instance.rows && _tileMap[_mtx][_mty] != undefined ) {
					var p:int, tile:b2EntityTile = _tileMap[_mtx][_mty] as b2EntityTile;
					
					switch( e.target ) {
						case _edit_btnTrash:
							if ( editMode ) _trashTile( e ); break;
						case _edit_btnCopy: break;
						case _edit_btnRotate: break;
						case _edit_btnLink:
							_linkTile = tile;
							_isTileLinking = true;
							break;
						case _edit_btnUnlink: break;
						case _edit_btnUnTool: break;
						case _edit_btnAddTool: break;
						case _edit_btnPrimeBall: break;
					default:
							if ( e.currentTarget == _edit_overlay ) {
								if ( toolBar.tileType.substr(0, 6) == 'floor_' && UserInput.instance.isKeyDown(KeyCode.SHIFT) ) {
									_isTileAdd = true;
									_ptx = -1; _pty = -1;
									
								} else {
									if ( !_isTileAdd ) _dragStart( tile );
									_edit_overlayCanvas.graphics.clear();
								}
							}
							break;
					}
					
				} else 
				if ( e.target == _edit_overlay ) {
					_isTileAdd = true;
					// force update
					_ptx = -1; _pty = -1;
				}
			}
			private function _editMu( e:MouseEvent ):void
			{
				
			}
			//}
			
			
			//{ -- world canvas mouse down/up action
			private function _click( e:MouseEvent ):void
			{
				if ( !Session.isRunning || Session.isBusy ) return;
				if ( !Session.world || Session.instance.movingEntitiesCount > 0 ) return;
				
				if ( _mtx >= 0 && _mty >= 0 && _mtx < Session.instance.cols && _mty < Session.instance.rows && _tileMap[_mtx][_mty] != undefined ) {
					var tile:b2EntityTile = _tileMap[_mtx][_mty] as b2EntityTile;
					if ( tile.wasMoved )
						for ( var k:String in _tempMap )
							if ( _tempMap[k].defTileX == _mtx && _tempMap[k].defTileY == _mty && !_tempMap[k].wasMoved && !_tempMap[k].isDisposed() ) {
								tile = _tempMap[k]; break;
							}
					
					if ( tile.isToolkit && !tile.wasMoved )
						switch ( e.target ) {
							case _test_btnTrash:
								if ( hud.storeTool(tile as b2EntityTileTool) ) {
									_tileMap[ tile.defTileX ][ tile.defTileY ] = null;
									Session.world.disposeEntity( tile );
									tile.deactivate();
									var p:int = _tempMap.indexOf( tile );
									if ( p > -1 ) _tempMap.splice( p, 1 );
								}
								_test_btnTrash.visible = _test_btnRotate.visible = false;
								break;
							case _test_btnRotate:
							default:
								if ( e.target==_test_btnRotate || (!_dragBounds.contactsCount && _dragLastX==_mtx && _dragLastY==_mty && _dragTime>getTimer() && Tile.TILE_NONROTATES.indexOf(tile.type)==-1) )
									tile.setDefault( tile.defPx, tile.defPy, tile.defRa +Trigo.HALF_PI );
								break;
						}
				}
				
			}
			private function _md( e:MouseEvent ):void
			{
				if ( !Session.isRunning || Session.isBusy ) return;
				if ( !Session.world || Session.instance.movingEntitiesCount > 0 ) return;
				
				if ( _mtx >= 0 && _mty >= 0 && _mtx < Session.instance.cols && _mty < Session.instance.rows && _tileMap[_mtx][_mty] != undefined ) {
					var tile:b2EntityTile = _tileMap[_mtx][_mty] as b2EntityTile;
					if ( tile.wasMoved )
						for ( var k:String in _tempMap )
							if ( _tempMap[k].defTileX == _mtx && _tempMap[k].defTileY == _mty && !_tempMap[k].wasMoved && !_tempMap[k].isDisposed() ) {
								tile = _tempMap[k]; break;
							}
					if ( tile.isToolkit && tile is b2EntityTileTool )
						switch ( e.target ) {
							case _test_btnTrash: break;
							case _test_btnRotate: break;
							default: if ( e.target == _world_canvas && tile.isToolkit && !tile.wasMoved ) _dragStart( tile ); break;
						}
				}
				
			}
			private function _mu( e:MouseEvent ):void
			{
				
			}
			//}
			
			
			//{ -- import callbacks
			pb2internal function _importInit( cols:int, rows:int ):void
			{
				var r:Number = (MathUtils.randomNumber(5, 85) +MathUtils.randomInt(0,3)*90) *Trigo.DEG_TO_RAD;
				var ses:Session = Session.instance;
				
				ses.sun_angle.Set( FastMath.cos(r), FastMath.sin(r) );
				ses.sun_length = MathUtils.randomInt( 19, 50 );
				
				/*ses.sun_angle.Set( Trigo.VEC2_60_DEG.x, Trigo.VEC2_60_DEG.y );
				ses.sun_length = 38;
				ses.sun_strength = .2;*/
				
				ses.create( cols, rows, _world_canvas, PuttBase2.STAGE_WIDTH -HudGame.HUD_WIDTH, PuttBase2.STAGE_HEIGHT );
				ses.start();
				_initEditOverlay();
				_initWorldCanvas();
				
				/*var sp:Sprite;
				ses.ground.gndRender.clip.addChild( sp = PuttBase2.assets.createDisplayObject('screen.ui.bg.titleShade') as Sprite );
				sp.x = sp.y = 18;*/
			}
			
			pb2internal function _importComplete():void
			{
				_isImporting = false;
				
				trace( 'import complete [' + Session.instance.map.name +']' );
				Session.instance.map.loaded();
				
				Session.instance.world.signalResize.add( _initEditOverlay );
				Session.instance.onPutt.add( _autoSave );
				
				var map:MapData = Session.instance.map;
				var t:b2EntityTileTool, xml:XML = map.xml;
				if ( xml != null && xml.child('items').length() ) {
					var a:Array = String(xml.items).split(',');
					var j:int = a.length/4 >>0;
					
					for ( var i:int; i < j; i++ ) {
						t = hud.releaseTool( Tile.getTileType(int(a[i * 4])) );
						if ( t ) {
							t.setDefault( (int(a[i*4+1]) +1)*Registry.tileSize, (int(a[i*4+2]) +1)*Registry.tileSize, int(a[i*4+3])*90*Trigo.DEG_TO_RAD );
							Session.instance.tileMap[ t.defTileX ][ t.defTileY ] = t;
						}
					}
				}
				
				_forceEnter();
				_autoSave();
			}
			
			pb2internal function _importError( e:Error ):void
			{
				var ses:Session = Session.instance;
				
				trace( '3:import error ['+ ses.map.name +'] '+ e.name +'['+ e.errorID +']' );
				trace( e.getStackTrace() );
				trace( '3:import error ['+ ses.map.name +'] '+ e.name +'['+ e.errorID +']' );
				
				ses.cols = 14; ses.rows = 8;
				ses.bgColorIdx = MathUtils.randomInt( 0, Ground.COLORS.length-1 );
				ses.map = null;
				changeScreen( RelayScreen, EditorScreen );
			}
			//}
			
			
			//{ -- autosave
			public function _autoSave( e:*=null ):void
			{
				//if ( _alterTime +_timer2.delay*2 > getTimer() )
				if ( Session.instance.tileMap )
					new MapExport( '', hud.getPar(), _autoSaveNow ).start();
			}
			
			private function _autoSaveNow( result:String ):void
			{
				if ( !MapDataMngr.instance.saveEditMap(result, hud.getPar(), hud.totalItems, null, hud.releasedItems) )
					hud.addChild( PopPrompt.create('Please allow proper storage to ensure your maps are saved accordingly.', 130, {name:'OK'}) );
				_clipSaved.visible = true;
				_clipSaved.alpha = 1;
				_lastSave = getTimer();
				onMapSaved.dispatch();
			}
			
			private function _mapAltered():void
			{
				//_alterTime = getTimer();
				_timer2.stop();
				_timer2.start();
			}
			//}
			
			
			//{ -- utils
			private function _dragStart( tile:b2EntityTile ):void
			{
				if ( !_dragFrToolbox ) {
					if ( _mtx>0 && _tileMap[_mtx-1][_mty] != undefined && _tileMap[_mtx-1][_mty].requiresTile == tile )
						return;
					else if ( _mtx+1 < _tileMap.length && _tileMap[_mtx+1][_mty] != undefined && _tileMap[_mtx+1][_mty].requiresTile == tile )
						return;
					else if ( _mty>0 && _tileMap[_mtx][_mty-1] != undefined && _tileMap[_mtx][_mty-1].requiresTile == tile )
						return;
					else if ( _mty+1 < _tileMap[0].length && _tileMap[_mtx][_mty+1] != undefined && _tileMap[_mtx][_mty+1].requiresTile == tile )
						return;
				}
				
				var ts:Number = Registry.tileSize, ts2:Number = ts/2;
				
				var d:DisplayObject = tile.render is IDragBaseDraw ? IDragBaseDraw(tile.render).basedraw() : tile.render.buffer;
				var m:Matrix = d.transform.matrix.clone();
				
				//m.rotate( tile.defRa );
				m.tx = m.ty = 0;
				if ( tile.render is AbstractBmpRender && !(tile.render is IDragBaseDraw) && !(tile.render is Ib2TileFaceLinkedRender) )
					m.translate( AbstractBmpRender(tile.render).bmpOffX, AbstractBmpRender(tile.render).bmpOffY );
				m.translate( ts2, ts2 );
				m.translate( 4, 4 );
				m.scale( .75, .75 );
				
				d.filters = [new GlowFilter(0xffffff,1,4,4,10,1)];
				with ( _dragBmp.bitmapData ) {
					lock();
					fillRect( rect, 0 );
					draw( d, m );
					unlock();
				}
				d.filters = [];
				
				_dragTile = tile;
				_dragFrToolbox = false;
				_dragLastX = tile.defTileX;
				_dragLastY = tile.defTileY;
				_dragTime = getTimer()+500;
				
				_dragBmp.visible = true;
				
				var inRange:Boolean = Session.world.camera.bounds.isContaining( _world_canvas.mouseX, _world_canvas.mouseY );
				_dragBmp.x = !inRange? _overlay.mouseX -15: ts*(_mtx +.5)+1 -Session.world.camera.bounds.min.x +HudGame.HUD_WIDTH;
				_dragBmp.y = !inRange? _overlay.mouseY -15: ts*(_mty +.5)+1 -Session.world.camera.bounds.min.y;
				
				_dragTile.deactivate();
				_dragTile.setDefault( tile.defPx, tile.defPy, tile.defRa );
				//if ( !editMode )
				//	_dragBounds.activate();
				
				for each( var b:SimpleButton in [_edit_btnTrash, _edit_btnRotate, _edit_btnCopy, _edit_btnLink, _edit_btnUnlink, _edit_btnUnTool, _edit_btnAddTool, _edit_btnPrimeBall, _test_btnRotate, _test_btnTrash] )
					b.visible = false;
				grid.render.setVisible( true );
			}
			
			private function _dragEnd():void
			{
				if ( ! _dragTile ) return;
				
				_dragTile.activate();
				
				var inRange:Boolean = _mtx >= 0 && _mty >= 0 && _mtx < Session.instance.cols && _mty < Session.instance.rows;
				
				var tile:b2EntityTile, radian:Number = _dragTile.defRa, requireSide:uint = 0;
				// check push button requirements
				if ( _dragTile is PushButton || _dragTile is Puncher2 || _dragTile is WallGate ) {
					
					// check left
					if ( _mtx > 0 ) {
						tile = _tileMap[_mtx-1][_mty];
						if ( tile != null && tile is ISolidWall && tile.shapeName == 'sq' )
							requireSide |= 1;
					} else
						requireSide |= 1;
					
					// check right
					if ( _mtx+1 < _tileMap.length ) {
						tile = _tileMap[_mtx+1][_mty];
						if ( tile != null && tile is ISolidWall && tile.shapeName == 'sq' )
							requireSide |= 2;
					} else
						requireSide |= 2;
					
					// check above
					if ( _mty > 0 ) {
						tile = _tileMap[_mtx][_mty-1];
						if ( tile != null && tile is ISolidWall && tile.shapeName == 'sq' )
							requireSide |= 4;
					} else
						requireSide |= 4;
					
					// check below
					if ( _mty+1 < _tileMap[0].length ) {
						tile = _tileMap[_mtx][_mty+1];
						if ( tile != null && tile is ISolidWall && tile.shapeName == 'sq' )
							requireSide |= 8;
					} else
						requireSide |= 8;
					
					if ( !requireSide ) inRange = false;
					else if ( requireSide & 1 ) { radian = 0; }
					else if ( requireSide & 2 ) { radian = Math.PI; }
					else if ( requireSide & 4 ) { radian = Trigo.HALF_PI; }
					else if ( requireSide & 8 ) { radian = Math.PI +Trigo.HALF_PI; }
				}
				
				
				if ( inRange && (_tileMap[_mtx][_mty]==undefined || (_tileMap[_mtx][_mty] && _tileMap[_mtx][_mty].wasMoved && _dragTile.isToolkit && !editMode)) && (!_dragBounds.contactsCount || editMode) ) {
					if ( !_dragFrToolbox && _tileMap[_dragTile.defTileX][_dragTile.defTileY] == _dragTile )
						_tileMap[ _dragTile.defTileX ][ _dragTile.defTileY ] = null;
					if ( !_dragTile.isToolkit && (_mtx != _dragTile.defTileX || _mty != _dragTile.defTileY) )
						onMapAlter.dispatch();
					
					if ( _dragTile.isToolkit && _tileMap[_mtx][_mty] ) {
						if ( _tempMap.indexOf(_dragTile) == -1 )
							_tempMap.push( _dragTile );
					} else {
						_tileMap[_mtx][_mty] = _dragTile;
					}
					_dragTile.setDefault( (_mtx +1)*Registry.tileSize, (_mty +1)*Registry.tileSize, radian );
					if ( _dragTile is Hole || _dragTile is Portal )
						Session.instance.floor.setTexture( _mtx, _mty, 0 );
					
					if ( _dragTile is PushButton || _dragTile is Puncher2 || _dragTile is WallGate ) {
						if ( _mtx>0 && requireSide & 1 ) _dragTile.requiresTile = _tileMap[_mtx-1][_mty];
						else if ( _mtx+1 < _tileMap.length && requireSide & 2 ) _dragTile.requiresTile = _tileMap[_mtx+1][_mty];
						else if ( _mty>0 && requireSide & 4 ) _dragTile.requiresTile = _tileMap[_mtx][_mty-1];
						else if ( _mty+1 < _tileMap[0].length && requireSide & 8 ) _dragTile.requiresTile = _tileMap[_mtx][_mty+1];
					}
					
					
				}
				else {
					if ( _dragTile.isToolkit && (!inRange || _tileMap[_mtx][_mty] != _dragTile) ) {
						if ( hud.storeTool(_dragTile as b2EntityTileTool) )
							Session.world.disposeEntity( _dragTile );
					} else
						_dragTile.setDefault( _dragTile.defPx, _dragTile.defPy, _dragTile.defRa );
					
					if ( _mtx != _dragTile.defTileX || _mty != _dragTile.defTileY )
						GameSounds.play( GameAudio.BUZZ );
				}
				
				/*if ( inRange && _tileMap[_mtx][_mty] == undefined && (editMode || !_dragBounds.contactsCount) ) {
					if ( !_dragFrToolbox && _tileMap[_dragTile.defTileX][_dragTile.defTileY] == _dragTile )
						_tileMap[ _dragTile.defTileX ][ _dragTile.defTileY ] = null;
					
					if ( editMode ) {
						//_tileMap[ _mtx ][ _mty ] = _dragTile;
						_dragTile.setDefault( (_mtx +1)*Registry.tileSize, (_mty +1)*Registry.tileSize, _dragTile.defRa );
					} else
					if ( _dragFrToolbox ) {
						_dragTile.setPos( (_mtx +1)*Registry.tileSize, (_mty +1)*Registry.tileSize, _dragTile.defRa );
					}
					
				} else {
					//if ( (!inRange || _tileMap[_mtx][_mty] != _dragTile) && (_dragFrToolbox || !editMode) && _dragTile is b2EntityTileTool ) {
					if ( (!inRange || _tileMap[_mtx][_mty] != _dragTile) && _dragFrToolbox ) {
						hud.storeTool( _dragTile as b2EntityTileTool );
						Session.world.disposeEntity( _dragTile );
						
					} else
						_dragTile.setDefault( _dragTile.defPx, _dragTile.defPy, _dragTile.defRa );
				}*/
				
				_dragTile = null;
				_dragBmp.visible = false;
				_dragLastX = _dragLastY = -1;
				if ( !editMode )
					grid.render.setVisible( false );
				_mouseClip.gotoAndStop( 1 );
				
				//if ( !editMode )
				//	_dragBounds.deactivate();
				
				// refresh mouseover values
				_ptx = -1; _pty = -1;
			}
			
			private function _drawLinks( tile:b2EntityTile, ...ignoreThis ):void
			{
				var g:Graphics = _edit_overlayCanvas.graphics;
				
				if ( tile is Ib2SignalNode ) {
					var relay:b2EntityTile = Ib2SignalNode( tile ).getRelay() as b2EntityTile;
					if ( ! relay ) return;
					
					g.lineStyle( 1, 0xffffff );
					if ( tile is Ib2SignalTransmitter ) {
						g.moveTo( tile.p.x +3 -HudGame.HUD_WIDTH, tile.p.y +3 );
						g.lineTo( relay.p.x -3 -HudGame.HUD_WIDTH, relay.p.y -3 );
						g.beginFill( 0xffff00 );
						g.drawRect( tile.p.x -3+3 -HudGame.HUD_WIDTH, tile.p.y -3+3, 6, 6 );
						g.drawCircle( relay.p.x -3 -HudGame.HUD_WIDTH, relay.p.y -3, 3 );
						g.endFill();
					} else
					if ( tile is Ib2SignalReceiver ) {
						g.moveTo( tile.p.x -3 -HudGame.HUD_WIDTH, tile.p.y -3 );
						g.lineTo( relay.p.x +3 -HudGame.HUD_WIDTH, relay.p.y +3 );
						g.beginFill( 0xffff00 );
						g.drawRect( relay.p.x -3+3 -HudGame.HUD_WIDTH, relay.p.y -3+3, 6, 6 );
						g.drawCircle( tile.p.x -3 -HudGame.HUD_WIDTH, tile.p.y -3, 3 );
						g.endFill();
					}
					
				} else
				if ( tile is Ib2SignalRelay ) {
					Ib2SignalRelay( tile ).receivers.forEach( _drawLinks );
					Ib2SignalRelay( tile ).transmitters.forEach( _drawLinks );
					
				} else
				if ( tile is Portal ) {
					var p1:Portal = tile as Portal;
					var p2:Portal = p1.linkPortal;
					
					g.beginFill( 0xffffff );
					g.drawCircle( p1.p.x -HudGame.HUD_WIDTH, p1.p.y, 5 );
					g.drawCircle( p2.p.x -HudGame.HUD_WIDTH, p2.p.y, 5 );
					g.lineStyle( 1, 0xffffff );
					g.moveTo( p1.p.x -HudGame.HUD_WIDTH, p1.p.y );
					g.lineTo( p2.p.x -HudGame.HUD_WIDTH, p2.p.y );
					g.endFill();
				}
				
			}
			
			private function _dragToolbox( tile:b2EntityTileTool ):void
			{
				_dragFrToolbox = true;
				_dragStart( tile );
				_dragFrToolbox = true;
				tile.setDefault( 0, 0, 0 );
			}
			
			private function _dragBoundsHasContact():void
			{
				if ( _mtx >= 0 && _mty >= 0 && _mtx < Session.instance.cols && _mty < Session.instance.rows ) {
					var tile:b2EntityTile = _tileMap[_mtx][_mty];
					if ( tile && tile.isToolkit && _test_btnRotate.visible )
						_test_btnRotate.visible = false;
				}
			}
			//}
			
			
			//{ -- transitions
			private var _cache:Cache4Bmp, _timer:uint, _bmpD:BitmapData
			
			override protected function _onPreEnter():Boolean 
			{
				_cache.bitmapData.draw( _canvas, _canvas.transform.matrix, _canvas.transform.colorTransform );
				_canvas.visible = false;
				_timer = GameLoop.instance.time +FADE_ENTER_DUR;
				
				_bmpD.fillRect( _bmpD.rect, 0x191919 );
				LoadingOverlay.prepare( 0x191919 );
				LoadingOverlay.instance.bitmap.bitmapData = _bmpD;
				
				if ( _isImporting ) {
					use namespace pb2internal;
					new MapImport( Session.instance.map.str, _importInit, _importComplete, _importError ).start();
					
					GameAudio.instance.stopMusic();
					GameAudio.instance.playAmbience( 3000 );
					
					CONFIG::onFGL {
						Registry.FGL_TRACKER.customMsg( 'editor', 0 ); }
				}
				
				return !_isImporting;
			}
			
			override protected function _onPreExit():void 
			{
				_cache.bitmapData.draw( _canvas, _canvas.transform.matrix, _canvas.transform.colorTransform );
				_canvas.visible = false;
				_timer = GameLoop.instance.time +FADE_EXIT_DUR;
				
				_bmpD.fillRect( _bmpD.rect, 0x191919 );
				LoadingOverlay.prepare( 0x191919 );
				LoadingOverlay.instance.bitmap.bitmapData = _bmpD;
				
				GameAudio.instance.stopAmbience( FADE_EXIT_DUR*.9 >>0 );
				
				Session.instance.clean();
			}
			
			override protected function _doWhileEntering():Boolean 
			{
				var dur:uint = FADE_ENTER_DUR;
				var t:int = dur - (_timer - GameLoop.instance.time);
				var s:Number = t<dur? Quad.easeIn( t, -100, 100, dur ) :0;
				_cache.colorTrnsfrm.alphaMultiplier = (100+s)/100;
				
				_bmpD.lock();
				//_bmpD.applyFilter( _cache.bitmapData, _bmpD.rect, _cache.point, ColorMatrixUtil.setSaturation(s) );
				_bmpD.applyFilter( _cache.bitmapData, _bmpD.rect, _cache.point, new BlurFilter(Linear.easeIn(t,24,-24,dur), Linear.easeIn(t,8,-8,dur), 1) );
				_bmpD.colorTransform( _bmpD.rect, _cache.colorTrnsfrm );
				//LoadingOverlay.instance.bitmap.filters = [new BlurFilter(
				_bmpD.unlock();
				
				if ( t < dur )
					return true;
				
				LoadingOverlay.dismiss();
				_canvas.visible = true;
				toolBar.show();
				
				if ( !Session.instance.map.str ) hud.init();
				
				onModeChange.dispatch();
				hud.restart();
				
				return false;
			}
			
			override protected function _doWhileExiting():Boolean 
			{
				var dur:uint = FADE_EXIT_DUR;
				var t:int = dur - (_timer - GameLoop.instance.time);
				var s:Number = t<dur? Quad.easeOut( t, 0, -100, dur ) :-100;
				_cache.colorTrnsfrm.alphaMultiplier = (100+s)/100;
				
				_bmpD.lock();
				//_bmpD.applyFilter( _cache.bitmapData, _bmpD.rect, _cache.point, ColorMatrixUtil.setSaturation(s) );
				_bmpD.applyFilter( _cache.bitmapData, _bmpD.rect, _cache.point, new BlurFilter(Linear.easeIn(t,0,24,dur), Linear.easeIn(t,0,8,dur), 1) );
				_bmpD.colorTransform( _bmpD.rect, _cache.colorTrnsfrm );
				_bmpD.unlock();
				
				if ( t < dur )
					return true;
				
				return false;
			}
			//}
			
			
	}

}