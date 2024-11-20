package pb2.game 
{
	import com.jaycsantos.ExternalAssetFactory;
	import pb2.util.CustomLevel;
	import pb2.util.pb2internal;
	import Playtomic.PlayerLevel;
	/**
	 * ...
	 * @author ...
	 */
	public class MapData 
	{
		public function MapData( xmlData:XML, customLevel:CustomLevel=null, levelIndex:int=-1 ) 
		{
			_xml = XML(xmlData.toXMLString());
			_customLvl = customLevel;
			_lvlIndex = levelIndex
		}
		
		public function loaded():void
		{
			_loaded = true;
		}
		
		public function get isCustom():Boolean
		{
			return Boolean(_customLvl);
		}
		
		public function get customLevel():CustomLevel
		{
			return _customLvl;
		}
		
		public function get isLoaded():Boolean
		{
			return _loaded;
		}
		
		public function get str():String
		{
			return _xml.map;
		}
		
		public function get hash():String
		{
			return _customLvl ? _customLvl.id : _xml.@hash;
		}
		
		public function get name():String
		{
			return _xml.@name;
		}
		
		public function get group():uint
		{
			return uint(_xml.@group);
		}
		
		public function get sett():uint
		{
			return uint(_xml.@sett);
		}
		
		public function get item():uint
		{
			return uint(_xml.item);
		}
		
		public function get par():uint
		{
			return uint(_xml.par);
		}
		
		public function get extra():uint
		{
			return uint(_xml.extra);
		}
		
		
		public function get xml():XML
		{
			return XML(_xml.toXMLString());
		}
		
		public function get levelIndex():int
		{
			return _lvlIndex;
		}
		
		
		pb2internal function set customLevel( value:CustomLevel ):void
		{
			_customLvl = value;
		}
		
			// -- private --
			
			private var _xml:XML, _loaded:Boolean, _customLvl:CustomLevel, _lvlIndex:int
		
		
	}

}