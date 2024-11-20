package pb2.game.entity.render 
{
	import Box2D.Common.Math.b2Vec2;
	import com.demonsters.debugger.MonsterDebugger;
	import com.jaycsantos.display.animation.SimpleAnimationTiming;
	import com.jaycsantos.display.CachedAssets;
	import com.jaycsantos.display.CachedBmp;
	import com.jaycsantos.display.render.IAnimatedRender;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.*;
	import com.jaycsantos.util.GameLoop;
	import flash.display.*;
	import flash.geom.Matrix;
	import pb2.game.entity.b2.*;
	import pb2.game.entity.RelayBlock;
	import pb2.game.Registry;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class RelayBlkRender extends b2EntRender implements IDragBaseDraw, Ib2TileFaceLinkedRender, IAnimatedRender
	{
		public var bg:Bitmap, clip:Bitmap
		
		public function RelayBlkRender( relay:RelayBlock, args:EntityArgs )
		{
			super( relay, args );
			
			relay.blkRender = this;
			
			Sprite(buffer).addChild( bg = new Bitmap );
			Sprite(buffer).addChild( clip = new Bitmap );
			Session.instance.shades.addShade( clipShade = new Bitmap );
			//rotation = MathUtils.randomInt(0, 11) *30;
			
			_animator = new SimpleAnimationTiming( [1,2,3,4,5,6,1,2,3,4,5,6,1,2,3,4,5,6,1,2,3,4,5,6,1], GameLoop.instance.timeFrameRate*2 );
			_animator.stop();
			
			
			var ses:Session = Session.instance, sun:b2Vec2 = ses.sun_angle.Copy(); sun.Multiply( ses.sun_length );
			var sunAngle:int = Trigo.getAngle(sun.x, sun.y) << 0;
			
			var cacheName:String, cached:CachedBmp = CachedAssets.getClip( cacheName = 'shades.sq@'+ (relay.defRa +Trigo.DEG_TO_RAD <<0) );
			if ( ! cached ) {
				var shade:Shape = new Shape;
				Session.instance.shades.drawShade( shade.graphics, relay.body );
				cached = CachedAssets.instance.cacheTempClip( cacheName, shade, true );
			}
			Bitmap(clipShade).bitmapData = cached.data;
			_shadeOffX = cached.offX;
			_shadeOffY = cached.offY;
			
			_drawFrame();
		}
		
		override public function dispose():void 
		{
			// don't dispose, we cached it!
			bg.bitmapData = clip.bitmapData = null;
			bg = clip = null;
			_animator.dispose(); _animator = null;
			
			super.dispose();
		}
		
		
		override public function update():void 
		{
			if ( _animator.isPlaying ) {
				_animator.update();
				_drawFrame();
			}
			
			super.update();
		}
		
		
		public function basedraw():DisplayObject
		{
			var mc:MovieClip = Session.getDisplayAsset( 'entity.block.' + _entity.type ) as MovieClip;
			mc.gotoAndStop( 1 );
			return mc;
		}
		
		public function redrawAndNeighbors():void
		{
			var tileMap:Vector.<Vector.<b2EntityTile>> = Session.instance.tileMap;
			var blk:RelayBlock = _entity as RelayBlock;
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
		
		public function play( data:Object = null ):void
		{
			_animator.playAt();
		}
		
		public function stop( data:Object = null ):void {}
		public function reset( data:Object = null ):void {}
		
		
		
			// -- private --
			
			protected var _animator:SimpleAnimationTiming
			
			override protected function _draw():void 
			{
				var relay:RelayBlock = _entity as RelayBlock;
				
				var frame:int = FaceLinks.getFaceFrame( relay.defTileX, relay.defTileY ) +1;
				var cacheName:String, cached:CachedBmp = CachedAssets.getClip( cacheName = 'entity.block.wall_sq@'+ frame );
				if ( ! cached ) {
					var mc:MovieClip = Session.getDisplayAsset( 'entity.block.wall_sq' ) as MovieClip;
					mc.gotoAndStop( frame );
					if ( ! mc.width || ! mc.height )
						mc.gotoAndStop( (frame-1) %16 +1 );
					cached = CachedAssets.instance.cacheTempClip( cacheName, mc, true );
				}
				bg.bitmapData = cached.data;
				bg.x = cached.offX;
				bg.y = cached.offY;
			}
			
			protected function _drawFrame():void
			{
				var mc:MovieClip, relay:RelayBlock = _entity as RelayBlock;
				var name:String = 'entity.block.'+ relay.type;
				var frame:int = _animator.frame;
				
				var cacheName:String, cached:CachedBmp = CachedAssets.getClip( cacheName = name+'@'+frame );
				if ( ! cached ) {
					mc = Session.getDisplayAsset( name ) as MovieClip;
					for ( var i:int; i < 7; i++ ) {
						mc.gotoAndStop( i + 2 );
						CachedAssets.instance.cacheTempClip( name+'@'+(i+1), mc, true );
					}
					cached = CachedAssets.getClip( cacheName );
				}
				clip.bitmapData = cached.data;
				clip.x = cached.offX;
				clip.y = cached.offY;
			}
			
			
	}

}