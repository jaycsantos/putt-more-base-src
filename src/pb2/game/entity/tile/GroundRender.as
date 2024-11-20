package pb2.game.entity.tile 
{
	import Box2D.Common.Math.b2Vec2;
	import com.demonsters.debugger.MonsterDebugger;
	import com.jaycsantos.display.render.*;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.*;
	import flash.display.*;
	import flash.filters.GlowFilter;
	import flash.geom.*;
	import pb2.game.*;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class GroundRender extends AbstractBmpRender 
	{
		public static const COLORSET_0:Array = [0xCCCCCC, 0xAAAAAA];
		public static const COLORSET_A:Array = [0x806A4D, 0x493C2C];
		public static const COLORSET_B:Array = [0x6C7980, 0x363C41];
		public static const COLORSET_C:Array = [0xC6A477, 0x9C805E];
		
		
		public var clip:Sprite, clipChildDepth:uint
		
		public function GroundRender( ground:Ground, args:EntityArgs = null )
		{
			super( ground, args );
			
			ground.gndRender = this;
			
			var ts:Number = Registry.tileSize;
			
			hasAlphaChannel = true;
			_dirtyTile = new Vector.<b2Vec2>;
			_partBmp = new BitmapData( ts *3 +2, ts *3 +2, true, 0 );
			_cache_point = new Point;
			
			clip = new Sprite;
			clip.name = 'clip';
			clip.visible = false;
			create();
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			_partBmp.dispose();
			_partBmp = null;
			
			var i:int = clip.numChildren;
			while ( i-- )
				clip.removeChildAt( i );
			clip = null;
		}
		
		
		override public function update():void 
		{
			if ( _flags.isTrue(STATE_MUSTREDRAW) )
				_draw();
			else if ( _dirtyTile.length )
				_dirtyTile.forEach( _drawPartial );
			_flags.setFalse( STATE_MUSTREDRAW );
			_dirtyTile.splice( 0, _dirtyTile.length );
			
			_reposition();
		}
		
		
		
		public function create():void
		{
			clip.graphics.clear();
			clip.graphics.beginGradientFill( 
				GradientType.RADIAL, Ground.COLORS[Session.instance.bgColorIdx], [1, 1], [0, 255],
				new Matrix(1,0,0,1, bmp.width/2, bmp.height/2) );
			clip.graphics.drawRect( 0, 0, bmp.width, bmp.height );
			clip.graphics.endFill();
			
			var randRot:int = MathUtils.randomInt( 0, 3 ) *90;
			
			var sp:Sprite, i:int, j:int, tx:int = Math.ceil(bmp.width / 400), ty:int = Math.ceil(bmp.height / 400);
			for ( i = 0; i < tx; i++ )
				for ( j = 0; j < ty; j++ ) {
					/*clip.addChild( sp = PuttBase2.assets.createDisplayObject('entity.ground.type1') as Sprite );
					sp.x = i *360 +180; sp.y = j *360 +180;
					sp.blendMode = BlendMode.LIGHTEN;
					sp.alpha = .05;
					sp.name = 'type1_'+ i +'_'+ j;*/
					
					clip.addChild( sp = PuttBase2.assets.createDisplayObject('entity.ground.type2') as Sprite );
					sp.x = i *400 +200; sp.y = j *400 +200;
					sp.rotation = randRot;
					//sp.transform.colorTransform = new ColorTransform( .5, .5, .5, .03, 82, 69, 52, 0 );
					sp.blendMode = BlendMode.MULTIPLY;
					sp.name = '___type2_'+ i +'_'+ j;
					
					clip.addChild( sp = PuttBase2.assets.createDisplayObject('entity.ground.grid') as Sprite );
					sp.x = i *396 +198; sp.y = j *396 +198;
					sp.blendMode = BlendMode.LAYER;
					sp.alpha = .02;
					sp.name = '___grid_'+ i +'_'+ j;
					
					clip.addChild( sp = PuttBase2.assets.createDisplayObject('entity.ground.type3') as Sprite );
					sp.x = i *400 +200; sp.y = j *400 +200;
					sp.rotation = -randRot;
					sp.transform.colorTransform = new ColorTransform( 0, 0, 0, .10, 0, 153, 153, 0 );
					sp.blendMode = BlendMode.OVERLAY;
					sp.name = '___type3_'+ i +'_'+ j;
					
					clip.addChild( sp = PuttBase2.assets.createDisplayObject('entity.ground.type3') as Sprite );
					sp.x = i *400 +200; sp.y = j *400 +200;
					sp.rotation = 180 -randRot;
					sp.transform.colorTransform = new ColorTransform( 0, 0, 0, .10, 169, 171, 78, 0 );
					sp.blendMode = BlendMode.OVERLAY;
					sp.name = '___type3_'+ i +'_'+ j;
				}
			
			
			var mc:MovieClip, ses:Session = Session.instance;
			if ( Session.isOnPlay && !ses.map.isCustom ) {
				clip.addChild( mc = PuttBase2.assets.createDisplayObject('screen.tutorial.helpClip') as MovieClip );
				mc.gotoAndStop( ses.map.levelIndex +1 );
				mc.alpha = .35;
				mc.filters = [new GlowFilter(0x0033CC, 1, 2, 2, .5)];
			}
			
			
			clipChildDepth = clip.numChildren;
			buffer.visible = true;
		}
		
		public function drawPartial( tx:int, ty:int ):void
		{
			_dirtyTile.push( new b2Vec2(tx, ty) );
		}
		
		
			// -- private --
			
			protected var _dirtyTile:Vector.<b2Vec2>
			protected var _partBmp:BitmapData
			protected var _cache_point:Point
			
			override protected function _draw():void 
			{
				bmp.lock();
				bmp.fillRect( bmp.rect, 0 );
				bmp.draw( clip );
				bmp.unlock();
			}
			
			protected function _drawPartial( v:b2Vec2, index:int, list:Vector.<b2Vec2> ):void
			{
				var m:Matrix = new Matrix;
				
				m.tx = -(v.x -.5) * Registry.tileSize +1;
				m.ty = -(v.y -.5) * Registry.tileSize +1;
				_cache_point.x = -m.tx;
				_cache_point.y = -m.ty;
				
				_partBmp.fillRect( _partBmp.rect, 0 );
				_partBmp.draw( clip, m );
				
				bmp.lock();
				bmp.copyPixels( _partBmp, _partBmp.rect, _cache_point );
				bmp.unlock();
				
				//if ( Session.isOnEditor )
					//MonsterDebugger.snapshot( this, clip );
				//MonsterDebugger.snapshot( this, new Bitmap(_partBmp) );
			}
			
			override protected function _reposition():void 
			{
				var camera:AABB = _entity.world.camera.bounds;
				buffer.x = -camera.min.x;
				buffer.y = -camera.min.y;
			}
			
			
			
	}

}