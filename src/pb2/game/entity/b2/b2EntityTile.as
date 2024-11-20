package pb2.game.entity.b2 
{
	import Box2D.Common.Math.b2Vec2;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.Trigo;
	import pb2.game.Registry;
	import pb2.game.Session;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class b2EntityTile extends b2Entity implements Ib2Tile 
	{
		public var shapeName:String;
		public var materialName:String;
		
		public var defPx:Number, defPy:Number;
		public var defRa:Number;
		public var defTileX:int;
		public var defTileY:int;
		
		public var requiresTile:b2EntityTile
		
		
		public function b2EntityTile( args:EntityArgs ) 
		{
			super( args );
			
			shapeName = type.substr( type.indexOf('_') +1 );
			materialName = type.indexOf('_')>-1 ? type.substr( 0, type.indexOf('_') ) : type;
			
			onMoveStart.add( _hasMoved );
		}
		
		override public function dispose():void 
		{
			if ( defTileX > -1 && defTileY > -1 )
				if ( Session.instance.tileMap && 
							defTileX < Session.instance.tileMap.length && 
							defTileY < Session.instance.tileMap[0].length && 
							Session.instance.tileMap[defTileX][defTileY] == this )
					Session.instance.tileMap[defTileX][defTileY] = null;
			
			requiresTile = null;
			
			super.dispose();
		}
		
		
		public function setDefault( x:Number, y:Number, a:Number = 0 ):void
		{
			defPx = x;
			defPy = y;
			defRa = Trigo.simplifyRadian( a );
			
			defTileX = Math.floor( x /Registry.tileSize -.5 );
			defTileY = Math.floor( y /Registry.tileSize -.5 );
			
			useDefault();
			
			if ( render ) render.redraw();
		}
		
		public function useDefault():void
		{
			if ( body ) {
				body.SetPositionAndAngle( new b2Vec2(defPx / Registry.b2Scale, defPy / Registry.b2Scale), defRa );
				body.SetLinearVelocity( new b2Vec2 );
				body.SetAngularVelocity( 0 );
				body.SetAwake( true );
				p.x = defPx;
				p.y = defPy;
			}
			
			_flag.setFalse( FLAG_WASMOVED );
			
			onMoveStop.dispatch( this );
			_flag.setFalse( FLAG_ISMOVING );
			
			onRotateStop.dispatch( this );
			_flag.setFalse( FLAG_ISROTATING );
		}
		
		public function setPos( x:Number, y:Number, a:Number=0 ):void
		{
			body.SetPositionAndAngle( new b2Vec2(x/Registry.b2Scale, y/Registry.b2Scale), Trigo.simplifyRadian(a) );
			body.SetLinearVelocity( new b2Vec2 );
			body.SetAngularVelocity( 0 );
			body.SetAwake( true );
			p.x = x;
			p.y = y;
			
			_flag.setFalse( FLAG_WASMOVED );
		}
		
		
		public function get isToolkit():Boolean
		{
			return _flag.isTrue( FLAG_ISTOOLKIT ) && this is b2EntityTileTool;
		}
		
		public function get wasMoved():Boolean
		{
			return _flag.isTrue( FLAG_WASMOVED );
		}
		
		
			// -- private --
			
			private function _hasMoved( ent:b2Entity ):void
			{
				_flag.setTrue( FLAG_WASMOVED );
			}
			
	}

}