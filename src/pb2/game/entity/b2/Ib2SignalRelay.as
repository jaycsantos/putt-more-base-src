package pb2.game.entity.b2 
{
	import com.jaycsantos.IDisposable;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public interface Ib2SignalRelay extends IDisposable
	{
		function get state():Boolean
		
		function get nodeCount():uint
		
		function addNode( node:Ib2SignalNode ):void
		function removeNode( node:Ib2SignalNode ):void
		
		function receiveTransmit( data:*, from:Ib2SignalNode ):void
		function get transmitters():Vector.<Ib2SignalTransmitter>
		function get receivers():Vector.<Ib2SignalReceiver>
	}
	
}