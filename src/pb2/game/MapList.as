package pb2.game 
{
	import com.jaycsantos.ExternalAssetFactory;
	import mx.core.ByteArrayAsset;
	/**
	 * ...
	 * @author jaycsantos
	 */
	CONFIG::release {
	[Embed(source="../../../lib/pb2.levels.xml", mimeType="application/octet-stream")] }
	public class MapList extends ByteArrayAsset
	{
		public function MapList()
		{ }
		
		public static function get list():XML
		{
			CONFIG::release { const xml:XML = XML(new MapList); }
			CONFIG::debug { const xml:XML = ExternalAssetFactory(PuttBase2.assets).getXML('levels'); }
			
			return xml;
		}
		
	}

}