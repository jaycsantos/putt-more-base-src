package pb2.game.entity.render 
{
	import com.jaycsantos.display.CachedAssets;
	import com.jaycsantos.display.CachedBmp;
	import com.jaycsantos.entity.EntityArgs;
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import pb2.game.entity.b2.b2EntBmpRender;
	import pb2.game.entity.b2.b2Entity;
	import pb2.game.entity.b2.b2EntRender;
	import pb2.game.entity.Hole;
	import pb2.game.Registry;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class HoleRender extends b2EntBmpRender implements IDragBaseDraw
	{
		public var clip:Bitmap
		
		public function HoleRender( hole:Hole, args:EntityArgs ) 
		{
			super( hole, args );
			
			hole.holeRender = this;
			
			if ( clipShade && clipShade.parent )
				clipShade.parent.removeChild( clipShade );
			
			//Sprite(buffer).addChild( clip = new Bitmap );
			Session.instance.ground.gndRender.clip.addChild( clip = new Bitmap );
			
			var cached:CachedBmp = CachedAssets.getClip( 'entity.block.hole' );
			if ( ! cached ) {
				var mc:MovieClip = Session.getDisplayAsset( 'entity.block.hole' ) as MovieClip;
				mc.gotoAndStop(2);
				cached = CachedAssets.instance.cacheTempClip( 'entity.block.hole', mc, true );
			}
			clip.name = buffer.name;
			clip.blendMode = BlendMode.HARDLIGHT;
			clip.bitmapData = cached.data;
			bmpOffX = cached.offX;
			bmpOffY = cached.offY;
			
			bounds.resize( Registry.tileSize, Registry.tileSize );
			_boundOffX = _boundOffY = 0;
			
			// special case, its on the ground, immediately show
			buffer.visible = true;
			depth = 0xffff;
		}
		
		override public function dispose():void
		{
			var hole:Hole = _entity as Hole;
			clip.parent.removeChild( clip );
			Session.instance.ground.gndRender.drawPartial( hole.defTileX, hole.defTileY );
			
			// don't dispose, we cached it!
			clip.bitmapData = null;
			clip = null;
			
			super.dispose();
		}
		
		
		override public function update():void 
		{
			_review();
			_cull();
			
			if ( _flags.isTrue(STATE_MUSTREDRAW) )
				_draw();
		}
		
		
		public function basedraw():DisplayObject
		{
			var hole:Hole = _entity as Hole;
			
			clip.visible = false;
			Session.instance.ground.gndRender.drawPartial( hole.defTileX, hole.defTileY );
			
			var mc:MovieClip = Session.getDisplayAsset( 'entity.block.hole' ) as MovieClip;
			mc.gotoAndStop(1);
			return mc;
		}
		
		
			// -- private --
			
			override protected function _draw():void 
			{
				_flags.setFalse( STATE_MUSTREDRAW );
				
				var hole:Hole = _entity as Hole;
				clip.x = hole.p.x +bmpOffX;
				clip.y = hole.p.y +bmpOffY;
				clip.visible = buffer.visible;
				Session.instance.ground.gndRender.drawPartial( hole.defTileX, hole.defTileY );
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