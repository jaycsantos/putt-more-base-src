package pb2.game.entity.tile 
{
	import com.jaycsantos.entity.Entity;
	import com.jaycsantos.entity.EntityArgs;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Ground extends Entity 
	{
		public static const COLORS:Vector.<Array> = Vector.<Array>([
			[0xC6A477, 0x9C805E], // yellowish
			[0x697F52, 0x4C593F], // green
			[0x47B2B2, 0x327F7F], // blue green
			[0xAAB273, 0x5E663D], // light green
			[0x5994B2, 0x3F637F], // green blue
			[0xB27C85, 0x66333D], // pink
			[0xB4905A, 0x7F5D4C], // off orange
			[0x4F6072, 0x352D4C], // dark blue
		]);
		
		
		
		public var gndRender:GroundRender
		
		public function Ground( args:EntityArgs = null ) 
		{
			args.dimension.x = Session.instance.width;
			args.dimension.y = Session.instance.height;
			super( args );
			
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			gndRender = null;
		}
		
		
	}

}