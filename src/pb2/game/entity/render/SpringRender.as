package pb2.game.entity.render 
{
	import com.jaycsantos.entity.EntityArgs;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import pb2.game.entity.b2.b2Entity;
	import pb2.game.entity.b2.b2EntRender;
	import pb2.game.entity.b2.Ib2EntRenderAni;
	import pb2.game.entity.Spring;
	import pb2.game.Registry;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class SpringRender extends b2EntRender
	{
		
		public function SpringRender( spring:Spring, args:EntityArgs = null )
		{
			super( spring, args );
			
			_clip = Sprite(buffer).addChild( PuttBase2.assets.createDisplayObject('entity.block.'+ spring.type) ) as MovieClip;
			
			bounds.resize( Registry.tileSize, Registry.tileSize );
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			_clip = null;
		}
		
		
		override public function update():void 
		{
			super.update();
			
			
		}
		
		
			// -- private --
			
			private var _clip:MovieClip
			
			
	}

}