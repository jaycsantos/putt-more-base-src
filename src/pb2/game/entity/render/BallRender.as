package pb2.game.entity.render 
{
	import apparat.math.FastMath;
	import Box2D.Common.b2internal;
	import Box2D.Common.Math.b2Vec2;
	import com.demonsters.debugger.MonsterDebugger;
	import com.jaycsantos.display.*;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.math.*;
	import flash.display.*;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.entity.b2.*;
	import pb2.game.entity.Ball;
	import pb2.game.Session;
	import pb2.screen.EditorScreen;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class BallRender extends b2EntTileToolRender implements IDragBaseDraw
	{
		public var clip:MovieClip
		
		public function BallRender( ball:Ball, args:EntityArgs = null )
		{
			var ses:Session = Session.instance,
				sun:b2Vec2 = ses.sun_angle.Copy(); sun.Multiply( ses.sun_length );
			var sunAngle:int = Trigo.getAngle(sun.x, sun.y) << 0;
			
			super( ball, args );
			ball.ballRender = this;
			_ball = ball;
			
			Sprite(buffer).mouseEnabled = false;
			Sprite(buffer).mouseChildren = true;
			
			Sprite(buffer).addChild( clip = PuttBase2.assets.createDisplayObject('entity.block.'+ball.type) as MovieClip );
			clip.gotoAndStop( FRAME_GREEN );
			clip.buttonMode = true;
			clip.mouseChildren = false;
			clip.mouseEnabled = false;
			
			
			if ( clip.hasOwnProperty('dimples') )
				clip.dimples.stop();
			clip.innershade.rotation = sunAngle;
			
			var cached:CachedBmp, shadeCacheName:String = 'shades.'+ ball.type;
			cached = CachedAssets.getClip( shadeCacheName );
			if ( ! cached ) {
				var shade:Sprite = new Sprite, g:Graphics = Shape(shade.addChild( new Shape )).graphics;
				g.beginFill( 0 );
				g.drawCircle( 0, 0, ball.radius );
				shade.getChildAt(0).width = ball.radius*2 +ses.sun_length;
				shade.getChildAt(0).rotation = sunAngle;
				
				cached = CachedAssets.instance.cacheTempClip( shadeCacheName, shade, true );
			}
			
			ses.shades.addShade( clipShade = new Bitmap(cached.data) );
			clipShade.name = buffer.name;
			_shadeOffX = cached.offX +sun.x/2;
			_shadeOffY = cached.offY +sun.y/2;
			
			bounds.resize( ball.radius*2 +Math.abs(sun.x), ball.radius*2 +Math.abs(sun.y) );
			
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			_ball = null;
		}
		
		
		public function basedraw():DisplayObject
		{
			return clip;
		}
		
		
		b2internal function setAsPrimary():void
		{
			clip.gotoAndStop( FRAME_WHITE );
			Sprite(buffer).mouseChildren = true;
			clip.mouseEnabled = true;
			clip.innershade.rotation = Trigo.getAngle(Session.instance.sun_angle.x, Session.instance.sun_angle.y) << 0;
			
			var sp:Sprite
			if ( !(GameRoot.screen is EditorScreen) ) {
				Session.instance.ground.gndRender.clip.addChild( sp = PuttBase2.assets.createDisplayObject('block.entity.teeArea') as Sprite );
				Session.instance.ground.gndRender.drawPartial( _ball.defTileX, _ball.defTileY );
				sp.blendMode = 'darken';
				sp.x = _entity.p.x;
				sp.y = _entity.p.y;
			}
		}
		
		b2internal function unsetAsPrimary():void
		{
			clip.gotoAndStop( FRAME_GREEN );
			Sprite(buffer).mouseChildren = false;
			clip.mouseEnabled = false;
			clip.innershade.rotation = Trigo.getAngle(Session.instance.sun_angle.x, Session.instance.sun_angle.y) << 0
		}
		
		
			// -- private --
			
			private static const FRAME_STATIC:int = 1
			private static const FRAME_WHITE:int = 3
			private static const FRAME_GREEN:int = 7
			
			protected var _ball:Ball
			private var _dimpleFrame:Number = 1
			
			override protected function _draw():void 
			{
				if ( _ball.isMoving ) {
					use namespace b2internal;
					
					var v:b2Vec2 = _ball.body.m_linearVelocity.Copy();
					/*if ( _ball.isConveyed ) {
						var cAxis:b2Vec2 = _ball.conveyed.axis;
						if ( (cAxis.x && Math.abs(v.x)<=.66 && FastMath.sign(cAxis.x)==FastMath.sign(v.x)) || (cAxis.y && Math.abs(v.y)<=.66 && FastMath.sign(cAxis.y)==FastMath.sign(v.y)) ) return;
					}*/
					
					var fsp:Number = v.Length()*2;
					if ( _dimpleFrame +fsp > 9 ) _dimpleFrame = (_dimpleFrame +fsp) %9 +1;
					else _dimpleFrame += fsp;
					
					clip.dimples.rotation = (Trigo.getRadian(v.x, v.y) -_ball.body.m_angularVelocity/2) * Trigo.RAD_TO_DEG << 0;
					clip.dimples.gotoAndStop( _dimpleFrame << 0 );
				} else {
					clip.dimples.rotation = 135;
				}
			}
			
			
	}

}