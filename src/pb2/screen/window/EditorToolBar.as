package pb2.screen.window 
{
	import com.greensock.easing.Quad;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.util.GameLoop;
	import com.jaycsantos.util.UserInput;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.geom.*;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import org.osflash.signals.Signal;
	import pb2.game.ctrl.*;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.entity.Portal;
	import pb2.game.Session;
	import pb2.game.Tile;
	import pb2.screen.EditorScreen;
	import pb2.screen.ui.HudGameEditor;
	import pb2.screen.ui.UIFactory;
	import pb2.util.pb2internal;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class EditorToolBar extends Pb2Window 
	{
		use namespace pb2internal
		
		public static const FADE_DUR:uint = 100;
		public static var BoxWgtLimit:uint = 200;
		
		public var onSelectType:Signal
		
		
		public function EditorToolBar() 
		{
			super( 'Editing' );
			
			name = 'level editor toolbar';
			mouseEnabled = true;
			blendMode = BlendMode.LAYER;
			removeChild(_overlay);
			
			//_contents.graphics.lineStyle( 1, 0, 0 );
			//_contents.graphics.drawRect( 0, 0, 150, 20 );
			
			addChildAt( _drag = new Sprite, 0 );
			_drag.name = 'drag';
			_drag.addEventListener( MouseEvent.MOUSE_DOWN, _dragMd, false, 0, true );
			_drag.buttonMode = true; _drag.mouseChildren = _drag.tabEnabled = false;
			
			
			_contents.addChild( _btnTile = new Sprite );
			_btnTile.buttonMode = true; _btnTile.mouseChildren = _btnTile.tabChildren = false;
			_btnTile.name = 'tile select button';
			_btnTile.addEventListener( MouseEvent.MOUSE_OVER, _btnTileMovr, false, 0, true );
			_btnTile.addEventListener( MouseEvent.MOUSE_OUT, _btnTileMout, false, 0, true );
			_btnTile.addEventListener( MouseEvent.CLICK, _btnTileClick, false, 0, true );
			
			_btnTile.addChild( _btnTile_bmp = new Bitmap(new BitmapData(17,17)) );
			_btnTile_bmp.x = 1.5; _btnTile_bmp.y = 1.5;
			
			_btnTile_triangles = Vector.<Number>([21,7.5,26,7.5,23.5,12.5])
			_btnTileMout();
			
			_btnTile.addChild( _tileBox = new Sprite );
			
			
			_contents.addChildAt( _btnTest = new Sprite, _contents.numChildren -1 );
			_btnTest.x = _btnTile.x +_btnTile.width +1;
			_btnTest.buttonMode = true; _btnTest.mouseChildren = _btnTest.tabChildren = false;
			_btnTest.name = 'test button';
			_btnTest.addEventListener( MouseEvent.MOUSE_OVER, _btnTestMovr, false, 0, true );
			_btnTest.addEventListener( MouseEvent.MOUSE_OUT, _btnTestMout, false, 0, true );
			_btnTest.addEventListener( MouseEvent.CLICK, _btnTestCk, false, 0, true );
			
			_btnTest.addChild( _btnTest_txf = UIFactory.createTextField('Test', 'menuBarText') );
			_btnTest_txf.x = 15; _btnTest_txf.y = 1; _btnTest_txf.height = 18;
			
			_btnTest_triangles = Vector.<Number>([5, 5, 14, 10, 5, 15]);
			_btnTestMout();
			
			
			_contents.addChildAt( _btnEdit = new Sprite, _contents.numChildren -2 );
			_btnEdit.x = _btnTest.x;
			_btnEdit.buttonMode = true; _btnEdit.mouseChildren = _btnEdit.tabChildren = false;
			_btnEdit.name = 'edit button';
			_btnEdit.addEventListener( MouseEvent.MOUSE_OVER, _btnEditMovr, false, 0, true );
			_btnEdit.addEventListener( MouseEvent.MOUSE_OUT, _btnEditMout, false, 0, true );
			_btnEdit.addEventListener( MouseEvent.CLICK, _btnEditCk, false, 0, true );
			
			_btnEdit.addChild( _btnEdit_txf = UIFactory.createTextField('Edit', 'menuBarText') );
			_btnEdit_txf.x = 15; _btnEdit_txf.y = 1; _btnEdit_txf.height = 18;
			_btnEditMout();
			_btnEdit.visible = false;
			
			
			_contents.addChild( _btnTools = new Sprite );
			_btnTools.x = _btnTest.x +Math.max(_btnTest.width, _btnEdit.width) +1;
			_btnTools.buttonMode = true; _btnTools.mouseChildren = _btnTools.tabChildren = false;
			_btnTools.name = 'tools button';
			_btnTools.addEventListener( MouseEvent.MOUSE_OVER, _btnToolsMovr, false, 0, true );
			_btnTools.addEventListener( MouseEvent.MOUSE_OUT, _btnToolsMout, false, 0, true );
			_btnTools.addEventListener( MouseEvent.CLICK, _btnToolsCk, false, 0, true );
			
			_btnTools.addChild( _btnTools_ico = PuttBase2.assets.createDisplayObject('screen.ui.ico.btnTools') as MovieClip );
			_btnTools_ico.x = 10; _btnTools_ico.y = 10;
			_btnToolsMout();
			
			
			onSelectType = new Signal( String );
			_portals = new Vector.<Portal>;
			
			_resize();
			_initTileBox();
			_initToolsMenu();
			
			_drag.graphics.beginFill( 0, 0 );
			_drag.graphics.drawRect( 0, 0, _bgClip.width, 20 );
			
			//BallCtrl.instance.onPull.add( hide );
			//BallCtrl.instance.onPullCancel.add( show );
			//BallCtrl.instance.onPullEnd.add( show );
			Session.instance.onEntityMoveStart.add( hide );
			Session.instance.onEntitiesMoveStop.add( show );
			
		}
		
		override public function dispose():void 
		{
			_drag.removeEventListener( MouseEvent.MOUSE_DOWN, _dragMd );
			_btnTile.removeEventListener( MouseEvent.MOUSE_OVER, _btnTileMovr );
			_btnTile.removeEventListener( MouseEvent.MOUSE_OUT, _btnTileMout );
			_btnTile.removeEventListener( MouseEvent.CLICK, _btnTileClick );
			_btnTest.removeEventListener( MouseEvent.MOUSE_OVER, _btnTestMovr );
			_btnTest.removeEventListener( MouseEvent.MOUSE_OUT, _btnTestMout );
			_btnTest.removeEventListener( MouseEvent.CLICK, _btnTestCk );
			_btnEdit.removeEventListener( MouseEvent.MOUSE_OVER, _btnEditMovr );
			_btnEdit.removeEventListener( MouseEvent.MOUSE_OUT, _btnEditMout );
			_btnEdit.removeEventListener( MouseEvent.CLICK, _btnEditCk );
			_btnTools.removeEventListener( MouseEvent.MOUSE_OVER, _btnToolsMovr );
			_btnTools.removeEventListener( MouseEvent.MOUSE_OUT, _btnToolsMout );
			_btnTools.removeEventListener( MouseEvent.CLICK, _btnToolsCk );
			
			//BallCtrl.instance.onPull.remove( hide );
			//BallCtrl.instance.onPullEnd.remove( show );
			
			_btnTile_bmp.bitmapData.dispose();
			_btnTile_bmp = null;
			
			super.dispose();
			
			_portals.splice( 0, _portals.length );
			_boxLimit.splice( 0, _boxLimit.length );
			
			var i:int = numChildren;
			while ( i-- )
				removeChildAt( i );
			
			onSelectType.removeAll(); onSelectType = null;
		}
		
		
		public function selectTile( type:String, angle:Number = 0 ):void
		{
			var i:String, j:int, m:Matrix;
			var tiles:Vector.<Array> = Tile.TILE_ALL;
			
			for ( i in tiles ) {
				j = tiles[i].indexOf( type );
				if ( j > -1 ) {
					_tileBoxSelect.x = _tileBoxActive.x = j *24 +3;
					_tileBoxSelect.y = _tileBoxActive.y = int(i) *24 +3;
					
					m = new Matrix;
					m.rotate( angle );
					m.translate( 18, 18 );
					m.scale( 16.5/36, 16.5/36 );
					
					_btnTile_bmp.bitmapData.lock();
					_btnTile_bmp.bitmapData.fillRect( _btnTile_bmp.bitmapData.rect, 0x0 );
					_btnTile_bmp.bitmapData.draw( _tileBox.getChildByName(type), m );
					_btnTile_bmp.bitmapData.unlock();
					_btnTile_bmp.transform.colorTransform = _tileBox.getChildByName(type).transform.colorTransform;
					
					_tileType = type;
					_tileAngle = angle;
					
					onSelectType.dispatch( type );
					return;
				}
			}
			
		}
		
		
		public function get tileType():String
		{
			return _tileType;
		}
		
		public function get tileAngle():Number
		{
			return _tileAngle;
		}
		
		
		public function requestTile( type:String ):Boolean
		{
			var code:uint = Tile.getTileCode( type );
			var a:Array = _boxLimit[ code ];
			
			// unlimited, check
			if ( a != null && (a[0] == int.MIN_VALUE || a[0] > 0) ) {
				// if ( a[1]+_boxWgt <= BoxWgtLimit ) {
					if ( a[0] > 0 ) a[0]--;
					//_boxWgt += a[1];
					
					if ( a[0] == 0 ) {
						_tileBox.getChildByName( type ).transform.colorTransform = new ColorTransform(.5, .5, .5, 1, 102, 102, 102, 0 );
						selectTile( _tileType, _tileAngle );
					}
					return true;
				// }
			}
			
			return false;
		}
		
		public function returnTileWgt( tile:b2EntityTile ):void
		{
			var a:Array = _boxLimit[Tile.getTileCode(tile.type)];
			
			if ( a != null && a[0] > -1 ) {
				a[0]++;
				if ( a[0] == 1 ) {
					_tileBox.getChildByName( tile.type ).transform.colorTransform = new ColorTransform;
					selectTile( _tileType, _tileAngle );
				}
			}
			//_boxWgt -= a[1];
			
			if ( tile is Portal ) {
				var i:int = _portals.indexOf(tile);
				if ( i > -1 ) _portals.splice( i, 1 );
			}
			
		}
		
		
		public function addPortal( p:Portal, autoLink:Boolean=true ):void
		{
			if ( _portals.indexOf(p) == -1 ) {
				if ( !p.isLinked && autoLink ) {
					for each ( var p2:Portal in _portals )
						if ( !p2.isLinked ) {
							p2.linkTo( p );
							p.linkTo( p2 );
							break;
						}
				}
				_portals.push( p );
			}
			
		}
		
		
		public function test():void
		{
			_btnResetCk();
		}
		
		public function edit():void
		{
			_btnEditCk();
		}
		
			// -- private --
			
			protected var _tileType:String, _tileAngle:Number
			
			override protected function _update():void 
			{
				var input:UserInput = UserInput.instance;
				var p:Point, tx:int, ty:int;
				
				if ( _dragged ) {
					if ( input.isMouseReleased || input.isFocusLost ) {
						this.stopDrag();
						_dragged = false;
					}
					
					x = Math.max( 0, Math.min(x, PuttBase2.STAGE_WIDTH-_bgClip.width) );
					y = Math.max( 0, Math.min(y, PuttBase2.STAGE_HEIGHT-_bgClip.height) );
				
				} else
				if ( _tileBox.visible ) {
					tx = Math.floor( (_tileBox.mouseX -5) /24 );
					ty = Math.floor( (_tileBox.mouseY -5) /24 );
					var tiles:Vector.<Array> = Tile.TILE_ALL;
					
					if ( ty >= 0 && ty < tiles.length )
						if ( tx >= 0 && tx < tiles[ty].length ) {
							_tileBoxSelect.x = tx *24 +3;
							_tileBoxSelect.y = ty *24 +3;
						}
				} else
				if ( _toolsMenu.visible ) {
					p = _toolsMenu.globalToLocal( new Point(input.mouseX, input.mouseY) );
					
					if ( p.y >= 0 && p.y < _toolsMenu.height ) {
						ty = Math.min( (p.y -3) /20 >> 0, 5 );
						_toolsMenu_select.visible = true;
						_toolsMenu_select.y = ty *(_menuShare.height +1) +3;
						
					} else {
						_toolsMenu_select.visible = false;
					}
					
				}
				
			}
			
			
			// -- button tile
			private var _btnTile:Sprite, _btnTile_bmp:Bitmap, _btnTile_triangles:Vector.<Number>
			private var _tileBox:Sprite, _tileBoxActive:Shape, _tileBoxSelect:Shape
			private var _boxLimit:Array, _boxWgt:uint
			private var _portals:Vector.<Portal>
			
			
			private function _initTileBox():void
			{
				var i:int, j:int, k:String, clip:Sprite, tiles:Vector.<Array> = Tile.TILE_ALL, m:int, maxW:int, maxH:int;
				
				_tileBox.addChild( _tileBoxActive = new Shape );
				_tileBox.addChild( _tileBoxSelect = new Shape );
				
				with ( _tileBoxActive.graphics ) {
					beginFill( 0x8C8C8C );
					drawRect( 0, 0, 24, 24 );
					endFill();
				}
				with ( _tileBoxSelect.graphics ) {
					lineStyle( 1, 0x8C8C8C );
					drawRect( 0, 0, 24, 24 );
				}
				
				for ( i=0; i<tiles.length; i++ )
					for ( j=0; j<tiles[i].length; j++ ) {
						k = tiles[i][j];
						clip = PuttBase2.assets.createDisplayObject( 'entity.block.'+ k ) as Sprite;
						clip.name = k;
						clip.scaleX = clip.scaleY = 18/36;
						clip.x = 5 +j*24 +10; clip.y = 5 +i*24 +10;
						if ( clip is MovieClip ) MovieClip(clip).stop();
						m = clip.numChildren
						while ( m-- )
							if ( clip.getChildAt(m) is MovieClip ) MovieClip( clip.getChildAt(m) ).stop();
						
						_tileBox.addChild( clip );
						maxW = Math.max( j, maxW );
						maxH = Math.max( i, maxH );
					}
				_tileBox.scrollRect = new Rectangle(0,0,(maxW+1)*24 +7,(maxH+1)*24 +7);
				with( _tileBox.graphics ) {
					lineStyle( 1, 0x8C8C8C );
					beginFill( 0xCCCCCC );
					drawRect( 0, 0, _tileBox.scrollRect.width-1, _tileBox.scrollRect.height-1 );
					endFill();
				}
				
				_tileBox.visible = false;
				_tileBox.scaleX = _tileBox.scaleY = .01;
				
				
				_boxLimit = new Array;
				for ( i=0; i<tiles.length; i++ )
					for ( j=0; j<tiles[i].length; j++ ) {
						m = Tile.getTileCode( k = tiles[i][j] );
						
						switch( k ) {
							case Tile.GOLFBALL:
								_boxLimit[m] = [10, 0];
								break;
							case Tile.BOMB:
								_boxLimit[m] = [8, 10];
								break;
							case Tile.HOLE:
								_boxLimit[m] = [1, 0];
								break;
							case Tile.SIGNAL_RELAY:
								_boxLimit[m] = [6, 1];
								break;
							case Tile.PUSH_BTN:
							case Tile.PUSH_BTN2:
							case Tile.PUSH_BTN3:
								_boxLimit[m] = [12, 3];
								break;
							case Tile.GATE_A:
							case Tile.GATE_B:
								_boxLimit[m] = [32, 1];
								break;
							case Tile.GATE_C:
							case Tile.GATE_D:
							case Tile.GATE_E:
							case Tile.GATE_F:
								_boxLimit[m] = [6, 1];
								break;
							case Tile.SPINFLAPS:
							case Tile.SPINFLAPS_BLU:
							case Tile.SPINFLAPS_RED:
							case Tile.SPINFLAPS_YEL:
								_boxLimit[m] = [64, 1];
								break;
							case Tile.CONVEYORBELT:
								_boxLimit[m] = [42, 10];
								break;
							case Tile.GLASS:
							case Tile.GLASSWOOD:
							case Tile.GLASSRUBBER:
							case Tile.GLASSWALL:
								_boxLimit[m] = [14, 4];
								break;
							case Tile.PUNCHER_SQ:
							case Tile.PUNCHER_RTRI:
							case Tile.PUNCHER2_SQ:
								_boxLimit[m] = [24, 5];
								break;
							case Tile.PPUNCHER_SQ:
								_boxLimit[m] = [16, 10];
								break;
							case Tile.FLOORBLOWER:
							case Tile.FLOORBLOWER2:
								_boxLimit[m] = [32, 5];
								break;
							case Tile.PORTAL:
								_boxLimit[m] = [14, 10];
								break;
							default:
								// is a wall, no limit
								if ( Tile.TILE_WALLS.indexOf(k) > -1 )
									_boxLimit[m] = [int.MIN_VALUE, 0];
								
								// is a toolkit, limit to 24 ea @ 3 units ea
								else //if ( Tile.TILE_TOOLKITS.indexOf(k) > -1 )
									_boxLimit[m] = [48, 4];
								break;
						}
					}
				
			}
			
			private function _btnTileMovr( e:MouseEvent ):void
			{
				with ( _btnTile.graphics ) {
					clear();
					lineStyle( 1, 0x8C8C8C, 1,false,'normal',null,'miter' );
					beginFill( 0xCCCCCC );
					drawRect( 0, 0, 28, 20 );
					endFill();
					lineStyle( 1, 0x595959 );
					beginFill( 0x666666 );
					drawTriangles( _btnTile_triangles );
					endFill();
				}
				_tileBox.visible = true;
				_tileBox.scaleX = _tileBox.scaleY = 1;
				
				if ( x > PuttBase2.STAGE_WIDTH -width )
					_tileBox.x = -_tileBox.width +28 +1;
				else
					_tileBox.x = 0;
				if ( y > PuttBase2.STAGE_HEIGHT -height )
					_tileBox.y = -_tileBox.height +1;
				else
					_tileBox.y = 20;
			}
			
			private function _btnTileMout( e:MouseEvent = null ):void
			{
				with ( _btnTile.graphics ) {
					clear();
					beginFill( 0, 0 );
					drawRect( 0, 0, 28, 20 );
					endFill();
					lineStyle( 1, 0x595959 );
					beginFill( 0x666666 );
					drawTriangles( _btnTile_triangles );
					endFill();
				}
				if ( _tileBox ) {
					_tileBox.visible = false;
					_tileBox.scaleX = _tileBox.scaleY = .01;
				}
			}
			
			private function _btnTileClick( e:MouseEvent ):void
			{
				//var p:Point = _tileBox.globalToLocal( new Point(e.stageX, e.stageY) );
				var tx:int = Math.floor( (_tileBox.mouseX -5) /24 );
				var ty:int = Math.floor( (_tileBox.mouseY -5) /24 );
				var tiles:Vector.<Array> = Tile.TILE_ALL;
				
				if ( ty >= 0 && ty < tiles.length )
					if ( tx >= 0 && tx < tiles[ty].length ) {
						selectTile( tiles[ty][tx] );
						_btnTileMout();
					}
			}
			
			
			// -- button test, restart, edit
			private var _btnTest:Sprite, _btnTest_txf:TextField, _btnTest_triangles:Vector.<Number>
			private var _btnEdit:Sprite, _btnEdit_txf:TextField
			
			
			private function _btnTestMovr( e:MouseEvent ):void
			{
				with ( _btnTest.graphics ) {
					clear();
					lineStyle( 1, 0x8C8C8C, 1,false,'normal',null,'miter' );
					beginFill( 0xCCCCCC );
					drawRect( 0, 0, _btnTest_txf.width +17, 20 );
					endFill();
					lineStyle( 1, 0x4973B2, 1,false,'normal',null,'bevel' );
					beginFill( 0x5B84CC );
					drawTriangles( _btnTest_triangles );
					endFill();
				}
			}
			
			private function _btnTestMout( e:MouseEvent = null ):void
			{
				with ( _btnTest.graphics ) {
					clear();
					beginFill( 0, 0 );
					drawRect( 0, 0, _btnTest_txf.width +17, 20 );
					endFill();
					lineStyle( 1, 0x4973B2, 1,false,'normal',null,'bevel' );
					beginFill( 0x5B84CC );
					drawTriangles( _btnTest_triangles );
					endFill();
				}
			}
			
			private function _btnTestCk( e:MouseEvent ):void
			{
				_btnResetCk( e );
			}
			
			
			private function _btnEditMovr( e:MouseEvent ):void
			{
				with ( _btnEdit.graphics ) {
					clear();
					lineStyle( 1, 0x8C8C8C, 1,false,'normal',null,'miter' );
					beginFill( 0xCCCCCC );
					drawRect( 0, 0, _btnEdit_txf.width +17, 20 );
					endFill();
					lineStyle( 1, 0xB24949 );
					beginFill( 0xCC5151 );
					drawRect( 5, 5, 9, 10 );
					endFill();
				}
			}
			
			private function _btnEditMout( e:MouseEvent = null ):void
			{
				with ( _btnEdit.graphics ) {
					clear();
					beginFill( 0, 0 );
					drawRect( 0, 0, _btnEdit_txf.width +17, 20 );
					endFill();
					lineStyle( 1, 0xB24949 );
					beginFill( 0xCC5151 );
					drawRect( 5, 5, 9, 10 );
					endFill();
				}
			}
			
			private function _btnEditCk( e:MouseEvent=null ):void
			{
				EditorScreen( GameRoot.screen ).edit();
				
				_btnTest.visible = true;
				_btnEdit.visible = false;
				_btnTile.buttonMode = _btnTile.mouseEnabled = _btnTools.buttonMode = _btnTools.mouseEnabled = true;
				_btnTile.alpha = _btnTools.alpha = 1;
				
				_title.htmlText = '<p class="windowTitle">Editing</p>';
			}
			
			
			private function _btnResetCk( e:MouseEvent=null ):void
			{
				EditorScreen( GameRoot.screen ).simulate();
				
				_btnTest.visible = false;
				_btnEdit.visible = true;
				_btnTile.buttonMode = _btnTile.mouseEnabled = _btnTools.buttonMode = _btnTools.mouseEnabled = false;
				_btnTile.alpha = _btnTools.alpha = .3;
				
				_title.htmlText = '<p class="windowTitle">Testing</p>';
			}
			
			
			// -- more buttons
			private var _btnTools:Sprite, _btnTools_ico:MovieClip
			private var _toolsMenu:Sprite, _toolsMenu_select:Shape
			private var _menuSettings:TextField, _menuSave:TextField, _menuShare:TextField
			
			private function _initToolsMenu():void
			{
				_btnTools.addChild( _toolsMenu = new Sprite );
				
				_toolsMenu.addChild( _toolsMenu_select = new Shape );
				_toolsMenu.addChild( _menuSettings = UIFactory.createTextField('Info', 'menuBarText') );
				_toolsMenu.addChild( _menuSave = UIFactory.createTextField('Save', 'menuBarText') );
				_toolsMenu.addChild( _menuShare = UIFactory.createTextField('Share', 'menuBarText') );
				
				_menuSettings.x = _menuSave.x = _menuShare.x = 10;
				_menuSettings.y = 3;
				_menuSave.y = _menuSettings.y +_menuSettings.height +1;
				_menuShare.y = _menuSave.y +_menuSave.height +1;
				
				with ( _toolsMenu.graphics ) {
					lineStyle( 1, 0x8C8C8C );
					beginFill( 0xCCCCCC );
					drawRect( 0, 0, _toolsMenu.width +20 <<0, _toolsMenu.height +6 );
					endFill();
				}
				with ( _toolsMenu_select.graphics ) {
					lineStyle( 1, 0x8C8C8C );
					drawRect( 5, 0, _toolsMenu.width -10 <<0, _menuShare.height );
				}
				
				_toolsMenu.visible = false;
				_toolsMenu.scaleX = _toolsMenu.scaleY = .01;
			}
			
			private function _btnToolsMovr( e:MouseEvent ):void
			{
				with ( _btnTools.graphics ) {
					clear();
					lineStyle( 1, 0x8C8C8C, 1,false,'normal',null,'miter' );
					beginFill( 0xCCCCCC );
					drawRect( 0, 0, 29, 20 );
					endFill();
					lineStyle( 1, 0x595959 );
					beginFill( 0x666666 );
					drawTriangles( _btnTile_triangles );
					endFill();
				}
				_btnTools_ico.gotoAndStop( 2 );
				_toolsMenu.visible = true;
				_toolsMenu.scaleX = _toolsMenu.scaleY = 1;
				
				_menuShare.alpha = HudGameEditor.instance.getPar() ? 1 : .25;
				
				
				if ( x > PuttBase2.STAGE_WIDTH -width )
					_toolsMenu.x = -_toolsMenu.width +29 +1;
				else
					_toolsMenu.x = 0;
				if ( y > PuttBase2.STAGE_HEIGHT -height )
					_toolsMenu.y = -_toolsMenu.height +1;
				else
					_toolsMenu.y = 20;
			}
			
			private function _btnToolsMout( e:MouseEvent = null ):void
			{
				with ( _btnTools.graphics ) {
					clear();
					beginFill( 0, 0 );
					drawRect( 0, 0, 29, 20 );
					endFill();
					lineStyle( 1, 0x595959 );
					beginFill( 0x666666 );
					drawTriangles( _btnTile_triangles );
					endFill();
				}
				_btnTools_ico.gotoAndStop( 2 );
				if ( _toolsMenu ) {
					_toolsMenu.visible = false;
					_toolsMenu.scaleX = _toolsMenu.scaleY = .01;
				}
			}
			
			private function _btnToolsCk( e:MouseEvent = null ):void
			{
				if ( ! _toolsMenu_select.visible ) return;
				
				var i:int = 1+ (_toolsMenu_select.y -3) /(_menuShare.height +1);
				var txf:TextField = _toolsMenu.getChildAt( i ) as TextField;
				var win:Window, hud:HudGameEditor = EditorScreen(GameRoot.screen).hud;
				
				use namespace pb2internal;
				
				switch( txf ) {
					case _menuSettings:
						hud.addChild( win = new PopHoleInfo );
						win.show();
						break;
						
					case _menuSave:
						EditorScreen(GameRoot.screen)._autoSave();
						break;
						
					case _menuShare:
						if ( _menuShare.alpha != 1 ) break;
						
						hud.addChild( win = new PopHoleUpload );
						win.show();
						break;
					
					default: break;
				}
				_btnToolsMout();
				
			}
			
			
			// -- export complete
			private var _lastResult:String
			private function _exportComplete( result:String ):void
			{
				_lastResult = result;
				trace( result );
			}
			
			
			// -- import
			private function _importComplete():void
			{
				
			}
			
			private function _importError():void
			{
				
			}
			
			
			// -- drag
			private var _drag:Sprite, _dragged:Boolean
			
			private function _dragMd( e:MouseEvent ):void
			{
				_dragged = true;
				this.startDrag();
			}
			
			
			// -- transition
			private var _timer:uint
			
			override protected function _onPreEnter():Boolean 
			{
				_timer = GameLoop.instance.time +FADE_DUR;
				visible = true;
				alpha = 0;
				mouseChildren = false;
				
				return true;
			}
			
			override protected function _doWhileEntering():Boolean 
			{
				var dur:uint = FADE_DUR;
				var t:int = dur - (_timer - GameLoop.instance.time);
				alpha = t<dur? Quad.easeIn( t, 0, 1, dur ) :1;
				
				if ( t < dur )
					return true;
				
				mouseChildren = true;
				
				return false;
			}
			
			override protected function _onPreExit():void 
			{
				_timer = GameLoop.instance.time +FADE_DUR;
				mouseChildren = false;
			}
			
			override protected function _doWhileExiting():Boolean 
			{
				var dur:uint = FADE_DUR;
				var t:int = dur - (_timer - GameLoop.instance.time);
				alpha = t<dur? Quad.easeIn( t, 1, -1, dur ) :0;
				
				if ( t < dur )
					return true;
				
				visible = false;
				alpha = 1;
				
				return false;
			}
			
			
			
	}

}