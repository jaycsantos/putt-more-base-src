package pb2.game.ctrl 
{
	import com.adobe.crypto.MD5;
	import com.jaycsantos.IDisposable;
	import com.jaycsantos.math.Trigo;
	import com.jaycsantos.util.GameLoop;
	import com.jaycsantos.util.ns.internalGameloop;
	import flash.utils.ByteArray;
	import mx.utils.Base64Encoder;
	import pb2.game.entity.b2.*;
	import pb2.game.entity.*;
	import pb2.game.*;
	import pb2.game.entity.tile.FloorTexture;
	import pb2.screen.ui.HudGameEditor;
	import pb2.screen.ui.toolbox.ToolBoxNode;      
	import pb2.util.pb2internal;
	import pb2.util.Short;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class MapExport implements IDisposable
	{
		public var key:String, par:uint, onComplete:Function
		
		
		public function MapExport( key:String, par:uint, completeCall:Function )
		{
			this.key = key?key:'';
			this.par = par;
			this.onComplete = completeCall;
		}
		
		public function dispose():void
		{
			_typeMap = null;
			_rotationMap = null;
			_linkMap = null;
			_linkRelays = null;
			onComplete = null;
		}
		
		
		public function start():void
		{
			GameLoop.instance.internalGameloop::addCallback( _update );
			_step1();
		}
		
			// -- private --
			
			private var _calls:Vector.<Function> = Vector.<Function>([_step1, _step2, _step3, _step4, _step5]);
			
			private var _binaryMap:Vector.<uint> = new Vector.<uint>
			private var _typeMap:Vector.<uint> = new Vector.<uint>
			private var _rotationMap:Vector.<uint> = new Vector.<uint>
			
			private var _binaryFMap:Vector.<uint> = new Vector.<uint>
			private var _fTypeMap:Vector.<uint> = new Vector.<uint>
			
			private var _linkMap:Vector.<uint> = new Vector.<uint>
			private var _linkRelays:Vector.<Ib2SignalRelay> = new Vector.<Ib2SignalRelay>
			private var _toolsMap:Vector.<uint> = new Vector.<uint>
			private var _toolsCount:Vector.<uint> = new Vector.<uint>
			private var _toolsRelMap:Vector.<uint> = new Vector.<uint>
			private var _portals:Vector.<Portal> = new Vector.<Portal>
			private var _portalMap:Vector.<uint> = new Vector.<uint>
			private var _portalsDone:Vector.<Portal> = new Vector.<Portal>
			
			
			private var _result:String
			
			
			private function _update():void
			{
				if ( _calls.length ) {
					_calls[0].call()
				} else {
					onComplete( _result );
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
				var tileMap:Vector.<Vector.<b2EntityTile>> = Session.instance.tileMap;
				var f:int, floor:FloorTexture = Session.instance.floor;
				var iL:int = tileMap.length;
				var jL:int = tileMap[0].length;
				var i:int, j:int, tile:b2EntityTile, tcode:int, angle:Number, ctr:int, rotCtr:int, fCtr:int;
				
				for ( j = 0; j < jL; j++ )
					for ( i = 0; i < iL; i++ ) {
						if ( ctr % 8 == 0 ) {
							_binaryMap.push( 0 );
							_binaryFMap.push( 0 );
						}
						
						tile = tileMap[i][j];
						
						f = floor.getTexture( i, j );
						if ( f > 0 ) {
							_binaryFMap[ _binaryFMap.length-1 ] += 1 << (ctr % 8);
							if ( fCtr % 4 == 0 )
								_fTypeMap.push( 0 );
							_fTypeMap[ _fTypeMap.length-1 ] += f << (fCtr%4)*2;
							fCtr++;
						}
						
						if ( ! tile || tile.isToolkit ) {
							ctr++;
							continue;
						}
						
						_binaryMap[ _binaryMap.length-1 ] += 1 << (ctr % 8);
						ctr++;
						
						tcode = Tile.getTileCode( tile.type );
						// primary ball
						if ( tcode == 200 && BallCtrl.instance.isPrimary(tile) ) tcode = 255;
						
						_typeMap.push( tcode );
						
						if ( Tile.TILE_NONROTATES.indexOf(tile.type) == -1 ) {
							if ( rotCtr % 4 == 0 )
								_rotationMap.push( 0 );
							
							angle = Math.round( Trigo.simplifyRadian(tile.defRa) *Trigo.RAD_TO_DEG );
							if ( angle < 0 ) angle += 360;
							
							_rotationMap[ _rotationMap.length -1 ] += int(angle / 90) << ((rotCtr % 4) * 2);
							rotCtr++;
							
							
						} else {
							if ( tile is Ib2SignalRelay )
								_linkRelays.push( tile );
							else if ( tile is Portal )
								_portals.push( tile as Portal );
						}
					}
				
				_calls.shift();
			}
			
			private function _step2():void
			{
				var tileMap:Vector.<Vector.<b2EntityTile>> = Session.instance.tileMap;
				var iL:int = tileMap.length;
				var jL:int = tileMap[0].length;
				var i:int, j:int, k:String, tile:b2EntityTile, tcode:int, angle:Number, linkCtr:int, relay:Ib2SignalRelay;
				
				for ( j = 0; j < jL; j++ )
					for ( i = 0; i < iL; i++ ) {
						tile = tileMap[i][j];
						if ( tile && tile is Ib2SignalNode ) {
							relay = Ib2SignalNode(tile).getRelay();
							
							if ( linkCtr % 2 == 0 )
								_linkMap.push( 0 );
							if ( relay ) {
								for ( k in _linkRelays )
									if ( _linkRelays[k] === relay )
										_linkMap[ _linkMap.length-1 ] += (int(k)+1) << ((linkCtr % 2) *4);
							}
							
							linkCtr++;
						}
					}
				
				_calls.shift();
			}
			
			private function _step3():void
			{
				use namespace pb2internal;
				var hud:HudGameEditor = HudGameEditor.instance;
				var nodes:Vector.<ToolBoxNode> = hud.getNodes();
				var ctr:uint, tile:b2EntityTileTool, released:Vector.<b2EntityTileTool>, angle:Number
				
				for each( var n:ToolBoxNode in nodes ) {
					_toolsMap.push( Tile.getTileCode(n.type) );
					
					released = n.getReleasedTiles();
					
					if ( ctr%5 == 0 ) _toolsCount.push( 0 );
					_toolsCount[ _toolsCount.length-1 ] += n.total << (ctr++%5 *3);
					if ( ctr%5 == 0 ) _toolsCount.push( 0 );
					_toolsCount[ _toolsCount.length-1 ] += released.length << (ctr++%5 *3);
					
					/*for each( tile in released ) {
						angle = Math.round( Trigo.simplifyRadian(tile.defRa) *Trigo.RAD_TO_DEG );
						if ( angle < 0 ) angle += 360;
						_toolsRelMap.push( tile.defTileX +(tile.defTileY<<5) +(Tile.TILE_NONROTATES.indexOf(tile.type)==-1? int(angle /90)<<10: 0) );
					}*/
				}
				
				_calls.shift();
			}
			
			private function _step4():void
			{
				var p1:Portal, n:uint, c:int;
				for ( var i:int; i<_portals.length; i++ ) {
					p1 = _portals[i];
					if ( _portalsDone.indexOf(p1) > -1 )
						continue;
					
					if ( c%2==0 )
						_portalMap.push( 0 );
					if ( p1.isLinked ) {
						n = (_portals.indexOf(p1.linkPortal)-i);
						_portalMap[ _portalMap.length-1 ] += n << (c%2*4);
						_portalsDone.push( p1.linkPortal );
					} else
						n = 0;
					_portalsDone.push( p1 );
					c++;
				}
				
				_calls.shift();
			}
			
			private function _step5():void
			{
				var i:int, ba:ByteArray = new ByteArray, b64:Base64Encoder = new Base64Encoder;
				
				// binary map
				ba.writeShort( _binaryMap.length );
				for each( i in _binaryMap )
					ba.writeByte( i );
				
				// par
				ba.writeByte( par );
				
				// cols
				ba.writeByte( Session.instance.cols );
				
				// bg color index
				ba.writeByte( Session.instance.bgColorIdx );
				
				// type map
				ba.writeShort( _typeMap.length );
				for each( i in _typeMap )
					ba.writeByte( i );
				
				// rotation map
				ba.writeShort( _rotationMap.length );
				for each( i in _rotationMap )
					ba.writeByte( i );
				
				// link map
				ba.writeShort( _linkMap.length );
				for each( i in _linkMap )
					ba.writeByte( i );
				
				// tools map
				ba.writeShort( _toolsMap.length );
				for each( i in _toolsMap )
					ba.writeByte( i );
				// tools released map
				ba.writeShort( _toolsRelMap.length );
				for each( i in _toolsRelMap )
					ba.writeShort( i );
				// tools count
				ba.writeShort( _toolsCount.length );
				for each( i in _toolsCount )
					ba.writeShort( i );
				
				// portal links
				ba.writeByte( _portalMap.length );
				for each( i in _portalMap )
					ba.writeByte( i );/**/
				
				// binary floor map
				ba.writeShort( _binaryFMap.length );
				for each( i in _binaryFMap )
					ba.writeByte( i );
				
				// floor type map
				ba.writeShort( _fTypeMap.length );
				for each( i in _fTypeMap )
					ba.writeByte( i );
				
				// write 3 more zero shorts
				ba.writeShort( 0 );
				ba.writeShort( 0 );
				ba.writeShort( 0 );
				
				
				ba.deflate();
				b64.encodeBytes( ba );
				
				var s:String = b64.toString().replace( RegExp(/A/g), '_' ).replace( RegExp(/=/g), 'A' ).replace( RegExp(/\//g), '-' ).replace( RegExp(/\n/g), '' );
				s = s.substr(0,5) +MD5.hash(String(key)).substr(8,6) +s.substr(5);
				
				var a1:Array = s.substr(0, s.length/2<<0).split('').reverse();
				var a2:Array = s.substr(s.length/2<<0).split('');
				
				_result = '';
				i = a1.length;
				while ( i-- ) _result += a1.shift() +a2.shift();
				_result += a2.join() +a1.join();
				
				_calls.shift();
			}
			
			
	}

}