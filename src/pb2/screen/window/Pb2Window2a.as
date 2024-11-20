package pb2.screen.window 
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Pb2Window2a extends Pb2Window2 
	{
		
		public function Pb2Window2a() 
		{
			super();
			
			_bgClip.removeChild( _bg2 );
			_bgClip.addChildAt( _bg2 = PuttBase2.assets.createDisplayObject('screen.window.bg3') as Sprite, 0 );
			_bgClip.filters = [ new GlowFilter(0x191919, .5, 12, 12, 1) ];
			
		}
		
	}

}