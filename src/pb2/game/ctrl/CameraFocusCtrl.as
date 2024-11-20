package pb2.game.ctrl 
{
	import com.jaycsantos.entity.GameCamera;
	import com.jaycsantos.math.AABB;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.math.Vector2D;
	import com.jaycsantos.util.UserInput;
	import pb2.game.entity.Ball;
	import pb2.game.Registry;
	import pb2.game.Session;
	import pb2.screen.ui.HudGame;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class CameraFocusCtrl 
	{
		public static const instance:CameraFocusCtrl = new CameraFocusCtrl
		
		public static function followBall( ball:Ball ):void
		{
			instance.followBall( ball );
		}
		
		public static function followMouse():void
		{
			instance.followMouse();
		}
		
		public static function followMouseBall( ball:Ball ):void
		{
			instance.followMouseBall( ball );
		}
		
		
		
		public function CameraFocusCtrl() 
		{
			if ( instance ) throw new Error('[pb2.game.ctrl.CameraFocusCtrl] Singleton class, use static property instance');
			
		}
		
		public function update():void
		{
			if ( _enabled && _update != null )
				_update();
		}
		
		
		public function enable():void
		{
			_enabled = true;
		}
		
		public function disable():void
		{
			_enabled = false;
		}
		
		public function get isEnabled():Boolean
		{
			return _enabled;
		}
		
		
		public function followBall( ball:Ball ):void
		{
			if ( ! Session.world ) return;
			
			Session.world.camera.target = ball.p;
			Session.instance.onEntitiesMoveStop.addOnce( followMouse );
			Session.world.camera.offWorldWidth = Session.world.camera.offWorldHeight = 0;
			//ball.onMoveStop.addOnce( followMouse );
			_update = null; _ball = null;
		}
		
		public function followMouse( a:* = null, ...rest ):void
		{
			if ( ! Session.world ) return;
			
			var cam:GameCamera = Session.world.camera;
			_mouseScroller.x = cam.p.x;
			_mouseScroller.y = cam.p.y;
			cam.target = _mouseScroller;
			cam.offWorldWidth = cam.offWorldHeight = 0;
			_update = _worldScroll; _ball = null;
		}
		
		public function followMouseBall( ball:Ball ):void
		{
			if ( ! Session.world ) return;
			
			var cam:GameCamera = Session.world.camera;
			_mouseScroller.x = cam.p.x;
			_mouseScroller.y = cam.p.y;
			cam.target = _mouseScroller;
			//cam.offWorldWidth = cam.offWorldHeight = 150;
			_update = _worldBallScroll; _ball = ball;
		}
		
		
		
			// -- private --
			
			private var _mouseScroller:Vector2D = new Vector2D
			private var _update:Function, _ball:Ball, _enabled:Boolean
			
			
			private function _worldScroll():void
			{
				var world:AABB = Session.world.bounds, cam:AABB = Session.world.camera.bounds;
				var ts:uint = Registry.tileSize, ts2:uint = ts *2;
				//var mouseX:uint = UserInput.instance.mouseX >HudGame.HUD_WIDTH? MathUtils.limit(UserInput.instance.mouseX -HudGame.HUD_WIDTH, 0, cam.width): ts2*2;
				var mouseX:int = MathUtils.limit( UserInput.instance.mouseX -HudGame.HUD_WIDTH, -1, cam.width );
				var mouseY:int = MathUtils.limit( UserInput.instance.mouseY, 0, cam.height );
				
				if ( mouseX >=0 && mouseX < ts2 )
					_mouseScroller.x -= (ts2 - mouseX) / 10;
				else if ( mouseX > cam.width - ts2 )
					_mouseScroller.x -= (cam.width - mouseX - ts2) / 10 << 0;
				_mouseScroller.x = Math.min(
													Math.max( 
														_mouseScroller.x, 
														cam.halfWidth
													),
													world.width - cam.halfWidth
												);
				
				if ( mouseX > 0 ) {
					if ( mouseY < ts2 )
						_mouseScroller.y -= (ts2 - mouseY) / 10;
					else if ( mouseY > cam.height - ts2 )
						_mouseScroller.y -= (cam.height - mouseY - ts2) / 10 << 0;
					_mouseScroller.y = Math.min(
														Math.max(
															_mouseScroller.y,
															cam.halfHeight
														),
														world.height - cam.halfHeight
													);
				}
				
			}
			
			private function _worldBallScroll():void
			{
				_worldScroll();
				
				var cam:AABB = Session.world.camera.bounds;
				var off:uint = 30;
				
				// make it to always show the ball
				_mouseScroller.x = MathUtils.limit( _mouseScroller.x, _ball.p.x +off -cam.halfWidth, _ball.p.x -off +cam.halfWidth );
				_mouseScroller.y = MathUtils.limit( _mouseScroller.y, _ball.p.y +off -cam.halfHeight, _ball.p.y -off +cam.halfHeight );
			}
			
	}

}