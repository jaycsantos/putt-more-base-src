package pb2.game.entity 
{
	import Box2D.Dynamics.b2FixtureDef;
	import com.jaycsantos.entity.EntityArgs;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.entity.render.FloorGateCDRender;
	import pb2.game.Registry;
	import pb2.game.Session;
	import pb2.game.Tile;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class FloorGateCD extends b2EntityTile 
	{
		public static const RADIUS:uint = 11
		public static const ISREVERSED:uint = 1 << 19
		
		public var gateRender:FloorGateCDRender
		
		public function FloorGateCD( args:EntityArgs )
		{
			super( args );
			
			_flag.setFlag( ISREVERSED, Boolean(args.data.isReversed) );
			_flag.setTrue( FLAG_ISFIXED );
			
			createBody();
		}
		
		override public function createBody():void 
		{
			var ts:Number = Registry.tileSize /Registry.b2Scale, ts2:Number = ts /2;
			
			body = Session.b2world.CreateBody( Registry.STATIC_b2BodyDef );
			body.SetUserData( this );
			
			var fixtDef:b2FixtureDef = Registry.STATIC_b2FixtDef;
			fixtDef.shape = Tile.getb2Circle( FloorGateCD.RADIUS );
			body.CreateFixture( fixtDef );
		}
		
		
		override public function useDefault():void 
		{
			super.useDefault();
			
			body.SetActive( _flag.isFalse(ISREVERSED) );
			gateRender.reset();
		}
		
		
		public function get isReversed():Boolean
		{
			return _flag.isTrue( ISREVERSED );
		}
		
		
	}

}