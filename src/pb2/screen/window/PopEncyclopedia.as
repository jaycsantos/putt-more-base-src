package pb2.screen.window 
{
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.util.ColorMatrixUtil;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.*;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import pb2.game.ctrl.*;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.entity.tile.FloorTexture;
	import pb2.game.*;
	import pb2.screen.ui.HudGame;
	import pb2.screen.ui.SmallBtn1;
	import pb2.screen.ui.toolbox.ToolBoxNode;
	import pb2.screen.ui.UIFactory;
	import pb2.util.UIkit;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PopEncyclopedia extends PopWindow 
	{
		private static const _frameName:Array = ['golfball', 'hole', 'sand', 'water', 'carpet', 'wall', 'wpad', 'wrub', 'wood', 'jelly', 'rubber', 'bomb', 'puncher2', 'ppuncher', 'spinner', 'floorblower', 'pushbtn', 'pushbtn3', 'srelay', 'gate', 'gate2', 'gate3', 'portal', 'glass', null, null, null, null];
		private static var _openType:String
		
		public static function scanNewTile():String
		{
			var toolbox:Vector.<ToolBoxNode> = HudGame.instance.unReleasedItems;
			var tileMap:Vector.<Vector.<b2EntityTile>> = Session.instance.tileMap;
			var tile:b2EntityTile, floor:FloorTexture = Session.instance.floor;
			var cols:int = tileMap.length, rows:int = tileMap[0].length;
			
			var m:int, k:String = SaveDataMngr.instance.getCustom('encyclopedia');
			var xml:XML = XML( k ? k : <list><golfball/><hole/><wall/></list> );
			var value:String
			
			for each ( var tool:ToolBoxNode in toolbox ) {
				k = tool.type.indexOf('_')>-1 ? tool.type.substr( 0, tool.type.indexOf('_') ) : tool.type;
				
				if ( !xml.child(k).length() ) {
					xml.appendChild( XML('<'+ k +'/>') );
					if ( !value) value = tool.type;
				}
			}
			
			var showGlass:Boolean = Session.instance.map.levelIndex == LevelSelect.PERPAGE-1;
			
			for ( var j:int=0; j<rows; j++ )
				for ( var i:int=0; i<cols; i++ ) {
					if ( (m = floor.getTexture(i, j)) && !xml.child(k = FloorTexture.TYPE_STRING[m]).length() ) {
						xml.appendChild( XML('<'+ k +'/>') );
						if ( !value) value = 'floor_'+ k;
					}
					if ( (tile = tileMap[i][j]) && !xml.child(k = tile.materialName).length() ) {
						
						if ( k == 'glass' && !showGlass ) continue;
						
						xml.appendChild( XML('<'+ k +'/>') );
						if ( !value) value = tile.type;
					}
				}
			
			SaveDataMngr.instance.saveCustom('encyclopedia', xml.toXMLString(), true );
			return _openType = value;
		}
		
		
		public function PopEncyclopedia( parentClass:Class ) 
		{
			super();
			
			var g:Graphics, mc:MovieClip, sp:Sprite, sp2:Sprite, shp:Shape, txf:TextField, i:int, j:int, k:String, a:Array;
			
			{//-- bg
				_bgClip.addChild( txf = UIFactory.createTextField('PUTT <b>PEDIA</b>', 'lvlsHeader', 'center', PuttBase2.STAGE_WIDTH/2, 25 ) );
				
				_overlay.graphics.clear();
				_overlay.graphics.beginFill( 0, .95 );
				_overlay.graphics.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			}
			
			{//-- contents
				k = SaveDataMngr.instance.getCustom('encyclopedia');
				_xml = XML( k ? k : <list><golfball/><hole/><wall/></list> );
				
				a = ColorMatrixUtil.setContrast(-50).matrix;
				a.concat( ColorMatrixUtil.setBrightness(100).matrix );
				a.concat( ColorMatrixUtil.setSaturation(-50).matrix );
				_filter = new ColorMatrixFilter( a );//new DropShadowFilter( 2, 45, 0, .3, 4, 4, 1 );
				
				_contents.addChild( _clipNodes = new Sprite );
				for ( i=0; i<22; i++ ) {
					_clipNodes.addChild( mc = PuttBase2.assets.createDisplayObject('screen.tutorial.pedia.icons') as MovieClip );
					mc.mouseChildren = false;
					mc.name = _frameName[i];
					mc.x = 100 +(i%5)*60;
					mc.y = 80 +(i/5>>0)*50;
					mc.filters = [_filter];
					
					if ( _xml.child(_frameName[i]).length() ) {
						if ( !String(_xml.child(_frameName[i])[0].@v).length ) {
							_clipNodes.addChild( sp = PuttBase2.assets.createDisplayObject('screen.tutorial.pedia.icoNew') as Sprite );
							sp.name = 'risk_'+ _frameName[i];
							sp.x = mc.x; sp.y = mc.y;
							sp.mouseEnabled = false;
							sp.filters = [new GlowFilter( 0xFF9900, 1, 8, 8, 1 )];
						}
						mc.gotoAndStop( i+1 );
						mc.buttonMode = true;
						
					} else {
						mc.gotoAndStop( 30 );
						mc.mouseEnabled = false;
					}
				}
				
				_contents.addChild( _clipDisplay = PuttBase2.assets.createDisplayObject('screen.tutorial.pedia.blocks') as MovieClip );
				_clipDisplay.gotoAndStop( 26 );
				_clipDisplay.x = 410; _clipDisplay.y = 80;
				
				_contents.addChild( _btnClose2 = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnClose') as SimpleButton );
				_btnClose2.x = 575; _btnClose2.y = 15;
			}
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.windows.popEncyclopedia') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 7, 1), 1, false, _showContents );
				_animator.addSequenceSet( END, MathUtils.intRangeA(7, 15, 1), 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
			}
			
			
			_contents.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
			_contents.addEventListener( MouseEvent.MOUSE_OVER, _movr, false, 0, true );
			_contents.addEventListener( MouseEvent.MOUSE_OUT, _mout, false, 0, true );
			
			if ( parentClass == HudGame ) {
				onPreShow.addOnce( Session.instance.stop );
				onPreShow.addOnce( CameraFocusCtrl.instance.disable );
				onHidden.addOnce( Session.instance.start );
				onHidden.addOnce( CameraFocusCtrl.instance.enable );
			}
		}
		
		override public function dispose():void 
		{
			_contents.removeEventListener( MouseEvent.CLICK, _click );
			_contents.removeEventListener( MouseEvent.MOUSE_OVER, _movr );
			_contents.removeEventListener( MouseEvent.MOUSE_OUT, _mout );
			
			_clipDisplay = null;
			_btnClose2 = null;
			
			super.dispose();
		}
		
		
		public function open( type:String ):void
		{
			var mc:MovieClip, mc2:MovieClip, sp:Sprite;
			if ( _frameName[_clipDisplay.currentFrame-1] == type ) return;
			
			mc = _clipNodes.getChildByName( type ) as MovieClip;
			if ( mc ) {
				if ( _clipDisplay.currentFrame < 25 ) {
					mc2 = _clipNodes.getChildByName( _frameName[_clipDisplay.currentFrame-1] ) as MovieClip;
					if ( mc2 ) mc2.filters = [_filter];
				}
				
				_clipDisplay.gotoAndStop( mc.currentFrame );
				mc.filters = [];
				
				sp = _clipNodes.getChildByName('risk_' + type) as Sprite;
				if ( sp ) {
					_clipNodes.removeChild( sp );
					_xml.child( type )[0].@v = '1';
					SaveDataMngr.instance.saveCustom('encyclopedia', _xml.toXMLString(), true );
				}
			}
			
			_openType = type;
		}
		
		
		
			// -- private --
			
			private var _clipNodes:Sprite, _clipDisplay:MovieClip,  _btnClose2:SimpleButton, _xml:XML, _filter:BitmapFilter
			
			
			private function _click( e:MouseEvent ):void
			{
				switch( e.target ) {
					case _btnClose2:
						hide();
						break;
					default:
						if ( DisplayObject(e.target).parent == _clipNodes )
							open( DisplayObject(e.target).name );
				}
			}
			
			private function _movr( e:MouseEvent ):void
			{
				if ( DisplayObject(e.target).parent == _clipNodes )
					DisplayObject(e.target).filters = [];
			}
			
			private function _mout( e:MouseEvent ):void
			{
				if ( DisplayObject(e.target).parent == _clipNodes && MovieClip(e.target).currentFrame != _clipDisplay.currentFrame )
					DisplayObject(e.target).filters = [ _filter ];
			}
			
			
	}

}