package pb2.game.ctrl 
{
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.math.Trigo;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	import pb2.game.entity.b2.b2EntityTileTool;
	import pb2.game.MapData;
	import pb2.game.MapList;
	import pb2.game.Tile;
	/**
	 * ...
	 * @author ...
	 */
	public class SaveDataMngr 
	{
		public static const instance:SaveDataMngr = new SaveDataMngr
		
		public static const SAVE_NAME:String = 'jaycsantos.com/puttbase2/savedata1'
		public static const SAVE_SIZE:uint = 10000
		
		
		public function SaveDataMngr() 
		{
			if ( instance ) throw new Error('[pb2.game.ctrl.SaveDataMngr] Singleton class, use static property instance');
			
			var so:SharedObject = SharedObject.getLocal( SAVE_NAME, '/' );
			//if ( so.size && so.data.bytes && so.data.bytes.bytesAvailable ) {
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
		
		public function validate( xml:XML ):void
		{
			var saveLvls:XMLList = _xml.l.lvl;
			if ( ! saveLvls || _validated ) return;
			
			trace( "4:", '[save validated]' );
			
			var found:Boolean, i:int = saveLvls.length();
			while ( i-- )
				if ( ! xml.level.(@hash == saveLvls[i].@hash).(@name == saveLvls[i].@name).length() ) {
					found = true;
					trace( "3:", 'INVALID level', saveLvls[i].@name );
					delete saveLvls[i];
				}
			
			i = 10;
			while( i-- )
				saveCustom( 'g'+i, uint(_xml.l.lvl.(@group==i).(@ok==1).length()), false );
			
			trace( _xml.toXMLString() );
			_save();
			_validated = true;
		}
		
		public function clearData():void
		{
			var so:SharedObject = SharedObject.getLocal( SAVE_NAME, '/' );
			so.clear();
			
			_xml = <x><c><sounds>1</sounds><music>1</music></c><l></l><p></p></x>;
			
			_save();
		}
		
		
		public function openLevel( name:String, group:uint, hash:String ):void
		{
			var n:String = name.replace(/\s/g,'');
			// create playable level data
			if ( !_xml.l[0].child('lvl').length() || !_xml.l[0].lvl.(@name == n).length() )
				_xml.l[0].appendChild( XML('<lvl name="'+ n +'" hash="'+ hash +'" group="'+ group +'" ok="0" score="0" par="0" item="0"/>') );
		}
		
		public function isLevelOpen( data:XML ):Boolean
		{
			if ( !_xml.l[0].child('lvl').length() || !_xml.l[0].lvl.(@name == data.@name).length() ) {
				if ( MapImport.validate(data) && (!data.child('requires').length() || (data.child('requires').length() && uint(getCustom('g'+data.requires.@group)) >= uint(data.requires.@count))) )
					_xml.l[0].appendChild( XML('<lvl name="'+ data.@name +'" hash="'+ data.@hash +'" group="'+ data.@group +'" ok="0" score="0" par="0" item="0"/>') );
				else
					return false;
			}
			return true;
		}
		
		public function saveLevelData( map:MapData, score:uint, par:int, items:uint, date:String ):void
		{
			_saveLevelData( _xml.l[0], map, score, par, items, date );
			
			saveCustom( 'g'+map.group, _xml.l[0].lvl.(@group==map.group).(@ok==1).length() );
			
			_save();
		}
		
		public function getLevelData( name:String, hash:String ):XML
		{
			return _getLevelData( _xml.l[0], name, hash );
		}
		
		public function saveLevelRank( hash:String, date:String, week:Array=null, month:Array=null, alltime:Array=null ):void
		{
			var xml:XML = _xml.l[0];
			// has existing level data
			if ( xml.child('lvl').length() && xml.lvl.(@hash==hash).length() ) {
				var lvl:XML = xml.lvl.(@hash==hash)[0];
				lvl.@date = date;
				
				if ( week && week.length )
					_saveLevelRank( lvl, 'rank_wk', week );
				if ( month && month.length )
					_saveLevelRank( lvl, 'rank_mo', month );
				if ( alltime && alltime.length )
					_saveLevelRank( lvl, 'rank_all', alltime );
				
				_save();
			}
		}
		
		
		public function savePlayerLevelData( map:MapData, score:uint, par:int, items:uint, date:String ):void
		{
			_saveLevelData( _xml.p[0], map, score, par, items, date );
			
			_save();
		}
		
		public function getPlayerLevelData( name:String, levelId:String ):XML
		{
			return _getLevelData( _xml.p[0], name, levelId );
		}
		
		public function savePlayerLevelRank( levelId:String, date:String, rank:uint, leaders:Array ):void
		{
			var xml:XML = _xml.p[0];
			// has existing level data
			if ( xml.child('lvl').length() && xml.lvl.(@hash==levelId).length() ) {
				var lvl:XML = xml.lvl.(@hash==levelId)[0];
				lvl.@date = date;
				
				_saveLevelRank( lvl, 'rank_all', new Array([rank]).concat(leaders) );
				
				_save();
			}
		}
		
		public function savePlayerLevelRating( levelId:String, rating:uint ):void
		{
			// has existing level data
			if ( _xml.p[0].child('lvl').length() && _xml.p[0].lvl.(@hash==levelId).length() ) {
				var xml:XML = _xml.p[0].lvl.(@hash==levelId)[0];
				xml.@rated = rating;
				
				_save();
			}
		}
		
		
		
		public function saveCustom( id:String, value:*, saveNow:Boolean=false ):void
		{
			if ( _xml.c.child(id).length() )
				delete _xml.c[id];
			_xml.c.appendChild( XML('<'+id+'>'+ String(value) +'</'+id+'>') );
			if ( saveNow ) _save();
		}
		
		public function getCustom( id:String ):String
		{
			if ( _xml.c.child(id).length() )
				return _xml.c.child(id)[0].children().toXMLString();
			else
				return null;
		}
		
		public function getTotalData():XML
		{
			var score:uint, par:int, item:uint, extra:uint, underpars:uint, aces:uint, count:uint;
			var i:int = _xml.l.child('lvl').length();
			while ( i-- ) {
				score += uint(_xml.l.lvl[i].@score);
				par += int(_xml.l.lvl[i].@par);
				item += uint(_xml.l.lvl[i].@item);
				count += uint(_xml.l.lvl[i].@score)>0 ? 1 : 0;
			}
			
			return XML('<total score="'+ score +'" par="'+ par +'" item="'+ item +'" count="'+ count +'" />');
		}
		
		public function getGroupTotalData( sett:uint ):XML
		{
			var score:uint, par:int, item:uint, extra:uint, count:uint;
			var maps:XMLList = MapList.list.level.(@sett==sett+'');
			var x:XML, xml:XMLList = _xml.l.child('lvl');
			/*var i:int = xml.length();
			while ( i-- )
				if ( maps.(@hash == xml[i].@hash) && xml[i].@ok=='1' ) {
					score += uint(xml[i].@score);
					par += uint(xml[i].@par);
					item += uint(xml[i].@item);
				}
			*/
			var i:int = maps.length();
			while ( i-- )
				if ( xml.(@hash==maps[i].@hash).length() ) {
					x = xml.(@hash==maps[i].@hash)[0];
					score += uint(x.@score);
					par += int(x.@par);
					item += uint(x.@item);
					count += uint(x.@score)>0 ? 1 : 0;
				}
			
			return XML('<total score="'+ score +'" par="'+ par +'" item="'+ item +'" count="'+ count +'" />');
		}
		
		
			// -- private --
			
			private var _xml:XML, _validated:Boolean
			
			
			private function _saveLevelData( xml:XML, map:MapData, score:uint, par:int, items:uint, date:String ):void
			{
				var level:XML, a:Array, t:b2EntityTileTool, ghost:Array=[], itemList:Array=[];
				
				// has existing level data
				if ( xml.child('lvl').length() && xml.lvl.(@hash==map.hash).length() )
					level = xml.lvl.(@hash==map.hash)[0];
				else
					xml.appendChild( level = XML('<lvl name="'+ map.name +'" hash="'+ map.hash +'" group="'+ map.group +'" ok="0" score="0" par="0" item="0" date="" extra=""/>') );
				
				// this is better
				if ( score >= uint(level.@score) ) {
					//level.@hash
					level.@score = score;
					level.@par = par;
					level.@item = items;
					level.@date = date;
					
					
					var b64:Base64Encoder = new Base64Encoder;
					//b64.encode( (new Date().valueOf()/1000 >>0)+'' );
					b64.encode( MathUtils.randomInt(0,131072)+'' );
					level.@extra2 = level.@extra;
					level.@extra = b64.toString();
					/*if ( list != null )
						for each ( a in list )
							ghost.push( a[0], a[1], Math.round(a[2]*100)/100, Math.round(a[3]*100)/100, Math.round(a[4]*100)/100, Math.round(a[5]*100)/100 );
					level.@ghost = ghost.join(',');
					
					if ( list2 != null )
						for each( t in list2 )
							itemList.push( Tile.getTileCode(t.type), t.defTileX, t.defTileY, t.defRa*Trigo.RAD_TO_DEG/90 +4 >>0 );
					level.@items = itemList.join(',');*/
				}
				
				level.@ok = '1';
			}
			
			private function _getLevelData( xml:XML, name:String, hash:String ):XML
			{
				var n:String = name.replace(/\s/g,'');
				// has existing level data
				if ( xml.child('lvl').length() && xml.lvl.(@name == n).(@hash == hash).length() )
					return XML( xml.lvl.(@name == n).(@hash == hash )[0].toXMLString() );
					
				// has no data
				else
					return null;
				
			}
			
			
			private function _saveLevelRank( lvl:XML, cat:String, list:Array ):void
			{
				if ( !lvl.child(cat).length() )
					lvl.appendChild( XML('<'+ cat +' r="0" pr="0"><lead score="0"></lead><lead score="0"></lead></'+ cat +'>') );
				
				var xml:XML = lvl.child(cat)[0];
				xml.@pr = xml.@r;
				xml.@r = list[0];
				if ( list.length > 1 ) {
					xml.lead[0] = list[1];
					xml.lead[0].@score = list[2];
				}
				if ( list.length > 3 ) {
					xml.lead[1] = list[3];
					xml.lead[1].@score = list[4];
				}
			}
			
			
			private function _save():void
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
				so.flush( Math.max(SAVE_SIZE, b.length) *1.1 );
				
				trace( '4:saved:', SAVE_NAME, so.size );
				trace( _xml.toXMLString() );
			}
			
			
	}

}