package pb2.game.entity.misc 
{
	import com.demonsters.debugger.MonsterDebugger;
	import com.jaycsantos.display.CachedAssets;
	import com.jaycsantos.display.CachedBmp;
	import com.jaycsantos.game.GameRoot;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.entity.SolidBlock;
	import pb2.game.Session;
	import pb2.screen.EditorScreen;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class MoreTexture 
	{
		
		public static function run( tileMap:Vector.<Vector.<b2EntityTile>> ):void
		{
			var mark0:int=0, mark90:int=0
			var mark0a:int=0, mark90a:int=0
			var blk:SolidBlock, bmp:Bitmap;
			var cached:CachedBmp;
			
			if ( !Session.isOnEditor && GameRoot.nextScreenClass != EditorScreen )
				for each( var list:Vector.<b2EntityTile> in tileMap )
					for each( var tile:b2EntityTile in list ) {
						if ( tile is SolidBlock && tile.shapeName == 'sq' ) {
							blk = tile as SolidBlock;
							
							switch( (blk.blkRender.faceFrame-1) % 16 ) {
								case 13: case 14:
									if ( blk.blkRender.faceFrame < 17 ) break;
								case 12:
									if ( mark0 % 4 == 0 ) {
										cached = CachedAssets.getClip( 'entity.block.wall.offdirt-0@'+ ((mark0*2%14)+1) );
										Sprite(blk.blkRender.buffer).addChild( bmp=new Bitmap(cached.data) );
										bmp.x = cached.offX;
										bmp.y = cached.offY;
									}
									mark0++;
									break;
									
								case 7: case 11:
									if ( blk.blkRender.faceFrame < 17 ) break;
								case 3:
									if ( mark90 % 3 == 0 ) {
										cached = CachedAssets.getClip( 'entity.block.wall.offdirt-90@'+ ((mark90*2%14)+1) );
										Sprite(blk.blkRender.buffer).addChild( bmp=new Bitmap(cached.data) );
										bmp.x = cached.offX;
										bmp.y = cached.offY;
									}
									mark90++;
									break;
							}
						}
						
						// apply gardening
						if ( tile is SolidBlock && SolidBlock(tile).blkRender.faceFrame != 256 && tile.shapeName == 'sq' ) {
							blk = tile as SolidBlock;
							switch( (blk.blkRender.faceFrame-1)%16 +1 ) {
								case 1: case 6: case 7: case 10: case 11: case 16:
									if ( mark0a%10 < 4 ) {
										cached = CachedAssets.getClip( 'entity.block.wall.offGarden-'+ (mark0a%2 *90)+'@'+ ((mark0a*2%10)+1) );
										Sprite(blk.blkRender.buffer).addChild( bmp=new Bitmap(cached.data) );
										bmp.x = cached.offX;
										bmp.y = cached.offY;
									}
									break;
								
								case 5: case 9: case 13: case 14: case 15:
									if ( mark0a%12 == 1 || mark0a%12 == 2 || (mark0a%12 == 3 && Math.random()<.3) ) {
										cached = CachedAssets.getClip( 'entity.block.wall.offGarden-0@'+ ((mark0a*2%10)+1) );
										Sprite(blk.blkRender.buffer).addChild( bmp=new Bitmap(cached.data) );
										bmp.x = cached.offX;
										bmp.y = cached.offY;
									}
									break;
								
								case 2: case 3: case 4: case 8: case 12:
									if ( mark0a%10 == 1 || mark0a%10 == 2 || (mark0a%10 == 3 && Math.random()<.3) ) {
										cached = CachedAssets.getClip( 'entity.block.wall.offGarden-90@'+ ((mark0a*2%10)+1) );
										Sprite(blk.blkRender.buffer).addChild( bmp=new Bitmap(cached.data) );
										bmp.x = cached.offX;
										bmp.y = cached.offY;
									}
									break;
							}
							mark0a++;
						}
					}
			
		}
		
		
	}

}