package pb2.game.entity.render 
{
	import Box2D.Common.Math.b2Vec2;
	import com.jaycsantos.display.CachedAssets;
	import com.jaycsantos.display.CachedBmp;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.Trigo;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import pb2.game.entity.b2.*;
	import pb2.game.entity.SolidBlock;
	import pb2.game.Registry;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author ...
	 */
	public class SolidBlkRender extends b2EntRender implements IDragBaseDraw, Ib2TileFaceLinkedRender
	{
		public var bmp:Bitmap, faceFrame:uint
		
		
		public function SolidBlkRender( block:SolidBlock, args:EntityArgs )
		{
			super( block, args );
			
			block.blkRender = this;
			
			Sprite(buffer).addChild( bmp = new Bitmap );
			
			Session.instance.shades.addShade( clipShade = new Bitmap );
			clipShade.name = buffer.name;
		}
		
		override public function dispose():void 
		{
			// don't dispose, we cached it!
			bmp.bitmapData = null; bmp = null;
			
			super.dispose();
		}
		
		
		public function basedraw():DisplayObject
		{
			var blk:SolidBlock = _entity as SolidBlock;
			
			var mc:MovieClip = PuttBase2.assets.createDisplayObject( 'entity.block.'+ blk.type ) as MovieClip;
			mc.gotoAndStop( 20 *Math.round( (blk.defRa<0? blk.defRa+Trigo.PI2: blk.defRa) /Trigo.HALF_PI ) +1 );
			
			return mc;
		}
		
		public function redrawAndNeighbors():void
		{
			var tileMap:Vector.<Vector.<b2EntityTile>> = Session.instance.tileMap;
			var blk:SolidBlock = _entity as SolidBlock;
			for ( var i:int=blk.defTileX-1; i<=blk.defTileX+1; i++ )
				for ( var j:int=blk.defTileY-1; j<=blk.defTileY+1; j++ )
					if ( j < 0 )
						Session.instance.wallTop.wallRender.redraw();
					else if ( j >= tileMap[0].length )
						Session.instance.wallBottom.wallRender.redraw();
					else if ( i < 0 )
						Session.instance.wallLeft.wallRender.redraw();
					else if ( i >= tileMap.length )
						Session.instance.wallRight.wallRender.redraw();
					else if ( tileMap[i][j] && tileMap[i][j].render is Ib2TileFaceLinkedRender )
						Ib2TileFaceLinkedRender(tileMap[i][j].render).redraw();
			
			redraw();
		}
		
		
			// -- private --
			
			override protected function _draw():void
			{
				var blk:SolidBlock = _entity as SolidBlock;
				var completeName:String = 'entity.block.'+ blk.type;
				
				faceFrame = FaceLinks.getFaceFrame( blk.defTileX, blk.defTileY ) +1;
				var cacheName:String, cached:CachedBmp = CachedAssets.getClip( cacheName = completeName +'@'+ faceFrame );
				if ( ! cached ) {
					var mc:MovieClip = Session.getDisplayAsset( completeName ) as MovieClip;
					mc.gotoAndStop( faceFrame );
					if ( ! mc.width || ! mc.height )
						mc.gotoAndStop( (faceFrame-1) %16 +1 );
					cached = CachedAssets.instance.cacheTempClip( cacheName, mc, true );
				}
				
				if ( cached ) {
					bmp.bitmapData = cached.data;
					bmp.x = cached.offX;
					bmp.y = cached.offY;
				}
				
				var shade:Shape, shadeCacheName:String = 'shades.'+ blk.shapeName +'@'+ (blk.defRa +Trigo.DEG_TO_RAD <<0);
				cached = CachedAssets.getClip( shadeCacheName );
				if ( ! cached ) {
					shade = new Shape;
					Session.instance.shades.drawShade( shade.graphics, blk.body, true );
					cached = CachedAssets.instance.cacheTempClip( shadeCacheName, shade, true );
				}
				
				Bitmap(clipShade).bitmapData = cached.data;
				_shadeOffX = cached.offX;
				_shadeOffY = cached.offY;
			}
			
		
		
	}

}