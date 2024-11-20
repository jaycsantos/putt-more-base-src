package pb2.screen.ui.levelselect 
{
	import com.jaycsantos.game.IGameObject;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class LevelNode extends Sprite implements IGameObject
	{
		public var id:int
		
		public function LevelNode( name:String, id:int, icon:int=0 )
		{
			buttonMode = true;
			mouseChildren = false;
			
			
		}
		
		public function dispose():void
		{
			
		}
		
		
		public function update():void
		{
			
		}
		
		
			// -- private --
			
			private var _name:String, _icon:Sprite
		
		
	}

}