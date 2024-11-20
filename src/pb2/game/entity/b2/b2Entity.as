package pb2.game.entity.b2 
{
	import apparat.math.FastMath;
	import Box2D.Common.b2internal;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Contacts.b2Contact;
	import com.jaycsantos.entity.Entity;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.internalJayc;
	import org.osflash.signals.Signal;
	import pb2.game.Registry;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class b2Entity extends Entity
	{
		public static const FLAG_ISACTIVE:uint = 1 // 1<<0
		public static const FLAG_ISMOVING:uint = 2 // 1<<1
		public static const FLAG_ISROTATING:uint = 4 // 1<<2
		public static const FLAG_ISFIXED:uint = 16 // 1<<4
		public static const FLAG_ISTOOLKIT:uint = 32 // 1<<5
		public static const FLAG_WASMOVED:uint = 64 // 1<<6
		public static const FLAG_HASTILEMOVE:uint = 256 // 1<<8
		public static const FLAG_undefined:uint = 128 // 1<<7
		
		
		public var onContact:Signal, onContactEnd:Signal
		public var onMoveStart:Signal, onMoveStop:Signal, onRotateStart:Signal, onRotateStop:Signal
		public var body:b2Body
		
		public function b2Entity( args:EntityArgs )
		{
			super( args );
			
			_flag.setTrue( FLAG_ISACTIVE );
			
			onMoveStart = new Signal( b2Entity ); onMoveStop = new Signal( b2Entity );
			onRotateStart = new Signal( b2Entity ); onRotateStop = new Signal( b2Entity );
			onContact = new Signal( b2Contact, b2Fixture, b2Fixture );
			onContactEnd = new Signal( b2Contact, b2Fixture, b2Fixture );
		}
		
		public function createBody():void
		{
			
		}
		
		override public function dispose():void 
		{
			if ( isMoving ) onMoveStop.dispatch( this );
			if ( isRotating ) onRotateStop.dispatch( this );
			
			onContact.removeAll();
			onContactEnd.removeAll();
			onMoveStart.removeAll();
			onMoveStop.removeAll();
			onRotateStart.removeAll();
			onRotateStop.removeAll();
			onContact = onContactEnd = onMoveStart = onMoveStop = onRotateStart = onRotateStop = null;
			
			super.dispose();
			
			if ( body && Session.b2world )
				Session.b2world.DestroyBody( body );
			body.SetUserData( null );
			body = null;
		}
		
		
		override public function update():void
		{
			if ( _flag.isFalse(FLAG_ISACTIVE) ) return;
			
			use namespace b2internal;
			
			// body values are under b2internal namespace
			if ( body && body.m_mass ) {
				var bp:b2Vec2 = body.m_xf.position;
				var bv:b2Vec2 = body.m_linearVelocity;
				var br:Number = body.m_angularVelocity;
				p.x = bp.x *Registry.b2Scale;
				p.y = bp.y *Registry.b2Scale;
				
				_flag.setFalse( FLAG_HASTILEMOVE );
				if ( FastMath.abs(bv.x) > 0.0001 || FastMath.abs(bv.y) > 0.0001 || FastMath.abs(br) > 0.0001 ) {
					if ( _flag.isFalse(FLAG_ISMOVING) ) {
						onMoveStart.dispatch( this );
						_flag.setTrue( FLAG_ISMOVING );
					}
					if ( FastMath.abs(br) > 0.001 ) {
						if ( _flag.isFalse(FLAG_ISROTATING) ) {
							onRotateStart.dispatch( this );
							_flag.setTrue( FLAG_ISROTATING );
						}
					} else {
						if ( _flag.isTrue(FLAG_ISROTATING) ) {
							onRotateStop.dispatch( this );
							_flag.setFalse( FLAG_ISROTATING );
						}
					}
					
					var tx:int = p.x/Registry.tileSize -.5 >> 0;
					var ty:int = p.y/Registry.tileSize -.5 >> 0;
					
					if ( tx != _tileX ) {
						_tileX = tx;
						_flag.setTrue( FLAG_HASTILEMOVE );
					}
					if ( ty != _tileY ) {
						_tileY = ty;
						_flag.setTrue( FLAG_HASTILEMOVE );
					}
					
					
				} else {
					bv.x = bv.y = 0;
					body.m_angularVelocity = 0;
					
					if ( _flag.isTrue(FLAG_ISMOVING) ) {
						onMoveStop.dispatch( this );
						_flag.setFalse( FLAG_ISMOVING );
					}
					if ( _flag.isTrue(FLAG_ISROTATING) ) {
						onRotateStop.dispatch( this );
						_flag.setFalse( FLAG_ISROTATING );
					}
				}
			}
			
		}
		
		
		final public function dispatchContact( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture ):void
		{
			if ( onContact )
				onContact.dispatch( contact, thisFixt, fixt );
		}
		
		final public function dispatchContactEnd( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture ):void
		{
			if ( onContactEnd )
				onContactEnd.dispatch( contact, thisFixt, fixt );
		}
		
		
		public function get isMoving():Boolean
		{
			return _flag.isTrue( FLAG_ISMOVING );
		}
		
		public function get isRotating():Boolean
		{
			return _flag.isTrue( FLAG_ISROTATING );
		}
		
		public function get isFixed():Boolean
		{
			return _flag.isTrue( FLAG_ISFIXED );
		}
		
		public function get isActive():Boolean
		{
			return _flag.isTrue( FLAG_ISACTIVE );
		}
		
		
		public function activate():void
		{
			_flag.setTrue( FLAG_ISACTIVE );
			if ( body ) {
				body.SetActive( true );
				body.SetAwake( true );
			}
			if ( render ) render.setVisible( true );
		}
		
		public function deactivate():void
		{
			_flag.setFalse( FLAG_ISACTIVE );
			body.SetActive( false );
			//body.SetAwake( false );
			if ( render ) render.setVisible( false );
		}
		
			// -- private --
			
			protected var _tileX:int, _tileY:int
			
	}

}