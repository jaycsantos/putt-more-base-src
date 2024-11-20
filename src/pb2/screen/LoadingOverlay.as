package pb2.screen 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class LoadingOverlay extends Sprite 
	{
		public static const instance:LoadingOverlay = new LoadingOverlay
		
		public static function prepare( color:uint=0 ):void
		{
			instance.prepare( color );
		}
		
		public static function dismiss():void
		{
			instance.dismiss();
		}
		
		
		public var bitmap:Bitmap, clip:Sprite
		
		public function LoadingOverlay() 
		{
			mouseEnabled = mouseChildren = false;
			tabEnabled = tabChildren = false;
			
			addChild( bitmap = new Bitmap );
			addChild( clip = new Sprite );
			graphics.beginFill( 0 );
			graphics.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			graphics.endFill();
			visible = false;
		}
		
		public function prepare( color:uint=0 ):void
		{
			// keep on top
			if ( parent )
				parent.setChildIndex( this, parent.numChildren - 1 );
			
			clean();
			
			graphics.clear();
			graphics.beginFill( color );
			graphics.drawRect( 0,0,PuttBase2.STAGE_WIDTH,PuttBase2.STAGE_HEIGHT );
			graphics.endFill();
			
			visible = true;
		}
		
		public function dismiss():void
		{
			visible = false;
		}
		
		public function clean():void
		{
			// clean bgBmp
			bitmap.bitmapData = null;
			
			// clean bgClip
			var i:int = clip.numChildren;
			while ( i ) 
				clip.removeChildAt( i );
		}
		
		
	}

}