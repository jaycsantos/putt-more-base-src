package pb2.game.entity 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Dynamics.b2FixtureDef;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.sound.GameSounds;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.entity.b2.Ib2SignalReceiver;
	import pb2.game.entity.b2.Ib2SignalRelay;
	import pb2.game.entity.b2.Ib2SignalTransmitter;
	import pb2.game.entity.render.FloorGateRender;
	import pb2.game.Registry;
	import pb2.game.Session;
	import pb2.GameAudio;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class FloorGate extends b2EntityTile implements Ib2SignalReceiver
	{
		public static const STATE:uint = 1 << 17
		public static const ISREVERSED:uint = 1 << 19
		
		
		public var gateRender:FloorGateRender
		
		public function FloorGate(args:EntityArgs) 
		{
			super( args );
			
			_flag.setFlag( ISREVERSED, Boolean(args.data.isReversed) );
			_flag.setTrue( FLAG_ISFIXED );
			
			createBody();
		}
		
		override public function createBody():void 
		{
			var ts:Number = Registry.tileSize /Registry.b2Scale, ts2:Number = ts /2;
			
			body = Session.b2world.CreateBody( Registry.STATIC_b2BodyDef );
			body.SetUserData( this );
			
			var fixtDef:b2FixtureDef = Registry.STATIC_b2FixtDef;
			fixtDef.shape = b2PolygonShape.AsBox( ts2, ts2*7/18 );
			body.CreateFixture( fixtDef );
			
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			gateRender = null;
			
			if ( _relay )
				_relay.removeNode( this );
		}
		
		
		override public function setDefault( x:Number, y:Number, a:Number = 0 ):void 
		{
			super.setDefault( x, y, a );
			
			gateRender.reset();
		}
		
		override public function useDefault():void 
		{
			_flag.setFalse( STATE );
			
			super.useDefault();
			
			body.SetActive( _flag.isTrue(ISREVERSED)? _flag.isTrue(STATE): _flag.isFalse(STATE) );
		}
		
		
		
		public function get state():Boolean
		{
			return _flag.isTrue( STATE );
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
		
		public function receive( data:* ):Boolean
		{
			_flag.setFlag( STATE, Boolean(data) );
			
			body.SetActive( _flag.isTrue(ISREVERSED)? _flag.isTrue(STATE): _flag.isFalse(STATE) );
			gateRender.play();
			
			var vol:Number = MathUtils.limit((650-p.subtractedBy(BallCtrl.instance.getPrimary().p).length)/650, 0, 0.95);
			if ( !GameSounds.instance.isPlaying(GameAudio.GATE) )
				GameSounds.play( GameAudio.GATE, 0, 0, vol );
			else if ( vol > GameSounds.instance.getSoundObj(GameAudio.GATE).volume )
				GameSounds.setPanVol( GameAudio.GATE, 0, vol );
			
			return true;
		}
		
		
			// -- private --
			
			private var _relay:Ib2SignalRelay
		
	}

}