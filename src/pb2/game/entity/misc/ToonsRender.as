package pb2.game.entity.misc 
{
	import com.jaycsantos.display.animation.SimpleAnimationTiming;
	import com.jaycsantos.display.render.AbstractRender;
	import com.jaycsantos.entity.Entity;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.AABB;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.math.Trigo;
	import com.jaycsantos.util.DisplayKit;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class ToonsRender extends AbstractRender 
	{
		public var clip:Sprite
		
		public function ToonsRender( entity:Entity, args:EntityArgs=null ) 
		{
			super( entity, args );
			
			clip = Sprite(buffer);
			
			_clipImpacts = new Vector.<MovieClip>;
			var mc:MovieClip, i:int = 6;
			while ( i-- ) {
				_clipImpacts.push( mc = PuttBase2.assets.createDisplayObject('screen.ui.ani.impact') as MovieClip );
				clip.addChild( mc );
				mc.name = 'impact'+i;
				mc.gotoAndStop( 7 );
				mc.addFrameScript( 7, mc.stop );
			}
		}
		
		override public function dispose():void 
		{
			if ( clip.parent ) clip.parent.removeChild( clip );
			DisplayKit.removeAllChildren( clip, 2 );
			
			super.dispose();
		}
		
		
		override public function update():void 
		{
			_cull();
			if ( buffer.visible ) {
				_reposition();
				
			}
			
		}
		
		
		public function playImpact( x:Number, y:Number, rad:Number ):void
		{
			var mc:MovieClip, i:int = _clipImpacts.length;
			while ( i-- )
				if ( _clipImpacts[i].currentFrame>=7 ) {
					mc = _clipImpacts[i];
					mc.x = x;
					mc.y = y;
					mc.rotation = Trigo.RAD_TO_DEG *rad;
					mc.gotoAndPlay( 1 );
					return;
				}
		}
		
		
			// -- private --
			
			private var _clipMill:MovieClip, _animatorMill:SimpleAnimationTiming
			private var _clipImpacts:Vector.<MovieClip>;
			
			
			override protected function _cull():void 
			{
				buffer.visible = _flags.isTrue( STATE_ISVISIBLE );
			}
			
			override protected function _reposition():void 
			{
				var camera:AABB = _entity.world.camera.bounds;
				buffer.x = -camera.min.x;
				buffer.y = -camera.min.y;
			}
			
			
	}

}