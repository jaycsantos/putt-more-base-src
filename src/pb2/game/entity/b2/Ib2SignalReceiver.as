package pb2.game.entity.b2 
{
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public interface Ib2SignalReceiver extends Ib2SignalNode
	{
		function receive( data:* ):Boolean
	}
	
}