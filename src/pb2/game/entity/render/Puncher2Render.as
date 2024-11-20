package pb2.game.entity.render 
{
	import Box2D.Common.b2internal;
	import Box2D.Common.Math.b2Vec2;
	import com.jaycsantos.display.CachedAssets;
	import com.jaycsantos.display.CachedBmp;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.AABB;
	import com.jaycsantos.math.Trigo;
	import flash.display.*;
	import pb2.game.entity.b2.*;
	import pb2.game.entity.Puncher2;
	import pb2.game.*;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Puncher2Render extends b2EntRender implements IDragBaseDraw
	{
		public var bmpBase:Bitmap, bmpPunch:Bitmap, clpSpring:Sprite, clpTarget:Sprite
		
		
		public function Puncher2Render( puncher:Puncher2, args:EntityArgs ) 
		{
			super( puncher, args );
			
			puncher.puncherRender = this;
			
			var sh:Shape = new Shape;
			sh.graphics.beginFill( 0 );
			sh.graphics.drawRect( -Registry.tileSize/2, -Registry.tileSize/2, Registry.tileSize, Registry.tileSize );
			sh.graphics.endFill();
			
			with ( Sprite(buffer) ) {
				addChild( clpSpring = PuttBase2.assets.createDisplayObject('entity.block.puncher2_'+ puncher.shapeName +'.spring') as Sprite );
				addChild( bmpPunch = new Bitmap );
				addChild( bmpBase = new Bitmap );
				addChild( mask = sh );
			}
			
			clpTarget = PuttBase2.assets.createDisplayObject('entity.block.puncher2_sq.target') as Sprite;
			clpTarget.blendMode = 'overlay';
			Session.instance.ground.gndRender.clip.addChild( clpTarget );
			
			clpSpring.scaleX = .1;
		}
		
		override public function dispose():void 
		{
			var punch:Puncher2 = _entity as Puncher2;
			
			if ( clpTarget.parent )
				clpTarget.parent.removeChild( clpTarget );
			Session.instance.ground.gndRender.drawPartial( punch.defTileX, punch.defTileY );
			
			// don't dispose, we cached it!
			bmpBase.bitmapData = bmpPunch.bitmapData = null;
			bmpBase = bmpPunch = null;
			clpSpring = clpTarget = null;
			
			super.dispose();
		}
		
		
		public function basedraw():DisplayObject
		{
			var punch:Puncher2 = _entity as Puncher2;
			var mc:MovieClip = Session.getDisplayAsset('entity.block.'+ punch.type) as MovieClip;
			mc.rotation = punch.defRa *Trigo.RAD_TO_DEG >>0;
			mc.gotoAndStop(1);
			
			clpTarget.visible = false;
			Session.instance.ground.gndRender.drawPartial( punch.defTileX, punch.defTileY );
			
			return mc;
		}
		
		
			// -- private --
			
			protected var _punchOffX:int, _punchOffY:int
			
			
			override protected function _draw():void 
			{
				var punch:Puncher2 = _entity as Puncher2;
				var sp:Sprite, mc:MovieClip, cached:CachedBmp, cacheName:String, shade:Shape;
				var rotation:int = punch.defRa *Trigo.RAD_TO_DEG << 0;
				
				cached = CachedAssets.getClip( cacheName = 'entity.block.'+ punch.type +'@'+ rotation );
				if ( !cached ) {
					mc = Session.getDisplayAsset( 'entity.block.'+ punch.type ) as MovieClip;
					mc.gotoAndStop( 2 );
					mc.rotation = rotation;
					cached = CachedAssets.instance.cacheTempClip( cacheName, mc, true );
				}
				bmpBase.bitmapData = cached.data;
				bmpBase.x = cached.offX;
				bmpBase.y = cached.offY;
				
				cached = CachedAssets.getClip( cacheName = 'entity.block.'+ punch.type +'.punch@'+ rotation +'-'+ (punch.isToolkit?'tool':'') );
				if ( !cached ) {
					sp = Session.getDisplayAsset( 'entity.block.'+ punch.type +'.punch' ) as Sprite;
					sp.rotation = rotation;
					cached = CachedAssets.instance.cacheTempClip( cacheName, sp, true );
				}
				bmpPunch.bitmapData = cached.data;
				_punchOffX = cached.offX;
				_punchOffY = cached.offY;
				
				clpSpring.rotation = rotation;
				
				clpTarget.x = punch.p.x;
				clpTarget.y = punch.p.y;
				clpTarget.visible = buffer.visible;
				Session.instance.ground.gndRender.drawPartial( punch.defTileX, punch.defTileY );
			}
			
			override protected function _reposition():void 
			{
				super._reposition();
				
				var puncher:Puncher2 = Puncher2(_entity), camera:AABB = puncher.world.camera.bounds;
				var p:b2Vec2 = new b2Vec2, translation:Number;
				
				p.x = puncher.punch.b2internal::m_xf.position.x *Registry.b2Scale;
				p.y = puncher.punch.b2internal::m_xf.position.y *Registry.b2Scale;
				
				bmpPunch.x = Math.round( -puncher.p.x +p.x +_punchOffX );
				bmpPunch.y = Math.round( -puncher.p.y +p.y +_punchOffY );
				
				
				clpSpring.x = -puncher.jointAx.x*18;
				clpSpring.y = -puncher.jointAx.y*18;
				clpSpring.scaleX = .1 +(puncher.joint.GetJointTranslation()/puncher.joint.GetUpperLimit() *.9);
			}
			
			
	}

}