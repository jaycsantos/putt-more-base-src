package pb2.game.entity.tile 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2FixtureDef;
	import com.jaycsantos.entity.EntityArgs;
	import pb2.game.entity.b2.b2Entity;
	import pb2.game.entity.ISolidWall;
	import pb2.game.Registry;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author ...
	 */
	public class WallEdge extends b2Entity implements ISolidWall
	{
		public var args:EntityArgs, wallRender:WallEdgeRender
		
		public function WallEdge( args:EntityArgs )
		{
			super( args );
			
			this.args = args;
			
			createBody();
		}
		
		override public function createBody():void 
		{
			body = Session.b2world.CreateBody( Registry.STATIC_b2BodyDef );
			body.SetUserData( this );
			
			// -- build for the walls
			var ts:Number = Registry.tileSize /Registry.b2Scale, ts2:Number = ts /2,
				w:Number = Session.instance.width /Registry.b2Scale, w2:Number = w /2,
				h:Number = Session.instance.height /Registry.b2Scale, h2:Number = h /2;
			
			var fixtDef:b2FixtureDef = Registry.STATIC_b2FixtDef;
			switch( args.type ) {
				case 'wall_top':
					fixtDef.shape = b2PolygonShape.AsBox( w2 +ts2, ts2 );
					body.SetPosition( new b2Vec2(w2, 0) );
					break;
				case 'wall_bottom':
					fixtDef.shape = b2PolygonShape.AsBox( w2 +ts2, ts2 );
					body.SetPosition( new b2Vec2(w2, h) );
					break;
				case 'wall_left':
					fixtDef.shape = b2PolygonShape.AsBox( ts2, h2 -ts2 );
					body.SetPosition( new b2Vec2(0, h2) );
					break;
				case 'wall_right':
					fixtDef.shape = b2PolygonShape.AsBox( ts2, h2 -ts2 );
					body.SetPosition( new b2Vec2(w, h2) );
					break;
			}
			body.CreateFixture( fixtDef );
			
			p.x = body.GetPosition().x *Registry.b2Scale;
			p.y = body.GetPosition().y *Registry.b2Scale;
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			args = null;
			wallRender = null;
		}
		
		
	}

}