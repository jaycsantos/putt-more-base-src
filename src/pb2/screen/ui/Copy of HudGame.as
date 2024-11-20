package pb2.screen.ui 
{
	import apparat.math.FastMath;
	import com.jaycsantos.game.*;
	import com.jaycsantos.math.*;
	import com.jaycsantos.util.KeyCode;
	import com.jaycsantos.util.UserInput;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.*;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import org.osflash.signals.Signal;
	import pb2.game.ctrl.*;
	import pb2.game.entity.b2.*;
	import pb2.game.entity.*;
	import pb2.game.MapData;
	import pb2.game.Session;
	import pb2.GameAudio;
	import pb2.screen.*;
	import pb2.screen.ui.toolbox.ToolBoxNode;
	import pb2.screen.window.*;
	import pb2.util.pb2internal;
	import Playtomic.Log;
	
	/**
	 * ...
	 * @author ...
	 */
	public class HudGame_ extends Sprite implements IGameObject
	{
		public static const HUD_WIDTH:uint = 38
		public static const NODE_GAP:uint = 39
		public static const NODE_COUNT:uint = 4
		
		
		public var releaseCallback:Function
		public var onReset:Signal, onPause:Signal, onUnpause:Signal, onBallRelease:Signal
		
		public var window:Pb2Window2, prompt:Pb2Prompt2
		
		
		public function HudGame_() 
		{
			_timeStarted = getTimer();
			mouseEnabled = tabEnabled = false;
			
			addChild( _bg = new Bitmap(new BitmapData(65, PuttBase2.STAGE_HEIGHT, true, 0)) );
			
			//{ -- background
			var sp:Sprite = new Sprite;
			var shape:Shape = new Shape;
			var g:Graphics = shape.graphics;
			var m:Matrix = new Matrix;
			m.createGradientBox( 40, _bg.height, Trigo.HALF_PI );
			g.beginGradientFill( GradientType.LINEAR, [0xDDDDDD,0xBFBFBF], [1,1], [0,255], m );
			g.drawRect( 0, 0, 40, _bg.height );
			g.lineStyle( 1.5, 0x333333 );
			g.moveTo( 40, 0 );
			g.lineTo( 40, _bg.height );
			shape.filters = [new GlowFilter(0x191919, .7, 24, 24, 2)];
			sp.addChild( shape );
			sp.addChild( PuttBase2.assets.createDisplayObject('screen.ui.hud.ctrlBg') );
			
			_bg.bitmapData.draw( sp );
			//}
			
			//{ -- buttons
			addChild( _btnStart = PuttBase2.assets.createDisplayObject('screen.ui.hud.btnStart') as SimpleButton );
			addChild( _btnPause = PuttBase2.assets.createDisplayObject('screen.ui.hud.btnPause') as SimpleButton );
			addChild( _btnRestart = PuttBase2.assets.createDisplayObject('screen.ui.hud.btnRestart') as SimpleButton );
			addChild( _container = new Sprite );
			addChild( _nodeScrollUp = new Sprite );
			addChild( _nodeScrollDown = new Sprite );
			addChild( _btnLock = PuttBase2.assets.createDisplayObject('screen.ui.ico.lock') as MovieClip );
			
			_btnStart.addEventListener( MouseEvent.CLICK, _start, false, 0, true );
			_btnPause.addEventListener( MouseEvent.CLICK, _pause, false, 0, true );
			_btnRestart.addEventListener( MouseEvent.CLICK, _restart, false, 0, true );
			
			_btnRestart.enabled = _btnRestart.mouseEnabled = false;
			_btnRestart.alpha = .5;
			
			
			_container.name = 'node container';
			_container.x = 5; _container.y = 160;
			_container.scrollRect = new Rectangle( -1, 0, 31, 160 );
			_container.addEventListener( MouseEvent.MOUSE_WHEEL, _mw, false, 0, true );
			_container.addEventListener( MouseEvent.MOUSE_DOWN, _md, false, 0, true );
			
			_btnLock.gotoAndStop( (_toolsLock=Boolean(SaveDataMngr.instance.getCustom('hudLock'))) ?2: 1 );
			_btnLock.x = 19; _btnLock.y = _container.y -25;
			_btnLock.buttonMode = true;
			_btnLock.addEventListener( MouseEvent.CLICK, _toolLock_ck, false, 0, true );
			_btnLock.addEventListener( MouseEvent.MOUSE_OVER, _toolLock_movr, false, 0, true );
			_btnLock.addEventListener( MouseEvent.MOUSE_OUT, _toolLock_mout, false, 0, true );
			//}
			
			//{ -- scrolls
			_nodeScrollUp.x = _container.x; _nodeScrollUp.y = _container.y -20;
			_nodeScrollUp.alpha = .3; _nodeScrollUp.buttonMode = true; _nodeScrollUp.visible = _nodeScrollUp.tabEnabled = false;
			_nodeScrollUp.addEventListener( MouseEvent.MOUSE_DOWN, _nodeUp, false, 0, true );
			with ( _nodeScrollUp.graphics ) {
				beginFill( 0, 0 );
				drawRect( 0, 0, 28, 20 );
				endFill();
				beginFill( 0x808080, 1 );
				drawTriangles( Vector.<Number>([14,4,4,16,24,16]) );
				endFill();
			}
			
			_nodeScrollDown.x = _container.x;
			_nodeScrollDown.alpha = .3; _nodeScrollDown.buttonMode = true; _nodeScrollDown.visible = _nodeScrollDown.tabEnabled = false;
			_nodeScrollDown.addEventListener( MouseEvent.MOUSE_DOWN, _nodeDown, false, 0, true );
			with ( _nodeScrollDown.graphics ) {
				beginFill( 0, 0 );
				drawRect( 0, 0, 28, 20 );
				endFill();
				beginFill( 0x808080, 1 );
				drawTriangles( Vector.<Number>([4,4,24,4,14,16]) );
				endFill();
			}
			//}
			
			//{ -- par
			//addChild( _txfSwings = UIFactory.createTextField('', 'hudSwings', 'center', 620, 340) );
			addChild( _txSwingsClip = new Sprite );
			_txSwingsClip.x = 20; _txSwingsClip.y = 345;
			var mc:MovieClip;
			_txSwingsClip.addChild( mc = PuttBase2.assets.createDisplayObject('screen.ui.number.impact32') as MovieClip );
			mc.gotoAndStop( 10 );
			_txSwingsClip.addChild( mc = PuttBase2.assets.createDisplayObject('screen.ui.number.impact32') as MovieClip );
			mc.gotoAndStop( 1 );
			mc.visible = false;
			
			addChild( _txfPar = UIFactory.createFixedTextField('', 'hudPar', 'center', 17, 375) )
			_txSwingsClip.filters = _txfPar.filters = [new GlowFilter(0x191919,1,4,4,6)];//[new DropShadowFilter(2, 45, 0, 1, 0, 0, 6)];
			//}
			
			//{ -- pointers
			addChild( _pointerBall = PuttBase2.assets.createDisplayObject('screen.ui.hud.offscreenPointer') as Sprite );
			addChild( _pointerHole = PuttBase2.assets.createDisplayObject('screen.ui.hud.offscreenPointer') as Sprite );
			_pointerBall.addChild( _icoBall = PuttBase2.assets.createDisplayObject('screen.ui.ico.golfTee') as Sprite );
			_pointerHole.addChild( _icoHole = PuttBase2.assets.createDisplayObject('screen.ui.ico.holeFlag') as Sprite );
			
			_pointerBall.visible = _pointerHole.visible = false;
			_icoBall.scaleX = _icoBall.scaleY = _icoHole.scaleX = _icoHole.scaleY = .75;
			//}
			
			_nodeList = new Vector.<ToolBoxNode>;
			onReset = new Signal; onPause = new Signal;
			onUnpause = new Signal; onBallRelease = new Signal;
			onBallRelease.add( _onBallRelease );
			
			_successTimer = new Timer( 1500, 1 );
			_successTimer.addEventListener( TimerEvent.TIMER, _showSuccessWindow, false, 0, true );
		}
		
		public function init( data:Object = null ):void
		{
			for ( var k:String in data )
				_nodeList.push( _container.addChild(new ToolBoxNode(k, data[k])) );
			
			_nodeScrollUp.visible = _nodeScrollDown.visible = _nodeList.length > NODE_COUNT;
			_dirty = true;
			
			if ( !(this is HudGameEditor) )
				Session.instance.onPutt.add( _onPutt );
			
			_txfPar.text = 'par '+ Session.instance.map.par;
			_swings = 0;
			_updateSwings();
			_btnLock.visible = _nodeList.length>0 || this is HudGameEditor;
			
			var map:MapData = Session.instance.map;
			var xml:XML = SaveDataMngr.instance.getLevelData( map.name, map.hash );
			_firstPutt = xml !=null && uint(xml.@score) > 0;
			
			Session.instance.onEntitiesMoveStop.add( _onAllMoveStop );
			Session.instance.onBounce.add( _onBounce );
			Session.world.camera.signalMove.add( _onCamMove );
		}
		
		public function dispose():void
		{
			CONFIG::release {
			if ( ! _firstPutt && !Session.instance.map.isCustom )
				Log.LevelAverageMetric( 'putt_first_exit_time', Session.instance.map.name, (getTimer() - _timeStarted)/1000 >>0, true );
			}
			
			if ( parent ) parent.removeChild( this );
			
			_btnStart.removeEventListener( MouseEvent.CLICK, _start );
			_btnPause.removeEventListener( MouseEvent.CLICK, _pause );
			_btnRestart.removeEventListener( MouseEvent.CLICK, _restart );
			_container.removeEventListener( MouseEvent.MOUSE_WHEEL, _mw );
			_container.removeEventListener( MouseEvent.MOUSE_DOWN, _md );
			
			_nodeScrollDown.removeEventListener( MouseEvent.MOUSE_DOWN, _nodeDown );
			_nodeScrollUp.removeEventListener( MouseEvent.MOUSE_DOWN, _nodeUp );
			
			_btnLock.removeEventListener( MouseEvent.CLICK, _toolLock_ck );
			_btnLock.removeEventListener( MouseEvent.MOUSE_OVER, _toolLock_movr );
			_btnLock.removeEventListener( MouseEvent.MOUSE_OUT, _toolLock_mout );
			
			_successTimer.removeEventListener( TimerEvent.TIMER, _showSuccessWindow );
			
			
			onReset.removeAll(); onReset = null;
			onPause.removeAll(); onPause = null;
			onUnpause.removeAll(); onUnpause = null;
			
			removeWindow();
			removePrompt();
		}
		
		public function clean():void
		{
			for each ( var n:ToolBoxNode in _nodeList ) n.dispose();
			_nodeList.splice( 0, _nodeList.length );
			
			var i:int = _container.numChildren;
			while ( i-- ) _container.removeChildAt( i );
		}
		
		
		public function update():void
		{
			var input:UserInput = UserInput.instance;
			var rect:Rectangle, len:int = _nodeList.length;
			
			if ( _dirty ) {
				_dirty = false;
				var n:ToolBoxNode, i:int = len, dy:Number;
				while ( i-- ) {
					dy = i*37 -_nodeList[i].y;
					if ( dy ) {
						_dirty = true;
						_nodeList[i].y += Math.abs(dy)>1? dy/8: dy;
					}
				}
				rect = _container.scrollRect;
				//rect.height = Math.min(len*NODE_GAP, 240);
				rect.y = MathUtils.limit( rect.y, 0, (len*NODE_GAP -15) -rect.height );
				_container.scrollRect = rect;
				
				_nodeScrollUp.visible = _nodeScrollDown.visible = len > NODE_COUNT;
				_container.y = _nodeScrollUp.y +(_nodeScrollUp.visible? _nodeScrollUp.height: 4);
				_nodeScrollDown.y = _container.y +rect.height +(!_nodeScrollDown.visible? -_nodeScrollDown.height: 0);
				_nodeScrollUp.alpha = (_nodeScrollUp.useHandCursor = rect.y>0) ? 1: .3;
				_nodeScrollDown.alpha = (_nodeScrollDown.useHandCursor = rect.y<(len*NODE_GAP-15 -rect.height)) ? 1: .3;
				
			} else 
			if ( len > NODE_COUNT && _nodeScroll ) {
				rect = _container.scrollRect;
				
				if ( _nodeScroll < 0 )
					rect.y = Math.max( rect.y -5, 0 );
				else
					rect.y = Math.min( rect.y +5, (len*NODE_GAP-15) -rect.height );
				_container.scrollRect = rect;
				
				_nodeScrollUp.alpha = (_nodeScrollUp.useHandCursor = rect.y>0) ? 1: .3;
				_nodeScrollDown.alpha = (_nodeScrollDown.useHandCursor = rect.y<(len*NODE_GAP-15 -rect.height)) ? 1: .3;
				if ( input.isMouseReleased ) _nodeScroll = 0;
				
			}
			
			if ( prompt ) prompt.update();
			if ( window ) window.update();
			
			if ( input.isKeyReleased(KeyCode.ESC) )// || input.isFocusLost )
				_pause();
			
		}
		
		
		
		public function storeTool( tile:b2EntityTileTool ):Boolean
		{
			var i:int, j:int, n:ToolBoxNode, type:String = tile.type;
			for each ( n in _nodeList )
				if ( n.type == tile.type ) {
					if ( n.store(tile) ) {
						if ( n.stockCount == 1 ) {
							_nodeList.splice( _nodeList.indexOf(n), 1 );
							
							i = MathUtils.limit( _container.mouseY /NODE_GAP >>0, 0, _nodeList.length );
							for ( j = 0; j < i; j++ )
								if ( !_nodeList[j].stockCount ) {
									i = j; break;
								}
							
							_nodeList.splice( i, 0, n );
							_container.setChildIndex( n, _container.numChildren-1 );
							n.y = _container.mouseY -14;
							_dirty = true;
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
							_container.setChildIndex( n, 0 );
							_dirty = true;
						}
						return ent;
					}
					break;
				}
			
			return null;
		}
		
		
		public function get swings():uint
		{
			return _swings;
		}
		
		public function get unusedItems():uint
		{
			var i:int;
			
			for each ( var n:ToolBoxNode in _nodeList )
				i += n.stockCount;
			
			return i;
		}
		
		public function get unusedItemList():Vector.<ToolBoxNode>
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
		
		public function get totalBounces():uint
		{
			return _bounce;
		}
		
		
		public function restart( everything:Boolean=false ):void
		{
			var tile:b2EntityTile, tileMap:Vector.<Vector.<b2EntityTile>> = Session.instance.tileMap;
			
			var map:MapData = Session.instance.map;
			if ( !(GameRoot.screen is EditorScreen) && !map.isCustom ) {
				Log.LevelCounterMetric( 'Restarts', map.name );
				if ( _swings )
					Log.LevelAverageMetric( 'SwingsOnRestart', map.name, _swings );
			}
			
			if ( !everything && (_toolsLock || GameRoot.screen is EditorScreen) ) {
				for each ( var list:Vector.<b2EntityTile> in tileMap )
					for each ( tile in list )
						if ( tile ) tile.useDefault();
				
			}
			else {
				for ( var i:int; i < tileMap.length; i++ )
					for ( var j:int=0; j < tileMap[i].length; j++ )
						if ( tileMap[i][j] ) {
							tile = tileMap[i][j];
							if ( tile.isToolkit ) {
								if ( storeTool(tile as b2EntityTileTool) ) {
									tile.dispose(); 
									tileMap[i][j] = null;
								}
								
							} else {
								tile.useDefault();
							}
						}
			}
			
			
			onReset.dispatch();
			_swings = 0; _bounce = 0;
			_updateSwings();
			
			//CameraFocusCtrl.instance.enable();
			
			_btnPause.enabled = _btnPause.mouseEnabled = true;
			_btnPause.alpha = 1;
			_btnRestart.enabled = _btnRestart.mouseEnabled = false;
			_btnRestart.alpha = .5;
			_btnStart.enabled = _btnStart.mouseEnabled = true;
			_btnStart.alpha = 1;
			
			Session.instance.start();
		}
		
		
		public function removeWindow():void
		{
			if ( window ) window.dispose();
			window = null;
		}
		
		public function removePrompt():void
		{
			if ( prompt ) prompt.dispose();
			prompt = null;
		}
		
		
			// -- private --
			
			protected var _bg:Bitmap, _btnStart:SimpleButton, _btnPause:SimpleButton, _btnRestart:SimpleButton
			protected var _container:Sprite, _nodeScrollUp:Sprite, _nodeScrollDown:Sprite, _nodeScroll:int
			protected var _nodeList:Vector.<ToolBoxNode>
			protected var _dirty:Boolean, _swings:uint, _bounce:uint, _timeStarted:uint, _firstPutt:Boolean
			
			protected var _btnLock:MovieClip, _toolsLock:Boolean
			protected var _txfPar:TextField, _txSwingsClip:Sprite
			protected var _prompt:Pb2Prompt2, _successTimer:Timer
			
			protected var _pointerHole:Sprite, _pointerBall:Sprite, _icoHole:Sprite, _icoBall:Sprite
			
			
			protected function _start( e:MouseEvent ):void
			{
				BallCtrl.instance.release();
			}
			
			private function _pause( e:MouseEvent=null ):void
			{
				if ( window ) return;
				
				Session.instance.stop();
				CameraFocusCtrl.instance.disable();
				onPause.dispatch();
				
				addChild( window = new PauseWindow );
				window.onHidden.addOnce( removeWindow );
				window.onHidden.addOnce( onUnpause.dispatch );
				window.onHidden.addOnce( Session.instance.start );
				window.onHidden.addOnce( CameraFocusCtrl.instance.enable );
				window.show();
			}
			
			private function _restart( e:MouseEvent ):void
			{
				restart();
			}
			
			
			// -- prompt over par
			private function _checkIsWayOverPar():void
			{
				if ( BallCtrl.instance.getPrimary() && BallCtrl.instance.getPrimary().isOnHole ) return;
				
				if ( GameRoot.screen is PlayScreen ) {
					if ( _swings >= Session.instance.map.par + 20 ) {
						//CameraFocusCtrl.instance.disable();
					}
				} else if ( GameRoot.screen is EditorScreen ) {
					
				}
			}
			
			
			
			// -- mouse
			private function _md( e:MouseEvent ):void
			{
				if ( Session.instance.movingEntitiesCount ) return;
				
				var i:int = (_container.mouseY /NODE_GAP) <<0;
				if ( i >= 0 && i < _nodeList.length && releaseCallback != null ) {
					var ent:b2EntityTileTool = releaseTool( _nodeList[i].type );
					if ( ent )
						releaseCallback( ent );
				}
			}
			
			private function _mw( e:MouseEvent ):void
			{
				var len:uint = _nodeList.length;
				if ( len > NODE_COUNT ) {
					var rect:Rectangle = _container.scrollRect;
					rect.y = MathUtils.limit( rect.y -FastMath.sign(e.delta)*10, 0, (len*NODE_GAP-15) -rect.height );
					_container.scrollRect = rect;
					
					_nodeScrollUp.alpha = (_nodeScrollUp.useHandCursor = rect.y>0) ? 1: .3;
					_nodeScrollDown.alpha = (_nodeScrollDown.useHandCursor = rect.y<(len*NODE_GAP-15 -rect.height)) ? 1: .3;
				}
			}
			
			
			private function _nodeUp( e:MouseEvent ):void
			{
				_nodeScroll = -1;
			}
			
			private function _nodeDown( e:MouseEvent ):void
			{
				_nodeScroll = 1;
			}
			
			
			private function _toolLock_ck( e:MouseEvent ):void
			{
				_btnLock.gotoAndStop( (_toolsLock=(_btnLock.currentFrame == 1)) ?2: 1 );
				SaveDataMngr.instance.saveCustom( 'hudLock', _btnLock.currentFrame == 2 ? 1: 0, false );
			}
			private function _toolLock_movr( e:MouseEvent ):void
			{
				_btnLock.scaleX = _btnLock.scaleY = 1.25;
			}
			private function _toolLock_mout( e:MouseEvent ):void
			{
				_btnLock.scaleX = _btnLock.scaleY = 1;
			}
			
			
			private function _onBallRelease():void
			{
				_btnRestart.enabled = _btnRestart.mouseEnabled = true;
				_btnRestart.alpha = 1;
				_btnStart.enabled = _btnStart.mouseEnabled = false;
				_btnStart.alpha = .5;
				
				_swings++;
				_updateSwings();
			}
			
			private function _updateSwings():void
			{
				var clrXform:ColorTransform;
				if ( _swings == 0 )
					clrXform = new ColorTransform( 0, 0, 0, 1, 204, 204, 204, 0 );
				else if ( _swings < Session.instance.map.par )
					clrXform = new ColorTransform( 0, 0, 0, 1, 0, 204, 0, 0 );
				else if ( _swings == Session.instance.map.par )
					clrXform = new ColorTransform( 0, 0, 0, 1, 204, 204, 0, 0 );
				else
					clrXform = new ColorTransform( 0, 0, 0, 1, 204, 51, 0, 0 );
				
				
				var mc:MovieClip;
				if ( _swings < 10 ) {
					mc = _txSwingsClip.getChildAt(0) as MovieClip;
					mc.gotoAndStop( _swings? _swings: 10 );
					mc.x = 0;
					mc.transform.colorTransform = clrXform;
					
					_txSwingsClip.getChildAt(1).visible = false;
				} else {
					mc = _txSwingsClip.getChildAt(0) as MovieClip;
					mc.gotoAndStop( _swings%10? _swings%10: 10 );
					mc.x = 8;
					mc.transform.colorTransform = clrXform;
					
					mc = _txSwingsClip.getChildAt(1) as MovieClip;
					mc.gotoAndStop( _swings/10 >>0 );
					mc.visible = true;
					mc.x = -8;
					mc.transform.colorTransform = clrXform;
				}
				
			}
			
			private function _onAllMoveStop():void
			{
				_btnStart.enabled = _btnStart.mouseEnabled = true;
				_btnStart.alpha = 1;
				
				_checkIsWayOverPar();
			}
			
			private function _onBounce():void
			{
				_bounce++;
				trace( '2:bounce #' + _bounce ); 
			}
			
			private function _onPutt():void
			{
				_btnStart.enabled = _btnStart.mouseEnabled = _btnPause.enabled = _btnPause.mouseEnabled = _btnRestart.enabled = _btnRestart.mouseEnabled = false;
				_btnStart.alpha = _btnPause.alpha = _btnRestart.alpha = .5;
				
				_successTimer.start();
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
				
			}
			
			
			private function _showSuccessWindow( e:Event=null):void
			{
				CONFIG::release {
					if ( ! _firstPutt && !Session.instance.map.isCustom ) {
						_firstPutt = true;
						Log.LevelAverageMetric( 'putt_first_time', Session.instance.map.name, (getTimer() - _timeStarted)/1000 >>0, true );
					}
				}
				
				GameAudio.stopMusic( true, 1000 );
				Session.instance.stop();
				CameraFocusCtrl.instance.disable();
				addChild( window = new SuccessWindow );
				window.onHidden.addOnce( removeWindow );
				window.onHidden.addOnce( Session.instance.start );
				window.onHidden.addOnce( CameraFocusCtrl.instance.enable );
				window.show();
			}
			
	}

}