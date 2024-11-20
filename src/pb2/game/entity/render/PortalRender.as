package pb2.game.entity.render 
{
	import com.jaycsantos.display.animation.SimpleAnimationTiming;
	import com.jaycsantos.display.CachedAssets;
	import com.jaycsantos.display.CachedBmp;
	import com.jaycsantos.display.render.IAnimatedRender;
	import com.jaycsantos.entity.EntityArgs;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import pb2.game.entity.b2.*;
	import pb2.game.entity.Portal;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PortalRender extends b2EntRender implements IAnimatedRender
	{
		public var clip:MovieClip, bmp:Bitmap, glow:MovieClip
		
		public function PortalRender( portal:Portal, args:EntityArgs) 
		{
			super( portal, args );
			
			portal.portalRender = this;
			
			if ( clipShade && clipShade.parent )
				clipShade.parent.removeChild( clipShade );
			
			Sprite(buffer).addChild( clip = PuttBase2.assets.createDisplayObject('entity.block.portal') as MovieClip );
			clip.gotoAndStop( 1 );
			clip.addFrameScript( 199, reset );
			clip.addChild( _light = PuttBase2.assets.createDisplayObject('entity.block.portal.light') as MovieClip );
			_light.gotoAndStop( 1 );
			
			Sprite(buffer).addChild( bmp = new Bitmap );
			bmp.visible = false;
			
			Sprite(buffer).addChild( glow = PuttBase2.assets.createDisplayObject('entity.block.portal.glow') as MovieClip );
			glow.stop(); glow.visible = false;
			glow.addFrameScript( 49, _stopGlow );
			
			redraw();
		}
		
		override public function dispose():void 
		{
			// don't dispose, we cached it!
			bmp.bitmapData = null;
			bmp = null; clip = glow = null;
			
			super.dispose();
		}
		
		override public function update():void 
		{
			super.update();
			
		}
		
		
		public function play( data:Object=null ):void
		{
			clip.gotoAndPlay( 1 );
			glow.gotoAndPlay( 1 );
			clip.visible = glow.visible = true;
			bmp.visible = false;
		}
		
		public function stop( data:Object=null ):void
		{
			reset();
		}
		
		public function reset( data:Object=null ):void
		{
			if ( !clip ) return;
			clip.gotoAndStop( 1 );
			glow.gotoAndStop( 50 );
			clip.visible = glow.visible = false;
			bmp.visible = true;
		}
		
		
		public function lightUp( val:int=0 ):void
		{
			_light.gotoAndStop( val+1 );
			redraw();
		}
		
		
			// -- private --
			
			private var _light:MovieClip
			
			override protected function _draw():void 
			{
				reset();
				
				var completeName:String = 'entity.block.portal-'+ _light.currentFrame;
				var cached:CachedBmp = CachedAssets.getClip( completeName );
				if ( ! cached )
					cached = CachedAssets.instance.cacheTempClip( completeName, clip, true );
				bmp.bitmapData = cached.data;
				bmp.x = cached.offX;
				bmp.y = cached.offY;
			}
			
			private function _stopGlow():void
			{
				glow.stop();
				glow.visible = false;
			}
			
			
	}

}