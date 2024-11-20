package pb2.util 
{
	import flash.utils.ByteArray;
	import mx.formatters.DateFormatter;
	import Playtomic.PlayerLevel;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class CustomLevel 
	{
		public var name:String, id:String, author:String, data:String, par:int, item:int
		public var wins:uint, quits:uint, plays:uint, rating:uint, votes:uint
		public var RDate:String, bestScore:uint, bestName:String
		public var origData:Object
		
		public function CustomLevel( _id:String, _name:String, _author:String ) 
		{
			id = _id;
			name = _name;
			author = _author;
			data = '';
		}
		
		
		public static function createFromPlaytomic( d:PlayerLevel ):CustomLevel
		{
			var n:CustomLevel = new CustomLevel( d.LevelId, d.Name, d.PlayerName );
			n.data = d.Data;
			n.par = int(d.CustomData.par);
			n.item = int(d.CustomData.item);
			n.wins = d.Wins;
			n.quits = d.Quits;
			n.plays = d.Starts;
			n.RDate = d.RDate.replace(/\shour/g, 'hr').replace(/\sminute/g, 'min').replace(/\sago/g, '');
			n.bestScore = int(d.CustomData.bestscore);
			n.bestName = d.CustomData.bestname;
			n.rating = d.Rating *10 >>0;
			n.votes = d.Votes;
			n.origData = d;
			
			return n;
		}
		
		public static function createFromGamersafe( d:Object ):CustomLevel
		{
			var n:CustomLevel = new CustomLevel( d.ID, d.Attributes.name, d.Attributes.author );
			var ba:ByteArray = d.Data as ByteArray;
			n.data = ba.readObject() as String;
			n.par = d.Attributes.par;
			n.item = d.Attributes.item;
			n.wins = d.Attributes.wins;
			n.quits = d.Attributes.quits;
			n.plays = d.Attributes.plays;
			n.RDate = timeToRelative( phpDateToAs3Date(d.Modified, '-0400').toUTCString() );
			n.bestScore = d.Attributes.bestscore;
			n.bestName = d.Attributes.bestname;
			n.rating = d.AvgRating *10 >>0;
			n.votes = d.NumRatings;
			n.origData = d;
			
			return n;
		}
		
		
		public static function phpDateToAs3Date( timestamp:String, tz:String='' ):Date
		{
			return new Date( timestamp.substr(5,2) +'/'+ timestamp.substr(8,2) +'/'+ timestamp.substr(0,4) +' '+ timestamp.substring(11) +' GMT'+ tz );
		}
		
		public static function timeToRelative( timestamp:String ):String
		{
			//--Parse the timestamp as a Date object--
			var pastDate:Date = new Date( timestamp );
			//--Get the current data in the same format--
			var currentDate:Date = new Date();
			//--seconds inbetween the current date and the past date--
			var secondDiff:int = Math.max( (currentDate.getTime() - pastDate.getTime())/1000 >>0, 0 );
			
			var a:Array
			//--Return the relative equavalent time--
			switch ( true ) {
				/*case secondDiff < 60:
					return 'just now';//int(secondDiff) + ' seconds ago';
					break;
				case secondDiff < 120:
					return 'some min';
					break;*/
				case secondDiff < 1800:
				//case secondDiff < 3600:
					return 'just now';//int(secondDiff / 60) + ' mins';
					break;
				case secondDiff < 7200:
					return 'a while ago';//'some hr';
					break;
				case secondDiff < 86400:
					return int(secondDiff / 3600) +' hrs';
					break;
				case secondDiff < 172800:
					return 'yesterday';
					break;
				case secondDiff < 604800:
					return int(secondDiff / 86400) + ' days';
					break;
				case secondDiff < 1209600:
					return 'last week';
					break;
				case secondDiff < 2419200:
					return int(secondDiff / 604800) + ' wks';
					break;
				case currentDate.fullYear == pastDate.fullYear:
					/*var df:DateFormatter = new DateFormatter();
					df.formatString = 'D MMM';
					return df.format( pastDate );*/
					a = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sept','Oct','Nov','Dec'];
					return pastDate.day +' '+ a[pastDate.month];
					break;
				default:
					/*var df2:DateFormatter = new DateFormatter();
					df2.formatString = 'MMM YYYY';
					return df2.format( pastDate );*/
					a = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sept','Oct','Nov','Dec'];
					return a[pastDate.month] +' '+ pastDate.fullYear;
					break;
			}
		}
		
		
	}

}