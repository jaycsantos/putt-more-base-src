package pb2.game.entity.render 
{
	import Box2D.Common.Math.b2Vec2;
	import com.jaycsantos.display.animation.SimpleAnimationTiming;
	import com.jaycsantos.display.CachedAssets;
	import com.jaycsantos.display.CachedBmp;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.math.Trigo;
	import com.jaycsantos.util.GameLoop;
	import flash.display.*;
	import pb2.game.entity.b2.b2Entity;
	import pb2.game.entity.b2.b2EntRender;
	import pb2.game.entity.Glass;
	import pb2.game.Registry;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author ...
	 */
	public class GlassRender extends b2EntRender implements IDragBaseDraw
	{
		public var clip:MovieClip, bmp:Bitmap
		
		public function GlassRender( glass:Glass, args:EntityArgs )
		{
			glass.glassRender = this;
			super( glass, args );
			
			Sprite(buffer).addChild( clip = PuttBase2.assets.createDisplayObject('entity.block.'+glass.type) as MovieClip );
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
			
			_animator = new SimpleAnimationTiming([1,2,3,4,5,6,7,8,9,10,11,12,13,14, 14,14,14,14,14,14,14,14,14,14, 14,14,14,14,14,14,14,14,14,14, 14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,15], 0, false, _looped);
			_animator.stop( 0 );
			
			_useBitmap();
		}
		
		override public function dispose():void 
		{
			_animator.dispose(); _animator = null;
			super.dispose();
		}
		
		override public function update():void 
		{
			if ( _animator.isPlaying ) {
				_animator.update();
				clip.gotoAndStop( _animator.frame );
				clip.alpha = MathUtils.limit( 1 -_animator.index/_animator.length, 0, 1 );
			}
			
			super.update();
		}
		
		
		public function hitBreak():void
		{
			_animator.playAt();
			_useVector();
			clip.alpha = 1;
			clip.rotation = MathUtils.randomInt(0, 3) *90;
			
			clipShade.alpha = 0;
		}
		
		public function reassemble():void
		{
			_animator.stop( 0 );
			clip.gotoAndStop( _animator.frame );
			clip.alpha = clipShade.alpha = 1;
			clip.visible = true;
			_useBitmap();
		}
		
		
		public function basedraw():DisplayObject
		{
			return clip;
		}
		
		
			// -- private --
			
			protected var _oldAngle:Number
			protected var _animator:SimpleAnimationTiming
			
			override protected function _reposition():void 
			{
				var angle:Number = Glass(_entity).body.GetAngle();
				
				if ( angle != _oldAngle ) {
					Session.instance.shades.drawShade( Shape(clipShade).graphics, Glass(_entity).body );
					clip.rotation = angle *Trigo.RAD_TO_DEG << 0;
					if ( ! clip.visible )
						_useVector();
				} else
				if ( 0&& ! bmp.visible ) {
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
				var cacheName:String = 'entity.block.'+ _entity.type +'@'+ rot +'@'+ clip.currentFrame;
				var cached:CachedBmp = CachedAssets.getClip( cacheName );
				if ( ! cached ) {
					clip.rotation = rot;
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
			
			private function _looped():void
			{
				//clip.alpha = bmp.alpha = 0;
				clip.visible = false;
				//_useBitmap();
			}
			
			
	}

}