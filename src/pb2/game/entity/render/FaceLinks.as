package pb2.game.entity.render 
{
	import com.jaycsantos.math.Trigo;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.entity.ISolidWall;
	import pb2.game.entity.SolidBlock;
	import pb2.game.Session;
	/**
	 * ...
	 * @author ...
	 */
	public class FaceLinks 
	{
		
		public static function getFaceFrame( tx:int, ty:int ):uint
		{
			var tileMap:Vector.<Vector.<b2EntityTile>> = Session.instance.tileMap;
			var flag:uint = 0, frame:uint, tile:b2EntityTile;
			
			if ( tx==-1 || ty==-1 || tx==tileMap.length || ty==tileMap[0].length ) {
				
				// check my top
				flag |= faceHasBelow(tx,ty-1,tileMap) ? 1: 0;
				// check my bottom
				flag |= faceHasAbove(tx,ty+1,tileMap) ? 2: 0;
				// check my left
				flag |= faceHasBesideRight(tx-1,ty,tileMap) ? 4: 0;
				// check my right
				flag |= faceHasBesideLeft(tx+1,ty,tileMap) ? 8: 0;
				// check my top left
				flag |= faceHasBelow(tx-1,ty-1,tileMap) && faceHasBesideRight(tx-1,ty-1,tileMap) ? 16: 0;
				// check my top right
				flag |= faceHasBelow(tx+1,ty-1,tileMap) && faceHasBesideLeft(tx+1,ty-1,tileMap) ? 32: 0;
				// check my bottom left
				flag |= faceHasAbove(tx-1,ty+1,tileMap) && faceHasBesideRight(tx-1,ty+1,tileMap) ? 64: 0;
				// check my bottom right
				flag |= faceHasAbove(tx+1,ty+1,tileMap) && faceHasBesideLeft(tx+1,ty+1,tileMap) ? 128: 0;
				
				// recheck top -> left
				if ( (flag & (16+1)) > 0 && !faceHasBesideLeft(tx,ty-1,tileMap) ) flag &= ~16;
				// recheck left -> top
				if ( (flag & (16+4)) > 0 && !faceHasAbove(tx-1,ty,tileMap) ) flag &= ~16;
				// recheck top -> right
				if ( (flag & (32+1)) > 0 && !faceHasBesideRight(tx,ty-1,tileMap) ) flag &= ~32;
				// recheck right -> top
				if ( (flag & (32+8)) > 0 && !faceHasAbove(tx+1,ty,tileMap) ) flag &= ~32;
				// recheck bottom -> left
				if ( (flag & (64+2)) > 0 && !faceHasBesideLeft(tx,ty+1,tileMap) ) flag &= ~64;
				// recheck left -> bottom
				if ( (flag & (64+4)) > 0 && !faceHasBelow(tx-1,ty,tileMap) ) flag &= ~64;
				// recheck bottom -> right
				if ( (flag & (128+8)) > 0 && !faceHasBesideRight(tx,ty+1,tileMap) ) flag &= ~128;
				// recheck right -> bottom
				if ( (flag & (128+4)) > 0 && !faceHasBelow(tx+1,ty,tileMap) ) flag &= ~128;
				
				frame = flag;
				//MovieClip(clip.getChildByName( 't'+ (tx+1) +'_'+ (ty+1) )).gotoAndStop( frame +1 );
			}
			else {
				if ( ! tileMap[tx] || ! tileMap[tx][ty] ) return 0;
				
				tile = tileMap[tx][ty];
				if ( tile is ISolidWall ) {
					if ( !tile.isActive ) return flag;
					switch( tile.shapeName ) {
						case 'hf':
						case 'rtri':
						case 'isotri':
						case 'hfisotri':
						case 'hfrtri1':
						case 'hfrtri2':
						case 'hfrtri3':
						case 'hfrtri4':
							//{
							// check my top
							flag |= faceHasBelow(tx,ty-1,tileMap) ? 1: 0;
							// check my bottom
							flag |= faceHasAbove(tx,ty+1,tileMap) ? 2: 0;
							// check my left
							flag |= faceHasBesideRight(tx-1,ty,tileMap) ? 4: 0;
							// check my right
							flag |= faceHasBesideLeft(tx+1,ty,tileMap) ? 8: 0;
							
							frame = flag +20 *Math.round( (tile.defRa<0? tile.defRa+Trigo.PI2: tile.defRa) /Trigo.HALF_PI );
							
							break; //}
						case 'sq':
							//{
							// check my top
							flag |= faceHasBelow(tx,ty-1,tileMap) ? 1: 0;
							// check my bottom
							flag |= faceHasAbove(tx,ty+1,tileMap) ? 2: 0;
							// check my left
							flag |= faceHasBesideRight(tx-1,ty,tileMap) ? 4: 0;
							// check my right
							flag |= faceHasBesideLeft(tx+1,ty,tileMap) ? 8: 0;
							// check my top left
							flag |= faceHasBelow(tx-1,ty-1,tileMap) && faceHasBesideRight(tx-1,ty-1,tileMap) ? 16: 0;
							// check my top right
							flag |= faceHasBelow(tx+1,ty-1,tileMap) && faceHasBesideLeft(tx+1,ty-1,tileMap) ? 32: 0;
							// check my bottom left
							flag |= faceHasAbove(tx-1,ty+1,tileMap) && faceHasBesideRight(tx-1,ty+1,tileMap) ? 64: 0;
							// check my bottom right
							flag |= faceHasAbove(tx+1,ty+1,tileMap) && faceHasBesideLeft(tx+1,ty+1,tileMap) ? 128: 0;
							
							// recheck top -> left
							if ( (flag & (16|1)) == (16|1) && !faceHasBesideLeft(tx,ty-1,tileMap) ) flag &= ~16;
							// recheck left -> top
							if ( (flag & (16|4)) == (16|4) && !faceHasAbove(tx-1,ty,tileMap) ) flag &= ~16;
							// recheck top -> right
							if ( (flag & (32|1)) == (32|1) && !faceHasBesideRight(tx,ty-1,tileMap) ) flag &= ~32;
							// recheck right -> top
							if ( (flag & (32|8)) == (32|8) && !faceHasAbove(tx+1,ty,tileMap) ) flag &= ~32;
							// recheck bottom -> left
							if ( (flag & (64|2)) == (64|2) && !faceHasBesideLeft(tx,ty+1,tileMap) ) flag &= ~64;
							// recheck left -> bottom
							if ( (flag & (64|4)) == (64|4) && !faceHasBelow(tx-1,ty,tileMap) ) flag &= ~64;
							// recheck bottom -> right
							if ( (flag & (128|8)) == (128|8) && !faceHasBesideRight(tx,ty+1,tileMap) ) flag &= ~128;
							// recheck right -> bottom
							if ( (flag & (128|4)) ==(128|4) && !faceHasBelow(tx+1,ty,tileMap) ) flag &= ~128;
							
							frame = flag;
							
							break; //}
						default: break;
					}
				}
				
				// is top-bottom-left-right is occupied
				// disable this block
				// there is no way it will collide with anything (99% of the time)
				if ( (flag & 15) == 15 )
					tile.body.SetActive( false );
				else
					tile.body.SetActive( true );/**/
			}
			
			return frame;
		}
			
			
			
			private static function faceHasBelow( tx:int, ty:int, tileMap:Vector.<Vector.<b2EntityTile>> ):Boolean
			{
				if ( tx<-1 || tx>tileMap.length || ty<-1 || ty>tileMap[0].length )
					return false;
				else if ( tx==-1 || tx==tileMap.length || ty==-1 || ty==tileMap[0].length )
					return true;
				else if ( ! tileMap[tx] || ! tileMap[tx][ty] )
					return false;
				
				var tile:b2EntityTile = tileMap[tx][ty];
				if ( !tile.isActive ) return false;
				if ( tile is ISolidWall ) {
					switch( tile.shapeName ) {
						case 'sq': return true; break;
						case 'hf':
						case 'isotri':
						case 'hfisotri':
						case 'hfrtri1':
						case 'hfrtri2': return tile.defRa==0; break;
						case 'rtri':
						case 'hfrtri3': return tile.defRa==0 || tile.defRa==Trigo.HALF_PI; break;
						case 'hfrtri4': return tile.defRa==0 || tile.defRa==-Trigo.HALF_PI; break;
					}
				} else {
				}
				
				return false;
			}
			
			private static function faceHasAbove( tx:int, ty:int, tileMap:Vector.<Vector.<b2EntityTile>> ):Boolean
			{
				if ( tx<-1 || tx>tileMap.length || ty<-1 || ty>tileMap[0].length )
					return false;
				else if ( tx==-1 || tx==tileMap.length || ty==-1 || ty==tileMap[0].length )
					return true;
				else if ( ! tileMap[tx] || ! tileMap[tx][ty] )
					return false;
				
				var tile:b2EntityTile = tileMap[tx][ty];
				if ( !tile.isActive ) return false;
				if ( tile is ISolidWall ) {
					switch( tile.shapeName ) {
						case 'sq': return true; break;
						case 'hf':
						case 'isotri':
						case 'hfisotri':
						case 'hfrtri1':
						case 'hfrtri2': return tile.defRa==Math.PI; break;
						case 'rtri':
						case 'hfrtri3': return tile.defRa==Math.PI || tile.defRa==-Trigo.HALF_PI; break;
						case 'hfrtri4': return tile.defRa==Math.PI || tile.defRa==Trigo.HALF_PI; break;
					}
				} else {
				}
				
				return false;
			}
			
			private static function faceHasBesideRight( tx:int, ty:int, tileMap:Vector.<Vector.<b2EntityTile>> ):Boolean
			{
				if ( tx<-1 || tx>tileMap.length || ty<-1 || ty>tileMap[0].length )
					return false;
				else if ( tx==-1 || tx==tileMap.length || ty==-1 || ty==tileMap[0].length )
					return true;
				else if ( ! tileMap[tx] || ! tileMap[tx][ty] )
					return false;
				
				var tile:b2EntityTile = tileMap[tx][ty];
				if ( !tile.isActive ) return false;
				if ( tile is ISolidWall ) {
					switch( tile.shapeName ) {
						case 'sq': return true; break;
						case 'hf':
						case 'isotri':
						case 'hfisotri':
						case 'hfrtri1':
						case 'hfrtri2': return tile.defRa==-Trigo.HALF_PI; break;
						case 'rtri':
						case 'hfrtri3': return tile.defRa==0 || tile.defRa==-Trigo.HALF_PI; break;
						case 'hfrtri4': return tile.defRa==Math.PI || tile.defRa==-Trigo.HALF_PI; break;
					}
				} else {
				}
				
				return false;
			}
			
			private static function faceHasBesideLeft( tx:int, ty:int, tileMap:Vector.<Vector.<b2EntityTile>> ):Boolean
			{
				if ( tx<-1 || tx>tileMap.length || ty<-1 || ty>tileMap[0].length )
					return false;
				else if ( tx==-1 || tx==tileMap.length || ty==-1 || ty==tileMap[0].length )
					return true;
				else if ( ! tileMap[tx] || ! tileMap[tx][ty] )
					return false;
				
				var tile:b2EntityTile = tileMap[tx][ty];
				if ( !tile.isActive ) return false;
				if ( tile is ISolidWall ) {
					switch( tile.shapeName ) {
						case 'sq': return true; break;
						case 'hf':
						case 'isotri':
						case 'hfisotri':
						case 'hfrtri1':
						case 'hfrtri2': return tile.defRa==Trigo.HALF_PI; break;
						case 'rtri':
						case 'hfrtri3': return tile.defRa==Math.PI || tile.defRa==Trigo.HALF_PI; break;
						case 'hfrtri4': return tile.defRa==0 || tile.defRa==Trigo.HALF_PI; break;
					}
				} else {
				}
				
				return false;
			}
			
		
	}

}