package pb2.game.entity.tile 
{
	import com.jaycsantos.display.render.AbstractRender;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.MathUtils;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import pb2.game.Registry;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class FloorTextureRender extends AbstractRender 
	{
		
		public function FloorTextureRender( floor:FloorTexture , args:EntityArgs ) 
		{
			super( floor, args );
			
			floor.floorRender = this;
			
			Session.instance.ground.gndRender.clip.addChildAt( _gndClips = new Sprite, Session.instance.ground.gndRender.clipChildDepth );
			_gndClips.filters = [ new BlurFilter(2, 2) ];
		}
		
		
		public function setTexture( col:uint, row:uint, value:uint ):void
		{
			var mc:MovieClip = _gndClips.getChildByName('floor_'+ col +'_'+ row) as MovieClip;
			if ( mc )
				_gndClips.removeChild( mc );
			
			if ( value ) {
				_gndClips.addChild( mc = PuttBase2.assets.createDisplayObject('entity.floor.'+ FloorTexture.TYPE_STRING[value]) as MovieClip );
				
				mc.name = 'floor_'+ col +'_'+ row;
				mc.x = Math.floor( (col+1) *Registry.tileSize );
				mc.y = Math.floor( (row+1) *Registry.tileSize );
				mc.blendMode = value==3? 'multiply': 'overlay';
				mc.alpha = .70;
				mc['texture'] = value;
				mc.gotoAndStop( 1 );
			}
			
			for ( var i:int=col-1; i<col+2; i++ )
				for ( var j:int=row-1; j<row+2; j++ ) 
					_redrawFace( i, j );
			Session.instance.ground.gndRender.drawPartial( col, row );
		}
		
		
			// -- private --
			
			private var _gndClips:Sprite
			
			override protected function _draw():void 
			{
				
			}
			
			private function _redrawFace( tx:int, ty:int ):void
			{
				var mc:MovieClip = _gndClips.getChildByName('floor_'+ tx +'_'+ ty) as MovieClip;
				var ses:Session = Session.instance;
				
				if ( mc && mc['texture'] > 0 ) {
					var face:int, floor:FloorTexture = FloorTexture(_entity);
					
					// above
					if ( ty-1 < 0 || floor.getTexture(tx, ty-1) == mc['texture'] ) face |= 1;
					// below
					if ( ty+1 >= ses.rows || floor.getTexture(tx, ty+1) == mc['texture'] ) face |= 2;
					// left
					if ( tx-1 < 0 || floor.getTexture(tx-1, ty) == mc['texture'] ) face |= 4;
					// right
					if ( tx+1 >= ses.cols || floor.getTexture(tx+1, ty) == mc['texture'] ) face |= 8;
					
					if ( face == 15 ) {
						face += MathUtils.randomInt(0, 2);
						mc.rotation = MathUtils.randomInt(0,3) *90;
					} else
						mc.rotation = 0;
					
					mc.gotoAndStop( face+1 );
				}
			}
			
			
	}

}