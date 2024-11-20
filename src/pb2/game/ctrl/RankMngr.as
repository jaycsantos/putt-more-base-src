package pb2.game.ctrl 
{
	import mx.formatters.DateFormatter;
	import pb2.game.MapData;
	import pb2.game.Session;
	import pb2.util.CustomLevel;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class RankMngr 
	{
		public static const i:RankMngr = new RankMngr
		public static const GROUP_0_BOARD_ID:uint = GamerSafeConstants.SCOREBOARD_AMATEUR_LEADERS
		public static const GROUP_1_BOARD_ID:uint = GamerSafeConstants.SCOREBOARD_PROFESSIONAL_LEADERS
		public static const TIME_WEEK:String = 'week';
		public static const TIME_MONTH:String = 'month';
		public static const TIME_ALL:String = 'all';
		
		public var lastScoresId:uint, lastScoresObj:Object
		public var lastScoreGroup:uint, lastScoreGroupObj:Object
		public var lastCustomId:String, lastCustomRanks:Vector.<Array>
		
		public function RankMngr() 
		{
			if ( i ) throw new Error('[pb2.game.ctrl.RankMngr] Singleton class, use static property i');
			
			_grp_rank = new Vector.<Array>();
			_grp_rank.push( [0, 0, 0], [0, 0, 0] );
		}
		
		
		public function parseLevelRank( data:Object ):void
		{
			var a:Array, i:int, len:int;
			var name:String = SaveDataMngr.instance.getCustom('highscore_name');
			var map:MapData = Session.instance.map;
			if ( map.isCustom ) return;
			
			var xmlSave:XML = SaveDataMngr.instance.getLevelData( map.name, map.hash );
			var bestScore:uint = uint( xmlSave.@score );
			var extra:String = xmlSave.@extra;
			var timestamp:String;
			
			_lvl_wk = _lvl_mo = _lvl_all = null;
			
			
			len = (a = data.weekly).length;
			if ( len && bestScore <= a[len - 1].score ) {
				i = a[ len-1 ].score;
				i = Math.round( (i-bestScore)/i *1000 ) +len +1;
				_lvl_wk = [ i+1 ];
				_lvl_wk.push( a[0].username, a[0].score );
				_lvl_wk.push( a[1].username, a[1].score );
				
			} else {
				for ( i = 0; i < len; i++ )
					if ( a[i].score == bestScore && a[i].username==name && a[i].extra==extra ) {
						_lvl_wk = [i+1];
						timestamp = a[i].ts;
						
						if ( i > 0 ) _lvl_wk.push( a[0].username, a[0].score );
						if ( i > 1 ) _lvl_wk.push( a[1].username, a[1].score );
						if ( i < 1 ) {
							if ( len > 1 ) _lvl_wk.push( a[1].username, a[1].score );
							if ( len > 2 ) _lvl_wk.push( a[2].username, a[2].score );
						}
						break;
					}
			}
			
			len = (a = data.monthly).length;
			if ( len && bestScore <= a[len -1].score ) {
				i = a[ len-1 ].score;
				i = Math.round( (i-bestScore)/i *1000 ) +len +1;
				_lvl_mo = [ i+1 ];
				_lvl_mo.push( a[0].username, a[0].score );
				_lvl_mo.push( a[1].username, a[1].score );
				
			} else {
				for ( i = 0; i < len; i++ )
					if ( a[i].score == bestScore && a[i].username==name && a[i].extra==extra ) {
						_lvl_mo = [i+1];
						timestamp = a[i].ts;
						
						if ( i > 0 ) _lvl_mo.push( a[0].username, a[0].score );
						if ( i > 1 ) _lvl_mo.push( a[1].username, a[1].score );
						if ( i < 1 ) {
							if ( len > 1 ) _lvl_mo.push( a[1].username, a[1].score );
							if ( len > 2 ) _lvl_mo.push( a[2].username, a[2].score );
						}
						break;
					}
			}
			
			len = (a = data.all).length;
			if ( len && bestScore <= a[len -1].score ) {
				i = a[ len-1 ].score;
				i = Math.round( (i-bestScore)/i *1000 ) +len +1;
				_lvl_all = [ i+1 ];
				_lvl_all.push( a[0].username, a[0].score );
				_lvl_all.push( a[1].username, a[1].score );
				
			} else {
				for ( i = 0; i < len; i++ )
					if ( a[i].score == bestScore && a[i].username==name && a[i].extra==extra ) {
						_lvl_all = [i+1];
						timestamp = a[i].ts;
						
						if ( i > 0 ) _lvl_all.push( a[0].username, a[0].score );
						if ( i > 1 ) _lvl_all.push( a[1].username, a[1].score );
						if ( i < 1 ) {
							if ( len > 1 ) _lvl_all.push( a[1].username, a[1].score );
							if ( len > 2 ) _lvl_all.push( a[2].username, a[2].score );
						}
						break;
					}
			}
			
			
			if ( !map.isCustom ) {
				if ( timestamp ) _lvl_date = CustomLevel.phpDateToAs3Date( timestamp, '-0400' ).toUTCString();
				else _lvl_date = new Date().toUTCString();
				
				SaveDataMngr.instance.saveLevelRank( map.hash, _lvl_date, _lvl_wk, _lvl_mo, _lvl_all );
			}
			
		}
		
		public function parseGroupRank( data:Object, sett:uint ):void
		{
			var a:Array, i:int, len:int;
			var name:String = SaveDataMngr.instance.getCustom('highscore_name');
			var map:MapData = Session.instance.map;
			
			var rankExtra:String = SaveDataMngr.instance.getCustom('rankExtra_grp'+sett);
			var xml:XML = SaveDataMngr.instance.getGroupTotalData( sett );
			var bestScore:uint = uint( xml.@score );
			var rank:Array = _grp_rank[ sett ];
			
			len = (a = data.weekly).length;
			if ( len && bestScore <= a[len - 1].score ) {
				i = a[ len-1 ].score;
				rank[0] = Math.round( (i-bestScore)/i *1000 ) +len +1;
				
			} else {
				for ( i = 0; i < len; i++ )
					if ( a[i].score == bestScore && a[i].username==name && a[i].extra==rankExtra ) {
						rank[0] = i+1;
						break;
					}
			}
			
			len = (a = data.monthly).length;
			if ( len && bestScore <= a[len - 1].score ) {
				i = a[ len-1 ].score;
				rank[1] = Math.round( (i-bestScore)/i *1000 ) +len +1 +1;
				
			} else {
				for ( i = 0; i < len; i++ )
					if ( a[i].score == bestScore && a[i].username==name && a[i].extra==rankExtra ) {
						rank[1] = i+1;
						break;
					}
			}
			
			len = (a = data.all).length;
			if ( len && bestScore <= a[len - 1].score ) {
				i = a[ len-1 ].score;
				rank[2] = Math.round( (i-bestScore)/i *1000 ) +len +1 +1;
				
			} else {
				for ( i = 0; i < len; i++ )
					if ( a[i].score == bestScore && a[i].username==name && a[i].extra==rankExtra ) {
						rank[2] = i+1;
						break;
					}
			}
			
			if ( !rank[2] ) SaveDataMngr.instance.saveCustom( 'pendScore_grp'+ sett, 1, true );
		}
		
		public function parseCustomRank():void
		{
			var map:MapData = Session.instance.map;
			if ( !map.isCustom ) return;
			var data:Object = map.customLevel.origData;
			
			// array format [score, name, extra, date]
			var i:int, j:int, p:int, a1:Array, a2:Array, list:Vector.<Array> = new Vector.<Array>;
			if ( data && data.hasOwnProperty('Attributes') )
				for ( i=0; i<3; i++ )
					if ( data.Attributes['score' + i] ) {
						a1 = String(data.Attributes['score'+i]).split(',');
						a1[0] = uint(a1[0]);
						a1[3] = uint(a1[3]);
						
						p = list.length;
						for ( j=0; j<list.length; j++ )
							if ( a1[0] > list[j][0] || (a1[0] == list[j][0] && a1[3] < list[j][3]) ) {
								p = j; break;
							}
						list.splice( p, 0, a1 );
					}
			
			lastCustomId = map.customLevel.id;
			lastCustomRanks = list;
		}
		
		public function getParsedLevelRank():Object
		{
			if ( ! _lvl_wk ) return null;
			return { week:_lvl_wk, month:_lvl_mo, all:_lvl_all };
		}
		
		public function getParsedGroupRank( sett:uint ):Object
		{
			if ( sett >= _grp_rank.length )
				return { week:null, month:null, all:null };
			
			return { week:_grp_rank[sett][0], month:_grp_rank[sett][1], all:_grp_rank[sett][2] };
		}
		
		
			// -- private --
			
			private var _lvl_date:String, _lvl_wk:Array, _lvl_mo:Array, _lvl_all:Array
			private var _grp_rank:Vector.<Array>
			
			
	}

}