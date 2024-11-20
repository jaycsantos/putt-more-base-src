package pb2.game 
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Tile 
	{
		public static const GOLFBALL:String = 'golfball';
		public static const HOLE:String = 'hole';
		public static const SPRING_SQ:String = 'spring_sq';
		public static const SPRING_RTRI:String = 'spring_rtri';
		public static const PUNCHER_SQ:String = 'puncher_sq';
		public static const PUNCHER2_SQ:String = 'puncher2_sq';
		public static const PUNCHER_RTRI:String = 'puncher_rtri';
		public static const PPUNCHER_SQ:String = 'ppuncher_sq';
		public static const WALL_SQ:String = 'wall_sq';
		public static const WALL_HF:String = 'wall_hf';
		public static const WALL_RTRI:String = 'wall_rtri';
		public static const WALL_HFRTRI_1:String = 'wall_hfrtri1';
		public static const WALL_HFRTRI_2:String = 'wall_hfrtri2';
		public static const WALL_HFRTRI_3:String = 'wall_hfrtri3';
		public static const WALL_HFRTRI_4:String = 'wall_hfrtri4';
		public static const WALL_ISOTRI:String = 'wall_isotri';
		public static const WALL_HFISOTRI:String = 'wall_hfisotri';
		public static const WPAD_SQ:String = 'wpad_sq';
		public static const WPAD_HF:String = 'wpad_hf';
		public static const WPAD_RTRI:String = 'wpad_rtri';
		public static const WPAD_HFRTRI_1:String = 'wpad_hfrtri1';
		public static const WPAD_HFRTRI_2:String = 'wpad_hfrtri2';
		public static const WPAD_HFRTRI_3:String = 'wpad_hfrtri3';
		public static const WPAD_HFRTRI_4:String = 'wpad_hfrtri4';
		public static const WPAD_ISOTRI:String = 'wpad_isotri';
		public static const WPAD_HFISOTRI:String = 'wpad_hfisotri';
		public static const WRUB_SQ:String = 'wrub_sq';
		public static const WRUB_HF:String = 'wrub_hf';
		public static const WRUB_RTRI:String = 'wrub_rtri';
		public static const WRUB_HFRTRI_1:String = 'wrub_hfrtri1';
		public static const WRUB_HFRTRI_2:String = 'wrub_hfrtri2';
		public static const WRUB_HFRTRI_3:String = 'wrub_hfrtri3';
		public static const WRUB_HFRTRI_4:String = 'wrub_hfrtri4';
		public static const WRUB_ISOTRI:String = 'wrub_isotri';
		public static const WRUB_HFISOTRI:String = 'wrub_hfisotri';
		public static const WOOD_SQ:String = 'wood_sq';
		public static const WOOD_HF:String = 'wood_hf';
		public static const WOOD_RTRI:String = 'wood_rtri';
		public static const WOOD_HFRTRI_1:String = 'wood_hfrtri1';
		public static const WOOD_HFRTRI_2:String = 'wood_hfrtri2';
		public static const WOOD_HFRTRI_3:String = 'wood_hfrtri3';
		public static const WOOD_HFRTRI_4:String = 'wood_hfrtri4';
		public static const WOOD_ISOTRI:String = 'wood_isotri';
		public static const WOOD_HFISOTRI:String = 'wood_hfisotri';
		public static const RUB_SQ:String = 'rubber_sq';
		public static const RUB_HF:String = 'rubber_hf';
		public static const RUB_RTRI:String = 'rubber_rtri';
		public static const RUB_HFRTRI_1:String = 'rubber_hfrtri1';
		public static const RUB_HFRTRI_2:String = 'rubber_hfrtri2';
		public static const RUB_HFRTRI_3:String = 'rubber_hfrtri3';
		public static const RUB_HFRTRI_4:String = 'rubber_hfrtri4';
		public static const RUB_ISOTRI:String = 'rubber_isotri';
		public static const RUB_HFISOTRI:String = 'rubber_hfisotri';
		public static const JELL_SQ:String = 'jelly_sq';
		public static const JELL_HF:String = 'jelly_hf';
		public static const JELL_RTRI:String = 'jelly_rtri';
		public static const JELL_HFRTRI_1:String = 'jelly_hfrtri1';
		public static const JELL_HFRTRI_2:String = 'jelly_hfrtri2';
		public static const JELL_HFRTRI_3:String = 'jelly_hfrtri3';
		public static const JELL_HFRTRI_4:String = 'jelly_hfrtri4';
		public static const JELL_ISOTRI:String = 'jelly_isotri';
		public static const JELL_HFISOTRI:String = 'jelly_hfisotri';
		public static const RADIO_STATION:String = 'radiostation';
		public static const SIGNAL_RELAY:String = 'srelay_sq';
		public static const PUSH_BTN:String = 'pushbtn';
		public static const PUSH_BTN2:String = 'pushbtn_2';
		public static const PUSH_BTN3:String = 'pushbtn3';
		public static const GATE_A:String = 'gate_A';
		public static const GATE_B:String = 'gate_B';
		public static const GATE_C:String = 'gate3_A';
		public static const GATE_D:String = 'gate3_B';
		public static const GATE_E:String = 'gate2_A';
		public static const GATE_F:String = 'gate2_B';
		public static const CONVEYORBELT:String = 'conveyorbelt';
		public static const SPINFLAPS:String = 'spinner';
		public static const SPINFLAPS_BLU:String = 'spinner_blu';
		public static const SPINFLAPS_RED:String = 'spinner_red';
		public static const SPINFLAPS_YEL:String = 'spinner_yel';
		public static const FLOORBLOWER:String = 'floorblower';
		public static const FLOORBLOWER2:String = 'floorblower2';
		public static const PORTAL:String = 'portal';
		public static const GLASS:String = 'glass';
		public static const GLASSWOOD:String = 'glass_wood';
		public static const GLASSRUBBER:String = 'glass_rubber';
		public static const GLASSWALL:String = 'glass_wall';
		public static const BOMB:String = 'bomb';
		
		public static const FLOOR_NORMAL:String = 'floor_normal';
		public static const FLOOR_WATER:String = 'floor_water';
		public static const FLOOR_SAND:String = 'floor_sand';
		public static const FLOOR_CARPET:String = 'floor_carpet';
		
		//public static const :String = '';
		
		
		public static const TILE_INDEPENDENTS:Array = [
				GOLFBALL, HOLE, PORTAL, PUNCHER2_SQ, PPUNCHER_SQ, PUNCHER_SQ, PUNCHER_RTRI, SIGNAL_RELAY, GATE_A, GATE_B, GATE_C, GATE_D, GATE_E, GATE_F,
				PUSH_BTN, PUSH_BTN2, PUSH_BTN3, CONVEYORBELT, SPINFLAPS, SPINFLAPS_BLU, SPINFLAPS_RED, SPINFLAPS_YEL, GLASS, GLASSWOOD, GLASSRUBBER, GLASSWALL,
				BOMB, JELL_SQ, JELL_HF, JELL_RTRI, JELL_HFRTRI_1, JELL_HFRTRI_2, JELL_HFRTRI_3, JELL_HFRTRI_4, JELL_ISOTRI, JELL_HFISOTRI
			];
		
		public static const TILE_ALL:Vector.<Array> = Vector.<Array>([ [GOLFBALL, HOLE, FLOOR_NORMAL, FLOOR_CARPET, FLOOR_WATER, FLOOR_SAND],
				[WALL_SQ, WALL_HF, WALL_RTRI, WALL_HFRTRI_1, WALL_HFRTRI_2, WALL_HFRTRI_3, WALL_HFRTRI_4, WALL_ISOTRI, WALL_HFISOTRI],
				[WPAD_SQ, WPAD_HF, WPAD_RTRI, WPAD_HFRTRI_1, WPAD_HFRTRI_2, WPAD_HFRTRI_3, WPAD_HFRTRI_4, WPAD_ISOTRI, WPAD_HFISOTRI],
				[WRUB_SQ, WRUB_HF, WRUB_RTRI, WRUB_HFRTRI_1, WRUB_HFRTRI_2, WRUB_HFRTRI_3, WRUB_HFRTRI_4, WRUB_ISOTRI, WRUB_HFISOTRI],
				[WOOD_SQ, WOOD_HF, WOOD_RTRI, WOOD_ISOTRI, WOOD_HFISOTRI, WOOD_HFRTRI_1, WOOD_HFRTRI_2, WOOD_HFRTRI_3, WOOD_HFRTRI_4],
				[RUB_SQ, RUB_HF, RUB_RTRI, RUB_ISOTRI, RUB_HFISOTRI, RUB_HFRTRI_1, RUB_HFRTRI_2, RUB_HFRTRI_3, RUB_HFRTRI_4],
				[JELL_SQ, JELL_HF, JELL_RTRI, JELL_ISOTRI, JELL_HFISOTRI, JELL_HFRTRI_1, JELL_HFRTRI_2, JELL_HFRTRI_3, JELL_HFRTRI_4],
				[BOMB, SIGNAL_RELAY, SPINFLAPS, SPINFLAPS_BLU, SPINFLAPS_RED, SPINFLAPS_YEL],
				[PUSH_BTN, PUSH_BTN2, PUSH_BTN3, GATE_A, GATE_B, GLASS, GLASSWOOD, GLASSRUBBER, GLASSWALL],
				[PUNCHER2_SQ, PPUNCHER_SQ, GATE_C, GATE_D, GATE_E, GATE_F, FLOORBLOWER, PORTAL]
			]);
		
		public static const TILE_NONROTATES:Array = [GOLFBALL, HOLE, PORTAL, WOOD_SQ, WALL_SQ, WPAD_SQ, WRUB_SQ, RUB_SQ, JELL_SQ, SIGNAL_RELAY, GLASS, GLASSWOOD, GLASSRUBBER, GLASSWALL, BOMB];
		
		public static const TILE_STATICMATS:Array = ['wall', 'wpad', 'spring', 'hole', FLOORBLOWER];
		
		public static const TILE_WALLS:Array = [
			WALL_SQ, WALL_HF, WALL_RTRI, WALL_HFRTRI_1, WALL_HFRTRI_2, WALL_HFRTRI_3, WALL_HFRTRI_4, WALL_ISOTRI, WALL_HFISOTRI,
			WPAD_SQ, WPAD_HF, WPAD_RTRI, WPAD_HFRTRI_1, WPAD_HFRTRI_2, WPAD_HFRTRI_3, WPAD_HFRTRI_4, WPAD_ISOTRI, WPAD_HFISOTRI,
			WRUB_SQ, WRUB_HF, WRUB_RTRI, WRUB_HFRTRI_1, WRUB_HFRTRI_2, WRUB_HFRTRI_3, WRUB_HFRTRI_4, WRUB_ISOTRI, WRUB_HFISOTRI];
		
		public static const TILE_TOOLKITS:Array = [GOLFBALL, PPUNCHER_SQ,
				WOOD_SQ, WOOD_HF, WOOD_RTRI, WOOD_HFRTRI_1, WOOD_HFRTRI_2, WOOD_ISOTRI, WOOD_HFISOTRI,
				RUB_SQ, RUB_HF, RUB_RTRI, RUB_HFRTRI_1, RUB_HFRTRI_2, RUB_ISOTRI, RUB_HFISOTRI,
				JELL_SQ, JELL_HF, JELL_RTRI, JELL_HFRTRI_1, JELL_HFRTRI_2, JELL_ISOTRI, JELL_HFISOTRI
			];
		
		
		
		public static function getTileCode( type:String ):uint
		{
			if ( ! _tileCodes.length ) {
				_tileCodes[1] = WALL_SQ;
				_tileCodes[2] = WALL_HF;
				_tileCodes[3] = WALL_RTRI;
				_tileCodes[4] = WALL_HFRTRI_1;
				_tileCodes[5] = WALL_HFRTRI_2;
				_tileCodes[6] = WALL_HFRTRI_3;
				_tileCodes[7] = WALL_HFRTRI_4;
				_tileCodes[8] = WALL_ISOTRI;
				_tileCodes[9] = WALL_HFISOTRI;
				_tileCodes[11] = WRUB_SQ;
				_tileCodes[12] = WRUB_HF;
				_tileCodes[13] = WRUB_RTRI;
				_tileCodes[14] = WRUB_HFRTRI_1;
				_tileCodes[15] = WRUB_HFRTRI_2;
				_tileCodes[16] = WRUB_HFRTRI_3;
				_tileCodes[17] = WRUB_HFRTRI_4;
				_tileCodes[18] = WRUB_ISOTRI;
				_tileCodes[19] = WRUB_HFISOTRI;
				_tileCodes[21] = WPAD_SQ;
				_tileCodes[22] = WPAD_HF;
				_tileCodes[23] = WPAD_RTRI;
				_tileCodes[24] = WPAD_HFRTRI_1;
				_tileCodes[25] = WPAD_HFRTRI_2;
				_tileCodes[26] = WPAD_HFRTRI_3;
				_tileCodes[27] = WPAD_HFRTRI_4;
				_tileCodes[28] = WPAD_ISOTRI;
				_tileCodes[29] = WPAD_HFISOTRI;
				_tileCodes[31] = RUB_SQ;
				_tileCodes[32] = RUB_HF;
				_tileCodes[33] = RUB_RTRI;
				_tileCodes[34] = RUB_HFRTRI_1;
				_tileCodes[35] = RUB_HFRTRI_2;
				_tileCodes[36] = RUB_HFRTRI_3;
				_tileCodes[37] = RUB_HFRTRI_4;
				_tileCodes[38] = RUB_ISOTRI;
				_tileCodes[39] = RUB_HFISOTRI;
				_tileCodes[41] = WOOD_SQ;
				_tileCodes[42] = WOOD_HF;
				_tileCodes[43] = WOOD_RTRI;
				_tileCodes[44] = WOOD_HFRTRI_1;
				_tileCodes[45] = WOOD_HFRTRI_2;
				_tileCodes[46] = WOOD_HFRTRI_3;
				_tileCodes[47] = WOOD_HFRTRI_4;
				_tileCodes[48] = WOOD_ISOTRI;
				_tileCodes[49] = WOOD_HFISOTRI;
				_tileCodes[51] = JELL_SQ;
				_tileCodes[52] = JELL_HF;
				_tileCodes[53] = JELL_RTRI;
				_tileCodes[54] = JELL_HFRTRI_1;
				_tileCodes[55] = JELL_HFRTRI_2;
				_tileCodes[56] = JELL_HFRTRI_3;
				_tileCodes[57] = JELL_HFRTRI_4;
				_tileCodes[58] = JELL_ISOTRI;
				_tileCodes[59] = JELL_HFISOTRI;
				_tileCodes[200] = GOLFBALL;
				_tileCodes[201] = SPRING_SQ;
				_tileCodes[201] = HOLE;
				_tileCodes[211] = SPRING_SQ;
				_tileCodes[212] = SPRING_RTRI;
				_tileCodes[213] = PUNCHER_SQ;
				_tileCodes[214] = PUNCHER_RTRI;
				_tileCodes[215] = PUNCHER2_SQ;
				_tileCodes[216] = PPUNCHER_SQ;
				_tileCodes[217] = GATE_E;
				_tileCodes[218] = GATE_F;
				_tileCodes[219] = GATE_C;
				_tileCodes[220] = GATE_D;
				_tileCodes[221] = GATE_A;
				_tileCodes[222] = GATE_B;
				_tileCodes[223] = PUSH_BTN;
				_tileCodes[224] = PUSH_BTN2;
				_tileCodes[225] = PUSH_BTN3;
				_tileCodes[226] = SIGNAL_RELAY;
				_tileCodes[227] = CONVEYORBELT;
				_tileCodes[228] = SPINFLAPS;
				_tileCodes[229] = SPINFLAPS_BLU;
				_tileCodes[230] = SPINFLAPS_RED;
				_tileCodes[231] = SPINFLAPS_YEL;
				_tileCodes[232] = GLASS;
				_tileCodes[233] = FLOORBLOWER;
				_tileCodes[234] = FLOORBLOWER2;
				_tileCodes[235] = PORTAL;
				_tileCodes[236] = GLASSWOOD;
				_tileCodes[237] = GLASSRUBBER;
				_tileCodes[238] = GLASSWALL;
				_tileCodes[239] = BOMB;
				_tileCodes[255] = GOLFBALL; // primary golfball
			}
			
			var p:int = _tileCodes.indexOf( type );
			if ( p > 0 )
				return p;
			
			return 0;
		}
		
		public static function getTileType( code:int ):String
		{
			if ( ! _tileCodes.length )
				getTileCode('');
			
			return _tileCodes[ code ];
		}
		
		
		public static function getb2Shape( shapeName:String, smaller:uint = 0 ):b2Shape
		{
			if ( _shapes[shapeName+smaller] == undefined )
				_shapes[shapeName+smaller] = _buildShape( shapeName, smaller );
			
			return _shapes[shapeName+smaller];
		}
		
		public static function getb2Circle( radius:Number ):b2Shape
		{
			if ( _shapes['circ'+radius] == undefined )
				_shapes['circ'+radius] = new b2CircleShape( radius /Registry.b2Scale );
			
			return _shapes['circ'+radius];
		}
		
		
			// -- private --
			
			private static const _tileCodes:Array = []
			private static const _shapes:Object = {}
			
			private static function _buildShape( shapeName:String, smaller:uint = 0 ):b2Shape
			{
				var c:Number = (Registry.tileSize -smaller) / Registry.b2Scale, c2:Number = c / 2;
				
				switch( shapeName ) {
					case 'sq':
						return b2PolygonShape.AsBox( c2, c2 ); break;
					case 'hf': // half square on left side
						return b2PolygonShape.AsOrientedBox( c2, c2/2, new b2Vec2(0, c2 / 2) ); break;
					case 'rtri':
						return b2PolygonShape.AsArray([
							new b2Vec2( c2, -c2 ),
							new b2Vec2( c2, c2 ),
							new b2Vec2( -c2, c2 )
						], 3); break;
					case 'qrtri':
						return b2PolygonShape.AsArray([
							new b2Vec2( -c2, 0 ),
							new b2Vec2( 0, c2 ),
							new b2Vec2( -c2, c2 )
						], 3); break;
					case 'hfrtri1':
						return b2PolygonShape.AsArray([
							new b2Vec2( c2, 0 ),
							new b2Vec2( c2, c2 ),
							new b2Vec2( -c2, c2 )
						], 3); break;
					case 'hfrtri2':
						return b2PolygonShape.AsArray([
							new b2Vec2( -c2, 0 ),
							new b2Vec2( c2, c2 ),
							new b2Vec2( -c2, c2 )
						], 3); break;
					case 'hfrtri3':
						return b2PolygonShape.AsArray([
							new b2Vec2( c2, -c2 ),
							new b2Vec2( c2, c2 ),
							new b2Vec2( -c2, c2 ),
							new b2Vec2( -c2, 0 )
						], 4); break;
					case 'hfrtri4':
						return b2PolygonShape.AsArray([
							new b2Vec2( c2, 0 ),
							new b2Vec2( c2, c2 ),
							new b2Vec2( -c2, c2 ),
							new b2Vec2( -c2, -c2 )
						], 4); break;
					case 'isotri':
						return b2PolygonShape.AsArray([
							new b2Vec2( 0, -c2 ),
							new b2Vec2( c2, c2 ),
							new b2Vec2( -c2, c2 )
						], 3); break;
					case 'hfisotri': // half height
						return b2PolygonShape.AsArray([
							new b2Vec2( 0, 0 ),
							new b2Vec2( c2, c2 ),
							new b2Vec2( -c2, c2 )
						], 3); break;
					// irregular polygon
					case 'qcave': // quarter concave
						return b2PolygonShape.AsArray([
							new b2Vec2( -c2 *2/3, c2 ),
							new b2Vec2( 0, c2 *11/15 ),
							new b2Vec2( c2 *6.5/15, c2 *6.5/16 ),
							new b2Vec2( c2 *11/15, 0 ),
							new b2Vec2( c2, -c2 *2/3 ),
							new b2Vec2( c2, c2 )
						], 6); break;
					case 'qcvex': // quarter convex
						return b2PolygonShape.AsArray([
							new b2Vec2( -c2, -c2 ),
							new b2Vec2( c2, -c2 ),
							new b2Vec2( c2, -c2 *2/3 ),
							new b2Vec2( c2 *11/15, 0 ),
							new b2Vec2( c2 *6.5/15, c2 *6.5/16 ),
							new b2Vec2( 0, c2 *11/15 ),
							new b2Vec2( -c2 *2/3, c2 ),
							new b2Vec2( -c2, c2 )
						], 8); break;
					default:
						throw new Error("[pb2.game.Tile] '" + shapeName +"' is not a valid/registered shape name"); break;
				}
				return null;
			}
			
			
	}

}