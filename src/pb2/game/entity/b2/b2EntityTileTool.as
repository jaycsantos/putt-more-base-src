package pb2.game.entity.b2 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import com.jaycsantos.entity.EntityArgs;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.Registry;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class b2EntityTileTool extends b2EntityTile 
	{
		
		public function b2EntityTileTool( args:EntityArgs )
		{
			super( args );
		}
		
		
		override public function useDefault():void 
		{
			super.useDefault();
			
			if ( _flag.isTrue(FLAG_ISTOOLKIT) && render is b2EntTileToolRender )
				b2EntTileToolRender(render).showToolClip();
		}
		
		
		public function set isToolkit( value:Boolean ):void
		{
			_flag.setFlag( FLAG_ISTOOLKIT, value );
			
			if ( render is b2EntTileToolRender ) {
				var r:b2EntTileToolRender = render as b2EntTileToolRender;
				if ( value ) {
					r.drawToolkit();
					//BallCtrl.instance.onPull.add( r.hideToolClip );
					//BallCtrl.instance.onPullCancel.add( _maybeShowToolClip );
					Session.instance.onEntityMoveStart.add( r.hideToolClip );
					Session.instance.onEntitiesMoveStop.add( _maybeShowToolClip );
				} else {
					r.removeToolkit();
				}
			}
		}
		
			// -- private --
			
			private function _maybeShowToolClip():void
			{
				if ( _flag.isFalse(FLAG_WASMOVED) && render is b2EntTileToolRender )
					b2EntTileToolRender(render).showToolClip();
			}
			
	}

}