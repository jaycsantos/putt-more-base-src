package pb2.game.entity 
{
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Contacts.b2Contact;
	import com.jaycsantos.entity.EntityArgs;
	import pb2.game.entity.render.JellyRender;
	import pb2.game.Registry;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author ...
	 */
	public class JellyBlock extends Block 
	{
		public var jellyRender:JellyRender
		
		public function JellyBlock( args:EntityArgs )
		{
			super( args );
			
			onContact.add( _onContact );
		}
		
		override public function dispose():void 
		{
			jellyRender = null;
			
			super.dispose();
		}
		
		
		override public function setDefault(x:Number, y:Number, a:Number = 0):void 
		{
			jellyRender.wiggle();
			super.setDefault(x, y, a);
		}
		
		
			// -- private --
			
			
			private function _onContact( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture ):void
			{
				if ( contact.IsSensor() ) return;
				
				//jellyRender.wiggle( Math.min(fixt.GetBody().GetLinearVelocity().Length() /Registry.ballMaxSpeed *2, 1) );
				jellyRender.wiggle();
			}
			
		
		
	}

}