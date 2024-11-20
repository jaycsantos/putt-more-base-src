package pb2.screen.ui 
{
	import apparat.math.FastMath;
	import com.demonsters.debugger.MonsterDebugger;
	import com.greensock.easing.Quad;
	import com.jaycsantos.display.animation.SimpleAnimationTiming;
	import com.jaycsantos.game.*;
	import com.jaycsantos.math.*;
	import com.jaycsantos.sound.*;
	import com.jaycsantos.util.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.text.TextField;
	import flash.utils.*;
	import org.osflash.signals.Signal;
	import pb2.game.ctrl.*;
	import pb2.game.entity.b2.*;
	import pb2.game.entity.*;
	import pb2.game.*;
	import pb2.GameAudio;
	import pb2.screen.*;
	import pb2.screen.tutorial.*;
	import pb2.screen.ui.toolbox.ToolBoxNode;
	import pb2.screen.window.*;
	import pb2.util.pb2internal;
	import Playtomic.*;
	
	/**
	 * ...
	 * @author ...
	 */
	public class HudGame extends Sprite implements IGameObject
	{
		public static var instance:HudGame, isBusy:Boolean
		public static const HUD_WIDTH:uint = 60
		public static const NODE_GAP:uint = 35
		public static const NODE_COUNT:uint = 4
		
		public var releaseCallback:Function
		public var onReset:Signal, onPause:Signal, onUnpause:Signal, onBallRelease:Signal, onButtonClick:Signal
		
		public var tutorial:ATutorial
		
		
		public function HudGame() 
		{
			instance = this;
			var g:Graphics, mc:MovieClip, sp:Sprite, sp2:Sprite, shp:Shape, txf:TextField, m:Matrix, i:int, j:int, k:String, a:Array;
			
			_timeStarted = getTimer();
			mouseEnabled = tabEnabled = false;
			
			{//-- background
				addChild( _bg = new Bitmap(new BitmapData(90, PuttBase2.STAGE_HEIGHT, true, 0)) );
				sp = new Sprite;
				sp.addChild( PuttBase2.assets.createDisplayObject('screen.ui.hud.bg') );
				sp.filters = [new GlowFilter(0x191919, .7, 24, 24, 2)];
				_bg.bitmapData.draw( sp );
			}
			
			{//-- buttons under contents
				addChild( _contents = new Sprite );
				_contents.name = 'clickables';
				_contents.mouseEnabled = true;
				_contents.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
				_contents.addEventListener( MouseEvent.MOUSE_DOWN, _mdwn, false, 0, true );
				_contents.addEventListener( MouseEvent.MOUSE_OVER, _movr, false, 0, true );
				_contents.addEventListener( MouseEvent.MOUSE_OUT, _mout, false, 0, true );
				
				
				_contents.addChild( _btnInfo = PuttBase2.assets.createDisplayObject('screen.ui.hud.btnInfo') as SimpleButton );
				_btnInfo.x = 575; _btnInfo.y = 15;
				
				_contents.addChild( _btnPause = PuttBase2.assets.createDisplayObject('screen.ui.hud.btnPause') as SimpleButton );
				_contents.addChild( _btnReset = PuttBase2.assets.createDisplayObject('screen.ui.hud.btnReset') as SimpleButton );
				_btnReset.enabled = false; _btnReset.alpha = .25;
				
				_contents.addChild( _btnScrollUp = PuttBase2.assets.createDisplayObject('screen.hud.btnScrollUp') as SimpleButton );
				_contents.addChild( _btnScrollDown = PuttBase2.assets.createDisplayObject('screen.hud.btnScrollDown') as SimpleButton );
				_btnScrollUp.visible = _btnScrollDown.visible = false;
				
				if ( CONFIG::onAndkon )
					_contents.addChild( _btnSponsor = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnAndkon_hud') as SimpleButton );
				else if ( CONFIG::onMbreaker && !Registry.useDefaultSponsor )
					_contents.addChild( _btnSponsor = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnMbreaker_hud') as SimpleButton );
				else
					_contents.addChild( _btnSponsor = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnTurboNuke_hud') as SimpleButton );
			}
			
			{//-- tool box
				_contents.addChild( _clipToolbox = new Sprite );
				
				_clipToolbox.name = 'node container';
				_clipToolbox.x = 15; _clipToolbox.y = 100;
				_clipToolbox.scrollRect = new Rectangle( -1, 0, 45, NODE_GAP*NODE_COUNT +NODE_GAP/2 );
				_clipToolbox.buttonMode = true; _clipToolbox.mouseChildren = false;
				_clipToolbox.addEventListener( MouseEvent.MOUSE_WHEEL, _mw, false, 0, true );
				
			}
			
			{// -- pointers
				addChild( _pointerBall = PuttBase2.assets.createDisplayObject('screen.ui.hud.offscreenPointer') as Sprite );
				addChild( _pointerHole = PuttBase2.assets.createDisplayObject('screen.ui.hud.offscreenPointer') as Sprite );
				_pointerBall.addChild( _icoBall = PuttBase2.assets.createDisplayObject('screen.ui.ico.golfTee') as Sprite );
				_pointerHole.addChild( _icoHole = PuttBase2.assets.createDisplayObject('screen.ui.ico.holeFlag') as Sprite );
				
				_pointerBall.mouseEnabled = _pointerBall.mouseChildren = _pointerHole.mouseEnabled = _pointerHole.mouseChildren = false;
				_pointerBall.visible = _pointerHole.visible = false;
				_icoBall.scaleX = _icoBall.scaleY = _icoHole.scaleX = _icoHole.scaleY = .8;
			}
			
			{// -- scrollers
				addChild( _scrollUp = PuttBase2.assets.createDisplayObject('screen.hud.scroller') as Sprite );
				addChild( _scrollDown = PuttBase2.assets.createDisplayObject('screen.hud.scroller') as Sprite );
				addChild( _scrollLeft = PuttBase2.assets.createDisplayObject('screen.hud.scroller') as Sprite );
				addChild( _scrollRight = PuttBase2.assets.createDisplayObject('screen.hud.scroller') as Sprite );
				
				for each( mc in [_scrollUp, _scrollDown, _scrollLeft, _scrollRight] ) {
					mc.visible = mc.mouseEnabled = mc.mouseChildren = false;
					mc.blendMode = 'overlay';
				}
				
				_scrollUp.x = _scrollDown.x = HUD_WIDTH +(PuttBase2.STAGE_WIDTH -HUD_WIDTH) /2;
				_scrollUp.y = 10;
				_scrollDown.y = PuttBase2.STAGE_HEIGHT -10;
				_scrollDown.rotation = 180;
				_scrollLeft.y = _scrollRight.y = PuttBase2.STAGE_HEIGHT /2;
				_scrollLeft.x = HUD_WIDTH +10;
				_scrollLeft.rotation = -90;
				_scrollRight.x = PuttBase2.STAGE_WIDTH -10;
				_scrollRight.rotation = 90;
			}
			
			{//-- par
				addChild( _clipAni1 = PuttBase2.assets.createDisplayObject('screen.ui.number.counter') as MovieClip );
				addChild( _clipAni2 = PuttBase2.assets.createDisplayObject('screen.ui.number.counter') as MovieClip );
				_clipAni1.gotoAndStop( 1 );
				_clipAni2.gotoAndStop( 1 );
				_clipAni1.x = 30; _clipAni1.y = 355;
				_clipAni2.x = 10; _clipAni2.y = 355;
				
				a = MathUtils.uintRange(1,300,1).join(',').split(',');
				_ani1 = new SimpleAnimationTiming( a, 0, true );
				_ani2 = new SimpleAnimationTiming( a, 0, true );
				
				addChild( _txfPar = UIFactory.createFixedTextField('', 'hudPar', 'center', 28, 380) );
			}
			
			
			_clipGhost = new Sprite; _clipGhost.blendMode = 'overlay'; _clipGhost.alpha = .35;
			_nodeList = new Vector.<ToolBoxNode>;
			onReset = new Signal; onPause = new Signal;
			onUnpause = new Signal; onBallRelease = new Signal;
			onButtonClick = new Signal( String );
			onBallRelease.add( _onBallRelease );
			_flag = new Flags;
			_ghost = new Vector.<Array>;
			
			_clrXform = new ColorTransform;
			_clrXform2 = new ColorTransform( .5, .5, .5, 1, 128, 0, 0, 0 );
			
			_successTimer = new Timer( 1100, 1 );
			_successTimer.addEventListener( TimerEvent.TIMER, _showSuccessWindow, false, 0, true );
		}
		
		public function init( data:Object = null ):void
		{
			var ses:Session = Session.instance;
			
			for ( var k:String in data )
				_nodeList.push( _clipToolbox.addChild(new ToolBoxNode(k, data[k])) );
			
			_btnScrollUp.visible = _btnScrollDown.visible = _nodeList.length > NODE_COUNT;
			_flag.setTrue( FLAG_DIRTY );
			
			if ( !(this is HudGameEditor) )
				ses.onPutt.add( _onPutt );
			
			_txfPar.text = 'par '+ ses.map.par;
			_strokes = 0; _resets = 0;
			_updateSwings();
			
			
			var tut:String = Session.instance.map.xml ? Session.instance.map.xml.@tut : null;
			_successTimer.delay = tut=='Tutorial01a' || tut=='Tutorial03'? 3000: 1100;
			
			var map:MapData = ses.map;
			var saveMngr:SaveDataMngr = SaveDataMngr.instance;
			var xml:XML = saveMngr.getLevelData( map.name, map.hash );
			
			CONFIG::release {
				if ( Session.isOnPlay && !map.isCustom ) {
					_flag.setFlag( FLAG_FIRST_PUTT, !saveMngr.getCustom('putt'+map.levelIndex) );
					_flag.setFlag( FLAG_FIRST_QUIT, !saveMngr.getCustom('quit'+map.levelIndex) );
				}
			}
			
			ses.onEntityMoveStart.add( _onAnyMoveStart );
			ses.onEntitiesMoveStop.add( _onAllMoveStop );
			ses.world.camera.signalMove.add( _onCamMove );
			ses.world.camera.signalHitEdge.add( _onCamHitEdge );
			Sprite(ses.shades.shadeRender.buffer).addChild( _clipGhost );
			
			if ( Session.isOnPlay ) {
				k = PopEncyclopedia.scanNewTile();
				if ( k ) promptNewTile( k );
			}
			
			_onCamMove( 0, 0 );
		}
		
		public function dispose():void
		{
			if ( instance == this ) instance = null;
			
			CONFIG::release {
				if ( _flag.isTrue(FLAG_FIRST_QUIT) ) {
					_flag.setFalse( FLAG_FIRST_QUIT );
					SaveDataMngr.instance.saveCustom( 'quit' + Session.instance.map.levelIndex, 1 );
					Tracker.i.levelAverage( 'firstQuitDuration', Session.instance.map.name, (getTimer()-_timeStarted)/1000 >>0 );
				}
			}
			
			if ( parent ) parent.removeChild( this );
			if ( _clipGhost.parent ) _clipGhost.parent.removeChild( _clipGhost );
			
			_contents.removeEventListener( MouseEvent.CLICK, _click );
			_contents.removeEventListener( MouseEvent.MOUSE_DOWN, _mdwn );
			_contents.removeEventListener( MouseEvent.MOUSE_OVER, _movr );
			_contents.removeEventListener( MouseEvent.MOUSE_OUT, _mout );
			_clipToolbox.removeEventListener( MouseEvent.MOUSE_WHEEL, _mw );
			_successTimer.removeEventListener( TimerEvent.TIMER, _showSuccessWindow );
			
			onReset.removeAll(); onReset = null;
			onPause.removeAll(); onPause = null;
			onUnpause.removeAll(); onUnpause = null;
			
			if ( tutorial ) tutorial.dispose();
			tutorial = null;
		}
		
		public function clean():void
		{
			for each ( var n:ToolBoxNode in _nodeList ) n.dispose();
			_nodeList.splice( 0, _nodeList.length );
			
			var i:int = _clipToolbox.numChildren;
			while ( i-- ) _clipToolbox.removeChildAt( i );
		}
		
		
		public function update():void
		{
			var input:UserInput = UserInput.instance;
			var rect:Rectangle, len:int = _nodeList.length;
			var dx:Number, dy:Number
			
			if ( _flag.isTrue(FLAG_DIRTY) ) {
				_flag.setFalse( FLAG_DIRTY );
				var n:ToolBoxNode, i:int = len;
				while ( i-- ) {
					dy = i*NODE_GAP -_nodeList[i].y;
					if ( dy ) {
						_flag.setTrue( FLAG_DIRTY );
						_nodeList[i].y += Math.abs(dy)>1? dy/8: dy;
					}
				}
				rect = _clipToolbox.scrollRect;
				//rect.height = Math.min(len*NODE_GAP, 240);
				rect.y = MathUtils.limit( rect.y, 0, (len*NODE_GAP -15) -rect.height );
				_clipToolbox.scrollRect = rect;
				
				if ( len > NODE_COUNT ) {
					_btnScrollUp.visible = rect.y > 0;
					_btnScrollDown.visible = rect.y < (len*NODE_GAP-15 -rect.height);
				} else
					_btnScrollUp.visible = _btnScrollDown.visible = false;
				
			} else 
			if ( len > NODE_COUNT && _flag.isTrue(FLAG_SCROLL) ) {
				rect = _clipToolbox.scrollRect;
				
				if ( _flag.isTrue(FLAG_SCROLL_UP) )
					rect.y = Math.max( rect.y -5, 0 );
				else
					rect.y = Math.min( rect.y +5, (len*NODE_GAP-5) -rect.height );
				_clipToolbox.scrollRect = rect;
				
				if ( len > NODE_COUNT ) {
					_btnScrollUp.visible = rect.y > 0;
					_btnScrollDown.visible = rect.y < (len*NODE_GAP-5 -rect.height);
				} else
					_btnScrollUp.visible = _btnScrollDown.visible = false;
				if ( input.isMouseReleased )
					_flag.setFalse( FLAG_SCROLL | FLAG_SCROLL_DN | FLAG_SCROLL_UP );
				
			}
			
			
			if ( _ani1.isPlaying ) {
				_ani1.update();
				if ( _ani1.frame >= _ani1Target && _ani1.frame <= _ani1Target+10 )
					_ani1.stop( _ani1Target-1 );
				_clipAni1.gotoAndStop( _ani1.frame );
				
			}
			if ( _ani2.isPlaying ) {
				_ani2.update();
				if ( _ani2.frame >= _ani2Target && _ani2.frame <= _ani2Target+10 )
					_ani2.stop( _ani2Target-1 );
				_clipAni2.gotoAndStop( _ani2.frame );
			}
			
			if ( tutorial ) tutorial.update();
			if ( _clipNewTile && _clipNewTile.y ) _clipNewTile.y = Math.min( _clipNewTile.y+2, 0 );
			
			if ( input.isKeyReleased(KeyCode.R) && !Window.instanceCount() )
				restart();
			
			CONFIG::release {
				if ( (input.isKeyReleased(KeyCode.ESC) || input.isKeyReleased(KeyCode.P) || input.isKeyReleased(KeyCode.SPACEBAR)) && pause() )
					Tracker.i.buttonClick( 'pause', 'keyboard' );
				if ( input.isFocusLost && pause() )
					Tracker.i.buttonClick( 'autoPause', 'hud' );
			}
			CONFIG::debug {
				if ( input.isKeyReleased(KeyCode.ESC) || input.isKeyReleased(KeyCode.P) || input.isKeyReleased(KeyCode.SPACEBAR) )
					pause();
			}
			
		}
		
		
		public function storeTool( tile:b2EntityTileTool ):Boolean
		{
			var i:int, j:int, n:ToolBoxNode, type:String = tile.type;
			for each ( n in _nodeList )
				if ( n.type == tile.type ) {
					if ( n.store(tile) ) {
						if ( n.stockCount == 1 ) {
							_nodeList.splice( _nodeList.indexOf(n), 1 );
							
							i = MathUtils.limit( _clipToolbox.mouseY /NODE_GAP >>0, 0, _nodeList.length );
							for ( j = 0; j < i; j++ )
								if ( !_nodeList[j].stockCount ) {
									i = j; break;
								}
							
							_nodeList.splice( i, 0, n );
							_clipToolbox.setChildIndex( n, _clipToolbox.numChildren-1 );
							n.y = _clipToolbox.mouseY -14;
							_flag.setTrue( FLAG_DIRTY );
						}
						return true;
					}
					break;
				}
			
			return false;
		}
		
		public function releaseTool( type:String ):b2EntityTileTool
		{
			var n:ToolBoxNode, ent:b2EntityTileTool;
			for each ( n in _nodeList )
				if ( n.type == type ) {
					if ( (ent = n.release()) ) {
						if ( !n.stockCount ) {
							_nodeList.splice( _nodeList.indexOf(n), 1 );
							_nodeList.push( n );
							_clipToolbox.setChildIndex( n, 0 );
							_flag.setTrue( FLAG_DIRTY );
						}
						return ent;
					}
					break;
				}
			
			return null;
		}
		
		
		//{ -- getter methods
		public function get swings():uint
		{
			return _strokes;
		}
		
		public function get resets():uint
		{
			return _resets;
		}
		
		public function get unusedItems():uint
		{
			var i:int;
			for each ( var n:ToolBoxNode in _nodeList )
				i += n.stockCount;
			
			var list:Vector.<b2EntityTileTool> = releasedItems;
			var j:int = list.length;
			while( j-- )
				if ( ! list[j].wasMoved ) i++;
			
			return i;
		}
		
		public function get unReleasedItems():Vector.<ToolBoxNode>
		{
			var list:Vector.<ToolBoxNode> = new Vector.<ToolBoxNode>;
			for each( var n:ToolBoxNode in _nodeList )
				if ( n.stockCount )
					list.push( n );
			
			return list;
		}
		
		public function get usedItems():Vector.<b2EntityTileTool>
		{
			var list:Vector.<b2EntityTileTool> = releasedItems;
			var i:int = list.length;
			while( i-- )
				if ( ! list[i].wasMoved )
					list.splice( i, 1 );
			
			return list;
		}
		
		public function get releasedItems():Vector.<b2EntityTileTool>
		{
			var list:Vector.<b2EntityTileTool> = new Vector.<b2EntityTileTool>;
			var a:Vector.<b2EntityTileTool>;
			
			use namespace pb2internal;
			
			for each( var n:ToolBoxNode in _nodeList )
				if ( n.getReleasedTiles().length )
					list = list.concat( n.getReleasedTiles() );
			
			return list;
		}
		
		public function get totalItems():uint
		{
			var c:uint = 0;
			for each( var n:ToolBoxNode in _nodeList )
				c += n.total;
			
			return c;
		}
		
		//}
		
		
		public function restart( all:Boolean=false ):Boolean
		{
			if ( Session.isBusy ) return false;
			
			Session.instance.reset( all );
			
			var tile:b2EntityTile, tileMap:Vector.<Vector.<b2EntityTile>> = Session.instance.tileMap;
			
			onReset.dispatch();
			if ( !Session.instance.map.isCustom && Session.isOnPlay ) {
				if ( _strokes )
					Tracker.i.levelAverage( 'swingsOnRestart', Session.instance.map.name, _strokes );
				Tracker.i.levelCounter( 'hudreset', Session.instance.map.name );
			}
			_strokes = 0; _resets++;
			_ani1.frameSpeed = _ani2.frameSpeed = GameLoop.instance.timeFrameRate/3;
			_updateSwings();
			
			//CameraFocusCtrl.instance.enable();
			
			_contents.mouseEnabled = _btnPause.enabled = true;
			_btnPause.alpha = 1;
			_btnReset.enabled = false; _btnReset.alpha = .25;
			_clipAni1.transform.colorTransform = _clipAni2.transform.colorTransform = _clrXform;
			
			Session.instance.start();
			_drawGhosts();
			
			return true;
		}
		
		public function pause():Boolean
		{
			if ( Window.instanceCount() ) return false;
			
			onPause.dispatch();
			
			var win:Window
			addChild( win = new PauseMenu );
			win.onHidden.addOnce( onUnpause.dispatch );
			win.show();
			
			return true;
		}
		
		
		public function showIntro():void
		{
			var win:Window
			addChild( win = new PopIntro );
			win.show();
			win.onHidden.addOnce( showTutorial );
		}
		
		public function showTutorial():void
		{
			var win:Window, ses:Session = Session.instance;
			var tutFlag:uint = uint( SaveDataMngr.instance.getCustom('tutflag') );
			if ( Session.isOnPlay && !ses.map.isCustom )
				switch ( ses.map.levelIndex ) {
					case 0:
						// demo controls
						if ( (tutFlag & 1) == 0 ) {
							addChild( win = new PopInfoControls );
							BallCtrl.onMousePress.addOnce( win.show );
							BallCtrl.onMouseRelease.addOnce( win.hide );
							win.onShown.addOnce( function():void {
								SaveDataMngr.instance.saveCustom( 'tutflag', 1 | uint(SaveDataMngr.instance.getCustom('tutflag')), true );
							} );
							
							/*addChild( win = new DemoControls );
							BallCtrl.onMouseRelease.addOnce( win.hide );
							win.show();*/
						}
						
						// info about stroke/par
						if ( (tutFlag & 2) == 0 ) {
							addChildAt( win = new PopInfoPar, getChildIndex(_clipAni1) );
							win.onShown.addOnce( function():void {
								SaveDataMngr.instance.saveCustom( 'tutflag', 2 | uint(SaveDataMngr.instance.getCustom('tutflag')), true );
							} );
							ses.onPutt.addOnce( win.show );
							ses.onPutt.addOnce( CameraFocusCtrl.instance.disable );
							_successTimer.delay = 4000;
						}
						// info about reset button
						if ( (tutFlag & 4) == 0 ) {
							addChildAt( win = new PopInfoReset, getChildIndex(_contents) );
						}
						// info about reset button when over par
						if ( (tutFlag & 16) == 0 ) {
							addChildAt( win = new PopInfoReset, getChildIndex(_contents) );
						}
						break;
						
					case 1:
						// info about extra items
						if ( (tutFlag & 8) == 0 ) {
							addChildAt( win = new PopInfoItems, getChildIndex(_contents) );
							ses.onEntityMoveStart.addOnce( win.hide );
							win.show();
							addChild( win = new DemoItems );
							win.onHidden.addOnce( function():void {
								SaveDataMngr.instance.saveCustom( 'tutflag', 8 | uint(SaveDataMngr.instance.getCustom('tutflag')), true );
							} );
							win.show();
						}
						// info about reset button
						if ( (tutFlag & 4) == 0 ) {
							addChildAt( win = new PopInfoReset, getChildIndex(_contents) );
						}
						// info about reset button when over par
						if ( (tutFlag & 16) == 0 ) {
							addChildAt( win = new PopInfoReset, getChildIndex(_contents) );
						}
						break;
						
					case 2:
					case 3:
					case 4:
					case 5:
					case 6:
						// info about reset button when over par
						if ( (tutFlag & 16) == 0 ) {
							addChildAt( win = new PopInfoReset, getChildIndex(_contents) );
						}
						// info about encyclopedia
						if ( 0 && (tutFlag & 32) == 0 ) {
							addChildAt( win = new PopInfoPedia, getChildIndex(_contents) );
							win.show();
						}
						// info about spare items
						if ( (tutFlag & 64) == 0 ) {
							addChild( win = new PopInfoSpare );
							ses.onPutt.addOnce( win.show );
							ses.onPutt.addOnce( CameraFocusCtrl.instance.disable );
							_successTimer.delay = 4000;
						} else
						// info about awesomeness
						if ( (tutFlag & 128) == 0 ) {
							addChild( win = new PopInfoAwesome );
							ses.onPutt.addOnce( win.show );
							ses.onPutt.addOnce( CameraFocusCtrl.instance.disable );
							_successTimer.delay = 4000;
						}
						break;
				}
			SaveDataMngr.instance.saveCustom( 'tutflag', tutFlag, true );
			
			
			/*if ( ! tutorial && Session.isOnPlay ) {
				var def:String = String(Session.instance.map.xml.@tut);
				if ( !def ) return;
				
				try {
					var c:Class = getDefinitionByName( 'pb2.screen.tutorial.' + def ) as Class; }
				catch ( e:Error ) {
					return; }
				
				addChild( tutorial = new c );
				
				//if ( !SaveDataMngr.instance.getCustom(def) )
					tutorial.show();
				
			} else
			if ( tutorial )
				tutorial.show();
			*/
		}
		
		public function hideTutorial():void
		{
			if ( tutorial ) tutorial.hide();
		}
		
		public function promptNewTile( type:String ):void
		{
			if ( !_clipNewTile ) {
				_contents.addChild( _clipNewTile = PuttBase2.assets.createDisplayObject('screen.ui.hud.notifyNewTile') as MovieClip );
				_clipNewTile.buttonMode = true; _clipNewTile.mouseChildren = false;
				_clipNewTile.x = 495; _clipNewTile.y = -30;
				
				var sp:Sprite
				_clipNewTile.addChild( sp = PuttBase2.assets.createDisplayObject('entity.block.'+ type) as Sprite );
				if ( sp is MovieClip ) MovieClip(sp).stop();
				sp.x = 11; sp.y = 14;
				sp.scaleX = sp.scaleY = .4;
			}
		}
		
		
		public function markBallPosition( ball:Ball, angle:Number=NaN, teleport:Boolean=false ):void
		{
			var a:Array = [ball.p.x, ball.p.y];
			if ( !isNaN(angle) ) a.push( angle );
			else if ( teleport ) a.push( NaN, 1 );
			_ghost.push( a );
		}
		
		
			// -- private --
			
			private static const FLAG_SCROLL:int = 4;
			private static const FLAG_SCROLL_UP:int = 8;
			private static const FLAG_SCROLL_DN:int = 16;
			private static const FLAG_DIRTY:int = 32;
			private static const FLAG_FIRST_PUTT:int = 64;
			private static const FLAG_FIRST_QUIT:int = 128;
			
			protected var _bg:Bitmap, _contents:Sprite, _btnPause:SimpleButton, _btnReset:SimpleButton, _btnSponsor:SimpleButton
			protected var _btnScrollUp:SimpleButton, _btnScrollDown:SimpleButton, _nodeBox:Sprite, _btnInfo:SimpleButton, _clipNewTile:MovieClip
			
			protected var _flag:Flags, _strokes:uint, _resets:uint, _timeStarted:uint, _successTimer:Timer
			protected var _txfPar:TextField, _clipToolbox:Sprite, _nodeList:Vector.<ToolBoxNode>
			
			protected var _ani1:SimpleAnimationTiming, _ani2:SimpleAnimationTiming, _clipAni1:MovieClip, _clipAni2:MovieClip, _clrXform:ColorTransform, _clrXform2:ColorTransform
			protected var _ani1Target:uint, _ani2Target:uint
			protected var _pointerHole:Sprite, _pointerBall:Sprite, _icoHole:Sprite, _icoBall:Sprite
			
			protected var _scrollUp:Sprite, _scrollDown:Sprite, _scrollLeft:Sprite, _scrollRight:Sprite
			protected var _clipGhost:Sprite, _ghost:Vector.<Array>
			
			final protected function _makeDirty():void
			{
				_flag.setTrue( FLAG_DIRTY );
			}
			
			
			private function _click( e:MouseEvent ):void
			{
				if ( InteractiveObject(e.currentTarget).mouseEnabled )
					switch( e.target ) {
						case _btnReset:
							if ( _btnReset.enabled && restart() && Session.isOnPlay ) {
								Tracker.i.buttonClick( 'reset', 'hud' );
								onButtonClick.dispatch( 'reset' );
							}
							break;
							
						case _btnPause:
							_btnPause.enabled? pause(): null;
							Tracker.i.buttonClick( 'pause', 'hud' );
							onButtonClick.dispatch( 'pause' );
							break;
							
						case _clipNewTile:
						case _btnInfo:
							Tracker.i.buttonClick( 'newTile', 'hud' );
							var win:Window = new PopEncyclopedia( HudGame );
							addChild( win );
							win.show();
							
							if ( _clipNewTile ) {
								_clipNewTile.stop();
								_contents.removeChild( _clipNewTile );
							}
							_clipNewTile = null;
							onButtonClick.dispatch( 'pedia' );
							break;
							
						case _btnSponsor:
							Link.Open( Registry.SPONSOR_URL, 'more games', 'mainmenu' );
							break;
					}
			}
			
			private function _mdwn( e:MouseEvent ):void
			{
				switch( e.target ) {
					case _btnScrollUp:
						_flag.setTrue( FLAG_SCROLL_UP | FLAG_SCROLL );
						break;
					case _btnScrollDown:
						_flag.setTrue( FLAG_SCROLL_DN | FLAG_SCROLL );
						break;
						
					case _clipToolbox:
						if ( Session.instance.movingEntitiesCount ) return;
						var i:int = (_clipToolbox.mouseY /NODE_GAP) <<0;
						if ( i >= 0 && i < _nodeList.length && releaseCallback != null ) {
							var ent:b2EntityTileTool = releaseTool( _nodeList[i].type );
							if ( ent )
								releaseCallback( ent );
						}
						break;
					default: break;
				}
			}
			
			private function _movr( e:MouseEvent ):void
			{
				if ( InteractiveObject(e.currentTarget).mouseEnabled )
					switch( e.target ) {
						case _btnReset:
							break;
						case _btnPause:
							break;
						default: break;
					}
			}
			
			private function _mout( e:MouseEvent ):void
			{
				if ( InteractiveObject(e.currentTarget).mouseEnabled )
					switch( e.target ) {
						case _btnReset:
							break;
						case _btnPause:
							break;
						case _btnScrollUp:
							//_flag.setFalse( FLAG_SCROLL_UP );
							break;
						case _btnScrollDown:
							//_flag.setFalse( FLAG_SCROLL_DN );
							break;
						default: break;
					}
			}
			
			private function _mw( e:MouseEvent ):void
			{
				var len:uint = _nodeList.length;
				if ( len > NODE_COUNT ) {
					var rect:Rectangle = _clipToolbox.scrollRect;
					rect.y = MathUtils.limit( rect.y -FastMath.sign(e.delta)*10, 0, (len*NODE_GAP-5) -rect.height );
					_clipToolbox.scrollRect = rect;
					
					if ( len > NODE_COUNT ) {
						_btnScrollUp.visible = rect.y > 0;
						_btnScrollDown.visible = rect.y < (len*NODE_GAP-5 -rect.height);
					} else
						_btnScrollUp.visible = _btnScrollDown.visible = false;
				}
			}
			
			
			// -- prompt over par
			private function _checkStrokeParLimit():void
			{
				if ( !BallCtrl.instance.getPrimary() || BallCtrl.instance.getPrimary().isOnHole ) return;
				
				if ( Session.isOnPlay ) {
					CONFIG::release {
						if ( _strokes >= Session.instance.map.par + 20 ) {
							var win:Window;
							addChild( win = new PopFail );
							win.show();
						}
					}
					CONFIG::debug {
						if ( _strokes >= Session.instance.map.par + 5 ) {
							var win:Window;
							addChild( win = new PopFail );
							win.show();
						}
					}
					
					if ( _strokes >= Session.instance.map.par )
						_clipAni1.transform.colorTransform = _clipAni2.transform.colorTransform = _clrXform2;
					else
						_clipAni1.transform.colorTransform = _clipAni2.transform.colorTransform = _clrXform;
					
				} else
				if ( Session.isOnEditor ) {
					if ( _strokes > Registry.EDITOR_MAX_PAR )
						addChild( PopPrompt.create('EDITOR:\nCourse must be '+ Registry.EDITOR_MAX_PAR +' par or lower only. Putting will reset.', 160, {name:'OK'}) );
				}
			}
			
			private function _updateSwings():void
			{
				_ani1Target = (_strokes%10) *30 +1;
				if ( _ani1Target != _ani1.frame )
					_ani1.playAt( _ani1.index );
				
				_ani2Target = ((_strokes/10 >>0) %10) *30 +1;
				if ( _ani2Target != _ani2.frame )
					_ani2.playAt( _ani2.index );
					
				
				/*var clrXform:ColorTransform;
				if ( _strokes == 0 )
					clrXform = new ColorTransform( 0, 0, 0, 1, 204, 204, 204, 0 );
				else if ( _strokes < Session.instance.map.par )
					clrXform = new ColorTransform( 0, 0, 0, 1, 0, 204, 0, 0 );
				else if ( _strokes == Session.instance.map.par )
					clrXform = new ColorTransform( 0, 0, 0, 1, 204, 204, 0, 0 );
				else
					clrXform = new ColorTransform( 0, 0, 0, 1, 204, 51, 0, 0 );
				
				
				var mc:MovieClip;
				if ( _strokes < 10 ) {
					mc = _txSwingsClip.getChildAt(0) as MovieClip;
					mc.gotoAndStop( _strokes? _strokes: 10 );
					mc.x = 0;
					mc.transform.colorTransform = clrXform;
					
					_txSwingsClip.getChildAt(1).visible = false;
				} else {
					mc = _txSwingsClip.getChildAt(0) as MovieClip;
					mc.gotoAndStop( _strokes%10? _strokes%10: 10 );
					mc.x = 8;
					mc.transform.colorTransform = clrXform;
					
					mc = _txSwingsClip.getChildAt(1) as MovieClip;
					mc.gotoAndStop( _strokes/10 >>0 );
					mc.visible = true;
					mc.x = -8;
					mc.transform.colorTransform = clrXform;
				}*/
				
			}
			
			//{ -- event listeners
			private function _onBallRelease():void
			{
				_strokes++;
				_ani1.frameSpeed = _ani2.frameSpeed = GameLoop.instance.timeFrameRate;
				_updateSwings();
			}
			
			private function _onAnyMoveStart():void
			{
				_btnReset.enabled = true;
				_btnReset.alpha = 1;
			}
			
			private function _onAllMoveStop():void
			{
				if ( !BallCtrl.instance.getPrimary() || BallCtrl.instance.getPrimary().isOnHole )
					return;
				
				_checkStrokeParLimit();
				
				markBallPosition( BallCtrl.instance.getPrimary() );
			}
			
			private function _onPutt():void
			{
				_btnPause.enabled = false;
				_btnPause.alpha = .25;
				
				if ( !(GameRoot.screen is EditorScreen) ) {
					_btnReset.enabled = false;
					_btnReset.alpha = .25;
					_contents.mouseEnabled = false;
				}
				
				_successTimer.start();
				
				if ( Session.isOnPlay )
					GameAudio.instance.stopMusic( _successTimer.delay*.9 );
				
				markBallPosition( BallCtrl.instance.getPrimary() );
			}
			
			private function _onCamMove( x:Number, y:Number ):void
			{
				_pointerBall.visible = _pointerHole.visible = false;
				
				var camRect:AABB = Session.world.camera.bounds;
				var ball:Ball = BallCtrl.instance.getPrimary();
				var hole:Hole = BallCtrl.instance.getHole();
				
				if ( ball && (ball.ballRender.isOffScreen || !camRect.isContaining(ball.p.x, ball.p.y)) ) {
					_pointerBall.visible = true;
					_pointerBall.x = MathUtils.limit( ball.p.x -camRect.min.x, 20, camRect.width -20 ) +HUD_WIDTH;
					_pointerBall.y = MathUtils.limit( ball.p.y -camRect.min.y, 20, camRect.height -20 );
					_icoBall.rotation = -(_pointerBall.rotation = Trigo.getAngle( ball.p.x -camRect.min.x -(_pointerBall.x -HUD_WIDTH), ball.p.y -camRect.min.y -_pointerBall.y ));
				}
				
				if ( hole && (hole.holeRender.isOffScreen || !camRect.isContaining(hole.p.x, hole.p.y)) ) {
					_pointerHole.visible = true;
					_pointerHole.x = MathUtils.limit( hole.p.x -camRect.min.x, 20, camRect.width -20 ) +HUD_WIDTH;
					_pointerHole.y = MathUtils.limit( hole.p.y -camRect.min.y, 20, camRect.height -20 );
					_icoHole.rotation = -(_pointerHole.rotation = Trigo.getAngle( hole.p.x -camRect.min.x -(_pointerHole.x -HUD_WIDTH), hole.p.y -camRect.min.y -_pointerHole.y ));
				}
				
				_clipGhost.x = -camRect.min.x;
				_clipGhost.y = -camRect.min.y;
			}
			
			private function _onCamHitEdge( edge:int ):void
			{
				if ( Session.instance.movingEntitiesCount ) {
					_scrollUp.visible = _scrollDown.visible = _scrollLeft.visible = _scrollRight.visible = false;
					
				} else {
					_scrollUp.visible = !((edge&1) >0);
					_scrollDown.visible = !((edge&2) >0);
					_scrollLeft.visible = !((edge&4) >0);
					_scrollRight.visible = !((edge&8) >0);
				}
				
			}
			//}
			
			private function _showSuccessWindow( e:Event=null):void
			{
				CONFIG::release {
					if ( _flag.isTrue(FLAG_FIRST_PUTT) ) {
						_flag.setFalse( FLAG_FIRST_PUTT ); _flag.setFalse( FLAG_FIRST_QUIT );
						SaveDataMngr.instance.saveCustom( 'putt' + Session.instance.map.levelIndex, 1, true );
						SaveDataMngr.instance.saveCustom( 'quit' + Session.instance.map.levelIndex, 1, true );
						Tracker.i.levelAverage( 'firstQuitDuration', Session.instance.map.name, (getTimer()-_timeStarted)/1000 >>0 );
					}
				}
				
				if ( tutorial ) tutorial.hide();
				_successTimer.delay = 1100;
				
				Window.removeAllWindows();
				var win:Window;
				addChild( win = new PopSuccess );
				win.show();
			}
			
			
			private function _drawGhosts():void
			{
				if ( _ghost.length > 1 ) {
					var g:Graphics = _clipGhost.graphics;
					g.clear();
					g.beginFill( 0x191919, 1 );
					
					var j:int = _clipGhost.numChildren;
					while ( j-- ) _clipGhost.removeChildAt( j );
					
					var ap:Array, dx:int, dy:int, i:int, r:Number, d:Number, txf:TextField;
					for each ( var a:Array in _ghost ) {
						
						if ( ap && ap.length < 4 ) {
							dx = a[0] -ap[0];
							dy = a[1] -ap[1];
							r = Trigo.getRadian( dx, dy );
							d = FastMath.sqrt( dx*dx +dy*dy );
							i = 0;
							while( i+10 < d ) {
								i += 10;
								g.drawCircle( ap[0] +FastMath.cos(r)*i, ap[1] +FastMath.sin(r)*i, 1 );
							}
							
							if ( ap.length > 2 && !isNaN(ap[2]) ) {
								/*if ( ap[2] >= 90 || ap[2] < -90 ) {
									_clipGhost.addChild( txf = UIFactory.createTextField( ((ap[2]<0? 360:0) +ap[2]).toFixed(1) +'°', 'ballNote2', 'none', ap[0]+FastMath.cos(r)*65, ap[1]+FastMath.sin(r)*65 -7) );
									txf.width = 60; txf.height = 13;
									txf.rotation = ap[2] +180;
									
								} else {
									_clipGhost.addChild( txf = UIFactory.createTextField( ((ap[2]<0? 360:0) +ap[2]).toFixed(1) +'°', 'ballNote2', 'none', ap[0]+FastMath.cos(r)*10, ap[1]+FastMath.sin(r)*1 -5) );
									txf.width = 60; txf.height = 13;
									txf.rotation = ap[2];
								}*/
								g.drawCircle( ap[0], ap[1], 4 );
								
							} else 
								g.drawCircle( a[0], a[1], 1 );
							
						}
						
						ap = a;
					}
					if ( a.length < 3 ) g.drawCircle( a[0], a[1], 3 );
				}
				_ghost.splice( 0, _ghost.length );
			}
			
			
	}

}