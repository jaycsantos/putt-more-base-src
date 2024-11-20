package pb2.game.entity.tile 
{
	import Box2D.Common.Math.b2Vec2;
	import com.jaycsantos.entity.Entity;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.MathUtils;
	import flash.utils.ByteArray;
	import pb2.game.Registry;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class FloorTexture extends Entity
	{
		public static const TYPE_NORMAL:uint = 0, TYPE_WATER:uint = 1, TYPE_SAND:uint = 2, TYPE_CARPET:uint = 3;
		public static const TYPE_STRING:Array = ['', 'water', 'sand', 'carpet'];
		public static const TYPE_DAMP:Vector.<Number> = Vector.<Number>([1, 3, 6, .5]);
		
		
		public var floorRender:FloorTextureRender
		
		public function FloorTexture( args:EntityArgs ) 
		{
			super( args );
			
			var ses:Session = Session.instance;
			_cols = ses.cols; _rows = ses.rows;
			
			
			_byteMap = new ByteArray;
			
			var len:uint = ses.cols *ses.rows;
			for ( var i:int = 0; i < len; i++ )
				if ( i % 4 == 0 )
					_byteMap.writeByte( 0 );
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			floorRender = null;
			_byteMap = null;
		}
		
		
		public function init( binary:Vector.<Boolean>, type:Vector.<uint> ):void
		{
			var ses:Session = Session.instance;
			var i:int, j:int, t:int
			
			_cols = ses.cols; _rows = ses.rows;
			
			for ( var k:String in binary )
				if ( binary[k] ) {
					t = type.shift();
					_byteMap[ int(k)/4 >> 0 ] += t%4 << (int(k)%4)*2;
					
					floorRender.setTexture( int(k)%_cols, int(k)/_cols, t );
				}
		}
		
		
		public function resize( cols:uint, rows:uint ):void
		{
			var ba:ByteArray = new ByteArray;
			var i:int, j:int, p:int, p2:int, n:int;
			
			var len:uint = cols *rows;
			for ( i = 0; i < len; i++ )
				if ( i%4 == 0 ) ba.writeByte( 0 );
			
			var c:int = Math.min( cols, _cols ), r:int = Math.min( rows, _rows );
			for ( j = 0; j < r; j++ )
				for ( i = 0; i < c; i++ ) {
					p = j *_cols +i;
					p2 = j *cols +i;
					
					n = ( (_byteMap[ (p/4 >>0) ] >>>(p%4)*2)%4 );
					ba[ (p2/4 >>0) ] += n <<( p2%4 )*2;
				}
			_byteMap = ba;
			_cols = cols;
			_rows = rows;
		}
		
		
		public function getTexture( col:uint, row:uint ):uint
		{
			if ( col < 0 || row < 0 || col >= _cols || row >= _rows )
				return 0;
			
			// MapExport parses through col first before row
			var p:int = row*_cols + col;
			if ( p/4 < _byteMap.length )
				return (_byteMap[ (p/4 >>0) ] >>> (p%4)*2) %4;
			return 0;
		}
		
		public function setTexture( col:uint, row:uint, value:uint ):void
		{
			if ( col < 0 || row < 0 || col >= _cols || row >= _rows )
				return;
				
			// MapExport parses through col first before row
			var p:int = row*_cols + col;
			if ( p/4 < _byteMap.length ) { 
				var n:int = _byteMap[ (p/4 >>0) ];
				var m:int = ((n >>> (p%4)*2)%4);
				if ( m != value ) {
					n &= ~(3 << (p%4)*2);
					n += value%4 << (p%4)*2;
					_byteMap[ (p/4 >>0) ] = n;
					floorRender.setTexture( col, row, value );
				}
			}
			
		}
		
		
		public function getDampXY( x:Number, y:Number ):Number
		{
			var ts:uint = Registry.tileSize;
			var n:uint = getTexture(x/ts -.5 >> 0, y/ts -.5 >> 0);
			if ( !isNaN(n) && TYPE_DAMP[n] )
				return TYPE_DAMP[ n ];
			return 1;
		}
		
		public function getDampB2vec2( v:b2Vec2 ):Number
		{
			return getDampXY( v.x *Registry.b2Scale, v.y *Registry.b2Scale );
		}
		
			// -- private --
			
			private var _byteMap:ByteArray
			private var _cols:uint, _rows:uint
		
	}

}