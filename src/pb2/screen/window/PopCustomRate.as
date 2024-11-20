package pb2.screen.window 
{
	import com.jaycsantos.math.MathUtils;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.system.System;
	import flash.text.TextField;
	import pb2.game.ctrl.GamerSafeHelper;
	import pb2.game.ctrl.SaveDataMngr;
	import pb2.game.MapData;
	import pb2.game.Registry;
	import pb2.game.Session;
	import pb2.screen.ui.UIFactory;
	import Playtomic.PlayerLevels;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PopCustomRate extends PopWindow 
	{
		
		public function PopCustomRate() 
		{
			super();
			
			var g:Graphics, mc:MovieClip, sp:Sprite, sp2:Sprite, shp:Shape, txf:TextField, i:int, j:int, k:String, a:Array;
			var map:MapData = Session.instance.map;
			var xmlSave:XML = SaveDataMngr.instance.getPlayerLevelData( map.name, map.customLevel.id );
			
			{//-- bg
				//_bgClip.addChild( txf = UIFactory.createTextField('RATE & <b>SHARE</b>', 'header2', 'left', 10, 5 ) );
				
				_overlay.graphics.clear();
				
				// borrow css style
				_bgClip.addChild( UIFactory.createTextField('Course link', 'clevel2Lbl', 'left', 153, 8) );
				_bgClip.addChild( UIFactory.createTextField('Course ID', 'clevel2Lbl', 'left', 243, 8) );
			}
			
			{//-- custom map url / rating
				_contents.addChild( _clipRating = new Sprite );
				_clipRating.x = 35; _clipRating.y = 21;
				_clipRating.mouseEnabled = false;
				a = ['What a waste', 'Pretty lame', 'Quite fine', 'Definitely good', 'Awesomely awesome'];
				for ( i=0; i<5; i++ ) {
					_clipRating.addChild( mc = PuttBase2.assets.createDisplayObject('screen.ui.ico.smileyRate') as MovieClip );
					mc.gotoAndStop( i+11 ); mc.x = i*20;
					mc.buttonMode = true; mc.name = a[i];
				}
				
				_contents.addChild( _txfRate = UIFactory.createFixedTextField('RATE THIS COURSE', 'successRateLbl', 'none', 8, 28) );
				_txfRate.width = 130; _txfRate.height = 18;
				
				_contents.addChild( _txfURL = UIFactory.createTextField(Registry.SPONSOR_GAME_URL_LVLID +map.customLevel.id, 'clevel2URL', 'none', 150, 23) );
				_txfURL.width = 80; _txfURL.height = 17;
				_txfURL.selectable = true; _txfURL.wordWrap = false;
				_txfURL.mouseEnabled = true;
				
				_contents.addChild( _txfID = UIFactory.createTextField(map.customLevel.id, 'clevel2URL', 'none', 240, 23) );
				_txfID.width = 80; _txfID.height = 17;
				_txfID.selectable = true; _txfID.wordWrap = false;
				_txfID.mouseEnabled = true;
			}
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.windows.popCRate') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 8, 1), 1, false, _showContents );
				_animator.addSequenceSet( END, MathUtils.intRangeA(8, 16, 1), 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
			}
			
			
			if ( xmlSave && int(xmlSave.@score) && int(xmlSave.@rated) ) {
				_rating = int(xmlSave.@rated)/2 -1;
				_txfRate.text = String(a[ _rating ]);
				j = 5;
				while ( j-- )
					if ( j != _rating ) _clipRating.getChildAt(j).alpha = .35;
					else MovieClip(_clipRating.getChildAt(j)).gotoAndStop( j+1 );
				_clipRating.mouseChildren = false;
			}
			
			
			_contents.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
			_contents.addEventListener( MouseEvent.MOUSE_OVER, _movr, false, 0, true );
			_contents.addEventListener( MouseEvent.MOUSE_OUT, _mout, false, 0, true );
		}
		
		
		
			// -- private --
			
			private var _clipRating:Sprite, _txfRate:TextField, _txfURL:TextField, _txfID:TextField, _rating:int
			
			
			override protected function _init(e:Event):void 
			{
				_contents.x = 155; _contents.y = 355;
				super._init(e);
			}
			
			
			override protected function _showContents():void 
			{
				onShown.dispatch();
				
				_contents.visible = _bgBmp.visible = true;
				_overlay.alpha = 1;
				_clip.filters = [ new GlowFilter(0x191919, 1, 12, 12, 2) ];
			}
			
			
			private function _click( e:MouseEvent ):void
			{
				var map:MapData = Session.instance.map;
				switch( e.target ) {
					case _txfURL:
						_txfURL.setSelection( 0, _txfURL.text.length );
						System.setClipboard( _txfURL.text );
						break;
					
					case _txfID:
						_txfID.setSelection( 0, _txfID.text.length );
						System.setClipboard( _txfID.text );
						break;
					
					default:
						if ( map.isCustom && DisplayObject(e.target).parent == _clipRating ) {
							var mc:MovieClip = MovieClip(e.target);
							_rating = _clipRating.getChildIndex( mc );
							var j:int = 5;
							while ( j-- )
								if ( j != _rating )
									_clipRating.getChildAt(j).alpha = .35;
							
							_clipRating.mouseChildren = false;
							CONFIG::useGamersafe {
								if ( GamerSafe.api.loaded ) {
									GamerSafeHelper.i.lvRated.addOnce( _ratingCompleteGs );
									GamerSafeHelper.i.lvException.addOnce( _gsError );
									GamerSafe.api.levelVaultRateLevel( int(map.customLevel.id), (_rating+1)*2 );
								} else {
									_ratingCompleteGs();
								}
							}
							CONFIG::usePlaytomicLvls { PlayerLevels.Rate( map.customLevel.id, (_rating+1)*2, _ratingComplete ); }
							
							CONFIG::onFGL {
								Registry.FGL_TRACKER.customMsg( 'rated', (_rating+1)*2, map.customLevel.id ); }
						}
						break;
				}
				
			}
			
			private function _movr( e:MouseEvent ):void
			{
				if ( DisplayObject(e.target).parent == _clipRating ) {
					var mc:MovieClip = MovieClip(e.target);
					mc.gotoAndStop( mc.currentFrame%10 );
					_txfRate.text = mc.name.toUpperCase();
				}
			}
			
			private function _mout( e:MouseEvent ):void
			{
				if ( DisplayObject(e.target).parent == _clipRating && _clipRating.mouseChildren ) {
					var mc:MovieClip = MovieClip(e.target);
					mc.gotoAndStop( mc.currentFrame%10 +10 );
					_txfRate.text = 'RATE THIS COURSE';
				}
			}
			
			
			private function _ratingComplete( response:Object ):void
			{
				if ( !stage ) return;
				
				if ( response.Success ) {
					SaveDataMngr.instance.savePlayerLevelRating( Session.instance.map.customLevel.id, (_rating+1)*2 );
					
				} else {
					var j:int = 5;
					while ( j-- )
						_clipRating.getChildAt(j).alpha = 1;
					_clipRating.mouseChildren = false;
					
					if ( response.ErrorCode != 402 ) {
						CONFIG::debug {
							addChild( new PopPrompt('Error ('+ response.ErrorCode +'): \n'+ Registry.PLAYTOMIC_ERR_MSG[response.ErrorCode], 110, [{name:'OK'}]) ); }
						CONFIG::release {
							addChild( new PopPrompt('Server might be busy. Try again later. ('+ response.ErrorCode +')', 110, [{name:'OK'}]) ); }
					}
					
				}
			}
			
			
			private function _ratingCompleteGs( e:Event=null ):void
			{
				if ( e!=null && e.type == GamerSafe.EVT_LEVELVAULT_LEVEL_RATED ) {
					null;
					CONFIG::release {
						SaveDataMngr.instance.savePlayerLevelRating( Session.instance.map.customLevel.id, (_rating+1)*2 );
					}
				}
				else {
					var j:int = 5;
					while ( j-- )
						_clipRating.getChildAt(j).alpha = 1;
					_clipRating.mouseChildren = false;
					
					addChild( new PopPrompt('Server might be busy. Try again later.', 110, [{name:'OK'}]) );
				}
				
				GamerSafeHelper.i.lvRated.remove( _ratingCompleteGs );
				GamerSafeHelper.i.lvException.remove( _gsError );
			}
			
			private function _gsError( e:Error ):void
			{
				GamerSafeHelper.i.lvRated.remove( _ratingCompleteGs );
				GamerSafeHelper.i.lvException.remove( _gsError );
				
				var j:int = 5;
				while ( j-- )
					_clipRating.getChildAt(j).alpha = 1;
				_clipRating.mouseChildren = false;
				
				addChild( new PopPrompt('Server might be busy. Try again later.', 110, [{name:'OK'}]) );
			}
			
	}

}