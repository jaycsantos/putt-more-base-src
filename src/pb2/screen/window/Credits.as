package pb2.screen.window 
{
	import com.jaycsantos.util.KeyCode;
	import com.jaycsantos.util.UserInput;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.net.URLVariables;
	import flash.text.TextField;
	import pb2.game.ctrl.SaveDataMngr;
	import pb2.game.Registry;
	import pb2.screen.ui.*;
	import Playtomic.Link;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Credits extends FadeWindow 
	{
		
		public function Credits() 
		{
			var g:Graphics, sp:Sprite, sp2:Sprite, btn:SimpleButton, shp:Shape, txf:TextField, i:int, j:int, k:String, a:Array;
			
			{//-- title
				_contents.addChild( sp = PuttBase2.assets.createDisplayObject('screen.ui.bg.titleShade') as Sprite );
				sp.transform.colorTransform = new ColorTransform( 0, 0, 0, 1, 213, 183, 94, 0 );
				sp.mouseEnabled = false;
				
				_canvas.graphics.clear();
				_canvas.graphics.beginFill( 0, .89 );
				_canvas.graphics.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			}
			
			{//-- credit texts
				_contents.addChild( UIFactory.createTextField('CREDITS', 'creditHeader', 'left', 145, 208) );
				
				_contents.addChild( txf = UIFactory.createTextField('<span class="creditTitle">Graphics/Programming/Design by</span>\n    Jayc Santos (jaycsantos.com)', 'creditTxt', 'left', 255, 210) );
				_contents.addChild( _btnJayc = new Sprite );
				g = _btnJayc.graphics; _btnJayc.buttonMode = true;
				g.beginFill( 0, 0 );
				g.drawRect( 255, 210, txf.width, txf.height );
				_btnJayc.mouseEnabled = _btnJayc.visible = CONFIG::allowLinks;
				
				_contents.addChild( txf = UIFactory.createTextField('<span class="creditTitle">Physics Powered by</span>\n  Box2D flash', 'creditTxt', 'left', txf.x +200, 210) );
				_contents.addChild( txf = UIFactory.createTextField('<span class="creditTitle">Ranks & Levels Sharing Powered by</span>\n  GamerSafe (gamersafe.com)', 'creditTxt', 'left', txf.x, 245) );
				
				
				_contents.addChild( txf = UIFactory.createTextField('<span class="creditTitle">Music by</span>\n    Kevin MacLeod (incompetech.com)', 'creditTxt', 'left', 255, 245) );
				
				
				_contents.addChild( txf = UIFactory.createTextField('<span class="creditTitle">Made possible by</span>\n    '+Registry.SPONSOR_NAME +' ('+ Registry.SPONSOR_URL_PLAIN +')', 'creditTxt', 'left', 255, 280) );
				_contents.addChild( _btnSponsor = new Sprite );
				g = _btnSponsor.graphics; _btnSponsor.buttonMode = true;
				g.beginFill( 0, 0 );
				g.drawRect( 255, 280, txf.width, txf.height );
			}
			
			{//-- social buttons
				_contents.addChild( _btnFb = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnFb2') as SimpleButton );
				_btnFb.x = 160; _btnFb.y = 240;
				
				_contents.addChild( _btnTwit = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnTwit2') as SimpleButton );
				_btnTwit.x = 160; _btnTwit.y = 260;
				
				_btnFb.visible = _btnTwit.visible = CONFIG::allowLinks && !CONFIG::onMbreaker;
			}
			
			{//-- buttons
				_contents.addChild( _btnClose = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnClose') as SimpleButton );
				_btnClose.x = 575; _btnClose.y = 15; _btnClose.name = 'close';
				
				_contents.addChild( _btnClearSave = new SmallBtn1('clear save data', 80) );
				_btnClearSave.x = PuttBase2.STAGE_WIDTH/2 -40 >>0;
				_btnClearSave.y = 10;
			}
			
			
			_contents.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
		}
		
		override public function dispose():void 
		{
			_canvas.removeEventListener( MouseEvent.CLICK, _click );
			
			super.dispose();
		}
		
			// -- private --
			
			private var _btnFb:SimpleButton, _btnTwit:SimpleButton, _btnJayc:Sprite, _btnSponsor:Sprite, _btnMusic:Sprite
			private var _btnClose:SimpleButton, _btnClearSave:SmallBtn1
			
			
			override protected function _update():void 
			{
				if ( UserInput.instance.isKeyDown(KeyCode.ESC) )
					hide();
				_btnClearSave.update();
			}
			
			
			private function _click( e:MouseEvent ):void
			{
				switch ( e.target ) {
					case _btnJayc:
						Link.Open( 'http://jaycsantos.com/', 'jayc', 'credits' );
						break;
					
					case _btnSponsor:
						Link.Open( Registry.SPONSOR_URL, 'sponsor', 'credits' );
						break;
					
					case _btnFb:
						Link.Open( 'http://www.facebook.com/jaycgames', 'like', 'credits' );
						break;
					
					case _btnTwit:
						Link.Open( 'http://twitter.com/JaycSantos', 'tweet', 'credits' );
						break;
						
					case _btnClose:
						hide();
						break;
					
					case _btnClearSave:
						addChild( PopPrompt.create('This action cannot be undone and is permanent. Are you sure you want to clear your save progress?', 140, {name:'YES', call:_clearSaveData}, {name:'NO'} ) );
						break;
				}
			}
			
			private function _clearSaveData():void
			{
				SaveDataMngr.instance.clearData();
				_btnClearSave.visible = false;
				PopPrompt.hide();
			}
			
			
	}

}