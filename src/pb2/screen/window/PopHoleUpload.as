package pb2.screen.window 
{
	import apparat.math.FastMath;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.util.UserInput;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import pb2.game.ctrl.*;
	import pb2.game.*;
	import pb2.screen.EditorScreen;
	import pb2.screen.ui.*;
	import pb2.util.CustomLevel;
	import pb2.util.pb2internal;
	import Playtomic.*;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PopHoleUpload extends PopWindow 
	{
		
		public function PopHoleUpload() 
		{
			super();
			var g:Graphics, sp:Sprite, sp2:Sprite, shp:Shape, txf:TextField, i:int, j:int, k:String, a:Array;
			
			{//-- title
				_bgClip.addChild( UIFactory.createTextField('SHARE & <b>UPLOAD</b>', 'header2', 'left', 45, 12) );
				_bgClip.addChild( sp = PuttBase2.assets.createDisplayObject('screen.ui.ico.holeFlag') as Sprite );
				sp.x = 35; sp.y = 27;
				
				_bgClip.graphics.lineStyle( 1.5, 0xCCCCCC );
				_bgClip.graphics.moveTo( 25, 42 );
				_bgClip.graphics.lineTo( 230, 42 );
			}
			
			{//-- form
				_bgClip.addChild( UIFactory.createTextField('Name:', 'windowTextLabel', 'left', 40, 52) );
				_contents.addChild( _inpName = UIFactory.createInputField('name', 'windowTextInput') );
				with ( _inpName ) {
					x = 105; y = 52;
					width = 100; height = 17;
					maxChars = 24; tabEnabled = true; tabIndex = 0;
					restrict = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 0987654321_';
				}
				
				_bgClip.addChild( UIFactory.createTextField('Author:', 'windowTextLabel', 'left', 40, 72) );
				_contents.addChild( _inpAuthor = UIFactory.createInputField('author', 'windowTextInput') );
				with ( _inpAuthor ) {
					x = 105; y = 72;
					width = _inpName.width; height = _inpName.height;
					maxChars = 16; tabEnabled = true; tabIndex = 1;
					restrict = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 0987654321_';
				}
				
				_bgClip.addChild( UIFactory.createTextField('Par:', 'windowTextLabel', 'left', 40, 92) );
				_contents.addChild( _inpPar = UIFactory.createInputField('par', 'windowTextInput') );
				with ( _inpPar ) {
					x = 105; y = 92;
					width = 40; height = 17; restrict = '1234567890';
					maxChars = 2; tabEnabled = true; tabIndex = 2;
				}
			}
			
			{//-- buttons
				_contents.addChild( _btnClose = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnClose') as SimpleButton );
				_btnClose.x = 165; _btnClose.y = 130;
				_btnClose.name = 'cancel'; _btnClose.blendMode = 'layer';
				
				_contents.addChild( _btnUpload = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnUpload') as SimpleButton );
				_btnUpload.x = 210; _btnUpload.y = 128;
				_btnUpload.name = 'upload'; _btnUpload.blendMode = 'layer';
				_btnUpload.scaleX = _btnUpload.scaleY = 1.25;
				
				_contents.addChild( _loading = PuttBase2.assets.createDisplayObject('screen.ui.ico.iconLoading') as MovieClip );
				_loading.stop(); _loading.visible = false;
				_loading.x = 210; _loading.y = 128;
				
				_contents.addChild( _tip = new PopBtnTip );
			}
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.windows.popHoleUpload') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 11, 1), 1, false, _showContents );
				_animator.addSequenceSet( END, MathUtils.intRangeA(11, 21, 1), 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
			}
			
			
			_inpPar.addEventListener( Event.CHANGE, _parChange, false, 0, true );
			_inpPar.addEventListener( MouseEvent.MOUSE_WHEEL, _parWheel, false, 0, true );
			_contents.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
			_contents.addEventListener( MouseEvent.MOUSE_OVER, _movr, false, 0, true );
			_contents.addEventListener( MouseEvent.MOUSE_OUT, _mout, false, 0, true );
			_contents.addEventListener( FocusEvent.FOCUS_IN, _movr, false, 0, true );
			_contents.addEventListener( FocusEvent.FOCUS_OUT, _mout, false, 0, true );
			
			onPreShow.addOnce( Session.instance.stop );
			onPreShow.addOnce( CameraFocusCtrl.instance.disable );
			onHidden.addOnce( Session.instance.start );
			onHidden.addOnce( CameraFocusCtrl.instance.enable );
		}
		
		override public function dispose():void 
		{
			_inpPar.removeEventListener( Event.CHANGE, _parChange );
			_inpPar.removeEventListener( MouseEvent.MOUSE_WHEEL, _parWheel );
			_contents.removeEventListener( MouseEvent.CLICK, _click );
			_contents.removeEventListener( MouseEvent.MOUSE_OVER, _movr );
			_contents.removeEventListener( MouseEvent.MOUSE_OUT, _mout );
			_contents.removeEventListener( FocusEvent.FOCUS_IN, _movr );
			_contents.removeEventListener( FocusEvent.FOCUS_OUT, _mout );
			
			_btnClose = _btnUpload = null;
			_inpName = _inpAuthor = _inpPar = null;
			_tip.dispose(); _tip = null;
			
			super.dispose();
		}
		
		
			// -- private --
			
			private var _minPar:uint=1, _maxPar:uint=16
			protected var _btnClose:SimpleButton, _btnUpload:SimpleButton, _loading:MovieClip
			protected var _inpName:TextField, _inpAuthor:TextField, _inpPar:TextField, _tip:PopBtnTip, level:CustomLevel
			
			
			override protected function _init( e:Event ):void 
			{
				_contents.x = 195; _contents.y = 105;
				
				super._init(e);
				
				var saveMngr:SaveDataMngr = SaveDataMngr.instance;
				// init contexts
				_inpName.text = '';
				_inpAuthor.text = saveMngr.getCustom('upload_name') ? saveMngr.getCustom('upload_name') : (saveMngr.getCustom('highscore_name') ? saveMngr.getCustom('highscore_name') : '');
				_minPar = HudGameEditor.instance.getPar();
				_maxPar = _minPar +8;
				_inpPar.text = (_minPar+1) +'';
				
				
			}
			
			
			private function _click( e:Event=null ):void
			{
				switch( e.target ) {
					case _btnUpload:
						var par:uint = int(_inpPar.text);//int(TextField(_parSelected.getChildAt(0)).text);
						HudGameEditor.instance.pb2internal::alterPar( par );
						
						{// validate input fields
							_inpName.text = _inpName.text.replace(/\s+/g, ' ');
							_inpAuthor.text = _inpAuthor.text.replace(/\s+/g, ' ');
							
							if ( ! par ) {
								addChild( PopPrompt.create('Please test and complete course to be able to share.', 90, {name:'OK'}) );
								return; }
							if ( _inpName.text.length < 3 ) {
								addChild( PopPrompt.create('Name must be 4-20 charaters.', 90, {name:'OK'}) );
								return; }
							if ( _inpAuthor.text.length < 3 ) {
								addChild( PopPrompt.create('Author must be 4-20 charaters.', 90, {name:'OK'}) );
								return; }
							if ( par < _minPar || par > _maxPar ) {
								addChild( PopPrompt.create('Par must be less than or equal to '+ _maxPar, 90, {name:'OK'}) );
								return; }
							
							SaveDataMngr.instance.saveCustom( 'upload_name', _inpAuthor.text, true );
						}
						
						{// upload now
							// export map first
							new MapExport( '', par, _exportComplete ).start();
							
							_btnUpload.visible = _btnClose.visible = false;
							_loading.visible = true; _loading.play();
							
							CONFIG::onFGL {
								Registry.FGL_TRACKER.customMsg('upload level', par); }
						}
						break;
						
					case _btnClose:
						hide();
						break;
					
					case _inpName:
					case _inpAuthor:
					case _inpPar:
						break;
				}
				
				
			}
			
			private function _movr( e:Event ):void
			{
				switch( e.target ) {
					case _btnUpload:
					case _btnClose:
						var btn:SimpleButton = e.target as SimpleButton;
						_tip.pop( btn.name, btn.x, btn.y );
						break;
						
					case _inpName:
					case _inpAuthor:
					case _inpPar:
						if ( TextField(e.target).stage.focus != e.target )
							TextField(e.target).borderColor = 0x8C7400;
						break;
				}
			}
			
			private function _mout( e:Event ):void
			{
				switch( e.target ) {
					case _btnUpload:
					case _btnClose:
						_tip.hide();
						break;
						
					case _inpName:
					case _inpAuthor:
					case _inpPar:
						if ( TextField(e.target).stage.focus != e.target )
							TextField(e.target).borderColor = 0x8C8C8C;
						break;
				}
			}
			
			private function _parChange( e:Event ):void
			{
				_inpPar.text = MathUtils.limit( int(_inpPar.text), _minPar, _maxPar ).toFixed();
			}
			
			private function _parWheel( e:MouseEvent ):void
			{
				_inpPar.text = MathUtils.limit( int(_inpPar.text) +FastMath.sign(e.delta), _minPar, _maxPar ).toFixed();
			}
			
			
			private function _exportComplete( result:String ):void
			{
				var xml:XML, mapMngr:MapDataMngr = MapDataMngr.instance;
				var hud:HudGameEditor = HudGameEditor.instance;
				
				var name:String = _inpName.text;// .replace(/\s/g, '-');
				var author:String = _inpAuthor.text.replace(/\s/g, '-');
				var par:uint = int(_inpPar.text);// Math.max( hud.getPar(), int(TextField(_parSelected.getChildAt(0)).text) );
				var item:uint = hud.totalItems;
				
				level = new CustomLevel( null, name, author );
				level.par = par;
				level.item = item;
				level.data = result;
				
				CONFIG::usePlaytomicLvls {
					var plvl:PlayerLevel = new PlayerLevel;
					plvl.Name = name;
					plvl.Data = result;
					plvl.PlayerName = author;
					plvl.CustomData = { par:par, item:item };
				}
				CONFIG::useGamersafe {
					var lvlAtt:Object = {
						plays: 0,
						wins: 0,
						quits: 0,
						name: name,
						author: author,
						par: par,
						item: item,
						isLevel: 1
					};
				}
				
				CONFIG::release {
					if ( CONFIG::useGamersafe ) {
						if ( GamerSafe.api && GamerSafe.api.loaded ) {
							GamerSafeHelper.i.lvCreated.addOnce( _uploadCompleteGs );
							GamerSafeHelper.i.networkError.addOnce( _uploadCompleteGs );
							GamerSafe.api.levelVaultCreateLevelWithAttributes( result, lvlAtt );
							
						} else {
							_uploadCompleteGs();
						}
					} else
					if ( CONFIG::usePlaytomicLvls ) {
						PlayerLevels.Save( plvl, null, _uploadCompletePlaytomic );
					}
				}
				CONFIG::debug {
					if ( UserInput.instance.isKeyDown(32) ) {
						if ( CONFIG::useGamersafe ) {
							if ( GamerSafe.api && GamerSafe.api.loaded ) {
								GamerSafeHelper.i.lvCreated.addOnce( _uploadCompleteGs );
								GamerSafeHelper.i.networkError.addOnce( _uploadCompleteGs );
								GamerSafe.api.levelVaultCreateLevelWithAttributes( result, lvlAtt );
								
							} else {
								_uploadCompleteGs();
							}
						} else
						if ( CONFIG::usePlaytomicLvls ) {
							PlayerLevels.Save( plvl, null, _uploadCompletePlaytomic );
						}
						
					} else {
						_btnUpload.visible = _btnClose.visible = true;
						_loading.visible = false; _loading.stop();
						EditorScreen(GameRoot.screen)._autoSave();
					}
				}
			}
			
			
			CONFIG::usePlaytomicLvls {
				private function _uploadCompletePlaytomic( plvl:PlayerLevel, response:Object ):void
				{
					if ( response.Success ) {
						level.id = plvl.LevelId;
						var pop:PopHoleSent = new PopHoleSent( level );
						parent.addChild( pop );
						onHidden.addOnce( pop.show );
						hide();
						
						Tracker.i.custom( 'uploadedCustomLevel' );
						Tracker.i.customLevelAverage( 'customCols', Session.instance.cols );
						Tracker.i.customLevelAverage( 'customRows', Session.instance.rows );
						Tracker.i.customLevelAverage( 'customPar', int(_inpPar.text) );
						Tracker.i.customLevelAverage( 'customItems', HudGameEditor.instance.totalItems );
						
						CONFIG::release {
							MapDataMngr.instance.clearData(); }
						
						CONFIG::onFGL {
							Registry.FGL_TRACKER.customMsg('uploaded level', 0, level.id); }
						
					}
					else {
						CONFIG::debug {
							addChild( PopPrompt.create('Error Code '+ response.ErrorCode +' returned', 100, {name:'OK'}) ); }
						CONFIG::release {
							addChild( PopPrompt.create('Server might be busy. Try again later. ('+ response.ErrorCode +')', 100, {name:'OK'}) ); }
						_btnUpload.visible = _btnClose.visible = true;
						_loading.visible = false; _loading.stop();
						
						Tracker.i.custom( 'uploadedCustomLevelFailed' );
					}
					
				}
			}
			
			CONFIG::useGamersafe {
				private function _uploadCompleteGs( e:Event=null ):void
				{
					if ( GamerSafe.api ) {
						GamerSafeHelper.i.lvCreated.remove( _uploadCompleteGs );
						GamerSafeHelper.i.networkError.remove( _uploadCompleteGs );
					}
					
					if ( e && e.type==GamerSafe.EVT_LEVELVAULT_LEVEL_CREATED ) {
						level.id = GamerSafe.api.levelVaultLastCreatedLevelID +'';
						var pop:PopHoleSent = new PopHoleSent( level );
						parent.addChild( pop );
						onHidden.addOnce( pop.show );
						hide();
						
						Tracker.i.custom( 'uploadedCustomLevel' );
						Tracker.i.customLevelAverage( 'customCols', Session.instance.cols );
						Tracker.i.customLevelAverage( 'customRows', Session.instance.rows );
						Tracker.i.customLevelAverage( 'customPar', int(_inpPar.text) );
						Tracker.i.customLevelAverage( 'customItems', HudGameEditor.instance.totalItems );
						
						CONFIG::release {
							MapDataMngr.instance.clearData(); }
						
						CONFIG::onFGL {
							Registry.FGL_TRACKER.customMsg('uploaded level', 0, level.id); }
						
					}
					else {
						addChild( PopPrompt.create('Server might be busy or inaccessible. Try again later or restart the game.', 120, {name:'OK'}) );
						
						_btnUpload.visible = _btnClose.visible = true;
						_loading.visible = false; _loading.stop();
						Tracker.i.custom( 'uploadedCustomLevelFailed' );
					}
				}
			}
			
	}

}