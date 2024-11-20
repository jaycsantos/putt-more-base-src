package pb2.game.entity 
{
	import apparat.math.FastMath;
	import Box2D.Collision.b2AABB;
	import Box2D.Collision.b2RayCastInput;
	import Box2D.Collision.b2RayCastOutput;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.b2internal;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2World;
	import Box2D.Dynamics.Contacts.b2Contact;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.math.Trigo;
	import com.jaycsantos.sound.GameSounds;
	import com.jaycsantos.sound.PlayRequestPriority;
	import com.jaycsantos.util.GameLoop;
	import flash.utils.getTimer;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.entity.b2.b2Entity;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.entity.render.FloorBlowerRender;
	import pb2.game.Registry;
	import pb2.game.Session;
	import pb2.game.Tile;
	import pb2.GameAudio;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class FloorBlower extends b2EntityTile 
	{
		public static const FLAG_DIAGONAL:uint = 8192
		public static const FLAG_ISBLOWING:uint = 16384
		
		public var axis:b2Vec2, axisForce:b2Vec2
		public var blowRender:FloorBlowerRender, floor:b2Fixture
		
		public function FloorBlower( args:EntityArgs )
		{
			super(args);
			
			createBody();
			
			axis = new b2Vec2( 1, 0 );
			axisForce = new b2Vec2( Registry.BLOWER_force, 0 );
			_visitors = new Vector.<b2Fixture>;
			_raycastA = new b2RayCastInput;
			_raycastB = new b2RayCastInput;
			_raycastC = new b2RayCastInput;
			_raycastA2 = new b2RayCastInput;
			_raycastB2 = new b2RayCastInput;
			_raycastC2 = new b2RayCastInput;
			
			_temp_rayOut = new b2RayCastOutput;
			_temp_vec = new b2Vec2;
			_temp_xlist = new Vector.<Number>;
			_temp_ylist = new Vector.<Number>;
			
			_flag.setFlag( FLAG_DIAGONAL, args.type == Tile.FLOORBLOWER2 );
			
			_flag.setTrue( FLAG_ISFIXED );
			onContact.add( _onContact );
			onContactEnd.add( _onContactEnd );
		}
		
		override public function createBody():void 
		{
			body = Session.b2world.CreateBody( new b2BodyDef );
			
			floor = body.CreateFixture( Registry.BLOWER_b2FixtDef );
			body.SetUserData( this );
			
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			floor = null;
			blowRender = null;
		}
		
		
		override public function update():void 
		{
			if ( !isActive ) return;
			
			super.update();
			
			
			var n:Number, ab:b2AABB, b:b2Body, ent:b2Entity, b2world:b2World = Session.b2world;
			var contact:Boolean, time:uint = getTimer();
			
			_flag.setFalse( FLAG_ISBLOWING );
			use namespace b2internal;
			
			for each( var fixt:b2Fixture in _visitors ) {
				b = fixt.GetBody();
				ent = b.GetUserData() as b2Entity;
				
				//var _temp_rayIn:b2RayCastInput = new b2RayCastInput( _raycastA.p1, _raycastB.p1 );
				
				if ( fixt.RayCast(_temp_rayOut, _raycastA) ) {
					_temp_xlist.push( _raycastA.p1.x +_temp_rayOut.fraction *(_raycastA.p2.x -_raycastA.p1.x) );
					_temp_ylist.push( _raycastA.p1.y +_temp_rayOut.fraction *(_raycastA.p2.y -_raycastA.p1.y) );
				}
				if ( fixt.RayCast(_temp_rayOut, _raycastB) ) {
					_temp_xlist.push( _raycastB.p1.x +_temp_rayOut.fraction *(_raycastB.p2.x -_raycastB.p1.x) );
					_temp_ylist.push( _raycastB.p1.y +_temp_rayOut.fraction *(_raycastB.p2.y -_raycastB.p1.y) );
				}
				if ( fixt.RayCast(_temp_rayOut, _raycastC) ) {
					_temp_xlist.push( _raycastC.p1.x +_temp_rayOut.fraction *(_raycastC.p2.x -_raycastC.p1.x) );
					_temp_ylist.push( _raycastC.p1.y +_temp_rayOut.fraction *(_raycastC.p2.y -_raycastC.p1.y) );
				}
				
				if ( _temp_xlist.length ) {
					if ( fixt.m_shape is b2CircleShape ) {
						if ( b.IsAwake() ) {
							b.ApplyForce( axisForce, b.GetWorldCenter() );
							_flag.setTrue( FLAG_ISBLOWING );
							contact = true;
						}
						
					} else {
						_temp_vec.x = _temp_vec.y = 0;
						for each( n in _temp_xlist ) _temp_vec.x += n;
						for each( n in _temp_ylist ) _temp_vec.y += n;
						_temp_vec.x /= _temp_xlist.length;
						_temp_vec.y /= _temp_ylist.length;
						
						if ( b.IsAwake() ) {
							b.ApplyForce( axisForce, _temp_vec );
							_flag.setTrue( FLAG_ISBLOWING );
							contact = true;
						}
					}
				}
				
				
			}
			_temp_xlist.splice( 0, _temp_xlist.length );
			_temp_ylist.splice( 0, _temp_ylist.length );
			
			if ( contact ) {
				var vol:Number = BallCtrl.instance.getVolumeFromAfar( p );
				if ( vol > 0.05 )
					PlayRequestPriority.requestPlay( GameAudio.FLOORWIND, 0, int.MAX_VALUE, vol/2 );
				else
					PlayRequestPriority.requestStop( GameAudio.FLOORWIND );
				
			} else
				PlayRequestPriority.requestStop( GameAudio.FLOORWIND );
			
			
		}
		
		override public function setDefault( x:Number, y:Number, a:Number=0 ):void 
		{
			if ( a != defRa ) blowRender.redraw();
			
			super.setDefault( x, y, a );
			
			if ( _flag.isTrue(FLAG_DIAGONAL) ) a += Trigo.QUART_PI;
			axisForce.x = (axis.x = Math.round(FastMath.cos( a ))) *Registry.BLOWER_force;
			axisForce.y = (axis.y = Math.round(FastMath.sin( a ))) *Registry.BLOWER_force;
			
			
			use namespace b2internal;
			
			var floor:b2PolygonShape = Registry.BLOWER_b2FixtDef.shape as b2PolygonShape;
			_raycastA.p1 = body.GetWorldPoint( floor.m_vertices[0] );
			_raycastA.p2 = body.GetWorldPoint( floor.m_vertices[1] );
			_raycastB.p1 = body.GetWorldPoint( floor.m_vertices[3] );
			_raycastB.p2 = body.GetWorldPoint( floor.m_vertices[2] );
			
			_raycastC.p1.x = _raycastA.p1.x +(_raycastB.p1.x -_raycastA.p1.x)/2;
			_raycastC.p1.y = _raycastA.p1.y +(_raycastB.p1.y -_raycastA.p1.y)/2;
			_raycastC.p2.x = _raycastA.p2.x +(_raycastB.p2.x -_raycastA.p2.x)/2;
			_raycastC.p2.y = _raycastA.p2.y +(_raycastB.p2.y -_raycastA.p2.y) / 2;
			
			_raycastA2.p1 = _raycastA.p2;
			_raycastA2.p2 = _raycastA.p1;
			_raycastB2.p1 = _raycastB.p2;
			_raycastB2.p2 = _raycastB.p1;
			_raycastC2.p1 = _raycastC.p2;
			_raycastC2.p2 = _raycastC.p1;
		}
		
		override public function useDefault():void 
		{
			super.useDefault();
			
		}
		
		
		public function get isBlowing():Boolean
		{
			return _flag.isTrue( FLAG_ISBLOWING );
		}
		
		
			// -- private --
			
			private var _raycastA:b2RayCastInput, _raycastB:b2RayCastInput, _raycastC:b2RayCastInput
			private var _raycastA2:b2RayCastInput, _raycastB2:b2RayCastInput, _raycastC2:b2RayCastInput
			private var _visitors:Vector.<b2Fixture>
			private var _startTime:uint
			private var _temp_rayOut:b2RayCastOutput, _temp_rayIn:b2RayCastInput, _temp_vec:b2Vec2
			private var _temp_xlist:Vector.<Number>
			private var _temp_ylist:Vector.<Number>
			
			
			private function _onContact( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture ):void
			{
				if ( !contact.IsSensor() ) return;
				
				
				if ( _visitors.indexOf(fixt) == -1 && !fixt.b2internal::m_isSensor )
					_visitors.push( fixt );
				
			}
			
			private function _onContactEnd( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture ):void
			{
				if ( !contact.IsSensor() ) return;
				
				var i:int = _visitors.indexOf( fixt );
				if ( i > -1 )
					_visitors.splice( i, 1 );
			}
			
			
		
		
	}

}