package pb2.game.entity.render 
{
	import com.jaycsantos.display.CachedAssets;
	import com.jaycsantos.display.CachedBmp;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.Trigo;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import pb2.game.entity.b2.b2EntBmpRender;
	import pb2.game.entity.b2.b2Entity;
	import pb2.game.entity.FloorBlower;
	import pb2.game.Registry;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class FloorBlowerRender extends b2EntBmpRender implements IDragBaseDraw
	{
		public var clip:Bitmap
		
		public function FloorBlowerRender( blow:FloorBlower, args:EntityArgs )
		{
			super( blow, args );
			
			blow.blowRender = this;
			hasAlphaChannel = true;
			
			if ( clipShade && clipShade.parent )
				clipShade.parent.removeChild( clipShade );
			
			Session.instance.ground.gndRender.clip.addChild( clip = new Bitmap );
			clip.blendMode = 'multiply';
			
			buffer.visible = true;
			buffer.alpha = 0;
			
			bounds.Set( blow.p, Registry.tileSize, Registry.tileSize );
		}
		
		override public function dispose():void
		{
			var blow:FloorBlower = _entity as FloorBlower;
			if ( clip.parent )
				clip.parent.removeChild( clip );
			Session.instance.ground.gndRender.drawPartial( blow.defTileX, blow.defTileY );
			
			// dont dispose, we cached it
			clip.bitmapData = null;
			clip = null;
			bmp = null;
			
			super.dispose();
		}
		
		
		override public function update():void 
		{
			var blow:FloorBlower = _entity as FloorBlower;
			if ( !blow.isActive ) return;
			
			super.update();
			
			if ( blow.isBlowing ) {
				bufferBmp.bitmapData = bmp;
				buffer.alpha = Math.min( buffer.alpha+.08, 1 );
				
			} else if ( bufferBmp.bitmapData ) {
				bufferBmp.bitmapData = null;
				buffer.alpha = 0;
			}
		}
		
		
		public function basedraw():DisplayObject
		{
			var blow:FloorBlower = _entity as FloorBlower;
			
			clip.visible = false;
			Session.instance.ground.gndRender.drawPartial( blow.defTileX, blow.defTileY );
			
			var mc:MovieClip = Session.getDisplayAsset( 'entity.block.'+ blow.type ) as MovieClip;
			mc.gotoAndStop(1);
			mc.rotation = blow.defRa*Trigo.RAD_TO_DEG;
			return mc;
		}
		
		
			// -- private --
			
			
			override protected function _draw():void 
			{
				_flags.setFalse( STATE_MUSTREDRAW );
				var mc:MovieClip, blow:FloorBlower = _entity as FloorBlower, completeName:String = 'entity.block.'+ blow.type;
				var rotation:int = blow.defRa * Trigo.RAD_TO_DEG;
				
				var cacheName:String, cached:CachedBmp = CachedAssets.getClip( cacheName = completeName +'@'+ rotation );
				if ( !cached ) {
					mc = Session.getDisplayAsset( completeName ) as MovieClip;
					mc.rotation = rotation; mc.gotoAndStop(2);
					cached = CachedAssets.instance.cacheTempClip( cacheName, mc, true );
				}
				clip.bitmapData = cached.data;
				clip.x = blow.p.x +cached.offX;
				clip.y = blow.p.y +cached.offY;
				clip.visible = buffer.visible;
				Session.instance.ground.gndRender.drawPartial( blow.defTileX, blow.defTileY );
				
				// prepare the blowing frame
				cached = CachedAssets.getClip(cacheName = completeName +'@'+ rotation +'-blow');
				if ( !cached ) {
					mc = Session.getDisplayAsset( completeName ) as MovieClip;
					mc.rotation = rotation; mc.gotoAndStop(4);
					cached = CachedAssets.instance.cacheTempClip( cacheName, mc, true );
				}
				bmp = cached.data;
				bmpOffX = cached.offX;
				bmpOffY = cached.offY;
			}
			
			override protected function _cull():void 
			{
				// hide if bounding box is outside of camera view
				if ( !_entity.world.camera.bounds.isColliding(bounds) )
					_flags.setTrue( STATE_ISOFFSCREEN );
					
				else
					_flags.setFalse( STATE_ISOFFSCREEN )
				
			}
			
	}

}