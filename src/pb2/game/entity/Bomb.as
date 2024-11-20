package pb2.game.entity 
{
	import apparat.math.FastMath;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Contacts.b2Contact;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.Trigo;
	import com.jaycsantos.sound.GameSounds;
	import org.osflash.signals.Signal;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.entity.render.BombRender;
	import pb2.game.Registry;
	import pb2.game.Session;
	import pb2.game.Tile;
	import pb2.GameAudio;
	import pb2.util.pb2internal;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Bomb extends b2EntityTile 
	{
		public var bombRender:BombRender
		public var sensor:b2Body
		public var onExplode:Signal
		
		
		public function Bomb( args:EntityArgs ) 
		{
			super(args);
			
			createBody();
			
			_flag.setTrue( FLAG_ISFIXED );
			
			onContact.add( _onContact );
			_impVec = new b2Vec2; _posTemp = new b2Vec2;
			onExplode = new Signal;
			_blastList = new Vector.<b2Body>;
		}
		
		override public function createBody():void 
		{
			var fixtDef:b2FixtureDef = Registry.STATIC_b2FixtDef;
			fixtDef.shape = Tile.getb2Circle( Registry.BOMB_Radius );
			
			body = Session.b2world.CreateBody( Registry.STATIC_b2BodyDef );
			body.CreateFixture( fixtDef );
			body.SetUserData( this );
			
			
			fixtDef = Registry.SENSOR_b2FixtDef;
			fixtDef.shape = Tile.getb2Circle( Registry.tileSize *2.6 );
			sensor = Session.b2world.CreateBody( Registry.ALL_b2bodyDef );
			sensor.CreateFixture( fixtDef );
			sensor.SetUserData( this );
			sensor.SetActive( false );
		}
		
		override public function dispose():void 
		{
			bombRender = null;
			onExplode.removeAll(); onExplode = null;
			
			super.dispose();
		}
		
		
		override public function update():void 
		{
			if ( _flag.isTrue(FLAG_BROKEN) && body.IsActive() ) {
				body.SetActive(false);
				bombRender.explode();
				sensor.SetActive( true );
				
				GameSounds.play( GameAudio.BOMB );
				
			} else if ( _flag.isTrue(FLAG_BROKEN) && _blastList.length ) {
				var d:Number, a:Number, dx:Number, dy:Number, max:Number = Registry.tileSize*2.5 / Registry.b2Scale;
				var ud:Object, c:b2Vec2, pos:b2Vec2, thisPos:b2Vec2 = body.GetWorldCenter();
				
				for each ( var b:b2Body in _blastList ) {
					if ( b.GetMass() ) {
						pos = b.GetWorldCenter()
						
						dx = pos.x-thisPos.x; dy = pos.y-thisPos.y;
						d = Math.max( max -FastMath.sqrt(dx*dx +dy*dy), 0 )*Registry.BOMB_Multiplier;
						
						if ( d ) {
							a = Trigo.getRadian( dx, dy );
							_posTemp.x = pos.x +0.01;
							_posTemp.y = pos.y +0.01;
							ud = b.GetUserData();
							b.SetAwake( true );
							if ( ud is Glass ) Glass(ud).pb2internal::trigger();
							else if ( ud is PushButton ) PushButton(ud).pb2internal::trigger();
							else if ( ud is PPuncher ) PPuncher(ud).pb2internal::trigger();
							
							_impVec.x = FastMath.cos(a) *d;
							_impVec.y = FastMath.sin(a) *d;
							b.ApplyImpulse( _impVec, _posTemp );
						}
					} else
					if ( b.GetUserData() is Bomb ) {
						pos = b.GetWorldCenter();
						dx = pos.x-thisPos.x; dy = pos.y-thisPos.y;
						
						if ( dx*dx +dy*dy < (max*max)/2 )
							Bomb(b.GetUserData()).pb2internal::trigger();
					}
				}
				_blastList.splice( 0, _blastList.length );
				sensor.SetActive( false );
				onExplode.dispatch();
				Session.world.camera.shake( Registry.BOMB_shakeIntensity, Registry.BOMB_shakeLength );
				
			} else
				super.update();
		}
		
		
		override public function useDefault():void 
		{
			if ( _flag.isTrue(FLAG_BROKEN) && defTileX > -1 && defTileY > -1 )
				activate();
			bombRender.reassemble();
			_flag.setFalse( FLAG_BROKEN | FLAG_WASMOVED );
			
			sensor.SetActive( false );
			
			super.useDefault();
			
			sensor.SetPosition( body.GetPosition() );
		}
		
		
		public function get hasExploded():Boolean
		{
			return _flag.isTrue( FLAG_BROKEN );
		}
		
		pb2internal function trigger():void
		{
			_flag.setTrue( FLAG_BROKEN | FLAG_WASMOVED );
		}
		
		
			// -- private --
			
			private static const FLAG_BROKEN:uint=512
			
			private var _impVec:b2Vec2, _posTemp:b2Vec2
			private var _blastList:Vector.<b2Body>
			
			private function _onContact( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture ):void
			{
				if ( !contact.IsSensor() ) {
					if ( thisFixt.GetBody() == body )
						_flag.setTrue( FLAG_BROKEN | FLAG_WASMOVED );
					
				} else {
					if ( thisFixt.GetBody() == sensor && !fixt.IsSensor() )
						_blastList.push( fixt.GetBody() );
					
				}
			}
			
			
	}

}