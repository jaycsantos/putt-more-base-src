package pb2.game.entity.b2 
{
	import Box2D.Common.Math.b2Vec2;
	import com.jaycsantos.display.render.AbstractBmpRender;
	import com.jaycsantos.entity.Entity;
	import com.jaycsantos.entity.EntityArgs;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import pb2.game.Registry;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class b2EntBmpRender extends AbstractBmpRender
	{
		public var bufferBmp:Bitmap, clipShade:Bitmap
		
		
		public function b2EntBmpRender( entity:b2Entity, args:EntityArgs )
		{
			super( entity, args );
			bufferBmp = buffer as Bitmap;
			hasAlphaChannel = true;
			
			var ts:uint = Registry.tileSize, ses:Session = Session.instance, sun:b2Vec2 = ses.sun_angle.Copy();
			sun.Multiply( ses.sun_length );
			
			ses.shades.addShade( clipShade = new Bitmap );
			clipShade.name = buffer.name;
			
			bounds.resize( Math.ceil(ts +Math.abs(sun.x)), Math.ceil(ts +Math.abs(sun.y)) );
			_boundOffX = Math.floor( sun.x /2 );
			_boundOffY = Math.floor( sun.y /2 );
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			if ( clipShade && clipShade.parent )
				clipShade.parent.removeChild( clipShade );
		}
		
		
			// -- private --
			
			protected var _shadeOffX:int =0, _shadeOffY:int =0
			
			override protected function _cull():void 
			{
				super._cull();
				clipShade.visible = buffer.visible;
			}
			
			override protected function _draw():void 
			{
				// null
			}
			
			override protected function _reposition():void 
			{
				super._reposition();
				
				clipShade.x = buffer.x +_shadeOffX -bmpOffX;
				clipShade.y = buffer.y +_shadeOffY -bmpOffY;
			}
			
			override protected function _onForcedShow():void 
			{
				if ( clipShade )
					clipShade.visible = buffer.visible;
			}
			
	}

}