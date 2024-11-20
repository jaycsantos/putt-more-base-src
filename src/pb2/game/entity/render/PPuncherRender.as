package pb2.game.entity.render 
{
	import apparat.math.FastMath;
	import Box2D.Common.b2internal;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2PrismaticJoint;
	import com.jaycsantos.display.CachedAssets;
	import com.jaycsantos.display.CachedBmp;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.Trigo;
	import flash.display.*;
	import flash.geom.Point;
	import pb2.game.entity.b2.*;
	import pb2.game.entity.PPuncher;
	import pb2.game.*;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PPuncherRender extends b2EntTileToolRender implements IDragBaseDraw
	{
		public var container:Sprite, bmp:Bitmap, punchShade:Shape
		public var clpBase:MovieClip, clpPunch:Sprite, clpSpring:Sprite
		
		public function PPuncherRender( punch:PPuncher, args:EntityArgs )
		{
			super( punch, args );
			
			punch.puncherRender = this;
			
			Sprite(buffer).addChild( container = new Sprite );
			with ( container ) {
				addChild( clpSpring = PuttBase2.assets.createDisplayObject('entity.block.ppuncher_'+ punch.shapeName +'.spring') as Sprite );
				addChild( clpPunch = PuttBase2.assets.createDisplayObject('entity.block.ppuncher_'+ punch.shapeName +'.punch') as Sprite );
				addChild( clpBase = PuttBase2.assets.createDisplayObject('entity.block.ppuncher_'+ punch.shapeName +'') as MovieClip );
				addChild( bmp = new Bitmap );
			}
			clpBase.gotoAndStop( 2 );
			
			
			Session.instance.shades.addShade( clipShade = new Shape );
			clipShade.name = punch.type + punch.id;
			Session.instance.shades.addShade( punchShade = new Shape );
			punchShade.name = punch.type + punch.id +'.punch';
			
		}
		
		override public function dispose():void 
		{
			var punch:PPuncher = _entity as PPuncher;
			
			// don't dispose, we cached it!
			bmp.bitmapData = null;
			bmp = null;
			clpSpring = clpPunch = null;
			clpBase = null;
			
			if ( punchShade.parent )
				punchShade.parent.removeChild( punchShade );
			punchShade = null;
			
			super.dispose();
		}
		
		
		public function basedraw():DisplayObject
		{
			var punch:PPuncher = _entity as PPuncher;
			var mc:MovieClip = Session.getDisplayAsset('entity.block.'+ punch.type) as MovieClip;
			mc.rotation = punch.defRa *Trigo.RAD_TO_DEG >>0;
			mc.gotoAndStop(1);
			
			clipShade.visible = punchShade.visible = false;
			
			
			return mc;
		}
		
		
			// -- private --
			
			protected var _oldAngle:Number
			protected var _punchOffX:int, _punchOffY:int
			
			
			override protected function _cull():void 
			{
				super._cull();
				
				punchShade.visible = clipShade.visible = buffer.visible;
			}
			
			override protected function _reposition():void 
			{
				var punch:PPuncher = _entity as PPuncher;
				if ( !punch.isActive ) return;
				
				var joint:b2PrismaticJoint = punch.joint;
				var angle:Number = punch.body.GetAngle();
				
				var p2:b2Vec2 = punch.punch.b2internal::m_xf.position.Copy();
				p2.Multiply( Registry.b2Scale );
				
				
				if ( punch.isMoving || _oldAngle != angle ) {
					if ( punch.isRotating || _oldAngle != angle ) {
						Session.instance.shades.drawShade( Shape(clipShade).graphics, punch.body );
						Session.instance.shades.drawShade( Shape(punchShade).graphics, punch.punch );
						clpSpring.rotation = clpPunch.rotation = clpBase.rotation = angle*Trigo.RAD_TO_DEG >>0;
					}
					
					_useVector();
					
					clpPunch.x = Math.round(-punch.p.x +p2.x);
					clpPunch.y = Math.round(-punch.p.y +p2.y);
					
					//clpSpring.x = -punch.jointAx.x*9;
					//clpSpring.y = -punch.jointAx.y*9;
					clpSpring.scaleX = .1 +(joint.GetJointTranslation()/punch.joint.GetUpperLimit() *.9);
					
				} else
				if ( ! bmp.visible ) {
					_useBitmap();
				}
				
				
				super._reposition();
				
				punchShade.x = clipShade.x +p2.x -punch.p.x;
				punchShade.y = clipShade.y +p2.y -punch.p.y;
				
				_oldAngle = angle;
			}
			
			
			protected function _useVector():void
			{
				clpSpring.visible = clpPunch.visible = clpBase.visible = true;
				bmp.visible = false;
			}
			
			protected function _useBitmap():void
			{
				var punch:PPuncher = _entity as PPuncher;
				var rot:int = clpBase.rotation << 0; rot += rot<0? 360: 0;
				var cacheName:String = 'entity.block.'+ _entity.type +'@'+ rot +'@'+ punch.joint.GetJointTranslation().toFixed(2);
				var cached:CachedBmp = CachedAssets.getClip( cacheName );
				
				if ( ! cached ) {
					clpSpring.visible = clpPunch.visible = clpBase.visible = true;
					bmp.visible = false;
					cached = CachedAssets.instance.cacheTempClip( cacheName, container, true );
				}
				if ( cached ) {
					bmp.bitmapData = cached.data;
					bmp.x = cached.offX;
					bmp.y = cached.offY;
					
					clpSpring.visible = clpPunch.visible = clpBase.visible = false;
					bmp.visible = true;
				} else {
					trace('cache not found '+ _entity.type +'@'+ rot);
				}
			}
			
		
	}

}