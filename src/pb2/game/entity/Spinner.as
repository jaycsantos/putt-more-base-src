package pb2.game.entity 
{
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Contacts.b2Contact;
	import com.jaycsantos.entity.EntityArgs;
	import org.osflash.signals.Signal;
	import pb2.game.entity.b2.b2Entity;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.entity.b2.Ib2PreSolveCaller;
	import pb2.game.entity.render.SpinnerRender;
	import pb2.game.Registry;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Spinner extends b2EntityTile implements Ib2PreSolveCaller
	{
		public var spinRender:SpinnerRender, ball:Ball
		public var sensor:b2Body, axis:b2Vec2
		public var onSpin:Signal
		
		public function Spinner( args:EntityArgs )
		{
			super( args );
			
			createBody();
			
			axis = new b2Vec2( 1, 0 );
			_flag.setTrue( FLAG_ISFIXED );
			onContact.add( _onContact );
			onContactEnd.add( _onContactEnd );
			onSpin = new Signal;
		}
		
		override public function createBody():void 
		{
			body = Session.b2world.CreateBody( Registry.STATIC_b2BodyDef );
			sensor = Session.b2world.CreateBody( new b2BodyDef );
			
			Registry.STATIC_b2FixtDef.shape = BODY_SHAPE;
			body.CreateFixture( Registry.STATIC_b2FixtDef );
			body.SetUserData( this );
			
			Registry.SENSOR_b2FixtDef.shape = SENSOR_SHAPE;
			sensor.CreateFixture( Registry.SENSOR_b2FixtDef );
			sensor.SetUserData( this );
			
		}
		
		override public function dispose():void 
		{
			Session.b2world.DestroyBody( sensor );
			sensor.SetUserData( null );
			
			super.dispose();
			
			spinRender = null;
			sensor = null;
			ball = null;
		}
		
		
		override public function setDefault( x:Number, y:Number, a:Number = 0 ):void 
		{
			super.setDefault( x, y, a );
			
			axis.x = Math.cos( a );
			axis.y = Math.sin( a );
			spinRender.redraw();
		}
		
		override public function useDefault():void 
		{
			super.useDefault();
			
			sensor.SetPositionAndAngle( body.GetPosition(), body.GetAngle() );
			spinRender.stop();
		}
		
		override public function activate():void 
		{
			super.activate();
			sensor.SetActive( true );
		}
		
		override public function deactivate():void 
		{
			super.deactivate();
			sensor.SetActive( false );
		}
		
			// -- private --
			private static const BODY_SHAPE:b2PolygonShape = b2PolygonShape.AsBox( Registry.b2TileScaleSize/2 *4/36, Registry.b2TileScaleSize/2 *30/36 );
			private static const SENSOR_SHAPE:b2PolygonShape = b2PolygonShape.AsBox( Registry.b2TileScaleSize/2 *3/36, Registry.b2TileScaleSize/2 *30/36 );
			
			
			private function _onContact( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture ):void
			{
				if ( sensor == thisFixt.GetBody() && fixt.GetBody().GetUserData() is Ball ) {
					ball = fixt.GetBody().GetUserData() as Ball;
					spinRender.play();
				}
			}
			
			private function _onContactEnd( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture ):void
			{
				if ( sensor == thisFixt.GetBody() )
					if ( ball == fixt.GetBody().GetUserData() )
						ball = null;
			}
			
		public function onPreSolveContact( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture, oldManifold:b2Manifold ):void
		{
			if ( body != thisFixt.GetBody() || ! (fixt.GetBody().GetUserData() is Ball) )
				return;
			
			var v:b2Vec2 = fixt.GetBody().GetLinearVelocity();
			
			if ( ball && ball.body == fixt.GetBody() ) {
				contact.SetEnabled( false );
				
			} else {
				if ( defRa %Math.PI == 0 ) {
					if ( axis.x > 0 == v.x > 0 )
						contact.SetEnabled( false );
				} else {
					if ( axis.y > 0 == v.y > 0 )
						contact.SetEnabled( false );
				}
				if ( contact.IsEnabled() )
					spinRender.stop();
			}
		}
		
		
	}

}