package pb2.game.entity 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Joints.*;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.math.Trigo;
	import com.jaycsantos.sound.GameSounds;
	import org.osflash.signals.Signal;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.entity.b2.*;
	import pb2.game.*;
	import pb2.game.entity.render.Puncher2Render;
	import pb2.GameAudio;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Puncher2 extends b2EntityTile implements Ib2PostSolveCaller
	{
		public var puncherRender:Puncher2Render
		public var sensor:b2Fixture, punch:b2Body, joint:b2PrismaticJoint, jointAx:b2Vec2
		public var onSprung:Signal
		
		public function Puncher2( args:EntityArgs ) 
		{
			super( args );
			
			if ( !_BodyShape ) {
				var ts2:Number = Registry.b2TileScaleSize /2;
				_BodyShape = b2PolygonShape.AsOrientedBox( ts2*2/36, ts2, new b2Vec2(-ts2*17/18, 0) );
				_SensorShape = b2PolygonShape.AsOrientedBox( ts2*18/36, ts2*14/36, new b2Vec2 );
				_PunchShape = b2PolygonShape.AsOrientedBox( ts2 * 18 / 36, ts2 * 34 / 36, new b2Vec2( -ts2 * 25 / 18, 0) );
			}
			
			createBody();
			
			_flag.setTrue( FLAG_ISFIXED );
			onContact.add( _onContact );
			onContactEnd.add( _onContactEnd );
			onSprung = new Signal;
		}
		
		override public function createBody():void 
		{
			// body is the static base
			body = Session.b2world.CreateBody( Registry.STATIC_b2BodyDef );
			
			var fd:b2FixtureDef = Registry.STATIC_b2FixtDef;
			fd.shape = _BodyShape;
			body.CreateFixture( fd );
			body.SetUserData( this );
			
			fd = Registry.STATIC_b2FixtDef;
			fd.shape = _SensorShape;
			sensor = body.CreateFixture( fd );
			sensor.SetSensor( true );
			
			
			punch = Session.b2world.CreateBody( Registry.PUNCH_b2BodyDef );
			fd = Registry.PUNCH_b2FixtDef;
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
			
			_contactList.splice( 0, _contactList.length );
			_contactList = null;
			
			onSprung.removeAll(); onSprung = null;
			puncherRender = null;
			punch = null;
			joint = null;
		}
		
		
		override public function update():void 
		{
			if ( _flag.isFalse(FLAG_ISACTIVE) ) return;
			
			super.update();
			
			var jointVal:Number = ((joint.GetJointTranslation() * 100) << 0) / 100;
			if ( jointVal+.02 >= joint.GetUpperLimit() || (joint.GetJointSpeed() == 0 && jointVal > 0) ) {
				joint.SetMotorSpeed( -Registry.PUNCH_b2MotorSpeed_Return );
				
			} else if ( !jointVal && joint.GetMotorSpeed() <= 0 ) {
				if ( _contactList.length ) {
					joint.SetMotorSpeed( Registry.PUNCH_b2MotorSpeed );
					GameSounds.play( GameAudio.SPRING_TAP, 0, 0, BallCtrl.instance.getVolumeFromAfar(p) );
					onSprung.dispatch();
					Session.world.camera.shake( Registry.PUNCH_shakeIntensity, Registry.PUNCH_shakeLength );
					
				} else if ( punch.IsAwake() ) {
					joint.SetMotorSpeed( 0 );
					punch.SetAwake( false );
				}
			}/* else if ( !jointVal && _contactList.length ) {
				joint.SetMotorSpeed( Registry.PUNCH_b2MotorSpeed );
				GameSounds.play( GameAudio.SPRING_TAP, 0, 0, BallCtrl.instance.getVolumeFromAfar(p) );
				onSprung.dispatch();
			}*/
			
		}
		
		
		override public function setDefault( x:Number, y:Number, a:Number = 0 ):void 
		{
			var changed:Boolean = a.toFixed(5) != defRa.toFixed(5);
			
			super.setDefault( x, y, a );
			
			if ( changed || !joint ) {
				if ( joint ) Session.b2world.DestroyJoint( joint );
				jointAx = new b2Vec2( Math.round(Math.cos(a)*1000)/1000, Math.round(Math.sin(a)*1000)/1000 );
				
				Registry.PUNCH_b2JointDef.Initialize( body, punch, punch.GetPosition(), jointAx );
				joint = Session.b2world.CreateJoint( Registry.PUNCH_b2JointDef ) as b2PrismaticJoint;
				joint.SetMotorSpeed( 0 );
			}
			
			if ( Session.isOnEditor ) {
				var ses:Session = Session.instance;
				switch ( defRa ) {
					case 0:
						if ( defTileX > 0 )
							requiresTile = ses.tileMap[defTileX-1][defTileY];
						break;
					case Math.PI:
						if ( defTileX < ses.cols-1 )
							requiresTile = ses.tileMap[defTileX+1][defTileY];
						break;
						
					case Trigo.HALF_PI:
						if ( defTileY > 0 )
							requiresTile = ses.tileMap[defTileX][defTileY-1];
						break;
					case -Trigo.HALF_PI:
						if ( defTileY < ses.rows-1 )
							requiresTile = ses.tileMap[defTileX][defTileY+1];
						break;
				}
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
			
			_contactList.splice( 0, _contactList.length );
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
		
		
			// -- private --
			private static var _BodyShape:b2PolygonShape, _SensorShape:b2PolygonShape, _PunchShape:b2PolygonShape
			
			private var _contactList:Vector.<b2Fixture> = new Vector.<b2Fixture>
			//private var _hitBall:Vector.<Ball> = new Vector.<Ball>
			
			
			private function _onContact( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture ):void
			{
				if ( contact.IsSensor() && sensor == thisFixt ) {
					if ( fixt.GetMassData().mass )
						_contactList.push( fixt );
					
				} else {
					_flag.setTrue( FLAG_WASMOVED );
				}
				
			}
			
			private function _onContactEnd( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture ):void
			{
				if ( contact.IsSensor() && sensor == thisFixt ) {
					var p:int = _contactList.indexOf(fixt);
					if ( p > -1 ) _contactList.splice( p, 1 );
				}
			}
			
			
		public function onPostSolveContact( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture, impulse:b2ContactImpulse ):void
		{
			if ( contact.IsSensor() ) return;
			
			// H4X0RZ
			var udata:* = fixt.GetBody().GetUserData();
			if ( punch == thisFixt.GetBody() && joint.GetMotorSpeed() > 0 && udata is Ball ) {
				var ball:Ball = fixt.GetBody().GetUserData() as Ball;
				var f:Number = Registry.BALL_MaxSpeed;
				ball.body.SetLinearVelocity( new b2Vec2(jointAx.x*f, jointAx.y*f) );
			}
			
			var imp:Number = impulse.normalImpulses[0];
			if ( imp < Registry.b2NormalImpulseMin ) return;
			var a:Array, vol:Number = MathUtils.limit((imp-Registry.b2NormalImpulseMin)/Registry.b2NormalImpulseMax, 0, 1) *BallCtrl.instance.getVolumeFromAfar(p);
			
			// hit the puncher
			if ( punch == thisFixt.GetBody() ) {
				if ( udata is Ball ) {
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
				if ( udata is Ball ) {
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