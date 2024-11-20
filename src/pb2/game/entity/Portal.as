package pb2.game.entity 
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Contacts.b2Contact;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.sound.GameSounds;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import org.osflash.signals.Signal;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.entity.render.PortalRender;
	import pb2.game.Registry;
	import pb2.game.Session;
	import pb2.GameAudio;
	import pb2.screen.ui.HudGame;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Portal extends b2EntityTile 
	{
		public static const RADIUS:uint = 6
		
		public var portalRender:PortalRender
		public var onWarp:Signal
		
		public function Portal( args:EntityArgs )
		{
			super( args );
			
			createBody();
			
			_ballMap = new Dictionary(true);
			_transfer = new Vector.<Ball>;
			_flag.setTrue( FLAG_ISFIXED );
			onWarp = new Signal;
			onContact.add( _onContact );
			onContactEnd.add( _onContactEnd );
		}
		
		override public function createBody():void 
		{
			body = Session.b2world.CreateBody( Registry.STATIC_b2BodyDef );
			
			Registry.SENSOR_b2FixtDef.shape = new b2CircleShape( RADIUS/Registry.b2Scale );
			body.CreateFixture( Registry.SENSOR_b2FixtDef );
			body.SetUserData( this );
			
		}
		
		override public function dispose():void 
		{
			for ( var k:* in _ballMap )
				delete _ballMap[k];
			
			unlink();
			portalRender = null;
			
			super.dispose();
		}
		
		
		override public function update():void 
		{
			if ( !isActive || !_link ) return;
			
			super.update();
			
			var released:Boolean, ball:Ball;
			for ( var b:* in _ballMap ) {
				if ( --_ballMap[b] ) continue;
				ball = b as Ball;
				
				ball.activate();
				ball.body.SetPosition( body.GetPosition() );
				//Ball(b).body.SetPosition( new b2Vec2(_ballMap[b][1]/Registry.b2Scale, _ballMap[b][2]/Registry.b2Scale) );
				//Ball(b).body.SetLinearVelocity( new b2Vec2(_ballMap[b][3], _ballMap[b][4]) );
				//Ball(b).body.SetAngularVelocity( _ballMap[b][5] );
				
				portalRender.play();
				released = true;
				
				if ( ball.isPrimary && HudGame.instance )
					HudGame.instance.markBallPosition( ball );
			}
			if ( released )
				GameSounds.play(GameAudio.WARP, 0, 0, MathUtils.limit((650-p.subtractedBy(BallCtrl.instance.getPrimary().p).length)/635, 0, 1));
			
			
			var i:int = _transfer.length;
			if ( i ) portalRender.play();
			while ( i-- )
				_link.transfer( _transfer[i] );
			_transfer.splice( 0, _transfer.length );
		}
		
		
		public function linkTo( p2:Portal ):void
		{
			if ( p2 == this ) return;
			
			_link = p2;
			portalRender.lightUp( p2.isLinked? 2: 1 );
		}
		
		public function unlink():void
		{
			var p:Portal = _link;
			_link = null;
			if ( p ) p.unlink();
			portalRender.lightUp( 0 );
		}
		
		public function get isLinked():Boolean
		{
			return Boolean(_link);
		}
		
		public function get linkPortal():Portal
		{
			return _link;
		}
		
		public function transfer( ball:Ball ):void
		{
			if ( _ballMap[ball] == undefined ) {
				if ( ball.isPrimary && HudGame.instance )
					HudGame.instance.markBallPosition( ball, NaN, true );
				
				var v:b2Vec2 = ball.body.GetLinearVelocity();
				_ballMap[ball] = Math.max( Math.abs(p.subtractedBy(ball.p).length/12) >>0, 10 );
				//_ballMap[ball] = [Math.abs(p.subtractedBy(ball.p).length/4) >>0, (ball.p.x-_link.p.x+p.x), (ball.p.y-_link.p.y+p.y), v.x, v.y, ball.body.GetAngularVelocity()];
				/*ball.body.SetPosition( new b2Vec2(_ballMap[ball][1], _ballMap[ball][2]) );
				ball.body.SetLinearVelocity( new b2Vec2(_ballMap[ball][3], _ballMap[ball][4]) );
				ball.body.SetAngularVelocity( _ballMap[ball][5] );*/
				ball.p.x = ball.p.x -_link.p.x +p.x;
				ball.p.y = ball.p.y -_link.p.y +p.y;
				ball.deactivate();
				onWarp.dispatch();
				
				GameSounds.play(GameAudio.WARP, 0, 0, ball.isPrimary? 1: MathUtils.limit((650-p.subtractedBy(BallCtrl.instance.getPrimary().p).length)/650, 0, 0.95));
			}
			
		}
		
		
		override public function useDefault():void 
		{
			super.useDefault();
			
			for ( var k:* in _ballMap ) {
				Ball(k).activate();
				delete _ballMap[k];
			}
			_transfer.splice( 0, _transfer.length );
		}
		
			// -- private --
			
			private var _ballMap:Dictionary, _link:Portal, _transfer:Vector.<Ball>
			
			private function _onContact( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture ):void
			{
				var b:b2Body = fixt.GetBody(), d:* = b.GetUserData();
				if ( d is Ball && _link && _ballMap[d] == undefined && _transfer.indexOf(d)==-1 )
					_transfer.push( d as Ball );
				
			}
			
			private function _onContactEnd( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture ):void
			{
				var b:b2Body = fixt.GetBody(), d:* = b.GetUserData();
				if ( d is Ball && _ballMap[d] != undefined )
					delete _ballMap[d];
			}
			
			
	}

}