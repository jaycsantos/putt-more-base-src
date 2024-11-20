package pb2.game.entity.tile 
{
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.b2internal;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	import com.demonsters.debugger.MonsterDebugger;
	import com.jaycsantos.display.render.AbstractRender;
	import com.jaycsantos.entity.Entity;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.AABB;
	import com.jaycsantos.math.Trigo;
	import flash.display.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import pb2.game.entity.b2.b2Entity;
	import pb2.game.Registry;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class ShadeRender extends AbstractRender 
	{
		public var clip:Sprite
		
		
		public function ShadeRender( entity:ShadeContainer, args:EntityArgs )
		{
			use namespace b2internal;
			
			var ses:Session = Session.instance;
			entity.shadeRender = this;
			
			super( entity, args );
			
			Sprite(buffer).addChild( clip = new Sprite );
			clip.tabEnabled = clip.tabChildren = clip.mouseEnabled = false;
			clip.blendMode = BlendMode.LAYER;
			clip.alpha = Session.instance.sun_strength;
			
			bounds.resize( Session.world.bounds.width, Session.world.bounds.height );
			
			buffer.visible = true;
		}
		
		override public function dispose():void 
		{
			Sprite(buffer).removeChild( clip );
			
			super.dispose();
			
			var i:int = clip.numChildren;
			while ( i-- )
				clip.removeChildAt( i );
		}
		
		
		override public function update():void 
		{
			
		}
		
		
		override protected function _reposition():void 
		{
			
		}
		
	}

}