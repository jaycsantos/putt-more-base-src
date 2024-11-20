package pb2.util 
{
	import flash.utils.ByteArray;
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Short 
	{
		
		public function Short() 
		{
			
		}
		
		
		
		public static function mapBinaryCompress( bin:String ):String
		{
			var l:uint = bin.length;
			var i:uint = l / 8 << 0;
			var b:ByteArray = new ByteArray();
			b.position = 0;
			var j:uint = 0;
			var d:uint = 0;
			var bm:uint = 1;
			
			while ( j++ < l ) {
				d += uint(bin.substr( -j, 1 )) * bm;
				bm *= 2;
				if ( j % 8 == 0 ) {
					b.writeByte( d );
					d = 0;
					bm = 1;
				} else if ( j >= l ) {
					b.writeByte( d );
					break;
				}
			}
			b.deflate();
			var b64:Base64Encoder = new Base64Encoder();
			b64.encodeBytes( b );
			
			var r:String = b64.toString();
			
			return r;
		}
		
		public static function mapBinaryDecompress( value:String ):String
		{
			var b64:Base64Decoder = new Base64Decoder();
			b64.decode( value );
			var b:ByteArray = b64.toByteArray();
			b.inflate();
			b.position = 0;
			
			var v:Vector.<String> = new Vector.<String>();
			var s:String = '';
			var k:int = 0;
			var d:uint;
			
			while ( b.position < b.length ) {
				d = b.readUnsignedByte();
				s = d.toString(2);
				
				if ( s.length < 8 ) {
					k = 8 - s.length;
					while ( k-- ) s = "0" + s;
				}
				v.push( s );
				s = '';
			}
			v.reverse();
			
			return v.join('');
		}
		
	}

}