package pb2.screen.window 
{
	import com.jaycsantos.display.animation.SimpleAnimationTiming;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.util.GameLoop;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import pb2.game.ctrl.CameraFocusCtrl;
	import pb2.game.ctrl.SaveDataMngr;
	import pb2.game.Registry;
	import pb2.game.Session;
	import pb2.screen.ui.UIFactory;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class TutorialWindow extends Pb2Window2a 
	{
		private static const TUTPAGE:Vector.<uint>=new Vector.<uint>
		
		public static function shouldShow( page:String ):Boolean
		{
			if ( !page )
				return false;
			
			if ( TUTPAGE.indexOf(int(page)) == -1 ) {
				if ( SaveDataMngr.instance.getCustom('tut'+ page) )
					TUTPAGE.push( page );
				else
					return true;
			}
			return false;
		}
		
		
		public var page:uint
		
		public function TutorialWindow( thePage:String ) 
		{
			var g:Graphics, mc:MovieClip, sp:Sprite, shp:Shape, txf:TextField, i:int, j:int, k:String, a:Array;
			
			page = int(thePage);
			SaveDataMngr.instance.saveCustom( 'tut' + page, 1, true );
			Session.instance.stop();
			CameraFocusCtrl.instance.disable();
			onHidden.addOnce( Session.instance.start );
			onHidden.addOnce( CameraFocusCtrl.instance.enable );
			
			_bgClip.addChild( mc = PuttBase2.assets.createDisplayObject('screen.tutorial.book') as MovieClip );
			mc.gotoAndStop( page );
			_bgClip.filters = [ new GlowFilter(0x191919, .75, 24, 42, 1) ];
			
			if ( page == 1 ) {
				_contents.addChild( _tut1 = PuttBase2.assets.createDisplayObject('screen.tutorial.aniControls') as MovieClip );
				_tut1.gotoAndStop( 1 );
				
				_animator = new SimpleAnimationTiming( MathUtils.uintRange(1, 120, 1).join(',').split(','), 250, true );
				_animator.playAt();
			}
			
			
			_contents.addChild( _btnClose = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnClose') as SimpleButton );
			_btnClose.x = 350; _btnClose.y = 30;
			_btnClose.visible = false;
			
			if ( page < 5 ) {
				_bg2.width = 380; _bg2.height = 240;
				
			} else if ( page == 5 ) {
				_bg2.width = 380; _bg2.height = 240;
				
			} else {
				_bg2.width = 380; _bg2.height = 140;
				_btnClose.visible = false;
			}
			_bgClip.addChild( UIFactory.createTextField('click anywhere to close', 'clevel2ExitTxt', 'center', _bgClip.width/2, _bgClip.height-3) );
			
			g = _overlay.graphics;
			g.clear();
			g.beginFill( 0, .35 );
			g.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			
			_contents.x = _bgClip.x = (PuttBase2.STAGE_WIDTH -_bgClip.width)/2 >>0;
			_contents.y = _bgClip.y = (PuttBase2.STAGE_HEIGHT -_bgClip.height)/2 >>0;
			
			_contents.mouseEnabled = false;
			g = _contents.graphics;
			g.beginFill( 0, 0 );
			g.drawRect( 0, 0, _bgClip.width, _bgClip.height );
			
			
			fadeEnterDur = 600;
			fadeExitDur = 200;
			onShown.add( _onShown );
			onHidden.add( _onHidden );
		}
		
		override public function dispose():void 
		{
			removeEventListener( MouseEvent.CLICK, _click );
			
			if ( _animator ) _animator.dispose();
			_animator = null;
			_tut1 = null;
			
			super.dispose();
		}
		
			// -- private --
			
			private var _animator:SimpleAnimationTiming
			private var _btnClose:SimpleButton, _tut1:MovieClip
			
			override protected function _update():void 
			{
				if ( _animator ) {
					_animator.update();
					_tut1.gotoAndStop( _animator.frame );
				}
				
				
			}
			
			
			private function _click( e:MouseEvent ):void
			{
				switch ( e.target ) {
					case _btnClose:
						hide();
						break;
						
					case _contents:
						break;
						
					default:
						//if ( page >= 7 )
							hide();
						break;
				}
			}
			
			
			private function _onShown():void
			{
				addEventListener( MouseEvent.CLICK, _click, false, 0, true );
				
				CONFIG::onFGL {
					Registry.FGL_TRACKER.customMsg('shown tutorial', page); }
			}
			
			private function _onHidden():void
			{
				visible = false;
			}
			
	}

}