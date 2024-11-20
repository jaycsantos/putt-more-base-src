package pb2.game.entity 
{
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.b2internal;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Contacts.b2Contact;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.math.Trigo;
	import com.jaycsantos.sound.GameSounds;
	import com.jaycsantos.sound.PlayRequestPriority;
	import org.osflash.signals.Signal;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.entity.b2.*;
	import pb2.game.entity.render.BallRender;
	import pb2.game.entity.tile.WallEdge;
	import pb2.game.*;
	import pb2.GameAudio;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Ball extends b2EntityTileTool implements Ib2PostSolveCaller
	{
		public static const FLAG_ISPRIMARYBALL:uint = 65536
		
		public var radius:Number
		public var hole:Hole
		public var ballRender:BallRender
		public var onSolveContact:Signal
		
		
		use namespace b2internal
		
		public function Ball( args:EntityArgs = null )
		{
			super( args );
			
			radius = args.data.radius;
			onSolveContact = new Signal( Number );
			
			createBody();
		}
		
		override public function createBody():void 
		{
			body = Session.b2world.CreateBody( Registry.BALL_b2BodyDef );
			body.SetUserData( this );
			//body.SetFixedRotation( true );
			
			var fixtDef:b2FixtureDef = Registry.BALL_b2FixtDef;
			fixtDef.shape = Tile.getb2Circle( radius );
			body.CreateFixture( fixtDef );
		}
		
		override public function dispose():void 
		{
			if ( isPrimary ) BallCtrl.instance.setPrimary( null );
			
			super.dispose();
			
			ballRender = null;
		}
		
		
		override public function update():void 
		{
			if ( !isActive || !body ) return;
			
			super.update();
			
			if ( !body.IsAwake() ) {
				//if ( _flag.isTrue(FLAG_ISPRIMARYBALL) && GameSounds.instance.getSoundObj(GameAudio.BALL_ROLL).isPlaying() ) GameSounds.stop( GameAudio.BALL_ROLL );
				PlayRequestPriority.requestStop( GameAudio.BALL_ROLL );
				return;
			}
			
			var vol:Number, v:b2Vec2 = body.m_linearVelocity, vl:Number = v.Length();
			
			if ( vl > Registry.BALL_MaxSpeed )
				// rescale to ration
				v.Multiply( Registry.BALL_MaxSpeed /vl );
			
			if ( vl )
				render.redraw();
			
			if ( !hole ) {
				var damp:Number = Session.instance.floor.getDampXY( p.x, p.y );
				CONFIG::debug { DOutput.show( 'damp:', damp ); }
				
				var mxLinDamp:Number = Registry.BALL_b2BodyDef.linearDamping;
				body.m_linearDamping = mxLinDamp / (vl>0 && vl<.5? vl: 1) *damp;
				
				var mxAngDamp:Number = Registry.BALL_b2BodyDef.angularDamping;
				body.m_angularDamping = (vl>2? mxAngDamp*(vl/2) : mxAngDamp/(vl/2)) *damp;
				
				// handle rolling audio
				vol = Math.min(vl,(Registry.BALL_MaxSpeed/2)) / (Registry.BALL_MaxSpeed/2);
				var b:Ball = BallCtrl.instance.getPrimary();
				if ( b && _flag.isFalse(FLAG_ISPRIMARYBALL) )
					vol *= 1 -MathUtils.limit( p.subtractedBy(b.p).length/700, 0, .95 );
				if ( vol > 0.08 )
					PlayRequestPriority.requestPlay( GameAudio.BALL_ROLL, 0, int.MAX_VALUE, vol );
				else
					PlayRequestPriority.requestStop( GameAudio.BALL_ROLL );
				
			} else {
				body.m_linearDamping = Registry.BALL_b2BodyDef.linearDamping;
				body.m_angularDamping = Registry.BALL_b2BodyDef.angularDamping;
			}
			
			CONFIG::debug {
				DOutput.show( 'projection: '+ Trigo.getAngle(v.x, v.y).toFixed(1) );
				DOutput.show( 'vx:', v.x.toFixed(2), ', vy:', v.y.toFixed(2), ', a:', Trigo.getAngle(v.x, v.y).toFixed(2) );
				DOutput.show( 'roll volume:', vol );
			}
		}
		
		
		override public function useDefault():void 
		{
			super.useDefault();
			
			if ( hole ) {
				activate();
				
				ballRender.clipShade.alpha = 1;
				ballRender.buffer.scaleX = ballRender.buffer.scaleY = 1;
				hole = null;
			}
			
			PlayRequestPriority.requestStop( GameAudio.BALL_ROLL );
		}
		
		
		public function get isOnHole():Boolean
		{
			return Boolean( hole );
		}
		
		public function get isPrimary():Boolean
		{
			return _flag.isTrue( FLAG_ISPRIMARYBALL );
		}
		
		
		
		b2internal function setAsPrimary():void
		{
			_flag.setTrue( FLAG_ISPRIMARYBALL );
			ballRender.setAsPrimary();
		}
		
		b2internal function unsetAsPrimary():void
		{
			_flag.setFalse( FLAG_ISPRIMARYBALL );
			ballRender.unsetAsPrimary();
		}
		
		
		override public function deactivate():void 
		{
			PlayRequestPriority.requestStop( GameAudio.BALL_ROLL );
			
			super.deactivate();
		}
			
			// -- private --
			
			public function onPostSolveContact( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture, impulse:b2ContactImpulse ):void
			{
				if ( contact.IsSensor() ) return;
				
				var udata:* = fixt.GetBody().GetUserData();
				var imp:Number = impulse.normalImpulses[0];
				onSolveContact.dispatch( imp );
				
				if ( isPrimary && imp > Registry.BALL_shakeImpulseMin )
					Session.world.camera.shake( Registry.BALL_shakeIntensity, Registry.BALL_shakeLength );
				
				if ( imp > Registry.b2NormalImpulseMin ) {
					var a:Array, vol:Number = MathUtils.limit( (imp-Registry.b2NormalImpulseMin)/Registry.b2NormalImpulseMax, 0, 1 ) *BallCtrl.instance.getVolumeFromAfar( p );
					
					if ( udata is b2EntityTile ) {
						switch( b2EntityTile(udata).materialName ) {
							case 'wood':
								a = [GameAudio.WOOD_TAP1, GameAudio.WOOD_TAP2, GameAudio.WOOD_TAP3];
								GameSounds.play( a[MathUtils.randomInt(0, 2)], 0, 0, vol );
								break;
							case 'golfball':
							case 'srelay':
							case 'wall':
							case 'gate':
							case 'gate2':
							case 'gate3':
								a = [GameAudio.WALL_TAP1, GameAudio.WALL_TAP2, GameAudio.WALL_TAP3];
								GameSounds.play( a[MathUtils.randomInt(0, 2)], 0, 0, vol );
								break;
							case 'wrub':
							case 'rubber':
								trace( 'rubber', vol );
								GameSounds.play( GameAudio.RUBBER_TAP, 0, 0, vol );
								break;
							case 'wpad':
								GameSounds.play( GameAudio.SQUISH_TAP, 0, 0, vol );
								break;
							case 'jelly':
								GameSounds.play( GameAudio.JELLY_TAP, 0, 0, vol );
								break;
							case 'glass':
								GameSounds.play( GameAudio.GLASSTAP, 0, 0, vol );
								break;
							case 'spinner':
								GameSounds.play( GameAudio.FLICK, 0, 0, vol );
								break;
							default:
								break;
						}
						
					} else
					if ( udata is WallEdge ) {
						a = [GameAudio.WALL_TAP1, GameAudio.WALL_TAP2, GameAudio.WALL_TAP3];
						GameSounds.play( a[MathUtils.randomInt(0, 2)], 0, 0, vol*.7 );
						
					}
					
					if ( imp > Registry.b2NormalImpulseMax/2 ) {
						var worldMani:b2WorldManifold = new b2WorldManifold();
						contact.GetWorldManifold( worldMani );
						var wp:b2Vec2 = worldMani.m_points[0].Copy();
						wp.Multiply( Registry.b2RenderScale );
						Session.instance.toons.applyImpact( wp.x, wp.y, Trigo.getRadian(p.x-wp.x, p.y-wp.y) );
					}
					
				} else if ( imp > 0 )
					trace( '3:impulse', imp.toFixed(4) );
					
			}
			
			
	}

}