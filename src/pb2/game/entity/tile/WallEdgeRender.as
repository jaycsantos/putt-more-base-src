package pb2.game.entity.tile 
{
	import Box2D.Common.Math.b2Vec2;
	import com.demonsters.debugger.MonsterDebugger;
	import com.jaycsantos.display.CachedAssets;
	import com.jaycsantos.display.CachedBmp;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.util.ColorMatrixUtil;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.geom.Point;
	import pb2.game.entity.b2.b2EntBmpRender;
	import pb2.game.entity.b2.b2Entity;
	import pb2.game.entity.b2.Ib2TileFaceLinkedRender;
	import pb2.game.entity.render.FaceLinks;
	import pb2.game.Registry;
	import pb2.game.Session;
	import pb2.screen.EditorScreen;
	
	/**
	 * ...
	 * @author ...
	 */
	public class WallEdgeRender extends b2EntBmpRender implements Ib2TileFaceLinkedRender
	{
		
		public function WallEdgeRender( wall:WallEdge, args:EntityArgs )
		{
			switch( args.type ) {
				case 'wall_top': case 'wall_bottom':
					args.dimension.x = Session.instance.width +Registry.tileSize +2;
					args.dimension.y = Registry.tileSize +2;
					_tx0 = -1; _tx1 = Session.instance.cols;
					_ty0 = _ty1 = args.type=='wall_top'? -1: Session.instance.rows;
					_isHorizontal = true;
					break;
				case 'wall_right': case 'wall_left':
					args.dimension.x = Registry.tileSize +2;
					args.dimension.y = Session.instance.height -Registry.tileSize +2;
					_tx0 = _tx1 = args.type=='wall_left'? -1: Session.instance.cols;
					_ty0 = 0; _ty1 = Session.instance.rows -1;
					break;
			}
			super( wall, args );
			
			wall.wallRender = this;
			hasAlphaChannel = true;
			
			bufferBmp.cacheAsBitmap = true;
			bmpOffX = -bmp.width /2;
			bmpOffY = -bmp.height /2;
			
			var shade:Shape, cacheName:String = 'shades.wall_'+ (_isHorizontal? 'x':'y');
			var cached:CachedBmp = CachedAssets.getClip( cacheName );
			if ( ! cached ) {
				shade = new Shape;
				Session.instance.shades.drawShade( shade.graphics, wall.body, true );
				cached = CachedAssets.instance.cacheTempClip( cacheName, shade, true );
			}
			clipShade.bitmapData = cached.data;
			_shadeOffX = cached.offX;
			_shadeOffY = cached.offY;
			
			var sun:b2Vec2 = Session.instance.sun_angle.Copy(); sun.Multiply( Session.instance.sun_length );
			bounds.resize( Math.ceil(bmp.width +Math.abs(sun.x)), Math.ceil(bmp.height +Math.abs(sun.y)) );
			
			
			cached = CachedAssets.getClip( 'entity.block.wall.offdirt-0@1' );
			if ( !cached ) {
				var mc:MovieClip = PuttBase2.assets.createDisplayObject( 'entity.block.wall.offdirt' ) as MovieClip;
				for ( var i:int; i < 28; i++ ) {
					mc.gotoAndStop( (i%14)+1 );
					mc.rotation = i<14? 0: 90;
					CachedAssets.instance.cacheTempClip( 'entity.block.wall.offdirt-'+mc.rotation+'@'+mc.currentFrame, mc, true );
				}
				
				mc = PuttBase2.assets.createDisplayObject( 'entity.block.wall.offGarden' ) as MovieClip;
				mc.filters = [ColorMatrixUtil.setSaturation(-40)];
				for ( i = 0; i < 20; i++ ) {
					mc.gotoAndStop( (i%10)+1 );
					mc.rotation = i<10? 0: 90;
					CachedAssets.instance.cacheTempClip( 'entity.block.wall.offGarden-'+mc.rotation+'@'+mc.currentFrame, mc, true );
				}
			}
			
		}
		
		
		public function basedraw():DisplayObject
		{
			return null;
		}
		
		public function redrawAndNeighbors():void
		{
			
		}
		
		
			// -- private --
			
			private var _isHorizontal:Boolean
			private var _tx0:int, _tx1:int, _ty0:int, _ty1:int
			private var _point:Point = new Point
			
			override protected function _draw():void 
			{
				//H4X here
				if ( !Session.isOnEditor && !Session.instance.map.isLoaded ) {
					_flags.setTrue( STATE_MUSTREDRAW );
					return;
				}
				
				var i:int, j:int, ts:uint = Registry.tileSize, ts2:Number = ts/2, frame:int, cached:CachedBmp;
				var mark0:int, mark90:int, markA:int;
				
				bmp.lock();
				bmp.fillRect( bmp.rect, 0 );
				
				//trace( '4:', _entity.type, mark0, mark90, markA );
				
				// vertical | left-right walls
				if ( _tx0 == _tx1 ) {
					mark0 = mark90 = markA = Math.max( Session.instance.map.levelIndex +Session.instance.map.par +_tx0, 0 );
					i = _tx0;
					for ( j = _ty0; j <= _ty1; j++ ) {
						frame = FaceLinks.getFaceFrame( i, j ) +1;
						cached = CachedAssets.getClip( 'entity.block.wall_sq@'+ frame );
						if ( ! cached ) cached = _createCacheClip( frame );
						_point.x = ts2 +cached.offX +1;
						_point.y = j*ts +ts2 +cached.offY +1;
						bmp.copyPixels( cached.data, cached.data.rect, _point, null, null, true );
						
						if (1|| !(GameRoot.screen is EditorScreen) && GameRoot.nextScreenClass != EditorScreen ) {
							switch( (frame-1) %16 ) {
								case 7: case 11:
									if ( frame < 17 ) break;
								case 3:
									if ( mark90 % 3 == 0 ) {
										cached = CachedAssets.getClip( 'entity.block.wall.offdirt-90@'+ ((mark90*3%14)+1) );
										_point.x = ts2 +cached.offX +1;
										_point.y = j*ts +ts2 +cached.offY +1;
										bmp.copyPixels( cached.data, cached.data.rect, _point, null, null, true );
									}
									mark90++;
									break;
							}
							if ( markA%10 < 3 ) {
								cached = CachedAssets.getClip( 'entity.block.wall.offGarden-90@'+ ((markA*3%10)+1) );
								_point.x = ts2 +cached.offX +1;
								_point.y = j*ts +ts2 +cached.offY +1;
								bmp.copyPixels( cached.data, cached.data.rect, _point, null, null, true );
							}
							markA++;
						}
						
					}
				} else
				// horizontal | top-bottom walls
				if ( _ty0 == _ty1 ) {
					mark0 = mark90 = markA = Math.max( Session.instance.map.levelIndex +Session.instance.map.par +_ty0, 0 );
					j = _ty0;
					for ( i = _tx0; i <= _tx1; i++ ) {
						frame = FaceLinks.getFaceFrame( i, j ) +1;
						cached = CachedAssets.getClip( 'entity.block.wall_sq@'+ frame );
						if ( ! cached ) cached = _createCacheClip( frame );
						_point.x = (i+1)*ts +ts2 +cached.offX +1;
						_point.y = ts2 +cached.offY +1;
						bmp.copyPixels( cached.data, cached.data.rect, _point, null, null, true );
						
						if (1|| !(GameRoot.screen is EditorScreen) && GameRoot.nextScreenClass != EditorScreen ) {
							switch( (frame-1) %16 ) {
								case 13: case 14:
									if ( frame < 17 ) break;
								case 12:
									if ( mark0++ % 4 == 0 ) {
										cached = CachedAssets.getClip( 'entity.block.wall.offdirt-0@'+ ((mark0*3%14)+1) );
										_point.x = (i+1)*ts +ts2 +cached.offX +1;
										_point.y = ts2 +cached.offY +1;
										bmp.copyPixels( cached.data, cached.data.rect, _point, null, null, true );
									}
									break;
							}
							if ( markA%12 < 4 ) {
								cached = CachedAssets.getClip( 'entity.block.wall.offGarden-0@'+ ((markA*3%10)+1) );
								_point.x = (i+1)*ts +ts2 +cached.offX +1;
								_point.y = ts2 +cached.offY +1;
								bmp.copyPixels( cached.data, cached.data.rect, _point, null, null, true );
							}
							markA++;
						}
						
					}
				}
				
				bmp.unlock();
			}
			
			protected function _createCacheClip( frame:int ):CachedBmp
			{
				var mc:MovieClip = Session.getDisplayAsset( 'entity.block.wall_sq' ) as MovieClip;
				mc.gotoAndStop( frame );
				if ( ! mc.width || ! mc.height )
					mc.gotoAndStop( (frame-1) %16 +1 );
				return CachedAssets.instance.cacheTempClip( 'entity.block.wall_sq@'+ frame, mc, true );
			}
			
			
	}

}