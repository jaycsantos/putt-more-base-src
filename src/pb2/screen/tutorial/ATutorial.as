package pb2.screen.tutorial 
{
	import com.jaycsantos.game.IGameObject;
	import com.jaycsantos.util.DisplayKit;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class ATutorial extends Sprite implements IGameObject 
	{
		
		public function ATutorial() 
		{
			Tutorial01a; Tutorial02; Tutorial03; Tutorial04;
			
			mouseEnabled = tabEnabled = false;
		}
		
		/* INTERFACE com.jaycsantos.game.IGameObject */
		
		public function update():void 
		{
			
		}
		
		public function dispose():void 
		{
			DisplayKit.removeAllChildren( this, 3 );
		}
		
		
		public function show():void
		{
			
		}
		
		public function hide():void
		{
			
		}
		
		
			// -- private --
			
			protected function _toggle( e:Event=null ):void
			{
				
			}
		
	}

}