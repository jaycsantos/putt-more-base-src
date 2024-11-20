package pb2.game.entity 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.b2internal;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Joints.*;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.Trigo;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.*;
	import pb2.game.entity.render.WallGateRender;
	import pb2.screen.EditorScreen;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class WallGate extends b2EntityTile 
	{
		public static const STATE:uint=131072, ISREVERSED:uint=262144, ISBROKEN:uint=524288;
		
		
		public var pjoint:b2PrismaticJoint, pjointAxis:b2Vec2
		public var gateRender:WallGateRender
		
		public function WallGate( args:EntityArgs )
		{
			super( args );
			
			_flag.setFlag( ISREVERSED, Boolean(args.data.isReversed) );
			_flag.setFlag( STATE, !Boolean(args.data.isReversed) );
			
			
			_flag.setTrue( FLAG_ISFIXED );
			pjointAxis = new b2Vec2;
			createBody();
		}
		
		override public function createBody():void 
		{
			body = Session.b2world.CreateBody( Registry.WALLGATE_b2BodyDef );
			body.CreateFixture( Registry.WALLGATE_b2FixtDef );
			body.SetUserData( this );
			
			pjoint = null;
		}
		
		
		override public function update():void 
		{
			if ( !isActive || !pjoint ) return;
			
			super.update();
			
			var jointVal:Number = ((pjoint.GetJointTranslation() * 100) << 0) / 100;
			if ( _flag.isTrue(STATE) ) {
				if ( jointVal+.02 >= pjoint.GetUpperLimit() && pjoint.GetMotorSpeed() > 0 )
					pjoint.SetMotorSpeed( 0 );
				
			} else {
				if ( jointVal-.02 <= pjoint.GetLowerLimit() && pjoint.GetMotorSpeed() < 0 )
					pjoint.SetMotorSpeed( 0 );
			}
			
			if ( !(Session.isOnEditor && EditorScreen.editMode) && _ctr++ > FRAME_DELAY ) {
				_ctr = 0;
				// not done, break it!
				if ( _flag.isTrue(STATE) && pjoint.GetMotorSpeed() ) {
					if ( ++_breakCtr >= Registry.WALLGATE_breakLimit ) {
						pjoint.SetMotorSpeed( 0 );
						_flag.setTrue( ISBROKEN );
					}
					gateRender.redraw();
				}
				if ( _flag.isFalse(ISBROKEN) ) {
					_flag.setFlag( STATE, _flag.isFalse(STATE) );
					pjoint.SetMotorSpeed( _flag.isTrue(STATE) ? Registry.WALLGATE_b2MotorSpeed : -Registry.WALLGATE_b2MotorSpeed );
				}
			}
			
		}
		
		
		override public function setDefault( x:Number, y:Number, a:Number = 0 ):void 
		{
			var changed:Boolean = a.toFixed(5) != defRa.toFixed(5) || defPx != x || defPy != y;
			
			super.setDefault( x, y, a );
			
			if ( changed || ! pjoint ) {
				if ( pjoint )
					Session.b2world.DestroyJoint( pjoint );
				pjointAxis.Set( Math.cos(a), Math.sin(a) );
				
				Registry.WALLGATE_b2JointDef.Initialize( Session.b2world.GetGroundBody(), body, body.GetPosition(), pjointAxis );
				pjoint = Session.b2world.CreateJoint( Registry.WALLGATE_b2JointDef ) as b2PrismaticJoint;
				
				pjoint.SetMotorSpeed( _flag.isTrue(ISREVERSED) ? -Registry.WALLGATE_b2MotorSpeed*5: 0 );
				
				
				gateRender.redraw();
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
			
			_flag.setFalse( ISBROKEN );
			_flag.setFlag( STATE, !_flag.isTrue(ISREVERSED) );
			_ctr = _breakCtr = 0;
			gateRender.redraw();
			
			if ( pjoint )
				pjoint.SetMotorSpeed( _flag.isFalse(STATE) ? -Registry.WALLGATE_b2MotorSpeed*5: 0 );
		}
		
		
		public function get breakCount():uint
		{
			return _breakCtr;
		}
		
		
			// -- private -
			private static const FRAME_DELAY:uint = 100;
			
			private var _ctr:int, _breakCtr:int
			
	}
		
		
		
	
}