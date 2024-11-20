package pb2.screen 
{
	import com.jaycsantos.display.screen.AbstractScreen;
	import com.jaycsantos.game.GameRoot;
	import pb2.game.Game;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class GameScreen extends AbstractScreen 
	{
		public var game:Game;
		
		public function GameScreen( root:GameRoot, data:Object = null )
		{
			super( root, data );
			
			game = new Game( 22, 12, _canvas );
		}
		
		override public function update():void 
		{
			game.update();
		}
		
		override public function dispose():void 
		{
			super.dispose();
			game.dispose();
			game = null;
		}
		
	}

}