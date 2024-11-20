package pb2.game.entity 
{
	import Box2D.Collision.Shapes.b2MassData;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2FilterData;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Joints.b2PrismaticJoint;
	import Box2D.Dynamics.Joints.b2PrismaticJointDef;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.math.Trigo;
	import com.jaycsantos.sound.GameSounds;
	import com.jaycsantos.util.GameLoop;
	import org.osflash.signals.Signal;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.entity.b2.b2Entity;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.entity.b2.Ib2SignalReceiver;
	import pb2.game.entity.b2.Ib2SignalRelay;
	import pb2.game.entity.b2.Ib2SignalTransmitter;
	import pb2.game.entity.render.PushBtnRender;
	import pb2.game.Registry;
	import pb2.game.Session;
	import pb2.GameAudio;
	import pb2.util.pb2internal;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PushButton extends b2EntityTile implements Ib2SignalTransmitter, Ib2SignalReceiver
	{
		public static const STATE:uint = 131072, ISTOGGLING:uint = 262144, ISREVERSED:uint = 524288;
		
		
		public var btnRender:PushBtnRender
		public var pjoint:b2PrismaticJoint, pjointAxis:b2Vec2
		
		public function PushButton( args:EntityArgs )
		{
			super( args );
			
			pjointAxis = new b2Vec2;
			_flag.setFlag( ISTOGGLING, Boolean(args.data.isToggle) );
			_flag.setFlag( ISREVERSED, Boolean(args.data.isReversed) );
			
			createBody();
			onContact.add( _onContact );
		}
		
		override public function createBody():void 
		{
			body = Session.b2world.CreateBody( Registry.ALL_b2bodyDef );
			body.CreateFixture( Registry.BUTTON_b2FixtDef );
			body.SetUserData( this );
			
			pjoint = null;
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			if ( _relay ) _relay.removeNode( this ); _relay = null;
			btnRender = null;
			pjoint = null;
		}
		
		
		override public function update():void 
		{
			if ( !isActive ) return;
			
			super.update();
			
			var ptrans:Number = ((pjoint.GetJointTranslation() * 100) << 0) / 100;
			if ( ptrans+.01 >= pjoint.GetUpperLimit() && pjoint.GetMotorSpeed() > 0 )
				pjoint.SetMotorSpeed( 0 );
				
			else if ( ptrans-.01 <= pjoint.GetLowerLimit() && pjoint.GetMotorSpeed() < 0 )
				pjoint.SetMotorSpeed( isToggleSwitch? Registry.BUTTON_b2MotorSpeed: 0 );
		}
		
		
		override public function setDefault( x:Number, y:Number, a:Number = 0 ):void 
		{
			var changed:Boolean = a.toFixed(5) != defRa.toFixed(5) || defPx != x || defPy != y;
			
			super.setDefault( x, y, a );
			
			if ( changed || ! pjoint ) {
				if ( pjoint )
					Session.b2world.DestroyJoint( pjoint );
				pjointAxis.Set( Math.cos(a), Math.sin(a) );
				
				Registry.BUTTON_b2JointDef.Initialize( Session.b2world.GetGroundBody(), body, body.GetPosition(), pjointAxis );
				pjoint = Session.b2world.CreateJoint( Registry.BUTTON_b2JointDef ) as b2PrismaticJoint;
				pjoint.SetMotorSpeed( _flag.isTrue(ISREVERSED) && _flag.isFalse(ISTOGGLING) ? -Registry.BUTTON_b2MotorSpeed: 0 );
				
				btnRender.redraw();
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
			
			_lastReceive = 0;
			_flag.setFalse( STATE );
			//transmit();
			
			if ( pjoint )
				pjoint.SetMotorSpeed( _flag.isTrue(ISREVERSED) && _flag.isFalse(ISTOGGLING) ? -Registry.BUTTON_b2MotorSpeed: 0 );
			
		}
		
		
		
		public function get state():Boolean
		{
			return _flag.isTrue( STATE );
		}
		
		public function get isToggleSwitch():Boolean
		{
			return _flag.isTrue( ISTOGGLING );
		}
		
		public function get isReversed():Boolean
		{
			return _flag.isTrue( ISREVERSED );
		}
		
		
		public function getRelay():Ib2SignalRelay
		{
			return _relay;
		}
		
		public function relayTo( relay:Ib2SignalRelay ):void
		{
			if ( _relay && _relay != relay )
				_relay.removeNode( this );
			
			_relay = relay;
			if ( relay ) _relay.addNode( this );
		}
		
		public function transmit():void
		{
			if ( _relay )
				_relay.receiveTransmit( _flag.isTrue(STATE), this );
		}
		
		public function receive( data:* ):Boolean
		{
			if ( _lastReceive > GameLoop.instance.time )
				return false;
			_lastReceive = GameLoop.instance.time +Registry.BUTTON_ToggleDelay;
			
			var value:Boolean = Boolean(data);
			if ( _flag.isFlag(STATE, value) )
				return false;
			_flag.setFlag( STATE, value );
			
			if ( _flag.isTrue(ISTOGGLING) )
				pjoint.SetMotorSpeed( -Registry.BUTTON_b2MotorSpeed );
			else
				pjoint.SetMotorSpeed( Registry.BUTTON_b2MotorSpeed *(!value?1:-1) *(_flag.isFalse(ISREVERSED)?1:-1) );
			
			transmit();
			return true;
		}
		
		
		pb2internal function trigger():void
		{
			if ( _flag.isTrue(ISTOGGLING) || _flag.isFlag(STATE, isReversed) )
				if ( receive(_flag.isFalse(STATE)) ) {
					_flag.setTrue( FLAG_WASMOVED );
					
					GameSounds.play( GameAudio.BEEP1, 0, 0, BallCtrl.instance.getVolumeFromAfar(p) );
				}
		}
		
		
			// -- private --
			
			private var _lastReceive:uint
			private var _relay:Ib2SignalRelay
			
			private function _onContact( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture ):void
			{
				if ( !contact.IsSensor() )
					pb2internal::trigger();
			}
			
			
	}

}