package pb2.game.entity.misc 
{
	import com.jaycsantos.entity.Entity;
	import com.jaycsantos.entity.EntityArgs;
	import flash.display.DisplayObject;
	import pb2.game.Registry;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Toons extends Entity 
	{
		
		public function Toons( args:EntityArgs=null )
		{
			super(args);
			
		}
		
		
		public function applyImpact( x:Number, y:Number, radian:Number ):void
		{
			ToonsRender(render).playImpact( x, y, radian );
		}
		
		
		public function addClip( d:DisplayObject ):DisplayObject
		{
			return ToonsRender(render).clip.addChild( d );
		}
		
		public function removeClip( d:DisplayObject ):DisplayObject
		{
			return ToonsRender(render).clip.removeChild( d );
		}
		
		
	}

}