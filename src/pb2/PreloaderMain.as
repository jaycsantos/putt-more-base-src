package pb2 
{
	import com.demonsters.debugger.MonsterDebugger;
	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import flash.utils.ByteArray;
	import mx.core.ByteArrayAsset;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PreloaderMain extends Sprite 
	{
		
		public function PreloaderMain() 
		{
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			
			_loc_3 = new PreloaderEvent;
			_loc_5 = _loc_3.length;
			addEventListener( Event.ENTER_FRAME, _loc_2 );
			
			CONFIG::debug {
				MonsterDebugger.initialize( this );
			}
		}
		
		
			// -- private --
			
			private var _loc_5:int, _loc_3:ByteArrayAsset, _loc_8:Loader
			
			
			private function _loc_2( e:Event ):void
			{
				var c:int = 100000, data:ByteArray = _loc_3;
				while ( c-- >0 && _loc_5-- >0 ) {
					data[_loc_5] = (data[_loc_5] -_loc_5%130 +256) %256;
				}
				
				if ( _loc_5 < 0 ) {
					
					addChild( _loc_8 = new Loader );
					with ( _loc_8.contentLoaderInfo ) {
						addEventListener( Event.COMPLETE, _loc_6 );
						addEventListener( IOErrorEvent.IO_ERROR, _loc_4 );
					}
					//_loc_8.set = ApplicationDomain.currentDomain;
					_loc_8.loadBytes( _loc_3 );
					removeEventListener( Event.ENTER_FRAME, _loc_2 );
				}
			}
			
			private function _loc_6( e:Event ):void
			{
				trace( "done" );
				//addChild( _loader.content );
			}
			
			private function _loc_4( e:Event ):void
			{
				
			}
			
	}

}