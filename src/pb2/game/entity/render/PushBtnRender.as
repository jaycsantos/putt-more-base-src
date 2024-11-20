package pb2.game.entity.render 
{
	import Box2D.Common.b2internal;
	import Box2D.Common.Math.b2Vec2;
	import com.jaycsantos.display.CachedAssets;
	import com.jaycsantos.display.CachedBmp;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.AABB;
	import com.jaycsantos.math.Trigo;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import pb2.game.entity.b2.b2EntBmpRender;
	import pb2.game.entity.PushButton;
	import pb2.game.Registry;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PushBtnRender extends b2EntBmpRender implements IDragBaseDraw
	{
		
		public function PushBtnRender( btn:PushButton, args:EntityArgs ) 
		{
			super( btn, args );
			
			btn.btnRender = this;
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
			mc.rotation = PushButton(_entity).defRa * Trigo.RAD_TO_DEG << 0;
			return mc;
		}
		
			// -- private --
			
			override protected function _draw():void 
			{
				var btn:PushButton = _entity as PushButton;
				var mc:MovieClip, cached:CachedBmp, cacheName:String, shade:Shape;
				var rotation:int = btn.defRa *Trigo.RAD_TO_DEG << 0;
				
				cached = CachedAssets.getClip( cacheName = 'entity.block.pushbtn'+(btn.isToggleSwitch?'3':'')+'@'+ rotation );
				if ( ! cached ) {
					mc = Session.getDisplayAsset( 'entity.block.pushbtn'+ (btn.isToggleSwitch?'3':'') ) as MovieClip;
					mc.gotoAndStop(1);
					mc.rotation = rotation;
					cached = CachedAssets.instance.cacheTempClip( cacheName, mc, true );
				}
				bufferBmp.bitmapData = bmp = cached.data;
				bmpOffX = cached.offX;
				bmpOffY = cached.offY;
				
				cached = CachedAssets.getClip( cacheName = 'shades.'+ btn.type +'@'+ rotation );
				if ( ! cached ) {
					shade = new Shape;
					Session.instance.shades.drawShade( shade.graphics, btn.body, true, 0, 0, true, -Session.instance.sun_length/3 );
					cached = CachedAssets.instance.cacheTempClip( cacheName, shade, true );
				}
				Bitmap(clipShade).bitmapData = cached.data;
				_shadeOffX = cached.offX;
				_shadeOffY = cached.offY;
			}
			
			
			
	}

}