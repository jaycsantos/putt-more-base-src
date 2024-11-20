package pb2.game.entity.b2 
{
	import com.jaycsantos.IDisposable;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public interface Ib2SignalNode extends IDisposable
	{
		function getRelay():Ib2SignalRelay
		function relayTo( relay:Ib2SignalRelay ):void
	}
	
}