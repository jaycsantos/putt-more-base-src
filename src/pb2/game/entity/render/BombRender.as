package pb2.game.entity.render 
{
	import apparat.math.FastMath;
	import Box2D.Common.Math.b2Vec2;
	import com.jaycsantos.display.animation.SimpleAnimationTiming;
	import com.jaycsantos.display.CachedAssets;
	import com.jaycsantos.display.CachedBmp;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.AABB;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.math.Trigo;
	import flash.display.*;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import pb2.game.entity.b2.b2EntBmpRender;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.entity.b2.b2EntRender;
	import pb2.game.entity.Bomb;
	import pb2.game.Registry;
	import pb2.game.Session;
	import pb2.util.pb2internal;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class BombRender extends b2EntBmpRender implements IDragBaseDraw
	{
		
		public function BombRender( bomb:Bomb, args:EntityArgs) 
		{
			bomb.bombRender = this;
			super( bomb, args );
			
			var ses:Session = Session.instance;
			var angle:int = Trigo.getAngle( ses.sun_angle.x, ses.sun_angle.y ) >> 0;
			
			{// -- cached
				var cacheName:String = 'entity.block.bomb';
				var cached:CachedBmp = CachedAssets.getClip( cacheName );
				if ( !cached ) {
					var mc:MovieClip = Session.getDisplayAsset( 'entity.block.bomb' ) as MovieClip;
					mc.gotoAndStop( 2 );
					CachedAssets.instance.cacheTempClip( cacheName +'-remains', mc, true );
					
					mc.gotoAndStop( 1 );
					CachedAssets.instance.cacheTempClip( cacheName, mc, true );
					
					mc.width = Registry.BOMB_Radius*2 +ses.sun_length/2;
					mc.rotation = angle;
					mc.transform.colorTransform = new ColorTransform( 0, 0, 0, 1 );
					CachedAssets.instance.cacheTempClip( cacheName +'-shade', mc, true );
					
					mc.transform.colorTransform = new ColorTransform;
					mc.transform.matrix = new Matrix;
					mc.rotation = angle;
				}
				cached = CachedAssets.getClip( cacheName );
				bufferBmp.bitmapData = cached.data;
				bmpOffX = cached.offX;
				bmpOffY = cached.offY;
				
				cached = CachedAssets.getClip( cacheName +'-shade' );
				clipShade.bitmapData = cached.data;
				_shadeOffX = cached.offX +ses.sun_angle.x*ses.sun_length/4;
				_shadeOffY = cached.offY +ses.sun_angle.y*ses.sun_length/4;
			}
			
			{// -- ground
				_dirt = PuttBase2.assets.createDisplayObject( 'entity.block.bomb.dirt' ) as MovieClip;
				_dirt.gotoAndStop( 1 );
				_dirt.blendMode = 'multiply';
				ses.ground.gndRender.clip.addChild( _dirt );
			}
			
			{// -- animation
				_explosion = PuttBase2.assets.createDisplayObject( 'entity.block.bomb.explode' ) as MovieClip;
				_animator = new SimpleAnimationTiming( MathUtils.intRangeA(1,30,1), 0, false, _endExplode );
				_animator.frameSpeed *= 2;
				_animator.addMovieClip( _explosion );
				_animator.stop( 29 );
				
				_animator.addIndexCallback( 1, _wave1 );
				_animator.addIndexCallback( 5, _wave2 );
			}
			
			
			bounds.resize( 160, 160 );
		}
		
		
		override public function dispose():void 
		{
			var bomb:Bomb = Bomb( _entity );
			
			_animator.dispose(); _animator = null;
			_endExplode();
			
			if ( _dirt.parent ) _dirt.parent.removeChild( _dirt );
			if ( Session.isOnEditor )
				Session.instance.ground.gndRender.drawPartial( bomb.defTileX, bomb.defTileY );
			
			_dirt = _explosion = null;
			
			super.dispose();
		}
		
		override public function update():void 
		{
			if ( _animator.isPlaying ) {
				_animator.update();
				
				_explosion.x = _entity.p.x;
				_explosion.y = _entity.p.y;
			}
			
			
			super.update();			
		}
		
		
		public function explode():void
		{
			Session.instance.toons.addClip( _explosion );
			_explosion.visible = true;
			_animator.playAt( 0 );
			
			//_flags.setFalse( STATE_ISVISIBLE );
			//bufferBmp.visible = false;
			
			var cached:CachedBmp = CachedAssets.getClip( 'entity.block.bomb-remains' );
			bufferBmp.bitmapData = cached.data;
			bmpOffX = cached.offX;
			bmpOffY = cached.offY;
			//_dirt.gotoAndStop( 2 );
			//redraw();
		}
		
		public function reassemble():void
		{
			_endExplode();
			_animator.stop( 29 );
			
			//_flags.setTrue( STATE_ISVISIBLE );
			//bufferBmp.visible = true;
			
			var cached:CachedBmp = CachedAssets.getClip( 'entity.block.bomb' );
			bufferBmp.bitmapData = cached.data;
			bmpOffX = cached.offX;
			bmpOffY = cached.offY;
			//_dirt.gotoAndStop( 1 );
			//redraw();
		}
		
		
		public function basedraw():DisplayObject
		{
			var bomb:Bomb = Bomb( _entity );
			var mc:MovieClip = Session.getDisplayAsset( 'entity.block.bomb' ) as MovieClip;
			mc.gotoAndStop( 1 );
			
			_dirt.visible = false;
			Session.instance.ground.gndRender.drawPartial( bomb.defTileX, bomb.defTileY );
			
			return mc;
		}
		
		
			// -- private --
			
			protected var _dirt:MovieClip, _explosion:MovieClip, _animator:SimpleAnimationTiming
			
			
			override protected function _cull():void 
			{
				// hide if bounding box is outside of camera view
				if ( !_entity.world.camera.bounds.isColliding(bounds) ) {
					_flags.setTrue( STATE_ISOFFSCREEN );
					buffer.visible = false;
				} else {
					_flags.setFalse( STATE_ISOFFSCREEN )
					buffer.visible = _flags.isTrue( STATE_ISVISIBLE );
				}
				
				clipShade.visible = buffer.visible && !Bomb(_entity).hasExploded;
			}
			
			override protected function _draw():void 
			{
				var bomb:Bomb = Bomb( _entity );
				
				_dirt.x = bomb.p.x;
				_dirt.y = bomb.p.y;
				_dirt.visible = buffer.visible;
				
				Session.instance.ground.gndRender.drawPartial( bomb.defTileX, bomb.defTileY );
			}
			
			
			private function _wave1():void
			{
				/*var tile:b2EntityTile, bomb:Bomb = Bomb( _entity );
				var tilemap:Vector.<Vector.<b2EntityTile>> = Session.instance.tileMap;
				
				for ( var i:int = bomb.defTileX-1; i < bomb.defTileX+2; i++ )
					for ( var j:int = bomb.defTileY-1; j < bomb.defTileY+2; j++ ) {
						tile = tilemap[i][j];
						if ( tile ) {
							if ( !tile.isFixed )
								tile.body.ApplyForce( new b2Vec2(FastMath.abs(bomb.p.x-tile.p.x), FastMath.abs(bomb.p.y-tile.p.y)), bomb.body.GetPosition() );
							else if ( tile is Bomb )
								tile.pb2internal::trigger();
						}
					}
				*/
			}
			
			private function _wave2():void
			{
				
			}
			
			private function _endExplode():void
			{
				if ( _explosion.parent )
					_explosion.parent.removeChild( _explosion );
				_explosion.visible = false;
			}
			
			
	}

}