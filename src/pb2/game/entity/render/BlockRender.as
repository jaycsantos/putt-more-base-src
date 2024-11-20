package pb2.game.entity.render 
{
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import com.demonsters.debugger.MonsterDebugger;
	import com.jaycsantos.display.*;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.*;
	import flash.display.*;
	import pb2.game.entity.b2.*;
	import pb2.game.entity.Block;
	import pb2.game.*;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class BlockRender extends b2EntTileToolRender implements IDragBaseDraw 
	{
		public var clip:MovieClip, bmp:Bitmap
		
		
		public function BlockRender( block:Block, args:EntityArgs = null ) 
		{
			super( block, args );
			
			Sprite(buffer).addChild( clip = PuttBase2.assets.createDisplayObject('entity.block.'+ block.type) as MovieClip );
			Sprite(buffer).addChild( bmp = new Bitmap );
			buffer.name = args.type + _entity.id + "_Render";
			buffer.visible = false; // defaultly hidden
			
			clip.stop();
			
			Session.instance.shades.addShade( clipShade = new Shape );
			clipShade.name = buffer.name;
			
			
			var ts:uint = Registry.tileSize, ses:Session = Session.instance, sun:b2Vec2 = ses.sun_angle.Copy();
			sun.Multiply( ses.sun_length );
			
			var r:Number = ts *Trigo.SQRT_2;
			bounds.resize( r +Math.abs(sun.x), r +Math.abs(sun.y) );
			
			_useVector();
		}
		
		public function basedraw():DisplayObject
		{
			return clip;
		}
		
		
		override public function dispose():void 
		{
			bmp.bitmapData = null;
			bmp = null; clip = null;
			
			super.dispose();
		}
		
			// -- private --
			
			protected var _oldAngle:Number
			
			
			override protected function _reposition():void 
			{
				var angle:Number = Block(_entity).body.GetAngle();
				
				if ( angle != _oldAngle ) {
					Session.instance.shades.drawShade( Shape(clipShade).graphics, Block(_entity).body );
					clip.rotation = angle *Trigo.RAD_TO_DEG << 0;
					if ( ! clip.visible )
						_useVector();
				} else
				if ( ! bmp.visible ) {
					_useBitmap();
				}
				
				
				super._reposition();
				
				_oldAngle = angle;
			}
			
			
			protected function _useVector():void
			{
				clip.visible = true;
				bmp.visible = false;
			}
			
			protected function _useBitmap():void
			{
				var rot:int = clip.rotation << 0; rot += rot<0? 360: 0;
				var cacheName:String = 'entity.block.' + _entity.type +'@' + rot
				var cached:CachedBmp = CachedAssets.getClip( cacheName );
				if ( ! cached ) {
					clip.rotation = rot;
					clip.gotoAndStop( 1 );
					cached = CachedAssets.instance.cacheTempClip( cacheName, clip, true );
				}
				
				if ( cached ) {
					bmp.bitmapData = cached.data;
					bmp.x = cached.offX;
					bmp.y = cached.offY;
					
					clip.visible = false;
					bmp.visible = true;
				} else {
					trace('cache not found '+ _entity.type +'@'+ rot);
				}
				
			}
			
	}

}