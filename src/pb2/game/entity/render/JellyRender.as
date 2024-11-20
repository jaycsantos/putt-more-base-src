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
	import flash.utils.getTimer;
	import pb2.game.entity.b2.b2Entity;
	import pb2.game.entity.b2.b2EntTileToolRender;
	import pb2.game.entity.Block;
	import pb2.game.entity.JellyBlock;
	import pb2.game.*;
	
	/**
	 * ...
	 * @author ...
	 */
	public class JellyRender extends b2EntTileToolRender implements IDragBaseDraw  
	{
		public var clip:MovieClip, bmp:Bitmap
		
		
		public function JellyRender( block:JellyBlock, args:EntityArgs=null ) 
		{
			block.jellyRender = this;
			
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
			
			_animator = new SimpleAnimationTiming([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19], GameLoop.instance.timeFrameRate*3, false, _looped);
			
			_useVector();
		}
		
		override public function dispose():void 
		{
			_animator.dispose(); _animator = null;
			
			// don't dispose, we cached it!
			bmp.bitmapData = null;
			bmp = null; clip = null;
			
			super.dispose();
		}
		
		override public function update():void 
		{
			if ( _animator.isPlaying ) {
				_animator.update();
				clip.gotoAndStop( _animator.frame );
				
			} else
			if ( _randomWiggle+2000 < getTimer() ) {
				_randomWiggle = getTimer() +MathUtils.randomInt(0,3000);
				if ( Math.random() < .3 ) wiggle();
			}
			
			super.update();
		}
		
		
		public function basedraw():DisplayObject
		{
			return clip;
		}
		
		public function wiggle( force:Number=1 ):void
		{
			//_animator.playAt( (1-force)*(_animator.length-1) >>0 );
			_animator.playAt( 0 );
			_useVector();
		}
		
		
			// -- private --
			
			protected var _oldAngle:Number
			protected var _animator:SimpleAnimationTiming, _randomWiggle:uint
			
			
			override protected function _reposition():void 
			{
				var angle:Number = Block(_entity).body.GetAngle();
				
				if ( angle != _oldAngle ) {
					Session.instance.shades.drawShade( Shape(clipShade).graphics, Block(_entity).body );
					clip.rotation = angle *Trigo.RAD_TO_DEG << 0;
					if ( ! clip.visible )
						_useVector();
				} else
				if ( !_animator.isPlaying && !bmp.visible ) {
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
			
			private function _looped():void
			{
				if ( b2Entity(_entity).body.GetLinearVelocity().Length() > 2 )
					_animator.playAt();
			}
		
	}

}