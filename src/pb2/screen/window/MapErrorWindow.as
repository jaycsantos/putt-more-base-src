package pb2.screen.window 
{
	import com.jaycsantos.game.GameRoot;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.system.System;
	import flash.text.TextField;
	import pb2.game.Registry;
	import pb2.game.Session;
	import pb2.screen.MenuActScreen;
	import pb2.screen.ui.UIFactory;
	import Playtomic.Link;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class MapErrorWindow extends Pb2Window2a 
	{
		
		public function MapErrorWindow( log:String ) 
		{
			var g:Graphics, mc:MovieClip, sp:Sprite, sp2:Sprite, shp:Shape, txf:TextField, i:int, j:int, k:String, a:Array;
			
			super();
			
			_bg2.width = 300; _bg2.height = 200;
			_bgClip.x = _contents.x = PuttBase2.STAGE_WIDTH/2 -_bgClip.width/2 >>0;
			_bgClip.y = _contents.y = PuttBase2.STAGE_HEIGHT/2 -_bgClip.height/2 >>0;
			
			_overlay.graphics.clear();
			
			_bgClip.addChild( txf = UIFactory.createTextField('<b>ERROR</b> OCCURED', 'header2', 'center', 160, 8 ) );
			_bgClip.addChild( mc = PuttBase2.assets.createDisplayObject('screen.ui.ico.smileyRate') as MovieClip );
			mc.gotoAndStop( 2 );
			mc.x = 160 -txf.width/2 -10; mc.y = 25;
			
			_bgClip.addChild( txf = UIFactory.createTextField('An unexpected error happened while trying to open the given level. You can help repair this issue by sending the error log below to the developer.', 'errSubTxt', 'none', 20, 40) );
			txf.wordWrap = true; txf.width = 260; txf.height = 50;
			_contents.addChild( _txfLog = UIFactory.createTextField(log, 'errLog', 'none', 25, 90) );
			_txfLog.width = 250; _txfLog.height = 54;
			_txfLog.selectable = true; _txfLog.wordWrap = _txfLog.multiline = true;
			_txfLog.mouseEnabled = true;
			
			_bgClip.addChild( UIFactory.createTextField('<a>Report error here</a>', 'errLink', 'left', 25, 155) );
			_contents.addChild( _btnSend = new Sprite );
			_btnSend.buttonMode = true;
			g = _btnSend.graphics;
			g.beginFill( 0, 0 );
			g.drawRect( 25, 155, 95, 18 );
			
			_contents.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
			
			_contents.addChild( _btnMenu = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnHome') as SimpleButton );
			_btnMenu.x = 265; _btnMenu.y = 165;
			
			
			CONFIG::onFGL {
				Registry.FGL_TRACKER.customMsg('map error', 0, log); }
		}
		
		override public function dispose():void 
		{
			_contents.removeEventListener( MouseEvent.CLICK, _click );
			
			super.dispose();
		}
		
		
			// -- private --
			
			private var _txfLog:TextField, _btnMenu:SimpleButton, _btnSend:Sprite
			
			private function _click( e:MouseEvent ):void
			{
				switch ( e.target ) {
					case _btnMenu:
						Session.instance.map = null;
						GameRoot.changeScreen( MenuActScreen );
						break;
						
					case _txfLog:
					case _btnSend:
						_txfLog.setSelection( 0, _txfLog.text.length );
						System.setClipboard( _txfLog.text );
						
						if ( e.target == _btnSend )
							Link.Open( 'http://jaycsantos.com/contact/#subject/puttmorebase+error+report/msg/'+ _txfLog.text, 'errorLog', 'error' );
						break;
						
					default: break;
				}
				
			}
			
			
	}

}