package pb2.game.entity.b2 
{
	import Box2D.Common.Math.b2Vec2;
	import com.jaycsantos.display.render.AbstractRender;
	import com.jaycsantos.entity.Entity;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.Trigo;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import pb2.game.Registry;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class b2EntRender extends AbstractRender 
	{
		public var clipShade:DisplayObject
		
		public function b2EntRender( entity:b2Entity, args:EntityArgs )
		{
			super( entity, args );
			
			var ts:uint = Registry.tileSize, ses:Session = Session.instance, sun:b2Vec2 = ses.sun_angle.Copy();
			sun.Multiply( ses.sun_length );
			
			bounds.resize( ts +Math.abs(sun.x), ts +Math.abs(sun.y) );
			_boundOffX = sun.x/2;
			_boundOffY = sun.y/2;
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			if ( clipShade && clipShade.parent )
				clipShade.parent.removeChild( clipShade );
			clipShade = null;
		}
		
		
			// -- private --
			
			protected var _shadeOffX:Number =0, _shadeOffY:Number =0
			
			
			override protected function _cull():void 
			{
				super._cull();
				if ( clipShade )
					clipShade.visible = buffer.visible;
			}
			
			override protected function _draw():void 
			{
				// null
			}
			
			override protected function _reposition():void 
			{
				super._reposition();
				
				if ( clipShade ) {
					clipShade.x = buffer.x +_shadeOffX;
					clipShade.y = buffer.y +_shadeOffY;
				}
			}
			
			override protected function _onForcedShow():void 
			{
				if ( clipShade )
					clipShade.visible = buffer.visible;
			}
			
			
	}

}