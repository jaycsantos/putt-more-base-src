package pb2.game.entity.render 
{
	import com.jaycsantos.display.CachedAssets;
	import com.jaycsantos.display.CachedBmp;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.Trigo;
	import flash.display.*;
	import pb2.game.entity.b2.b2EntBmpRender;
	import pb2.game.entity.WallGate;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class WallGateRender extends b2EntBmpRender 
	{
		
		public function WallGateRender( gate:WallGate, args:EntityArgs ) 
		{
			super( gate, args );
			
			gate.gateRender = this;
			hasAlphaChannel = true;
			
		}
		
		override public function dispose():void 
		{
			// don't dispose, we cached it!
			bufferBmp.bitmapData = bmp = null;
			
			super.dispose();
		}
		
		public function basedraw():DisplayObject
		{
			var mc:MovieClip = Session.getDisplayAsset( 'entity.block.'+ _entity.type ) as MovieClip;
			mc.rotation = WallGate(_entity).defRa * Trigo.RAD_TO_DEG << 0;
			return mc;
		}
		
			// -- private --
			
			override protected function _draw():void 
			{
				var gate:WallGate = _entity as WallGate;
				var mc:MovieClip, cached:CachedBmp, cacheName:String, shade:Shape;
				var rotation:int = gate.defRa *Trigo.RAD_TO_DEG << 0;
				
				cached = CachedAssets.getClip( cacheName = 'entity.block.gate2_A@'+ gate.breakCount +'@'+ rotation );
				if ( ! cached ) {
					mc = Session.getDisplayAsset( 'entity.block.gate2_A' ) as MovieClip;
					mc.gotoAndStop( gate.breakCount+1 );
					mc.rotation = rotation;
					cached = CachedAssets.instance.cacheTempClip( cacheName, mc, true );
				}
				bufferBmp.bitmapData = bmp = cached.data;
				bmpOffX = cached.offX;
				bmpOffY = cached.offY;
				
				cached = CachedAssets.getClip( cacheName = 'shades.'+ gate.type +'@'+ rotation );
				if ( ! cached ) {
					shade = new Shape;
					Session.instance.shades.drawShade( shade.graphics, gate.body, true, 0, 0, true, -Session.instance.sun_length/3 );
					cached = CachedAssets.instance.cacheTempClip( cacheName, shade, true );
				}
				clipShade.bitmapData = cached.data;
				_shadeOffX = cached.offX;
				_shadeOffY = cached.offY;
			}
			
			
	}

}