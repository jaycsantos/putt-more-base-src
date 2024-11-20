package pb2.game.ctrl 
{
	import com.adobe.crypto.MD5;
	import com.jaycsantos.math.Trigo;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	import flash.utils.ByteArray;
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	import pb2.game.entity.b2.b2EntityTileTool;
	import pb2.game.Tile;
	/**
	 * ...
	 * @author ...
	 */
	public class MapDataMngr 
	{
		public static const instance:MapDataMngr = new MapDataMngr
		
		public static const SAVE_NAME:String = 'jaycsantos.com/puttbase2/mapdata'
		public static const SAVE_SIZE:uint = 10000
		
		public function MapDataMngr() 
		{
			if ( instance ) throw new Error('[pb2.game.ctrl.MapDataMngr] Singleton class, use static property instance');
			
			var so:SharedObject = SharedObject.getLocal( SAVE_NAME, '/' );
			if ( so.size && so.data.d != undefined ) {
				try {
					var b64:Base64Decoder = new Base64Decoder;
					b64.decode( so.data.d );
					
					var b:ByteArray = b64.toByteArray();
					b.uncompress();
					b.position = 0;
					_xml = new XML( b.readUTF() );
				}
				catch ( e:Error ) {
					trace( '2:',e );
					clearData();
				}
				
			} else {
				clearData();
			}
		}
		
		public function clearData():void
		{
			var so:SharedObject = SharedObject.getLocal( SAVE_NAME, '/' );
			so.clear();
			
			_xml = <x></x>;
			
			_save();
		}
		
		
		public function saveEditMap( map:String, par:uint, item:uint, list:Array=null, list2:Vector.<b2EntityTileTool>=null ):Boolean
		{
			var xml:XML;
			if ( !_xml.child('level').length() )
				_xml.appendChild( xml = XML(<level name="" hash="" sett="0" group="0">
						<map></map>
						<par></par>
						<item></item>
						<ghost></ghost>
						<items></items>
					</level>) );
			else
				xml = _xml.level[0];
			
			xml.map = map;
			xml.par = par;
			xml.item = item;
			xml.@hash = MD5.hash( map+par+item );
			
			var a:Array, t:b2EntityTileTool, ghost:Array=[], itemList:Array=[];
			if ( list != null )
				for each ( a in list )
					ghost.push( a[0], a[1], Math.round(a[2]*100)/100, Math.round(a[3]*100)/100, Math.round(a[4]*100)/100, Math.round(a[5]*100)/100 );
			xml.ghost = ghost.join(',');
			
			if ( list2 != null )
				for each( t in list2 )
					itemList.push( Tile.getTileCode(t.type), t.defTileX, t.defTileY, t.defRa*Trigo.RAD_TO_DEG/90 +4 >>0 );
			xml.items = itemList.join(',');
			
			
			return _save();
		}
		
		public function getEditMap():XML
		{
			if ( _xml.child('level').length() )
				return _xml.level[0];
			return null;
		}
		
		
		public function getDataList():XML
		{
			return XML( _xml.toXMLString() );
		}
		
		public function saveData( hash:String, map:String, options:Object ):Boolean
		{
			// create level data
			if ( !_xml.child('lvl').length() || !_xml.lvl.(@hash==hash).length() )
				_xml.appendChild( XML('<lvl hash="'+ hash +'" name="" shared="0"><map></map><par></par><item></item><extra></extra></lvl>') );
			
			var level:XML = _xml.lvl.(@hash==hash)[0];
			
			level.@name = options.name;
			level.map[0] = map;
			level.par[0] = uint(options.par);
			level.item[0] = uint(options.item);
			level.extra[0] = uint(options.extra);
			if ( options['shared'] )
				level.@shared = 1;
			
			return _save();
		}
		
		public function removeData( mapName:String ):Boolean
		{
			if ( _xml.child('lvl').length() && _xml.lvl.(@name==mapName).length() ) {
				delete _xml.lvl.(@name == mapName)[0];
				return _save();
			}
			return false;
		}
		
		
			// -- private --
			
			private var _xml:XML
			
			private function _save():Boolean
			{
				var so:SharedObject = SharedObject.getLocal( SAVE_NAME, '/' );
				var b:ByteArray = new ByteArray;
				b.writeUTF( _xml.toXMLString() );
				b.compress();
				var b64:Base64Encoder = new Base64Encoder;
				b64.encodeBytes( b );
				//so.data.bytes = b;
				so.data.d = b64.toString();
				//so.data.xml = _xml.toXMLString();
				var res:String = so.flush( Math.max(SAVE_SIZE, b.length)*1.1 );
				
				trace( '4:saved:', SAVE_NAME, so.size );
				trace( _xml.toXMLString() );
				
				return (res == SharedObjectFlushStatus.FLUSHED);
			}
		
		
	}

}