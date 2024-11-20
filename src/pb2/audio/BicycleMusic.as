package pb2.audio 
{
	import com.jaycsantos.util.GameSoundObj;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class BicycleMusic 
	{
		
		public function BicycleMusic( loopSndObj:GameSoundObj ) 
		{
			_sndObj = loopSndObj;
		}
		
		public function play():void
		{
			_sndObj.play( 0, 3 );
			
		}
		
		
		
			// -- private --
			
			private var _sndObj:GameSoundObj
		
	}

}