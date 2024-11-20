package pb2.screen.window 
{
	import com.adobe.images.PNGEncoder;
	import com.jaycsantos.entity.GameWorld;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.util.L10n;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.net.FileReference;
	import flash.net.URLVariables;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import pb2.game.ctrl.*;
	import pb2.game.*;
	import pb2.screen.*;
	import pb2.screen.ui.*;
	import pb2.util.CustomLevel;
	import pb2.util.pb2internal;
	import Playtomic.*;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PopHoleSent extends PopWindow 
	{
		
		public function PopHoleSent( level:CustomLevel )
		{
			super();
			
			var g:Graphics, mc:MovieClip, sp:Sprite, sp2:Sprite, shp:Shape, txf:TextField, i:int, j:int, k:String, a:Array;
			_lvl = level;
			
			{//-- bg
				_bgClip.addChild( txf = UIFactory.createTextField('COURSE <b>UPLOADED</b>', 'header2', 'center', 130, 9 ) );
				_bgClip.addChild( mc = PuttBase2.assets.createDisplayObject('screen.ui.ico.smileyRate') as MovieClip );
				mc.gotoAndStop( 5 );
				mc.x = 130 -txf.width/2 -10; mc.y = 26;
				
				// borrow css style
				_bgClip.addChild( UIFactory.createTextField('Now share it to your\n friends and everyone else', 'errSubTxt', 'center', 130, 38) );
				
				_bgClip.addChild( UIFactory.createTextField('Course Link', 'clevel2Lbl', 'left', 25, 67.5) );
				_bgClip.addChild( UIFactory.createTextField('Course ID', 'clevel2Lbl', 'left', 25, 97.5) );
			}
			
			{//-- texts
				_contents.addChild( _txfLink = UIFactory.createTextField(Registry.SPONSOR_GAME_URL_LVLID +_lvl.id, 'clevel2URL', 'none', 25, 81) );
				_txfLink.width = 210; _txfLink.height = 18;
				_txfLink.selectable = _txfLink.mouseEnabled = true;
				
				_contents.addChild( _txfLvlid = UIFactory.createTextField(_lvl.id, 'clevel2URL', 'none', 25, 111) );
				_txfLvlid.width = 210; _txfLvlid.height = 18;
				_txfLvlid.selectable = _txfLvlid.mouseEnabled = true;
			}
			
			{//-- buttons
				_contents.addChild( _btnCam = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnCamera') as SimpleButton );
				_contents.addChild( _btnFb = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnFb') as SimpleButton );
				_contents.addChild( _btnTwit = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnTwit') as SimpleButton );
				_contents.addChild( _btnMenu = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnHome') as SimpleButton );
				_contents.addChild( _btnGo = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnGo') as SimpleButton );
				
				_btnCam.x = 40; _btnCam.name = L10n.t('snapshot');
				_btnFb.x = 70; _btnFb.name = L10n.t('share');
				_btnTwit.x = 100; _btnTwit.name = L10n.t('tweet');
				_btnMenu.x = 185; _btnMenu.name = L10n.t('menu');
				_btnGo.x = 225; _btnGo.name = L10n.t('play');
				
				_btnMenu.y = _btnGo.y = _btnCam.y = _btnFb.y = _btnTwit.y = 148;
				
				_contents.addChild( _tip = new PopBtnTip );
			}
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.windows.popHoleSent') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 11, 1), 1, false, _showContents );
				_animator.addSequenceSet( END, MathUtils.intRangeA(11, 21, 1), 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
			}
			
			
			_contents.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
			_contents.addEventListener( MouseEvent.MOUSE_OVER, _movr, false, 0, true );
			_contents.addEventListener( MouseEvent.MOUSE_OUT, _mout, false, 0, true );
			
			onPreShow.addOnce( Session.instance.stop );
			onPreShow.addOnce( CameraFocusCtrl.instance.disable );
			onHidden.addOnce( Session.instance.start );
			onHidden.addOnce( CameraFocusCtrl.instance.enable );
		}
		
		override public function dispose():void 
		{
			_contents.removeEventListener( MouseEvent.CLICK, _click );
			_contents.removeEventListener( MouseEvent.MOUSE_OVER, _movr );
			_contents.removeEventListener( MouseEvent.MOUSE_OUT, _mout );
			
			if ( _bmpSnap ) _bmpSnap.dispose();
			_lvl = null;
			_btnMenu = _btnGo = _btnCam = _btnFb = _btnTwit = null;
			_tip.dispose(); _tip = null;
			
			super.dispose();
		}
		
		
			// -- private --
			
			private var _txfLink:TextField, _txfLvlid:TextField, _tip:PopBtnTip
			private var _btnMenu:SimpleButton, _btnGo:SimpleButton, _btnFb:SimpleButton, _btnTwit:SimpleButton, _btnCam:SimpleButton
			
			private var _bmpSnap:BitmapData, _lvl:CustomLevel, _watermarkedClip:Sprite
			
			
			override protected function _init(e:Event):void 
			{
				_contents.x = 195; _contents.y = 110;
				
				super._init(e);
				
			}
			
			
			private function _click( e:MouseEvent ):void
			{
				var urlvar:URLVariables;
				switch( e.target ) {
					case _btnMenu:
						addChild( PopPrompt.create('Are you sure you want to return to main menu?', 100, {name:'YES', call:_goMainMenu}, {name:'NO'}) );
						break;
						
					case _btnGo:
						var xml:XML = XML(<level sett="9999" group="-1"><map></map><par></par><item></item></level>);
						xml.@name = _lvl.name.replace(/\s/g, '-');
						xml.@author = _lvl.author.replace(/\s/g, '-');
						xml.map = _lvl.data;
						xml.par = int(_lvl.par);
						xml.item = int(_lvl.item);
						
						Session.instance.map = new MapData( xml, _lvl );
						GameRoot.changeScreen( RelayScreen, PlayScreen );
						Tracker.i.buttonClick( 'createdLevel_play', 'uploaded' );
						break;
						
					case _txfLink:
						_txfLink.setSelection( 0, _txfLink.text.length );
						System.setClipboard( _txfLink.text );
						break;
						
					case _txfLvlid:
						_txfLvlid.setSelection( 0, _txfLvlid.text.length );
						System.setClipboard( _txfLvlid.text );
						break;
						
					case _btnCam:
						if ( !_bmpSnap ) {
							var txf:TextField, sp:Sprite = new Sprite;
							var world:GameWorld = Session.world;
							
							sp.addChild( UIFactory.createTextField( '[ID '+ _lvl.id +'] '+ _lvl.name +' by '+ _lvl.author +' \n'+ Registry.SPONSOR_GAME_URL_LVLID +_lvl.id, 'watermark', 'left', 4, 4) );
							sp.addChild( txf = UIFactory.createTextField( '<b>Putt More Base</b> \ngame by jaycsantos.com \nsponsored by '+ Registry.SPONSOR_URL_PLAIN, 'watermark2', 'right') );
							txf.x = world.bounds.width-txf.width-4; txf.y = world.bounds.height-txf.height-5;
							sp.filters = [new GlowFilter(0x262626, 1, 2, 2, 10)]; sp.alpha = .5;
							
							
							EditorScreen( GameRoot.screen ).simulate();
							Session.instance.onReset.addOnce( function():void {
								HudGameEditor.instance.restart( true );
								HudGameEditor.instance.pb2internal::setVisibleGhost( false );
								Session.instance.onReset.addOnce( _snapPromptSave );
							} );
							
							sp.x = -world.camera.bounds.min.x;
							sp.y = -world.camera.bounds.min.y;
							_watermarkedClip = sp;
						} else
							_snapPromptSave();
						
						Tracker.i.buttonClick( 'createdLevel_snap', 'uploaded' );
						break;
						
					case _btnFb:
						urlvar = new URLVariables();
						urlvar.t = 'Putt More Base - '+ _lvl.name +' (lvl by '+ _lvl.author +')';
						urlvar.u = Registry.SPONSOR_GAME_URL_LVLID +_lvl.id;
						Link.Open( 'http://www.facebook.com/sharer.php?'+ urlvar.toString(), 'createdLevel_fb', 'share' );
						break;
						
					case _btnTwit:
						urlvar = new URLVariables();
						urlvar.status = 'I made a PuttMoreBase level, play it! '+ Registry.SPONSOR_GAME_URL_LVLID +_lvl.id;
						Link.Open( 'http://twitter.com/?'+ urlvar.toString(), 'createdLevel_twit', 'share' );
						break;
						
					default: break;
				}
			}
			
			private function _movr( e:MouseEvent ):void
			{
				switch( e.target ) {
					case _btnMenu:
					case _btnGo:
					case _btnCam:
					case _btnFb:
					case _btnTwit:
						var btn:SimpleButton = e.target as SimpleButton;
						_tip.pop( btn.name, btn.x, btn.y );
						break;
						
					case _txfLvlid:
					case _txfLink:
						var txf:TextField = e.target as TextField;
						_tip.pop( 'copy', txf.x +txf.width/2, txf.y );
						break;
						
					default: break;
				}
			}
			
			private function _mout( e:MouseEvent ):void
			{
				switch( e.target ) {
					case _btnMenu:
					case _btnGo:
					case _btnCam:
					case _btnFb:
					case _btnTwit:
					case _txfLvlid:
					case _txfLink:
						_tip.hide();
						break;
						
					default: break;
				}
			}
			
			
			
			private function _goMainMenu():void
			{
				PopPrompt.remove();
				GameRoot.changeScreen( MenuActScreen );
			}
			
			
			private function _snapPromptSave():void
			{
				if ( !_bmpSnap )
					_bmpSnap = Session.world.wrender.snapShot( _watermarkedClip );
				addChild( PopPrompt.create('Save a snapshot:', 200, {name:'SAVE', call:_snapSnapshot}, {name:'CANCEL'} ) );
			}
			
			private function _snapSnapshot():void
			{
				PopPrompt.remove();
				var ba:ByteArray = PNGEncoder.encode( _bmpSnap );
        var file:FileReference = new FileReference();
				file.save( ba, 'puttmorebase-'+ _lvl.name.replace(/\s/,'-') +'[id-'+ _lvl.id +'].png' );
				//file.save( ba, 'puttmorebase-.png' );
				Tracker.i.buttonClick( 'createdLevel_saveSnap', 'uploaded' );
			}
			
			
	}

}