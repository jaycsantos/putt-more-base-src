package pb2.game.entity.b2 
{
	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Contacts.b2Contact;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public interface Ib2PreSolveCaller 
	{
		function onPreSolveContact( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture, oldManifold:b2Manifold ):void
	}
	
}