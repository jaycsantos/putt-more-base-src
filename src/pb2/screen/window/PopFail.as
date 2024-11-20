package pb2.screen.window 
{
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.math.MathUtils;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import pb2.game.ctrl.CameraFocusCtrl;
	import pb2.game.*;
	import pb2.GameAudio;
	import pb2.screen.MenuActScreen;
	import pb2.screen.ui.*;
	import Playtomic.Link;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PopFail extends PopWindow 
	{
		
		public function PopFail() 
		{
			super();
			
			obstrusive = mouseEnabled = mouseChildren = true;
			
			{//-- contents
				var mc:MovieClip, txf:TextField, map:MapData = Session.instance.map;
				_contents.addChild( mc = PuttBase2.assets.createDisplayObject('screen.ui.ico.smileyRate') as MovieClip );
				mc.gotoAndStop( 2 );
				mc.x = 300; mc.y = 172;
				
				_contents.addChild( txf = UIFactory.createFixedTextField('FAIL', 'header', 'left', 310, 155) );
				txf.width = 230; txf.height = 23;
				
				_contents.addChild( UIFactory.createFixedTextField('Try again, this time with less strokes.', 'errSubTxt', 'center', 325, 183) );
			}
			
			{//-- buttons
				_contents.addChild( _btnRestart = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnRestart') as SimpleButton );
				_contents.addChild( _btnHome = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnHome') as SimpleButton );
				_contents.addChild( _btnList = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnList') as SimpleButton );
				_contents.addChild( _btnGames = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnGame') as SimpleButton );
				
				_btnRestart.y = _btnList.y = _btnHome.y = _btnGames.y = 222;
				_btnRestart.x = 265; _btnRestart.name = 'retry';
				_btnList.x = 305; _btnList.name = 'browse';
				_btnHome.x = 385; _btnHome.name = 'menu';
				_btnGames.x = 345; _btnGames.name = 'games';
				
				_contents.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
				_contents.addEventListener( MouseEvent.MOUSE_OVER, _movr, false, 0, true );
				_contents.addEventListener( MouseEvent.MOUSE_OUT, _mout, false, 0, true );
				
				_contents.addChild( _tip = new PopBtnTip );
			}
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.windows.popFail') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 12, 1).reverse(), 1, false, _showContents );
				_animator.addSequenceSet( END, MathUtils.intRangeA(1, 12, 1), 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
			}
			
		}
		
		override public function dispose():void 
		{
			_contents.removeEventListener( MouseEvent.CLICK, _click );
			_contents.removeEventListener( MouseEvent.MOUSE_OVER, _movr );
			_contents.removeEventListener( MouseEvent.MOUSE_OUT, _mout );
			
			_tip.dispose(); _tip = null;
			
			super.dispose();
		}
		
		
		override public function show():void 
		{
			if ( Session.isOnPlay )
				GameAudio.instance.stopMusic( 1000 );
			
			Session.instance.stop();
			CameraFocusCtrl.instance.disable();
			super.show();
		}
		
		
			// -- private --
			
			private var _btnRestart:SimpleButton, _btnList:SimpleButton, _btnHome:SimpleButton, _btnGames:SimpleButton, _tip:PopBtnTip
			
			override protected function _showContents():void 
			{
				onShown.dispatch();
				
				_contents.visible = _bgBmp.visible = true;
				_overlay.alpha = 1;
				_clip.filters = [ new GlowFilter(0x191919, 1, 48, 48, 2) ];
			}
			
			
			private function _click( e:MouseEvent ):void
			{
				var win:Window
				switch ( e.target ) {
					case _btnRestart:
						if ( HudGame(parent).restart() )
							Tracker.i.buttonClick( 'reset', 'fail' );
						
						onHidden.addOnce( Session.instance.start );
						onHidden.addOnce( CameraFocusCtrl.instance.enable );
						onHidden.addOnce( function():void { GameAudio.instance.playGameMusic(GameAudio.instance.lastGameMusic); } );
						Window.removeAllWindows();
						break;
					
					case _btnList:
						addChild( win = Session.instance.map.isCustom ? new CLevelsWindow(PopFail) : new LevelSelect(PopFail) );
						win.show();
						break;
					
					case _btnHome:
						addChild( PopPrompt.create('Are you sure you want to exit to main menu?', 110, {name:'YES', call:_goMainMenu}, {name:'NO'}) );
						break;
					
					case _btnGames:
						Link.Open( Registry.SPONSOR_URL, 'sponsor', 'fail' );
						break;
				}
			}
			
			private function _movr( e:MouseEvent ):void
			{
				switch ( e.target ) {
					case _btnRestart:
					case _btnList:
					case _btnHome:
					case _btnGames:
						var btn:SimpleButton = e.target as SimpleButton
						_tip.pop( btn.name, btn.x, btn.y );
						break;
				}
			}
			
			private function _mout( e:MouseEvent ):void
			{
				switch ( e.target ) {
					case _btnRestart:
					case _btnList:
					case _btnHome:
					case _btnGames:
						_tip.hide();
						break;
				}
			}
			
			private function _goMainMenu():void
			{
				PopPrompt.remove();
				Tracker.i.buttonClick( 'mainMenu', 'success' );
				GameRoot.changeScreen( MenuActScreen );
			}
			
			
		
	}

}