package pb2.game.entity 
{
	import Box2D.Dynamics.b2FixtureDef;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.sound.GameSounds;
	import com.jaycsantos.util.GameLoop;
	import org.osflash.signals.Signal;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.entity.b2.*;
	import pb2.game.entity.render.RelayBlkRender;
	import pb2.game.*;
	import pb2.GameAudio;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class RelayBlock extends b2EntityTile implements ISolidWall, Ib2SignalRelay
	{
		public static const RELAY_STATE:uint = 131072;
		
		
		public var blkRender:RelayBlkRender, onBeep:Signal
		
		public function RelayBlock( args:EntityArgs )
		{
			super( args );
			
			_receivers = new Vector.<Ib2SignalReceiver>();
			_transmitters = new Vector.<Ib2SignalTransmitter>();
			
			createBody();
			
			_flag.setTrue( FLAG_ISFIXED );
			onBeep = new Signal;
			//materialName = 'wall';
		}
		
		override public function createBody():void 
		{
			body = Session.b2world.CreateBody( Registry.STATIC_b2BodyDef );
			body.SetUserData( this );
			
			var fixtDef:b2FixtureDef = Registry.STATIC_b2FixtDef;
			fixtDef.shape = Tile.getb2Shape( 'sq' );
			body.CreateFixture( fixtDef );
			
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			onBeep.removeAll(); onBeep = null;
			
			var i:int = _transmitters.length;
			while ( i-- )
				_transmitters[i].relayTo( null );
			
			i = _receivers.length;
			while ( i-- )
				_receivers[i].relayTo( null );
		}
		
		
		override public function setDefault( x:Number, y:Number, a:Number = 0 ):void 
		{
			super.setDefault( x, y, a );
			blkRender.redrawAndNeighbors();
		}
		
		override public function useDefault():void 
		{
			super.useDefault();
			_flag.setFalse( RELAY_STATE );
		}
		
		
		public function get state():Boolean
		{
			return _flag.isTrue( RELAY_STATE );
		}
		
		public function get nodeCount():uint 
		{
			return _transmitters.length + _receivers.length;
		}
		
		public function get transmitters():Vector.<Ib2SignalTransmitter> 
		{
			return _transmitters;
		}
		
		public function get receivers():Vector.<Ib2SignalReceiver> 
		{
			return _receivers;
		}
		
		public function addNode( node:Ib2SignalNode ):void
		{
			var i:int;
			
			if ( node is Ib2SignalReceiver ) {
				i = _receivers.indexOf( node );
				if ( i == -1 )
					_receivers.push( node );
			}
			
			if ( node is Ib2SignalTransmitter ) {
				i = _transmitters.indexOf( node );
				if ( i == -1 )
					_transmitters.push( node );
			}
			
		}
		
		public function removeNode( node:Ib2SignalNode ):void
		{
			var i:int;
			
			if ( node is Ib2SignalReceiver ) {
				i = _receivers.indexOf( node );
				if ( i > -1 )
					_receivers.splice( i, 1 );
			}
			
			if ( node is Ib2SignalTransmitter ) {
				i = _transmitters.indexOf( node );
				if ( i > -1 )
					_transmitters.splice( i, 1 );
			}
			
		}
		
		
		public function receiveTransmit( data:*, from:Ib2SignalNode ):void
		{
			if ( _transmitters.indexOf(from) == -1 ) return;
			if ( _lastReceive > GameLoop.instance.time ) return;
			_lastReceive = GameLoop.instance.time +Registry.BUTTON_ToggleDelay;
			
			var value:Boolean = Boolean(data);
			if ( _flag.isFlag(RELAY_STATE, value) ) return;
			_flag.setFlag( RELAY_STATE, value );
			
			
			var vol:Number = MathUtils.limit((650-p.subtractedBy(BallCtrl.instance.getPrimary().p).length)/650, 0, 0.95);
			if ( !GameSounds.instance.isPlaying(GameAudio.GATE) )
				GameSounds.play( GameAudio.GATE, 0, 0, vol );
			else if ( vol > GameSounds.instance.getSoundObj(GameAudio.GATE).volume )
				GameSounds.setPanVol( GameAudio.GATE, 0, vol );
			
			if ( !Session.isBusy ) 
				onBeep.dispatch();
			
			var i:int = _receivers.length;
			while ( i-- )
				_receivers[i].receive( value );
			
			blkRender.play();
			
		}
		
		
			// -- private --
			
			private var _receivers:Vector.<Ib2SignalReceiver>
			private var _transmitters:Vector.<Ib2SignalTransmitter>
			private var _lastReceive:uint
			
	}

}