package pb2.game.entity 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Contacts.b2Contact;
	import com.jaycsantos.entity.EntityArgs;
	import org.osflash.signals.Signal;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.Registry;
	import pb2.game.Session;
	import pb2.game.Tile;
	
	/**
	 * ...
	 * @author ...
	 */
	public class DragBounds extends b2EntityTile 
	{
		public var onHasContact:Signal
		public var filterTile:b2EntityTile
		
		public function DragBounds( args:EntityArgs ) 
		{
			super( args );
			
			createBody();
			
			
			onHasContact = new Signal;
			_contactFixts = new Vector.<b2Fixture>;
			
			onContact.add( _onContact );
			onContactEnd.add( _onContactEnd );
			deactivate();
		}
		
		override public function createBody():void 
		{
			var ts2:Number = Registry.tileSize /Registry.b2Scale /2;
			
			body = Session.b2world.CreateBody( Registry.ALL_b2bodyDef );
			Registry.SENSOR_b2FixtDef.shape = Tile.getb2Shape( 'sq', 1 );
			body.CreateFixture( Registry.SENSOR_b2FixtDef );
			body.SetUserData( this );
		}
		
		public function get contactsCount():uint
		{
			return _contactFixts.length;
		}
		
		
		override public function setDefault( x:Number, y:Number, a:Number=0 ):void 
		{
			super.setDefault( x, y, a );
			
			_contactFixts.splice( 0, _contactFixts.length );
		}
		
		
		override public function deactivate():void 
		{
			super.deactivate();
			_contactFixts.splice( 0, _contactFixts.length );
		}
		
		
			// -- private --
			
			private var _contactFixts:Vector.<b2Fixture>
			
			private function _onContact( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture ):void
			{
				if ( fixt.GetBody().GetUserData() != filterTile ) {
					if ( _contactFixts.indexOf(fixt) == -1 ) {
						_contactFixts.push( fixt );
						if ( _contactFixts.length == 1 )
							onHasContact.dispatch();
					}
				}
			}
			
			private function _onContactEnd( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture ):void
			{
				var p:int = _contactFixts.indexOf( fixt );
				if ( p > -1 )
					_contactFixts.splice( p, 1 );
			}
			
			
	}

}