package pb2.screen.window 
{
	import apparat.math.FastMath;
	import com.jaycsantos.display.animation.AnimationTiming;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.math.Trigo;
	import com.jaycsantos.util.L10n;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import pb2.game.ctrl.CameraFocusCtrl;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.entity.Puncher2;
	import pb2.game.entity.PushButton;
	import pb2.game.entity.render.IDragBaseDraw;
	import pb2.game.entity.tile.Ground;
	import pb2.game.Registry;
	import pb2.game.Session;
	import pb2.screen.*;
	import pb2.screen.ui.*;
	import pb2.util.pb2internal;
	import Playtomic.Log;
	/**
	 * ...
	 * @author ...
	 */
	public class PopHoleInfo extends PopWindow
	{
		
		public function PopHoleInfo()
		{
			super();
			var g:Graphics, sp:Sprite, sp2:Sprite, shp:Shape, txf:TextField, m:Matrix, i:int, j:int, k:String, a:Array;
			
			{//-- title
				_bgClip.addChild( txf = UIFactory.createTextField('COURSE <b>INFO</b>', 'header2', 'left', 45, 12) );
				_bgClip.addChild( sp = PuttBase2.assets.createDisplayObject('screen.ui.ico.holeFlag') as Sprite );
				sp.x = 35; sp.y = 27;
				
				_bgClip.graphics.lineStyle( 1.5, 0xCCCCCC );
				_bgClip.graphics.moveTo( 25, 42 );
				_bgClip.graphics.lineTo( 195, 42 );
			}
			
			{//-- form
				_bgClip.addChild( UIFactory.createFixedTextField('Dimensions:', 'windowTextLabel', 'right', 100, 50) );
				_bgClip.addChild( UIFactory.createFixedTextField('x', 'windowTextLabel', 'left', 130, 50) );
				_bgClip.addChild( UIFactory.createFixedTextField('Floor Paint:', 'windowTextLabel', 'right', 100, 73) );
				_bgClip.addChild( UIFactory.createFixedTextField('create new', 'windowSubTextLabel', 'left', 80, 115) );
				
				_contents.addChild( _inpCol = UIFactory.createInputField('col', 'windowTextInput') );
				_contents.addChild( _inpRow = UIFactory.createInputField('row', 'windowTextInput') );
				_inpCol.x = 110; _inpRow.x = 140;
				_inpCol.y = _inpRow.y = 49;
				_inpCol.text = '15'; _inpRow.text = '9';
				_inpCol.width = _inpRow.width = 20;
				_inpCol.height = _inpRow.height = 17;
				_inpCol.restrict = _inpRow.restrict = '012345679';
				//_inpCol.addEventListener( Event.CHANGE, _dimensionChange, false, 0, true );
				_inpCol.addEventListener( FocusEvent.FOCUS_IN, _movr, false, 0, true );
				_inpCol.addEventListener( FocusEvent.FOCUS_OUT, _mout, false, 0, true );
				//_inpRow.addEventListener( Event.CHANGE, _dimensionChange, false, 0, true );
				_inpRow.addEventListener( FocusEvent.FOCUS_IN, _movr, false, 0, true );
				_inpRow.addEventListener( FocusEvent.FOCUS_OUT, _mout, false, 0, true );
				
				_contents.addChild( _clipColor = new Sprite );
				_clipColor.x = 110; _clipColor.y = 73;
				_clipColor.buttonMode = true; _clipColor.mouseChildren = false;
				for ( k in Ground.COLORS )
					with ( _clipColor.graphics ) {
						beginFill( Ground.COLORS[k][0] );
						drawRect( (int(k)%COLOR_COL)*20, (int(k)/COLOR_COL>>0)*20, 16, 16 );
						endFill();
					}
				_clipColor.addChild( _clipColorSelect = new Shape );
				with ( _clipColorSelect.graphics ) {
					lineStyle( 2, 0x666666, 1, true, 'normal', 'square', 'miter' );
					drawRect( 0, 0, 16, 16 );
					endFill();
				}
				
				_contents.addChild( _clipCheck = new Sprite );
				_clipCheck.buttonMode = true; _clipCheck.mouseChildren = false;
				_clipCheck.x = 63; _clipCheck.y = 117;
				_checkBox();
				
			}
			
			{//-- buttons
				_contents.addChild( _btnOk = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnCheck') as SimpleButton );
				_contents.addChild( _btnClose = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnClose') as SimpleButton );
				
				_btnClose.x = 136; _btnClose.y = 145; _btnClose.name = L10n.t('cancel');
				_btnOk.x = 183; _btnOk.y = 143; _btnOk.name = L10n.t('ok');
				_btnOk.scaleX = _btnOk.scaleY = 1.25;
				
				_contents.addChild( _tip = new PopBtnTip );
			}
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.windows.popHoleInfo') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 11, 1), 1, false, _showContents );
				_animator.addSequenceSet( END, MathUtils.intRangeA(11, 21, 1), 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
			}
			
			_contents.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
			_contents.addEventListener( MouseEvent.MOUSE_OVER, _movr, false, 0, true );
			_contents.addEventListener( MouseEvent.MOUSE_OUT, _mout, false, 0, true );
			_contents.addEventListener( MouseEvent.MOUSE_WHEEL, _mwhel, false, 0, true );
			
			
			onPreShow.addOnce( Session.instance.stop );
			onPreShow.addOnce( CameraFocusCtrl.instance.disable );
			onHidden.addOnce( Session.instance.start );
			onHidden.addOnce( CameraFocusCtrl.instance.enable );
		}
		
		override public function dispose():void 
		{
			_inpCol.removeEventListener( Event.CHANGE, _dimensionChange );
			_inpCol.removeEventListener( FocusEvent.FOCUS_IN, _movr );
			_inpCol.removeEventListener( FocusEvent.FOCUS_OUT, _mout );
			//_inpRow.removeEventListener( Event.CHANGE, _dimensionChange );
			_inpRow.removeEventListener( FocusEvent.FOCUS_IN, _movr );
			_inpRow.removeEventListener( FocusEvent.FOCUS_OUT, _mout );
			
			_contents.removeEventListener( MouseEvent.CLICK, _click );
			_contents.removeEventListener( MouseEvent.MOUSE_OVER, _movr );
			_contents.removeEventListener( MouseEvent.MOUSE_OUT, _mout );
			_contents.removeEventListener( MouseEvent.MOUSE_WHEEL, _mwhel );
			
			_tip.dispose(); _tip = null;
			
			super.dispose();
		}
		
		
			// -- private --
			
			private static const COLOR_COL:uint = 4, MAX_COL:uint = 24, MAX_ROW:uint = 20;
			
			protected var _inpCol:TextField, _inpRow:TextField, _clipCheck:Sprite, _checked:Boolean
			protected var _clipColor:Sprite, _clipColorSelect:Shape, _colorIndex:int
			protected var _btnClose:SimpleButton, _btnOk:SimpleButton, _tip:PopBtnTip
			
			override protected function _init(e:Event):void 
			{
				_contents.x = 210; _contents.y = 112;
				
				super._init(e);
				
				// init texts
				if ( GameRoot.screen is EditorScreen ) {
					_inpCol.text = Session.instance.cols +'';
					_inpRow.text = Session.instance.rows +'';
					_clipColorSelect.x = (_colorIndex = Session.instance.bgColorIdx)%COLOR_COL *20;
					_clipColorSelect.y = (_colorIndex/COLOR_COL>>0) *20;
				}
				
			}
			
			
			private function _click( e:MouseEvent ):void
			{
				var i:int, j:int, ses:Session = Session.instance;
				switch( e.target ) {
					case _btnOk:
						if ( _checked ) {
							ses.cols = int(_inpCol.text); ses.rows = int(_inpRow.text);
							ses.bgColorIdx = _colorIndex;
							ses.map = null;
							Log.CustomMetric( 'btn_renew', 'editor' );
							GameRoot.changeScreen( RelayScreen, EditorScreen );
							
						} else {
							Log.CustomMetric( 'btn_resize', 'editor' );
							var c2:uint, r2:uint, c:uint = ses.cols, r:uint = ses.rows;
							ses.pb2internal::resize( c2=int(_inpCol.text), r2=int(_inpRow.text), _colorIndex );
							EditorScreen(GameRoot.screen).grid.render.redraw();
							EditorScreen.onMapAlter.dispatch();
							hide();
							
							
							// HAX to move dependent tiles
							var t:b2EntityTile, tm:Vector.<Vector.<b2EntityTile>> = ses.tileMap;
							// becase wider
							if ( c < c2 )
								for ( j=0; j<Math.min(r,r2); j++ ) {
									if ( (t = tm[c-1][j]) && (t is Puncher2 || t is PushButton) )
										if ( t.defRa == Math.PI ) {
											if ( t.render is IDragBaseDraw ) IDragBaseDraw(t.render).basedraw();
											t.deactivate();
											t.setDefault( (c2) *Registry.tileSize, t.defPy, t.defRa );
											tm[c2-1][j] = t;
											tm[c-1][j] = null;
											t.activate();
										}
								}
							// became taller
							if ( r < r2 )
								for ( i=0; i<Math.min(c,c2); i++ ) {
									if ( (t = tm[i][r-1]) && (t is Puncher2 || t is PushButton) )
										if ( t.defRa == -Trigo.HALF_PI ) {
											if ( t.render is IDragBaseDraw ) IDragBaseDraw(t.render).basedraw();
											t.deactivate();
											t.setDefault( t.defPx, (r2)*Registry.tileSize, t.defRa );
											tm[i][r2-1] = t;
											tm[i][r-1] = null;
											t.activate();
										}
								}
							
						}
						break;
						
					case _btnClose:
						hide();
						break;
						
					case _inpCol:
					case _inpRow:
						break;
						
					case _clipColor:
						_colorIndex = MathUtils.limit( ((e.localY-1)/20 >>0)*COLOR_COL +((e.localX-1)/20 >>0), 0, Ground.COLORS.length-1 );
						_clipColorSelect.x = _colorIndex%COLOR_COL *20;
						_clipColorSelect.y = (_colorIndex/COLOR_COL>>0) *20;
						break;
						
					case _clipCheck:
						_checked = !_checked;
						_checkBox();
						break;
						
					default: break;
				}
			}
			
			private function _mwhel( e:MouseEvent ):void
			{
				switch ( e.target ) {
					case _btnOk:
					case _btnClose:
						break;
						
					case _inpCol:
					case _inpRow:
						var txf:TextField = TextField(e.target);
						txf.text = MathUtils.limit( int(txf.text) +FastMath.sign(e.delta), 4, txf==_inpCol? MAX_COL:MAX_ROW ).toFixed();
						break;
					
					case _clipColor:
						_colorIndex = MathUtils.limit( _colorIndex+FastMath.sign(e.delta), 0, Ground.COLORS.length-1 );
						_clipColorSelect.x = _colorIndex%COLOR_COL *20;
						_clipColorSelect.y = (_colorIndex/COLOR_COL>>0) *20;
						break;
						
					default: break;
				}
			}
			
			private function _movr( e:Event ):void
			{
				switch ( e.target ) {
					case _btnOk:
					case _btnClose:
						var btn:SimpleButton = e.target as SimpleButton;
						_tip.pop( btn.name, btn.x, btn.y );
						break;
						
					case _inpCol:
					case _inpRow:
						TextField(e.target).borderColor = 0x8C7400;
						break;
					
					case _clipCheck:
						with( Sprite(e.target).graphics ) {
							lineStyle( 1, 0x8C7400 );
							drawRect( 1, 1, 10, 10 );
						}
						break;
					
					case _clipColor: break;
					default: break;
				}
			}
			
			private function _mout( e:Event ):void
			{
				switch ( e.target ) {
					case _btnOk:
					case _btnClose:
						_tip.hide();
						break;
						
					case _inpCol:
					case _inpRow:
						var txf:TextField = TextField(e.target);
						txf.text = MathUtils.limit( int(txf.text), 4, txf==_inpCol? MAX_COL: MAX_ROW ).toFixed();
						txf.borderColor = 0x8C8C8C;
						break;
					
					case _clipCheck:
						with( Sprite(e.target).graphics ) {
							lineStyle( 1, 0x8C8C8C );
							drawRect( 1, 1, 10, 10 );
						}
						break;
					
					case _clipColor: break;
					default: break;
				}
			}
			
			
			private function _dimensionChange( e:Event ):void
			{
				var txf:TextField = TextField(e.target);
				txf.text = MathUtils.limit( int(txf.text), 4, txf==_inpCol? MAX_COL: MAX_ROW ).toFixed();
			}
			
			private function _checkBox():void
			{
				var g:Graphics = _clipCheck.graphics;
				g.clear();
				g.beginFill( 0, 0 );
				g.drawRect( 0, 0, 70, 13 );
				g.endFill();
				g.beginFill( 0xCCCCCC );
				g.drawRect( 1, 1, 10, 10 );
				g.endFill();
				if ( _checked ) {
					g.beginFill( 0x666666 );
					g.drawRect( 3, 3, 7, 7 );
					g.endFill();
				}
				g.lineStyle( 1, 0x8C8C8C );
				g.drawRect( 1, 1, 10, 10 );
			}
			
			
	}

}