package pb2.game.entity 
{
	import Box2D.Dynamics.b2FixtureDef;
	import com.jaycsantos.entity.EntityArgs;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.entity.render.SolidBlkRender;
	import pb2.game.Registry;
	import pb2.game.Session;
	import pb2.game.Tile;
	
	/**
	 * ...
	 * @author ...
	 */
	public class SolidBlock extends b2EntityTile implements ISolidWall
	{
		public var blkRender:SolidBlkRender
		
		
		public function SolidBlock( args:EntityArgs )
		{
			super( args );
			
			createBody();
			
			_flag.setTrue( FLAG_ISFIXED );
		}
		
		override public function createBody():void 
		{
			body = Session.b2world.CreateBody( Registry.STATIC_b2BodyDef );
			body.SetUserData( this );
			
			var fixtDef:b2FixtureDef;
			switch( materialName ) {
				case 'wpad': fixtDef = Registry.STATIC_MOSS_b2FixtDef; break;
				case 'wrub': fixtDef = Registry.STATIC_RUBBER_b2FixtDef; break;
				case 'wall': default: fixtDef = Registry.STATIC_b2FixtDef; break;
			}
			fixtDef.shape = Tile.getb2Shape( shapeName );
			body.CreateFixture( fixtDef );
			
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			blkRender = null;
		}
		
		
		override public function setDefault( x:Number, y:Number, a:Number = 0 ):void 
		{
			super.setDefault( x, y, a );
			blkRender.redrawAndNeighbors();
		}
		
		
	}

}