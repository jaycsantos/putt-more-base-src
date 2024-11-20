package pb2.game.entity.b2 
{
	import com.jaycsantos.IDisposable;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public interface Ib2Tile extends IDisposable
	{
		function setDefault( x:Number, y:Number, a:Number = 0 ):void
		function useDefault():void
	}
	
}