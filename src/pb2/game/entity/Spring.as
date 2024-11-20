package pb2.game.entity 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Joints.b2PrismaticJoint;
	import Box2D.Dynamics.Joints.b2PrismaticJointDef;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.Trigo;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.Registry;
	import pb2.game.Session;
	import pb2.game.Tile;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Spring extends b2EntityTile 
	{		
		public static const headDef:b2BodyDef = new b2BodyDef
			headDef.type = b2Body.b2_dynamicBody
			headDef.bullet = true
			headDef.allowSleep = true
		
		public static var headSqShape:b2PolygonShape
		public static var headRtriShape:b2PolygonShape
		
		public static var headFDef:b2FixtureDef
		public static var pJointDef:b2PrismaticJointDef
		
		
		public var head:b2Body
		public var pjoint:b2PrismaticJoint
		public var pjointAxis:b2Vec2
		
		
		public function Spring( args:EntityArgs )
		{
			super( args );
			
			var fd:b2FixtureDef;
			var ts2:Number = Registry.tileSize / Registry.b2Scale / 2;
			
			// body is the static base
			body = Session.b2world.CreateBody( Registry.STATIC_b2BodyDef );
			fd = Registry.STATIC_b2FixtDef;
			fd.shape = Tile.getb2Shape( shapeName=='sq'? 'hf': 'qrtri' );
			body.CreateFixture( fd );
			body.SetUserData( this );
			
			// head
			head = Session.b2world.CreateBody( headDef );
			if ( ! headFDef ) {
				headFDef = new b2FixtureDef;
				headFDef.density = 1;
				headFDef.restitution = 1;
				headFDef.filter.groupIndex = Registry.b2SpringHeadGF;
			}
			if ( shapeName == 'sq' ) {
				if ( ! headSqShape )
					headSqShape = b2PolygonShape.AsOrientedBox( ts2*16/18, ts2*4/18, new b2Vec2(0,-ts2*13/18) );
				headFDef.shape = headSqShape;
			} else {
				if ( ! headRtriShape )
					headRtriShape = b2PolygonShape.AsOrientedBox( ts2*16/18, ts2*4/18, new b2Vec2(0,-ts2*1/18), Trigo.QUART_PI );
				headFDef.shape = headRtriShape;
			}
			
			
			head.CreateFixture( headFDef );
			head.SetUserData( this );
			
			if( ! pJointDef ) {
				pJointDef = new b2PrismaticJointDef;
				pJointDef.lowerTranslation = -ts2*11/18;
				pJointDef.upperTranslation = 0;//ts2*9/18;
				pJointDef.enableLimit = true;
				pJointDef.enableMotor = true;
			}
			
			pjointAxis = new b2Vec2;
		}
		
		override public function dispose():void 
		{
			Session.b2world.DestroyBody( head );
			
			super.dispose();
			
			head = null;
			pjoint = null;
		}
		
		override public function update():void 
		{
			if ( !isActive ) return;
			
			super.update();
			
			var pjt:Number = pjoint.GetJointTranslation();
			var pjs:Number = pjoint.GetJointSpeed();
			//pjoint.SetMaxMotorForce(Math.abs((pjt * 100) + (pjs * 10))); // 100 is the spring constant, 10 is the damping constant.
			pjoint.SetMaxMotorForce(Math.abs((-pjt * 1720) + (pjs * 10))); // 100 is the spring constant, 10 is the damping constant.
			pjoint.SetMotorSpeed( pjt<.01? -pjt*1000 : 0 ); // Arbitrary humongous number. 
			
			
			DOutput.show( 'joint speed:', pjoint.GetMotorForce().toFixed(3) );
			DOutput.show( 'max force:', pjoint.GetMotorForce().toFixed(3) );
			DOutput.show( 'joint trans:', pjt.toFixed(4) );
		}
		
		
		override public function setDefault( x:Number, y:Number, a:Number = 0 ):void 
		{
			var changed:Boolean = a.toFixed(5) != defRa.toFixed(5);
			
			super.setDefault( x, y, a );
			
			if ( changed || ! pjoint ) {
				if ( pjoint )
					Session.b2world.DestroyJoint( pjoint );
				var aa:Number = a - Trigo.HALF_PI +(shapeName=='rtri'? Trigo.QUART_PI :0);
				pjointAxis = new b2Vec2( Math.cos(aa), Math.sin(aa) );
				pJointDef.Initialize( body, head, head.GetPosition(), pjointAxis );
				pjoint = Session.b2world.CreateJoint( pJointDef ) as b2PrismaticJoint;
			}
		}
		
		override public function useDefault():void 
		{
			super.useDefault();
			head.SetPositionAndAngle( body.GetPosition(), defRa );
			head.SetLinearVelocity( new b2Vec2 );
			head.SetAngularVelocity( 0 );
		}
		
		
		
		
	}

}