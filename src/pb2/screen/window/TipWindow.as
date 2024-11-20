package pb2.screen.window 
{
	import com.jaycsantos.game.IGameObject;
	import com.jaycsantos.util.DisplayKit;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class TipWindow extends Sprite implements IGameObject 
	{
		
		public function TipWindow( x:uint, y:uint ) 
		{
			addChild( _bg = PuttBase2.assets.createDisplayObject('screen.ui.bg.tip') as Sprite );
			addChild( _contents = new Sprite );
			
			this.x = _x = x;
			this.y = _y = y;
		}
		
		public function update():void 
		{
			
		}
		
		public function dispose():void 
		{
			if ( parent ) parent.removeChild( this );
			DisplayKit.removeAllChildren( this, 1 );
		}
		
			// -- private --
			
			protected var _contents:Sprite, _bg:Sprite, _x:uint, _y:uint
			
	}

}