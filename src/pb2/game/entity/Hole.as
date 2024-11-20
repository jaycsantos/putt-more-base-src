package pb2.game.entity 
{
	import apparat.math.FastMath;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.b2internal;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Contacts.b2Contact;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.sound.GameSounds;
	import com.jaycsantos.sound.PlayRequestPriority;
	import org.osflash.signals.Signal;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.entity.b2.b2EntRender;
	import pb2.game.entity.render.HoleRender;
	import pb2.game.Registry;
	import pb2.game.Session;
	import pb2.GameAudio;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Hole extends b2EntityTile 
	{
		use namespace b2internal
		
		public var onPutt:Signal
		public var holeRender:HoleRender
		public var radius:Number, maxSpeedIntake:Number = 6
		
		
		public function Hole( args:EntityArgs )
		{
			super( args );
			
			radius = args.data.radius;
			_visitors = new Vector.<Ball>();
			
			createBody();
			
			
			onPutt = new Signal( Ball );
			
			_flag.setTrue( FLAG_ISFIXED );
			onContact.add( _onContact );
			onContactEnd.add( _onContactEnd );
			
			BallCtrl.instance.setHole( this );
		}
		
		override public function createBody():void 
		{
			body = Session.b2world.CreateBody( new b2BodyDef );
			
			Registry.SENSOR_b2FixtDef.shape = new b2CircleShape( radius /Registry.b2Scale );
			body.CreateFixture( Registry.SENSOR_b2FixtDef );
			body.SetUserData( this );
			
		}
		
		override public function dispose():void 
		{
			BallCtrl.instance.setHole( null );
			
			super.dispose();
			
			holeRender = null;
			onPutt.removeAll(); onPutt = null;
			
			_visitors.splice( 0, _visitors.length );
		}
		
		
		override public function update():void 
		{
			if ( !isActive ) return;
			
			super.update();
			
			var b:Ball = BallCtrl.instance.getPrimary();
			if ( b && b.isOnHole && !b.isMoving )
				return;
			
			var dCenter:Number, dx:Number, dy:Number, dRadius:Number, vl:Number;
			
			for each( var ball:Ball in _visitors ) {
				
				dx = p.x - ball.p.x;
				dy = p.y - ball.p.y;
				dCenter = p.distanceTo( ball.p );
				
				// ball's center of weight is within the hole/ its half inside
				if ( dCenter < radius ) {
					if ( ! ball.hole ) ball.hole = this;
					dRadius = radius -ball.radius;
					vl = ball.body.GetLinearVelocity().Length();
					
					if ( vl > maxSpeedIntake || vl == 0 )
						continue;
					
					if ( ball.isActive && ball.body.GetLinearVelocity().LengthSquared()>1 && !GameSounds.instance.isPlaying(GameAudio.BALL_HOLE) ) {
						if ( !ball.isPrimary )
							GameSounds.play( GameAudio.BALL_HOLE, 0, 0, MathUtils.limit((650-ball.p.subtractedBy(p).length)/650, 0, .9) );
						else
							GameSounds.play( GameAudio.BALL_HOLE, 0, 0, 1 );
						PlayRequestPriority.requestStop( GameAudio.BALL_ROLL );
					}
					
					// ball is totally inside of all
					if ( dCenter < dRadius ) {
						if ( ball.isActive && ball.isMoving ) {
							ball.body.m_linearVelocity.Set( 0, 0 );
							
							onPutt.dispatch( ball );
							ball.onMoveStop.dispatch( ball );
							ball.onRotateStop.dispatch( ball );
							ball.body.SetAwake( false );
							
							if ( !ball.isPrimary ) {
								ball.deactivate();
								
							} else {
								ball.ballRender.clipShade.alpha = 0;
							}
						}
						
					} else {
						ball.body.m_linearVelocity.Multiply( .5 );
						ball.body.ApplyImpulse( new b2Vec2(dx/10/Registry.b2Scale, dy/10/Registry.b2Scale), ball.body.GetPosition() );
						ball.ballRender.buffer.scaleX = ball.ballRender.buffer.scaleY = .9;
					}
					
				} else if ( GameSounds.instance.isPlaying(GameAudio.BALL_HOLE) )
					GameSounds.stop( GameAudio.BALL_HOLE );
				
			}
			
		}
		
		
			// -- private --
			
			private var _visitors:Vector.<Ball>
			
			
			private function _onContact( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture ):void
			{
				var trespaser:b2Body = fixt.GetBody();
				if ( trespaser.GetUserData() is Ball ) {
					var ball:Ball = trespaser.GetUserData() as Ball;
					if ( _visitors.indexOf(ball) == -1 )
						_visitors.push( ball );
				}
			}
			
			private function _onContactEnd( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture ):void
			{
				var trespaser:b2Body = fixt.GetBody();
				if ( trespaser.GetUserData() is Ball ) {
					var ball:Ball = trespaser.GetUserData() as Ball;
					if ( ball.isActive && ball.hole ) ball.hole = null;
					ball.ballRender.buffer.scaleX = ball.ballRender.buffer.scaleY = 1;
					var i:int = _visitors.indexOf( ball );
					if ( i > -1 )
						_visitors.splice( i, 1 );
				}
			}
			
			
			
	}

}