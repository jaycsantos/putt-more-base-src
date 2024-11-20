package pb2.game.entity.b2 
{
	import com.jaycsantos.display.CachedAssets;
	import com.jaycsantos.display.CachedBmp;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.game.GameRoot;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import pb2.screen.EditorScreen;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class b2EntTileToolRender extends b2EntRender 
	{
		internal var tool:Bitmap
		
		public function b2EntTileToolRender( entity:b2Entity, args:EntityArgs )
		{
			super( entity, args );
			
		}
		
		
		internal function drawToolkit():void
		{
			Sprite(buffer).addChild( tool = new Bitmap );
			//tool.gotoAndStop( 2 );
			//tool.blendMode = 'overlay';
			
			var cached:CachedBmp = CachedAssets.getClip('screen.ui.ico.tool');
			if ( ! cached ) {
				var mc:MovieClip = PuttBase2.assets.createDisplayObject('screen.ui.ico.tool') as MovieClip;
				mc.gotoAndStop( 2 );
				mc.alpha = .5;
				cached = CachedAssets.instance.cacheClip( 'screen.ui.ico.tool', mc, true );
			}
			
			tool.bitmapData = cached.data
			if ( GameRoot.screen is EditorScreen ) {
				tool.x = -14 +cached.offX; tool.y = 14 +cached.offY;
				
			} else {
				tool.x = -12 +cached.offX; tool.y = 11 +cached.offY;
				//Sprite(buffer).buttonMode = true;
				//Sprite(buffer).mouseEnabled = false;
			}
		}
		
		internal function removeToolkit():void
		{
			if ( tool.parent )
				tool.parent.removeChild( tool );
			tool.bitmapData = null;
			tool = null;
			Sprite(buffer).buttonMode = false;
		}
		
		internal function hideToolClip():void
		{
			if ( tool ) tool.visible = false;
		}
		
		internal function showToolClip():void
		{
			if ( tool ) tool.visible = true;
		}
		
	}

}