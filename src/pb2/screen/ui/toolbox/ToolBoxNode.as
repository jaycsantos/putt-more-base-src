package pb2.screen.ui.toolbox 
{
	import com.jaycsantos.IDisposable;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import pb2.game.entity.b2.b2EntityTileTool;
	import pb2.game.Session;
	import pb2.game.Tile;
	import pb2.screen.ui.UIFactory;
	import pb2.util.pb2internal;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class ToolBoxNode extends Sprite implements IDisposable
	{
		public static const MAX:uint = 7;
		
		public function ToolBoxNode( type:String=null, count:uint=0 )
		{
			addChild( PuttBase2.assets.createDisplayObject('screen.ui.toolbox.node') );
			addChild( _tile = new Sprite );
			addChild( _txf = UIFactory.createFixedTextField('x0','toolboxnode','right') );
			
			_txf.visible = false;
			_txf.x = 13.5;
			_txf.y = 13.5;
			_txf.filters = [new GlowFilter(0, 1, 2, 2, 5)];
			
			//cacheAsBitmap = true;
			buttonMode = true; mouseChildren = tabChildren = tabEnabled = false;
			
			Set( type, count );
		}
		
		public function dispose():void
		{
			_released.splice( 0, _released.length );
		}
		
		
		public function get stockCount():uint
		{
			return _total -_released.length;
		}
		
		public function get total():uint
		{
			return _total;
		}
		
		public function get type():String
		{
			return _type;
		}
		
		
		public function Set( type:String, count:uint ):Boolean
		{
			if ( _type==null && Tile.TILE_TOOLKITS.indexOf(type)>-1 ) {
				_type = type;
				_total = Math.min(count, MAX);
				_txf.visible = true;
				_updateCount();
				
				var clip:Sprite
				if ( _tile.numChildren )
					_tile.removeChildAt(0);
				_tile.addChild( clip = PuttBase2.assets.createDisplayObject('entity.block.'+ type) as Sprite );
				clip.scaleX = clip.scaleY = .75;
				clip.x = 13.5 +.5;
				clip.y = 13.5 +1.5;
				
				if ( clip is MovieClip ) MovieClip(clip).stop();
				if ( type=='golfball' ) MovieClip(clip).gotoAndStop( 6 );
				var i:int = clip.numChildren
				while ( i-- )
					if ( clip.getChildAt(i) is MovieClip ) MovieClip( clip.getChildAt(i) ).stop();
				return true;
			}
			return false;
		}
		
		pb2internal function plusOne():Boolean
		{
			if ( _total < MAX ) {
				_total++;
				_updateCount();
				trace('toolbox node('+ _type +'): +1, total='+ _total );
				
				return true;
			}
			return false;
		}
		
		pb2internal function minusOne():Boolean
		{
			if ( _total > 0 && _total > _released.length ) {
				_total--;
				_updateCount();
				trace('toolbox node('+ _type +'): -1, total='+ _total );
				
				return true;
			}
			return false;
		}
		
		pb2internal function plus( tile:b2EntityTileTool ):Boolean
		{
			if ( tile.type == _type && _total < MAX ) {
				tile.isToolkit = true;
				_released.push( tile );
				//tile.onDispose.add( store );
				
				_total++;
				_updateCount();
				if ( !stockCount ) _tile.visible = _txf.visible = false;
				
				trace('toolbox node('+ _type +'): +1('+ tile.id +'), total='+ _total );
				return true;
			}
			return false;
		}
		
		pb2internal function minus( tile:b2EntityTileTool ):Boolean
		{
			var p:int = _released.indexOf( tile );
			if ( tile.type == _type && _total > 0 && p > -1 ) {
				tile.isToolkit = false;
				_released.splice( p, 1 );
				//tile.onDispose.remove( store );
				
				_total--;
				_updateCount();
				if ( !stockCount ) _tile.visible = _txf.visible = false;
				
				trace('toolbox node('+ _type +'): -1('+ tile.id +'), total='+ _total );
				return true;
			}
			return false;
		}
		
		
		public function release():b2EntityTileTool
		{
			if ( _total > _released.length ) {
				var ent:b2EntityTileTool = Session.factory.spawnEntity( _type ) as b2EntityTileTool;
				ent.isToolkit = true;
				_released.push( ent );
				
				_updateCount();
				if ( !stockCount ) {
					_tile.visible = _txf.visible = false;
					//_tile.visible = _txf.visible = false;
				}
				
				//ent.onDispose.add( store );
				
				trace('toolbox node('+ _type +'): released('+ ent.id +'), stock='+ stockCount );
				return ent;
			}
			
			return null;
		}
		
		public function store( tile:b2EntityTileTool ):Boolean
		{
			var p:int = _released.indexOf( tile );
			if ( _type == tile.type && p > -1 ) {
				_released.splice( p, 1 );
				
				_updateCount();
				_tile.visible = _txf.visible = true;
				
				trace('toolbox node('+ _type +'): stored('+ tile.id +'), stock='+ stockCount );
				return true;
			}
			return false;
		}
		
		
			// -- private --
			
			protected var _type:String
			protected var _total:uint, _released:Vector.<b2EntityTileTool> = new Vector.<b2EntityTileTool>
			protected var _tile:Sprite
			protected var _txf:TextField
			
			protected function _updateCount():void
			{
				_txf.htmlText = 'x'+ (_total -_released.length);
			}
			
			
			pb2internal function getReleasedTiles():Vector.<b2EntityTileTool>
			{
				return _released;
			}
			
			
	}

}