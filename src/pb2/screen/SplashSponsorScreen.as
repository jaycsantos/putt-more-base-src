package pb2.screen 
{
	import com.jaycsantos.display.screen.AbstractScreen;
	import com.jaycsantos.game.GameRoot;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class SplashSponsorScreen extends AbstractScreen 
	{
		
		public function SplashSponsorScreen( root:GameRoot, data:Object=null ) 
		{
			super( root, data );
			
		}
		
		
		
			// -- private --
			
			private var _clip:MovieClip
			
			private function _frame121():void
			{
				changeScreen( SplashJaycScreen );
				//_clip.stop();
			}
			
			override protected function _doWhileEntering():Boolean 
			{
				_frame121();
				return super._doWhileEntering();
			}
	}

}