package pb2.game.ctrl 
{
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.b2internal;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Contacts.b2Contact;
	import com.demonsters.debugger.MonsterDebugger;
	import pb2.game.entity.b2.b2Entity;
	import pb2.game.entity.b2.Ib2PostSolveCaller;
	import pb2.game.entity.b2.Ib2PreSolveCaller;
	import pb2.game.entity.Ball;
	import pb2.game.Registry;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class ContactCtrl extends b2ContactListener 
	{
		use namespace b2internal;
		
		public function ContactCtrl() 
		{
			
		}
		
		
		override public function BeginContact( contact:b2Contact ):void 
		{
			var fixtA:b2Fixture = contact.m_fixtureA;
			var fixtB:b2Fixture = contact.m_fixtureB;
			var dataA:* = fixtA.m_body.GetUserData();
			var dataB:* = fixtB.m_body.GetUserData();
			trace( 'begin', dataA, dataB );
			
			if ( dataA is b2Entity && dataB is b2Entity ) {
				b2Entity(dataA).dispatchContact( contact, fixtA, fixtB );
				b2Entity(dataB).dispatchContact( contact, fixtB, fixtA );
			}
		}
		
		override public function EndContact( contact:b2Contact ):void 
		{
			var fixtA:b2Fixture = contact.m_fixtureA;
			var fixtB:b2Fixture = contact.m_fixtureB;
			var dataA:* = fixtA.m_body.GetUserData();
			var dataB:* = fixtB.m_body.GetUserData();
			trace( 'end', dataA, dataB );
			
			if ( dataA is b2Entity && dataB is b2Entity ) {
				b2Entity(dataA).dispatchContactEnd( contact, fixtA, fixtB );
				b2Entity(dataB).dispatchContactEnd( contact, fixtB, fixtA );
			}
		}
		
		
		override public function PreSolve( contact:b2Contact, oldManifold:b2Manifold ):void 
		{
			var fixtA:b2Fixture = contact.m_fixtureA;
			var fixtB:b2Fixture = contact.m_fixtureB;
			var dataA:* = fixtA.m_body.GetUserData();
			var dataB:* = fixtB.m_body.GetUserData();
			
			if ( dataA is Ib2PreSolveCaller && dataB is b2Entity ) 
				Ib2PreSolveCaller(dataA).onPreSolveContact( contact, fixtA, fixtB, oldManifold );
			if ( dataB is Ib2PreSolveCaller && dataA is b2Entity )
				Ib2PreSolveCaller(dataB).onPreSolveContact( contact, fixtB, fixtA, oldManifold );
		}
		
		override public function PostSolve( contact:b2Contact, impulse:b2ContactImpulse ):void 
		{
			var fixtA:b2Fixture = contact.m_fixtureA;
			var fixtB:b2Fixture = contact.m_fixtureB;
			var dataA:* = fixtA.m_body.GetUserData();
			var dataB:* = fixtB.m_body.GetUserData();
			
			if ( dataA is Ib2PostSolveCaller && dataB is b2Entity )
				Ib2PostSolveCaller(dataA).onPostSolveContact( contact, fixtA, fixtB, impulse );
			if ( dataB is Ib2PostSolveCaller && dataA is b2Entity )
				Ib2PostSolveCaller(dataB).onPostSolveContact( contact, fixtB, fixtA, impulse );
		}
		
	}

}