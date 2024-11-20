package pb2.game.entity 
{
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Contacts.b2Contact;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.sound.GameSounds;
	import org.osflash.signals.Signal;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.entity.b2.*;
	import pb2.game.entity.render.GlassRender;
	import pb2.game.*;
	import pb2.GameAudio;
	import pb2.util.pb2internal;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Glass extends b2EntityTile implements Ib2PostSolveCaller
	{
		public var glassRender:GlassRender
		public var onBreak:Signal
		
		public function Glass( args:EntityArgs )
		{
			super( args );
			
			createBody();
			//_flag.setTrue( FLAG_ISFIXED );
			
			onBreak = new Signal;
			//onContact.add( _onContact );
		}
		
		override public function createBody():void 
		{
			body = Session.b2world.CreateBody( Registry.ALL_b2bodyDef );
			
			var fixtDef:b2FixtureDef = Registry.GLASS_b2FixtDef;
			fixtDef.shape = Tile.getb2Shape( 'sq', .35 );
			
			body.CreateFixture( fixtDef );
			body.SetUserData( this );
			body.SetLinearDamping( 2 );
			body.SetAngularDamping( 3 );
		}
		
		override public function dispose():void 
		{
			glassRender = null;
			
			super.dispose();
		}
		
		
		override public function update():void 
		{
			if ( _flag.isTrue(FLAG_BROKEN) && body.IsActive() ) {
				body.SetActive(false);
				glassRender.hitBreak();
				body.SetLinearVelocity( new b2Vec2 );
				body.SetAngularVelocity( 0 );
				GameSounds.play( GameAudio.GLASSBREAK, 0, 0, BallCtrl.instance.getVolumeFromAfar(p) );
				onBreak.dispatch();
				
			} else
				super.update();
		}
		
		
		override public function useDefault():void 
		{
			if ( _flag.isTrue(FLAG_BROKEN) && defTileX > -1 && defTileY > -1 )
				activate();
			glassRender.reassemble();
			_flag.setFalse( FLAG_BROKEN );
			
			
			super.useDefault();
		}
		
		
		public function get isBroken():Boolean
		{
			return _flag.isTrue( FLAG_BROKEN );
		}
		
		pb2internal function trigger():void
		{
			_flag.setTrue( FLAG_BROKEN );
		}
		
		
			// -- private --
			
			private static const FLAG_BROKEN:uint=512
			
			public function onPostSolveContact( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture, impulse:b2ContactImpulse ):void
			{
				if ( contact.IsSensor() ) return;
				
				var i:Number = 0;
				//if ( contact.GetFixtureA() == thisFixt )
					i = impulse.normalImpulses[0];
				//else
					//i = impulse.normalImpulses[1];
				//for each( var j:Number in impulse.normalImpulses )
					//i += j;
				
				if ( i > Registry.GLASS_b2ImpactMin ) {
					trace( 'impulse:', i, impulse.normalImpulses.join(','), impulse.tangentImpulses.join(',') );
					_flag.setTrue( FLAG_BROKEN );
					
					//var ent:* = fixt.GetBody().GetUserData();
					//if ( ent is b2Entity )
						//GameSounds.play(GameAudio.GLASSBREAK, 0, 0, BallCtrl.instance.isPrimary(ent)? 1: MathUtils.limit((650-p.subtractedBy(BallCtrl.instance.getPrimary().p).length)/650, 0, 0.95));
				}
			}
			
			
			
	}

}