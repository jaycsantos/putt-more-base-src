package pb2.game.entity 
{
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Collision.Shapes.b2MassData;
	import Box2D.Common.b2internal;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Contacts.b2Contact;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.math.Trigo;
	import com.jaycsantos.sound.GameSounds;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.entity.b2.b2EntityTileTool;
	import pb2.game.entity.b2.Ib2PostSolveCaller;
	import pb2.game.entity.tile.WallEdge;
	import pb2.game.Registry;
	import pb2.game.Session;
	import pb2.game.Tile;
	import pb2.GameAudio;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Block extends b2EntityTileTool implements Ib2PostSolveCaller
	{
		
		public function Block( args:EntityArgs )
		{
			super( args );
			
			createBody();
		}
		
		override public function createBody():void 
		{
			var fixtDef:b2FixtureDef;
			switch( materialName ) {
				case 'jelly':
					body = Session.b2world.CreateBody( Registry.JELLY_b2BodyDef );
					fixtDef = Registry.JELLY_b2FixtDef; break;
				case 'rubber':
					body = Session.b2world.CreateBody( Registry.RUBBER_b2BodyDef );
					fixtDef = Registry.RUBBER_b2FixtDef; break;
				case 'wood': default:
					body = Session.b2world.CreateBody( Registry.ALL_b2bodyDef );
					fixtDef = Registry.ALL_b2FixtDef; break;
			}
			fixtDef.shape = Tile.getb2Shape( shapeName, 1 );
			body.CreateFixture( fixtDef );
			body.SetUserData( this );
			
			var md:b2MassData = new b2MassData;
			body.GetMassData( md );
			switch( shapeName ) {
				case 'sq': md.mass *3/4; body.SetMassData( md ); break;
				case 'hf': md.mass *3/2; body.SetMassData( md ); break;
				case 'hrtri1': md.mass *5/2; body.SetMassData( md ); break;
				case 'hrtri2': md.mass *5/2; body.SetMassData( md ); break;
				case 'hrtri3': md.mass *5/4; body.SetMassData( md ); break;
				case 'hrtri4': md.mass *5/4; body.SetMassData( md ); break;
			}
		}
		
		
		override public function update():void 
		{
			if ( !isActive || !body ) return;
			
			super.update();
			
			if ( !body.IsAwake() ) return;
			
			use namespace b2internal;
			
			if ( _flag.isTrue(FLAG_HASTILEMOVE) ) {
				var damp:Number = body.m_linearVelocity ? Session.instance.floor.getDampB2vec2(body.GetWorldCenter()) : 1;
				switch( materialName ) {
					case 'jelly':
						body.m_linearDamping = Registry.JELLY_b2BodyDef.linearDamping *damp;
						body.m_angularDamping = Registry.JELLY_b2BodyDef.angularDamping *damp;
						break;
					case 'rubber':
						body.m_linearDamping = Registry.RUBBER_b2BodyDef.linearDamping *damp;
						body.m_angularDamping = Registry.RUBBER_b2BodyDef.angularDamping *damp;
						break;
					case 'wood': default:
						body.m_linearDamping = Registry.ALL_b2bodyDef.linearDamping *damp;
						body.m_angularDamping = Registry.ALL_b2bodyDef.angularDamping *damp;
						break;
				}
			}
		}
		
		
		override public function setDefault( x:Number, y:Number, a:Number = 0 ):void 
		{
			// randomize rotation of square
			switch( materialName ) {
				case 'wood':
					if ( shapeName == 'sq' ) body.SetAngle( a = MathUtils.randomInt(-1, 2)*Trigo.HALF_PI );
					break;
				case 'rubber':
					break;
			}
			
			super.setDefault( x, y, a );
		}
		
		
			// -- private --
			
			public function onPostSolveContact( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture, impulse:b2ContactImpulse ):void
			{
				if ( contact.IsSensor() ) return;
				
				var udata:* = fixt.GetBody().GetUserData();
				var imp:Number = impulse.normalImpulses[0];
				
				if ( imp > Registry.b2NormalImpulseMin *2 ) {
					var vol:Number = MathUtils.limit( (imp-Registry.b2NormalImpulseMin*2)/Registry.b2NormalImpulseMax/2, 0, 1 ) *BallCtrl.instance.getVolumeFromAfar( p );
					
					if ( (udata is b2EntityTile || udata is WallEdge) && !(udata is Ball) ) {
						var material:String = udata is WallEdge || udata is RelayBlock ? 'wall' : b2EntityTile(udata).materialName;
						var a:Array;
						
						if ( material == 'wood' && materialName == 'wood' ) {
							a = [GameAudio.WOOD_TAP1, GameAudio.WOOD_TAP2, GameAudio.WOOD_TAP3];
							GameSounds.play( a[MathUtils.randomInt(0, 2)], 0, 0, vol );
							
						} else
						if ( (material == 'wood' && materialName == 'wall') || (material == 'wall' && materialName == 'wood') ) {
							a = [GameAudio.WALL_TAP1, GameAudio.WALL_TAP2, GameAudio.WALL_TAP3];
							GameSounds.play( a[MathUtils.randomInt(0, 2)], 0, 0, vol );
							
						} else
						/*if ( material == 'wrub' || material == 'rubber' || materialName == 'wrub' || materialName == 'rubber' ) {
							GameSounds.play( GameAudio.RUBBER_TAP, 0, 0, vol );
							
						} else*/
						if ( material == 'wpad' || materialName == 'wpad' ) {
							GameSounds.play( GameAudio.SQUISH_TAP, 0, 0, vol );
							
						} else
						if ( material == 'jelly' || materialName == 'jelly' ) {
							GameSounds.play( GameAudio.JELLY_TAP, 0, 0, vol );
							
						} else
						if ( udata is FloorGate ) {
							a = [GameAudio.WALL_TAP1, GameAudio.WALL_TAP2, GameAudio.WALL_TAP3];
							GameSounds.play( a[MathUtils.randomInt(0, 2)], 0, 0, vol );
						}
						
					}
					
					
					if ( !(udata is Ball) && imp > Registry.b2NormalImpulseMax/2 ) {
						var worldMani:b2WorldManifold = new b2WorldManifold();
						contact.GetWorldManifold( worldMani );
						var wp:b2Vec2 = worldMani.m_points[0].Copy();
						wp.Multiply( Registry.b2RenderScale );
						Session.instance.toons.applyImpact( wp.x, wp.y, Trigo.getRadian(p.x-wp.x, p.y-wp.y) );
					}
					
				}
					
			}
			
			
			
	}

}