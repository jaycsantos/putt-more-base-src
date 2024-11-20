package pb2.game.entity.misc 
{
	import com.jaycsantos.display.render.AbstractRender;
	import com.jaycsantos.entity.Entity;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.AABB;
	import flash.display.*;
	import pb2.game.Registry;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class GridRender extends AbstractRender 
	{
		
		public function GridRender( grid:Grid, args:EntityArgs=null )
		{
			super( grid, args );
			
			redraw();
		}
		
		
			// -- private --
			
			override protected function _draw():void 
			{
				var g:Graphics = Sprite(buffer).graphics;
				g.clear();
				g.lineStyle( 1, 0xffffff, .1 );
				
				var ses:Session = Session.instance;
				var ts:uint = Registry.tileSize, ts2:Number = ts/2;
				var i:int = ses.cols +1;
				var j:int = ses.rows +1;
				while ( i-- ) {
					g.moveTo( i*ts +ts2, 0 );
					g.lineTo( i*ts +ts2, ses.height );
				}
				while ( j-- ) {
					g.moveTo( 0, j*ts +ts2 );
					g.lineTo( ses.width, j*ts +ts2 );
				}
			}
			
			override protected function _cull():void 
			{
				buffer.visible = _flags.isTrue( STATE_ISVISIBLE );
			}
			
			
			override protected function _onForcedShow():void 
			{
				buffer.visible = _flags.isTrue( STATE_ISVISIBLE );
			}
			
			
	}

}