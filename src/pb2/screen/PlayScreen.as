package pb2.screen 
{
	import apparat.math.FastMath;
	import com.demonsters.debugger.MonsterDebugger;
	import com.greensock.easing.*;
	import com.jaycsantos.display.Cache4Bmp;
	import com.jaycsantos.display.render.*;
	import com.jaycsantos.display.screen.*;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.math.*;
	import com.jaycsantos.sound.*;
	import com.jaycsantos.util.*;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.filters.*;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import pb2.game.ctrl.*;
	import pb2.game.entity.b2.*;
	import pb2.game.entity.DragBounds;
	import pb2.game.entity.misc.Grid;
	import pb2.game.entity.render.IDragBaseDraw;
	import pb2.game.*;
	import pb2.game.entity.tile.WallEdgeRender;
	import pb2.GameAudio;
	import pb2.screen.ui.*;
	import pb2.screen.window.*;
	import pb2.util.pb2internal;
	
	/**
	 * ...
	 * @author ...
	 */
	public class PlayScreen extends AbstractScreen
	{
		public static const FADE_ENTER_DUR:uint = 300
		public static const FADE_EXIT_DUR:uint = 800
		
		private static const TILE_BTN_OFF:uint = 14
		
		public var hud:HudGame, hudAudio:HudAudio, grid:Grid
		
		public function PlayScreen( root:GameRoot, data:Object=null )
		{
			var i:int, j:int, k:String, ts:Number = Registry.tileSize, session:Session = Session.instance;
			
			super( root, data );
			
			_canvas.addChild( _world_canvas = new Sprite );
			_canvas.addChild( _overlay = new Sprite );
			_canvas.addChild( hudAudio = new HudAudio );
			
			_canvas.visible = false;
			_canvas.graphics.beginFill( 0x333333 );
			_canvas.graphics.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			_canvas.graphics.endFill();
			
			// --
			_overlay.name = 'screen overlay';
			_overlay.mouseEnabled = false;
			_overlay.addChild( hud = new HudGame );
			_overlay.addChild( _dragBmp = new Bitmap(new BitmapData(ts*1.2, ts*1.2)) );
			_overlay.addChild( _mouseClip = PuttBase2.assets.createDisplayObject('mouse.pointer.helper') as MovieClip );
			
			// --
			hud.releaseCallback = _dragToolbox;
			CameraFocusCtrl.instance.enable();
			
			
			// --
			_mouseClip.gotoAndStop( 1 ); _mouseClip.mouseEnabled = false;
			_dragBmp.name = 'drag bitmap';
			_dragBmp.visible = false;
			
			
			// --
			_world_canvas.name = 'world container';
			_world_canvas.x = HudGame.HUD_WIDTH;
			_world_canvas.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
			_world_canvas.addEventListener( MouseEvent.MOUSE_DOWN, _md, false, 0, true );
			
			_world_canvas.addChild( _test_btnTrash = PuttBase2.assets.createDisplayObject('screen.editor.btnTrash') as SimpleButton );
			_world_canvas.addChild( _test_btnRotate = PuttBase2.assets.createDisplayObject('screen.editor.btnRotate') as SimpleButton );
			_test_btnTrash.name = 'btnTrash (test)';
			_test_btnRotate.name = 'btnRotate (test)';
			_test_btnTrash.visible = _test_btnRotate.visible = false;
			
			
			// --
			_bmpD = new BitmapData( PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT, true, 0 );
			_cache = new Cache4Bmp( true, false, false, true );
			_cache.bitmapData = _bmpD.clone();
		}
		
		override public function dispose():void 
		{
			//if ( !_dragBounds.isDisposed() ) _dragBounds.dispose();
			_dragBounds = null
			//if ( !_grid.isDisposed() ) _grid.dispose();
			grid = null;
			
			super.dispose();
			
			hud.dispose(); hud = null;
			hudAudio.dispose(); hudAudio = null;
			
			Window.disposeAllWindows();
		}
		
		
		override public function update():void 
		{
			BallCtrl.instance.update();
			
			hud.update();
			
			_update();
		}
		
		
			// -- private --
			
			protected var _world_canvas:Sprite, _overlay:Sprite
			
			protected var _mtx:int, _mty:int, _ptx:int, _pty:int, _mouseClip:MovieClip
			protected var _dragBmp:Bitmap, _dragTile:b2EntityTile, _dragFrToolbox:Boolean, _dragBounds:DragBounds, _dragLastX:int, _dragLastY:int, _dragTime:uint, _dragDrop:Boolean
			private var _waitImport:Boolean = true
			private var _tempMap:Vector.<b2EntityTile>
			
			// world canvas buttons
			protected var _test_btnTrash:SimpleButton, _test_btnRotate:SimpleButton
			
			
			
			private function _init():void
			{
				_dragBounds = Session.factory.spawnEntity('drag_bounds') as DragBounds;
				_dragBounds.deactivate();
				_dragBounds.onHasContact.add( _dragBoundsHasContact );
				
				grid = Session.factory.spawnEntity('grid') as Grid;
				grid.render.setVisible( false );
				
				_tempMap = new Vector.<b2EntityTile>;
				Session.instance.onReset.add( _onSessionReset );
			}
			
			private function _onSessionReset():void
			{
				_tempMap.splice( 0, _tempMap.length );
			}
			
			protected function _update():void
			{
				if ( !Session.isRunning || Session.isBusy || Session.instance.movingEntitiesCount>0 ) return;
				
				var tile:b2EntityTile, input:UserInput = UserInput.instance, camEdge:Vector2D = Session.world.camera.bounds.min;;
				var ts:Number = Registry.tileSize, ts2:Number = ts /2;
				var tileMap:Vector.<Vector.<b2EntityTile>> = Session.instance.tileMap;
				
				_mtx = Math.floor( (_world_canvas.mouseX +camEdge.x) /ts -.5 );
				_mty = Math.floor( (_world_canvas.mouseY +camEdge.y) /ts -.5 );
				
				var dirty:Boolean = _mtx != _ptx || _mty != _pty;
				_ptx = _mtx; _pty = _mty;
				
				if ( dirty ) {
					_dragBounds.deactivate();
					_dragBounds.filterTile = null;
				}
				
				if ( input.isMouseReleased && _dragTile && _world_canvas.mouseX < 0 )
					if ( _dragTile.isToolkit && hud.storeTool(_dragTile as b2EntityTileTool) ) {
						if ( !_dragFrToolbox && tileMap[_dragTile.defTileX][_dragTile.defTileY] == _dragTile )
							tileMap[ _dragTile.defTileX ][ _dragTile.defTileY ] = null;
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
						_dragBounds.setDefault( (_mtx +1) * ts, (_mty +1) * ts );
						
						if ( _mtx >= 0 && _mty >= 0 && _mtx < Session.instance.cols && _mty < Session.instance.rows && !_dragBounds.contactsCount && (tileMap[_mtx][_mty] == undefined || tileMap[_mtx][_mty] == _dragTile || (_dragTile.isToolkit && tileMap[_mtx][_mty] && tileMap[_mtx][_mty].wasMoved)) ) {
							_dragBmp.alpha = 1;
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
						_dragDrop = true;//_dragEnd();
					
					_mouseClip.x = _overlay.mouseX;
					_mouseClip.y = _overlay.mouseY;
					
				} else
				if ( dirty && !input.isMouseDown ) {
					_world_canvas.buttonMode = false;
					_test_btnTrash.visible = _test_btnRotate.visible = false;
					if ( _mtx >= 0 && _mty >= 0 && _mtx < Session.instance.cols && _mty < Session.instance.rows ) {
						tile = tileMap[_mtx][_mty];
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
							_world_canvas.buttonMode = true;
						}
						
					}
				}
				
				
				if ( CONFIG::debug && input.isKeyPressed(KeyCode.ZERO) )
					Session.instance.toggleDebug();
			}
			
			
			
			//{ -- mouse
			private function _click( e:MouseEvent ):void
			{
				if ( !Session.isRunning || Session.isBusy ) return;
				if ( !Session.world || Session.instance.movingEntitiesCount > 0 ) return;
				
				var tileMap:Vector.<Vector.<b2EntityTile>> = Session.instance.tileMap;
				if ( _mtx >= 0 && _mty >= 0 && _mtx < Session.instance.cols && _mty < Session.instance.rows && tileMap[_mtx][_mty] != undefined ) {
					var tile:b2EntityTile = tileMap[_mtx][_mty] as b2EntityTile;
					if ( tile && tile.wasMoved )
						for ( var k:String in _tempMap )
							if ( _tempMap[k].defTileX == _mtx && _tempMap[k].defTileY == _mty && !_tempMap[k].wasMoved && !_tempMap[k].isDisposed() ) {
								tile = _tempMap[k]; break;
							}
					
					if ( tile.isToolkit && tile is b2EntityTileTool )
						switch ( e.target ) {
							case _test_btnTrash:
								if ( hud.storeTool(tile as b2EntityTileTool) ) {
									tileMap[ tile.defTileX ][ tile.defTileY ] = null;
									Session.world.disposeEntity( tile );
									_ptx = _pty = -1;
								}
								break;
							case _test_btnRotate:
								if ( !_dragBounds.contactsCount )
									tile.setDefault( tile.defPx, tile.defPy, tile.defRa +Trigo.HALF_PI );
								break;
							default:
								if ( _dragLastX!=_mtx || _dragLastY!=_mty || _dragTime<getTimer() ) break;
								if ( e.target != _world_canvas || Tile.TILE_NONROTATES.indexOf(tile.type) > -1 ) break;
								if ( !tile.wasMoved && !_dragBounds.contactsCount )
									tile.setDefault( tile.defPx, tile.defPy, tile.defRa +Trigo.HALF_PI );
								break;
						}
				}
				
			}
			private function _md( e:MouseEvent ):void
			{
				if ( !Session.isRunning || Session.isBusy ) return;
				if ( !Session.world || Session.instance.movingEntitiesCount > 0 ) return;
				
				var tileMap:Vector.<Vector.<b2EntityTile>> = Session.instance.tileMap;
				if ( _mtx >= 0 && _mty >= 0 && _mtx < Session.instance.cols && _mty < Session.instance.rows && tileMap[_mtx][_mty] != undefined ) {
					var tile:b2EntityTile = tileMap[_mtx][_mty] as b2EntityTile;
					if ( tile && tile.wasMoved )
						for ( var k:String in _tempMap )
							if ( _tempMap[k].defTileX == _mtx && _tempMap[k].defTileY == _mty && !_tempMap[k].wasMoved && !_tempMap[k].isDisposed() ) {
								tile = _tempMap[k]; break;
							}
					
					if ( tile.isToolkit && tile is b2EntityTileTool )
						switch ( e.target ) {
							case _test_btnTrash: break;
							case _test_btnRotate: break;
							default: 
								if ( e.target == _world_canvas && !tile.wasMoved ) 
									_dragStart( tile );
								break;
						}
				}
				
			}
			//}
			
			
			//{ -- drag
			private function _dragStart( tile:b2EntityTile ):void
			{
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
				_dragLastX = _mtx;
				_dragLastY = _mty;
				_dragTime = getTimer() +500;
				
				_dragBmp.visible = true;
				
				var inRange:Boolean = Session.world.camera.bounds.isContaining( _world_canvas.mouseX, _world_canvas.mouseY );
				_dragBmp.x = !inRange? _overlay.mouseX -15: ts*(_mtx +.5)+1 -Session.world.camera.bounds.min.x +HudGame.HUD_WIDTH;
				_dragBmp.y = !inRange? _overlay.mouseY -15: ts*(_mty +.5)+1 -Session.world.camera.bounds.min.y;
				
				_dragTile.deactivate();
				_dragTile.setDefault( tile.defPx, tile.defPy, tile.defRa );
				//if ( !editMode )
				//	_dragBounds.activate();
				
				for each( var b:SimpleButton in [_test_btnRotate, _test_btnTrash] )
					b.visible = false;
				
				grid.render.setVisible( true );
			}
			
			private function _dragEnd():void
			{
				if ( ! _dragTile ) return;
				
				_dragTile.activate();
				
				var inRange:Boolean = _mtx >= 0 && _mty >= 0 && _mtx < Session.instance.cols && _mty < Session.instance.rows;
				var tileMap:Vector.<Vector.<b2EntityTile>> = Session.instance.tileMap;
				
				if ( inRange && (tileMap[_mtx][_mty] == undefined || (_dragTile.isToolkit && tileMap[_mtx][_mty] && tileMap[_mtx][_mty].wasMoved)) && !_dragBounds.contactsCount ) {
					if ( !_dragFrToolbox && tileMap[_dragTile.defTileX][_dragTile.defTileY] == _dragTile )
						tileMap[ _dragTile.defTileX ][ _dragTile.defTileY ] = null;
					
					if ( _dragTile.isToolkit && tileMap[_mtx][_mty] ) {
						if ( _tempMap.indexOf(_dragTile) == -1 )
							_tempMap.push( _dragTile );
					} else {
						tileMap[_mtx][_mty] = _dragTile;
					}
					_dragTile.setDefault( (_mtx +1)*Registry.tileSize, (_mty +1)*Registry.tileSize, _dragTile.defRa );
					
				} else {
					if ( (!inRange || tileMap[_mtx][_mty] != _dragTile) && _dragTile is b2EntityTileTool ) {
						if ( hud.storeTool(_dragTile as b2EntityTileTool) )
							Session.world.disposeEntity( _dragTile );
					} else
						_dragTile.setDefault( _dragTile.defPx, _dragTile.defPy, _dragTile.defRa );
					
					if ( _mtx != _dragTile.defTileX || _mty != _dragTile.defTileY )
						GameSounds.play( GameAudio.BUZZ );
				}
				
				_dragTile = null;
				_dragLastX = _dragLastY = -1;
				_dragBmp.visible = false;
				grid.render.setVisible( false );
				_mouseClip.gotoAndStop( 1 );
				
				//if ( !editMode )
				//	_dragBounds.deactivate();
				
				// refresh mouseover values
				_ptx = -1; _pty = -1;
			}
			
			private function _dragToolbox( tile:b2EntityTileTool ):void
			{
				_dragStart( tile );
				tile.setDefault( 0, 0, 0 );
				_dragFrToolbox = true;
			}
			
			private function _dragBoundsHasContact():void
			{
				var tileMap:Vector.<Vector.<b2EntityTile>> = Session.instance.tileMap;
				if ( _mtx >= 0 && _mty >= 0 && _mtx < Session.instance.cols && _mty < Session.instance.rows ) {
					var tile:b2EntityTile = tileMap[_mtx][_mty];
					if ( tile && tile.isToolkit && _test_btnRotate.visible )
						_test_btnRotate.visible = false;
				}
			}
			//}
			
			
			//{ -- import
			private function _importInit( cols:int, rows:int ):void
			{
				var r:Number = (MathUtils.randomNumber(5, 85) +MathUtils.randomInt(0,3)*90) *Trigo.DEG_TO_RAD;
				Session.instance.sun_angle.Set( FastMath.cos(r), FastMath.sin(r) );
				Session.instance.sun_length = MathUtils.randomInt( 19, 50 );
				
				Session.instance.create( cols, rows, _world_canvas, PuttBase2.STAGE_WIDTH -HudGame.HUD_WIDTH, PuttBase2.STAGE_HEIGHT );
				Session.instance.start();
				_init();
				
				AwesomenessCtrl.i.init();
			}
			
			private function _importComplete():void
			{
				var map:MapData = Session.instance.map;
				
				trace( 'import complete ['+ map.name +']' );
				map.loaded();
				Session.instance.reset( true, true );
				
				Session.instance.wallLeft.render.redraw();
				Session.instance.wallLeft.render.update();
				Session.instance.wallRight.render.redraw();
				Session.instance.wallRight.render.update();
				Session.instance.wallTop.render.redraw();
				Session.instance.wallTop.render.update();
				Session.instance.wallBottom.render.redraw();
				Session.instance.wallBottom.render.update();
				
				CONFIG::debug {
					var t:b2EntityTileTool, xml:XML = SaveDataMngr.instance.getLevelData( map.name, map.hash );
					if ( xml != null && String(xml.@items) ) {
						var a:Array = String(xml.@items).split(',');
						var j:int = a.length/4 >>0;
						
						for ( var i:int; i < j; i++ ) {
							t = hud.releaseTool( Tile.getTileType(int(a[i * 4])) );
							if ( t ) {
								t.setDefault( (int(a[i*4+1]) +1)*Registry.tileSize, (int(a[i*4+2]) +1)*Registry.tileSize, int(a[i*4+3])*90*Trigo.DEG_TO_RAD );
								Session.instance.tileMap[ t.defTileX ][ t.defTileY ] = t;
							}
						}
						
					}
				}
				
				_waitImport = false;
				_forceEnter();
				
			}
			
			private function _importError( e:Error ):void
			{
				changeScreen( MapErrorScreen, e );
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
				
				if ( _waitImport ) {
					var map:MapData = Session.instance.map;
					var xml:XML = SaveDataMngr.instance.getLevelData( map.name, map.hash );
					
					if ( !map.isCustom && xml && !uint(xml.@score) )
						GameAudio.instance.playGameMusic( map.xml.@music );
					else
						GameAudio.instance.playGameMusic();
					
					
					new MapImport( map.str, _importInit, _importComplete, _importError, Math.random().toString(36) ).start();
				}
				
				return !_waitImport;
			}
			
			override protected function _onPreExit():void 
			{
				_cache.bitmapData.draw( _canvas, _canvas.transform.matrix, _canvas.transform.colorTransform );
				_canvas.visible = false;
				_timer = GameLoop.instance.time +FADE_EXIT_DUR;
				
				_bmpD.fillRect( _bmpD.rect, 0x191919 );
				LoadingOverlay.prepare( 0x191919 );
				LoadingOverlay.instance.bitmap.bitmapData = _bmpD;
				
				AwesomenessCtrl.i.clear();
				Session.instance.clean();
				GameAudio.instance.stopMusic( FADE_EXIT_DUR*.9 >>0 );
				GameAudio.instance.stopAmbience( FADE_EXIT_DUR*.9 >> 0 );
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
				_bmpD.unlock();
				
				if ( t < dur )
					return true;
				
				LoadingOverlay.dismiss();
				_canvas.visible = true;
				hud.showIntro();
				
				//Session.instance.onEntitiesMoveStop.add( GameAudio.playMusic );
				//Session.instance.onEntityMoveStart.add( _stopMusic );
				
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