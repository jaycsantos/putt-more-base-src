package pb2.game.entity 
{
	import apparat.math.FastMath;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.b2internal;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Dynamics.Joints.b2PrismaticJoint;
	import Box2D.Dynamics.Joints.b2PrismaticJointDef;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.sound.GameSounds;
	import org.osflash.signals.Signal;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.entity.b2.*;
	import pb2.game.entity.render.PPuncherRender;
	import pb2.game.Registry;
	import pb2.game.Session;
	import pb2.game.Tile;
	import pb2.GameAudio;
	import pb2.util.pb2internal;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PPuncher extends b2EntityTileTool implements Ib2PostSolveCaller 
	{
		public static const WAS_SPRUNG:uint = 131072, SHOULD_SPRUNG:uint = 262144;
		
		public var puncherRender:PPuncherRender
		public var sensor:b2Fixture, punch:b2Body, joint:b2PrismaticJoint, jointAx:b2Vec2
		public var onSprung:Signal
		
		public function PPuncher( args:EntityArgs )
		{
			super( args );
			
			if ( !_BodyShape ) {
				var ts2:Number = Registry.b2TileScaleSize /2;
				_BodyShape = b2PolygonShape.AsOrientedBox( ts2*8/18, ts2*17/18, new b2Vec2(-ts2*8/18,0) );
				_SensorShape = b2PolygonShape.AsOrientedBox( ts2*7/18, ts2*7/18, new b2Vec2(ts2*9/18,0) );
				_PunchShape = b2PolygonShape.AsOrientedBox( ts2*8/18, ts2*16/18, new b2Vec2(-ts2*7.5/18,0) );
			}
			
			createBody();
			
			onContact.add( _onContact );
			jointAx = new b2Vec2;
			onSprung = new Signal;
		}
		
		override public function createBody():void 
		{
			// body is the static base
			body = Session.b2world.CreateBody( Registry.IRON_b2BodyDef );
			var fd:b2FixtureDef = Registry.IRON_b2FixtDef;
			fd.shape = _BodyShape;
			var fx:b2Fixture = body.CreateFixture( fd );
			var filt:b2FilterData = fx.GetFilterData();
			filt.maskBits = uint.MAX_VALUE & ~Registry.PPUNCH_b2FixtDef.filter.categoryBits;
			body.SetUserData( this );
			
			fd = Registry.STATIC_b2FixtDef;
			fd.shape = _SensorShape;
			sensor = body.CreateFixture( fd );
			sensor.SetSensor( true );
			
			
			punch = Session.b2world.CreateBody( Registry.PUNCH_b2BodyDef );
			fd = Registry.PPUNCH_b2FixtDef;
			fd.shape = _PunchShape;
			punch.CreateFixture( fd );
			punch.SetUserData( this );
			
			joint = null;
		}
		
		override public function dispose():void 
		{
			Session.b2world.DestroyBody( punch );
			punch.SetUserData( null );
			
			super.dispose();
			
			puncherRender = null;
			sensor = null;
			punch = null;
			joint = null;
		}
		
		override public function update():void 
		{
			if ( _flag.isFalse(FLAG_ISACTIVE) ) return;
			
			use namespace b2internal;
			
			// body values are under b2internal namespace
			var bp:b2Vec2 = body.m_xf.position;
			var bv:b2Vec2 = body.m_linearVelocity;
			var br:Number = body.m_angularVelocity;
			p.x = bp.x *Registry.b2Scale;
			p.y = bp.y *Registry.b2Scale;
			
			if ( joint.GetMotorSpeed() || FastMath.abs(bv.x) > 0.0001 || FastMath.abs(bv.y) > 0.0001 || FastMath.abs(br) > 0.0001 ) {
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
				var jointVal:Number = ((joint.GetJointTranslation() * 100) << 0) / 100;
				if ( jointVal+.02 >= joint.GetUpperLimit() || (joint.GetJointSpeed() == 0 && jointVal > 0) )
					joint.SetMotorSpeed( 0 );
				
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
				if ( body.IsAwake() || punch.IsAwake() ) {
					punch.SetAwake( false );
					body.SetAwake( false );
				}
			}
			
			if ( _flag.isTrue(SHOULD_SPRUNG) && _flag.isFalse(WAS_SPRUNG) ) {
				joint.SetMotorSpeed( Registry.PUNCH_b2MotorSpeed );
				GameSounds.play( GameAudio.SPRING_TAP, 0, 0, BallCtrl.instance.getVolumeFromAfar(p) );
				onSprung.dispatch();
				Session.world.camera.shake( Registry.PUNCH_shakeIntensity, Registry.PUNCH_shakeLength );
				
				_flag.setTrue( WAS_SPRUNG | FLAG_WASMOVED );
				_flag.setFalse( SHOULD_SPRUNG );
			}
			
		}
		
		
		override public function setDefault( x:Number, y:Number, a:Number = 0 ):void 
		{
			var changed:Boolean = a.toFixed(5) != defRa.toFixed(5);
			
			super.setDefault( x, y, a );
			
			if ( changed || !joint ) {
				if ( joint ) Session.b2world.DestroyJoint( joint );
				jointAx = new b2Vec2( Math.cos(a), Math.sin(a) );
				
				Registry.PPUNCH_b2JointDef.Initialize( body, punch, punch.GetPosition(), jointAx );
				joint = Session.b2world.CreateJoint( Registry.PPUNCH_b2JointDef ) as b2PrismaticJoint;
			}
			
		}
		
		override public function useDefault():void 
		{
			super.useDefault();
			
			if ( punch ) {
				punch.SetPositionAndAngle( body.GetPosition(), defRa );
				punch.SetLinearVelocity( new b2Vec2 );
				punch.SetAngularVelocity( 0 );
				punch.SetAwake( true );
				
				if ( joint ) joint.SetMotorSpeed( 0 );
			}
			
			_flag.setFalse( WAS_SPRUNG | SHOULD_SPRUNG );
			//punchRender.clipShade.x = p.x;
			//punchRender.clipShade.y = p.y;
		}
		
		
		override public function activate():void 
		{
			super.activate();
			punch.SetActive( true );
			punch.SetAwake( true );
		}
		
		override public function deactivate():void 
		{
			super.deactivate();
			punch.SetActive( false );
			punch.SetAwake( false );
		}
		
		
		pb2internal function trigger():void
		{
			if ( _flag.isFalse(WAS_SPRUNG) )
				_flag.setTrue( SHOULD_SPRUNG );
		}
		
		
			// -- private --
			private static var _BodyShape:b2PolygonShape, _SensorShape:b2PolygonShape, _PunchShape:b2PolygonShape
			
			
			private function _onContact( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture ):void
			{
				if ( contact.IsSensor() && sensor == thisFixt && !fixt.IsSensor() ) {
					if ( _flag.isFalse(WAS_SPRUNG) )
						_flag.setTrue( SHOULD_SPRUNG );
					
				} else if ( !contact.IsSensor() ) {
					_flag.setTrue( FLAG_WASMOVED );
				}
				
			}
		
		
		/* INTERFACE pb2.game.entity.b2.Ib2PostSolveCaller */
		
		public function onPostSolveContact( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture, impulse:b2ContactImpulse ):void 
		{
			if ( contact.IsSensor() ) return;
			
			var udata:* = fixt.GetBody().GetUserData();
			
			if ( punch == thisFixt.GetBody() && joint.GetMotorSpeed() > 0 && udata is Ball ) {
				var ball:Ball = fixt.GetBody().GetUserData() as Ball;
				var f:Number = Registry.BALL_MaxSpeed;
				var angle:Number = punch.GetAngle();
				ball.body.SetLinearVelocity( new b2Vec2(FastMath.cos(angle)*f, FastMath.sin(angle)*f) );
			}
			
			var imp:Number = impulse.normalImpulses[0];
			if ( imp < Registry.b2NormalImpulseMin ) return;
			var a:Array, vol:Number = MathUtils.limit((imp-Registry.b2NormalImpulseMin)/Registry.b2NormalImpulseMax, 0, 1) *BallCtrl.instance.getVolumeFromAfar(p);
			
			// hit the puncher
			if ( punch == thisFixt.GetBody() ) {
				if ( udata is Ball || udata is Puncher2 ) {
					GameSounds.play( GameAudio.RUBBER_TAP, 0, 0, vol );
					GameSounds.play( GameAudio.RUBBER_TAP, 0, 0, vol );
					
				} else
				if ( udata is Block ) {
					switch ( Block(udata).materialName ) {
						case 'wood':
						case 'rubber':
							GameSounds.play( GameAudio.RUBBER_TAP, 0, 0, vol ); break;
						case 'jelly':
							//GameSounds.play( GameAudio.RUBBER_TAP, 0, 0, vol );
							GameSounds.play( GameAudio.JELLY_TAP, 0, 0, vol ); break;
						default: break;
					}
				}
				
			// hit the base
			} else {
				if ( udata is Ball || udata is Puncher2 ) {
					a = [GameAudio.WALL_TAP1, GameAudio.WALL_TAP2, GameAudio.WALL_TAP3];
					GameSounds.play( a[MathUtils.randomInt(0, 3)], 0, 0, vol );
					
				} else
				if ( udata is Block ) {
					switch ( Block(udata).materialName ) {
						case 'wood':
							GameSounds.play( GameAudio.WALL_TAP2, 0, 0, vol ); break;
						case 'rubber':
							GameSounds.play( GameAudio.RUBBER_TAP, 0, 0, vol ); break;
						case 'jelly':
							GameSounds.play( GameAudio.JELLY_TAP, 0, 0, vol ); break;
						default: break;
					}
				}
			}
			
		}
		
		
		
	}

}