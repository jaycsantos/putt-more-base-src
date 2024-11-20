package pb2.game.ctrl 
{
	import apparat.math.FastMath;
	import com.adobe.crypto.MD5;
	import com.demonsters.debugger.MonsterDebugger;
	import com.jaycsantos.display.screen.AbstractScreen;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.IDisposable;
	import com.jaycsantos.math.Trigo;
	import com.jaycsantos.util.GameLoop;
	import com.jaycsantos.util.ns.internalGameloop;
	import flash.utils.ByteArray;
	import mx.utils.Base64Decoder;
	import pb2.game.entity.b2.*;
	import pb2.game.entity.*;
	import pb2.game.entity.misc.*;
	import pb2.game.*;
	import pb2.screen.EditorScreen;
	import pb2.screen.ui.HudGame;
	import pb2.screen.ui.toolbox.ToolBoxNode;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class MapImport implements IDisposable 
	{
		public var importStr:String
		public var onInit:Function
		public var onComplete:Function
		public var onError:Function
		public var key:String = '';
		
		public function MapImport( value:String, initCall:Function, completeCall:Function, errorCall:Function, k:String='' ) 
		{
			importStr = value;
			onInit = initCall;
			onComplete = completeCall;
			onError = errorCall;
			key = k;
		}
		
		public function dispose():void
		{
			_typeMap = null;
			_rotationMap = null;
			_linkMap = null;
			_linkRelays = null;
			onInit = null;
			onComplete = null;
		}
		
		
		public function start():void
		{
			GameLoop.instance.internalGameloop::addCallback( _update );
		}
		
		
		public static function validate( xmlData:XML, k:String=null ):Boolean
		{
			if ( xmlData.@hash != MD5.hash(xmlData.map.toString()+xmlData.par.toString()+xmlData.item.toString()) )
				return false;
				
			if ( k != null ) {
				var a:Array = String(xmlData.map).split('');
				var i:int = a.length/2<<0;
				
				var s1:String ='', s2:String ='';
				while ( i-- ) {
					s1 += a[i*2];
					s2 += a[i*2+1];
				}
				var s:String = s1 + s2.split('').reverse().join('');
				
				if ( MD5.hash(k).substr(8, 6) != s.substr(5, 6) )
					return false;
			}
			
			return true;
		}
		
		
			// -- private --
			
			private var _calls:Vector.<Function> = Vector.<Function>([_step1, _step2, _step3, _step4, _step5, _step6, _step7]);
			private var _cols:int, _rows:int, _par:uint, _ctr:int
			
			private var _binaryMap:Vector.<Boolean> = new Vector.<Boolean>
			private var _typeMap:Vector.<uint> = new Vector.<uint>
			private var _rotationMap:Vector.<uint> = new Vector.<uint>
			
			private var _binaryFMap:Vector.<Boolean> = new Vector.<Boolean>
			private var _fTypeMap:Vector.<uint> = new Vector.<uint>
			
			private var _linkMap:Vector.<uint> = new Vector.<uint>
			private var _linkRelays:Vector.<Ib2SignalRelay> = new Vector.<Ib2SignalRelay>
			private var _toolsMap:Vector.<uint> = new Vector.<uint>
			private var _toolsCount:Vector.<uint> = new Vector.<uint>
			private var _toolsRelMap:Vector.<uint> = new Vector.<uint>
			private var _portalMap:Vector.<uint> = new Vector.<uint>
			private var _portals:Vector.<Portal> = new Vector.<Portal>
			private var _key:String
			
			
			private function _update():void
			{
				if ( _calls.length ) {
					_calls[0].call()
				} else {
					onComplete();
					_stop();
					dispose();
				}
			}
			
			private function _stop():void
			{
				GameLoop.instance.internalGameloop::removeCallback( _update );
			}
			
			
			private function _step1():void
			{
				var i:int, b:int, bits:int, ba:ByteArray, b64:Base64Decoder = new Base64Decoder;
				
				try {
					//var s:String = b64.toString().replace( RegExp(/A/g), '_' ).replace( RegExp(/=/g), 'A' ).replace( RegExp(/\//g), '-' ).replace( RegExp(/\n/g), '' );
					//var s:String = importStr.replace(RegExp(/-/g), '/').replace(RegExp(/A/g), '=').replace(RegExp(/_/g), 'A');
					
					var a:Array = importStr.split('');
					i = a.length/2<<0;
					
					var s1:String ='', s2:String ='';
					while ( i-- ) {
						s1 += a[i*2];
						s2 += a[i*2+1];
					}
					var s:String = s1 + s2.split('').reverse().join('');
					_key = s.substr(5, 6);
					
					s = s.substr(0, 5) +s.substr(11);
					s = s.replace(RegExp(/-/g), '/').replace(RegExp(/A/g), '=').replace(RegExp(/_/g), 'A');
					
					
					b64.decode( s );
					ba = b64.toByteArray();
					ba.inflate();
					ba.position = 0;
					
					// binary map
					i = ba.readUnsignedShort();
					while ( i-- ) {
						b = ba.readUnsignedByte();
						bits = 8;
						while( bits-- ) {
							_binaryMap.push( b & 1 );
							b = b >>> 1;
						}
					}
					
					// par
					_par = ba.readUnsignedByte();
					
					// cols
					_cols = ba.readUnsignedByte();
					
					// bg color index
					Session.instance.bgColorIdx = ba.readUnsignedByte();
					
					// type map
					i = ba.readUnsignedShort();
					while ( i-- )
						_typeMap.push( ba.readUnsignedByte() );
					
					// rotation map
					i = ba.readUnsignedShort();
					while ( i-- ) {
						b = ba.readUnsignedByte()
						bits = 4;
						while ( bits-- ) {
							_rotationMap.push( b & 3 );
							b = b >>> 2;
						}
					}
					
					// link map
					i = ba.readUnsignedShort();
					while ( i-- ) {
						b = ba.readUnsignedByte()
						bits = 2;
						while ( bits-- ) {
							_linkMap.push( b & 15 );
							b = b >>> 4;
						}
					}
					
					// tools map
					i = ba.readUnsignedShort();
					while ( i-- )
						_toolsMap.push( ba.readUnsignedByte() );
					// tools released map
					i = ba.readUnsignedShort();
					while ( i-- )
						_toolsRelMap.push( ba.readUnsignedShort() );
					// tools count
					i = ba.readUnsignedShort();
					while ( i-- ) {
						b = ba.readUnsignedShort();
						bits = 5;
						while ( bits-- ) {
							_toolsCount.push( b & 7 );
							b = b >>> 3;
						}
					}
					
					// portal links
					i = ba.readUnsignedByte();
					while ( i-- ) {
						b = ba.readUnsignedByte()
						bits = 2;
						while ( bits-- ) {
							_portalMap.push( b & 15 );
							b = b >>> 4;
						}
					}
					
					// binary floor map
					i = ba.readUnsignedShort();
					while ( i-- ) {
						b = ba.readUnsignedByte();
						bits = 8;
						while( bits-- ) {
							_binaryFMap.push( b & 1 );
							b = b >>> 1;
						}
					}
					
					
					// floor type map
					i = ba.readUnsignedShort();
					while ( i-- ) {
						b = ba.readUnsignedByte();
						bits = 4;
						while ( bits-- ) {
							_fTypeMap.push( b & 3 );
							b = b >>> 2;
						}
					}
					
					// check for 3 more zero shorts
					i = ba.readUnsignedShort();
					i = ba.readUnsignedShort();
					i = ba.readUnsignedShort();
					/**/
					
					_rows = _binaryMap.length / _cols << 0;
					_binaryMap.splice( _cols*_rows, _binaryMap.length - _cols*_rows );
				}
				catch ( e:Error ) {
					onError( e );
					_stop();
					dispose();
				}
				
				_calls.shift();
			}
			
			private function _step2():void
			{
				onInit( _cols, _rows );
				
				Session.instance.floor.init( _binaryFMap, _fTypeMap );
				
				_calls.shift();
			}
			
			private function _step3():void
			{
				var typeCode:int, type:String, materialName:String, tile:b2EntityTile, tx:int, ty:int, a:Number;
				
				var i:int = 10, tileMap:Vector.<Vector.<b2EntityTile>> = Session.instance.tileMap;
				try {
					while ( i-- && _ctr < _binaryMap.length ) {
						tx = _ctr % _cols;
						ty = _ctr / _cols << 0;
						if ( ! _binaryMap[_ctr++] ) continue;
						
						type = Tile.getTileType( typeCode = _typeMap.shift() );
						tile = Session.factory.spawnEntity( type ) as b2EntityTile;
						
						if ( GameRoot.screen is EditorScreen ) {
							EditorScreen(GameRoot.screen).toolBar.requestTile( type );
							tile.onDispose.addOnce( EditorScreen(GameRoot.screen).toolBar.returnTileWgt );
							if ( tile is Portal )
								EditorScreen(GameRoot.screen).toolBar.addPortal( tile as Portal, false );
						}
						
						a = 0;
						if ( Tile.TILE_NONROTATES.indexOf(type) == -1 )
							a = Trigo.simplifyRadian( int(_rotationMap.shift()) *90 *Trigo.DEG_TO_RAD );
						
						tile.setDefault( (tx+1)*Registry.tileSize, (ty+1)*Registry.tileSize, a );
						
						if ( tile is Ball && typeCode == 255 )
							BallCtrl.instance.setPrimary( tile as Ball );
						else if ( tile is Ib2SignalRelay )
							_linkRelays.push( tile as Ib2SignalRelay );
						else if ( tile is Portal )
							_portals.push( tile as Portal );
						
						
						tileMap[tx][ty] = tile;
					}
					
				}
				catch ( e:Error ) {
					onError( e );
					_stop();
					dispose();
				}
				
				if ( _ctr >= _binaryMap.length )
					_calls.shift();
			}
			
			private function _step4():void
			{
				var tileMap:Vector.<Vector.<b2EntityTile>> = Session.instance.tileMap;
				var iL:int = tileMap.length;
				var jL:int = tileMap[0].length;
				var i:int, j:int, m:int, tile:b2EntityTile;
				
				try {
					for ( j = 0; j < jL; j++ )
						for ( i = 0; i < iL; i++ ) {
							if ( !(tile = tileMap[i][j]) )
								continue;
							
							if ( tile is Ib2SignalNode ) {
								if ( _linkMap[0] > 0 )
									Ib2SignalNode(tile).relayTo( _linkRelays[_linkMap[0]-1] );
								_linkMap.shift();
								
							} else 
							if ( tile is PushButton || tile is Puncher2 ) {
								switch( tile.defRa ) {
									case 0:
										if ( tile.defTileX > 0 )
											tile.requiresTile = tileMap[ tile.defTileX-1 ][ tile.defTileY ];
										break;
									case Trigo.HALF_PI:
										if ( tile.defTileY > 0 )
											tile.requiresTile = tileMap[ tile.defTileX ][ tile.defTileY-1 ];
										break;
									case Math.PI:
										if ( tile.defTileX < iL-1 )
											tile.requiresTile = tileMap[ tile.defTileX+1 ][ tile.defTileY ];
										break;
									case -Trigo.HALF_PI:
										if ( tile.defTileY < jL-1 )
											tile.requiresTile = tileMap[ tile.defTileX ][ tile.defTileY+1 ];
										break;
									default: break;
								}
							}
						}
					
				}
				catch ( e:Error ) {
					onError( e );
					_stop();
					dispose();
				}
				
				_calls.shift();
			}
			
			private function _step5():void
			{
				var screen:AbstractScreen = GameRoot.screen;
				if ( screen.hasOwnProperty('hud') && screen['hud'] is HudGame ) {
					var type:String, data:Object ={}, released:Object ={};
					var tileMap:Vector.<Vector.<b2EntityTile>> = Session.instance.tileMap;
					
					for ( var k:String in _toolsMap ) {
						type = Tile.getTileType( _toolsMap[k] );
						data[type] = _toolsCount[int(k)*2];
						released[type] = _toolsCount[int(k)*2 +1];
					}
					
					var hud:HudGame = screen['hud'] as HudGame;
					hud.init( data );
					
					/*
					// only for owner on editor
					if ( MD5.hash(key).substr(8, 6) == _key && screen is EditorScreen ) {
						var j:int, tile:b2EntityTileTool, m:uint, tx:uint, ty:uint;
						for ( k in released ) {
							var i:int = released[k];
							while ( i-- ) {
								tile = hud.releaseTool( k );
								m = _toolsRelMap[j];
								tx = m & 31;
								ty = (m >>> 5) & 31;
								tile.setDefault( (tx+1)*Registry.tileSize, (ty+1)*Registry.tileSize, ((m>>>10) &3) *Trigo.HALF_PI );
								tileMap[tx][ty] = tile;
								j++;
							}
						}
					}*/
					
				}
				_calls.shift();
			}
			
			private function _step6():void
			{
				var p1:Portal, p2:Portal, m:int
				for ( var i:int; i<_portals.length; i++ ) {
					p1 = _portals[i];
					if ( !p1.isLinked ) {
						m = _portalMap.shift();
						if ( m ) {
							p2 = _portals[i+m];
							p1.linkTo( p2 );
							p2.linkTo( p1 );
						}
					}
				}
				
				_calls.shift();
			}
			
			private function _step7():void
			{
				MoreTexture.run( Session.instance.tileMap );
				
				_calls.shift();
			}
		
		
	}

}