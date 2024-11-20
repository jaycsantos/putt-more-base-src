package pb2.game.ctrl 
{
	import apparat.math.FastMath;
	import Box2D.Common.b2internal;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Contacts.b2Contact;
	import com.greensock.easing.*;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.math.*;
	import com.jaycsantos.sound.GameSounds;
	import com.jaycsantos.util.*;
	import flash.display.*;
	import flash.events.*;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.utils.*;
	import org.osflash.signals.Signal;
	import pb2.game.entity.b2.b2Entity;
	import pb2.game.entity.*;
	import pb2.game.entity.render.BallRender;
	import pb2.game.*;
	import pb2.GameAudio;
	import pb2.screen.*;
	import pb2.screen.tutorial.Tutorial01;
	import pb2.screen.ui.*;
	import pb2.util.pb2internal;
	import Playtomic.Log;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class BallCtrl 
	{
		public static const instance:BallCtrl = new BallCtrl
		
		public static const POWER_SPEED:Number = 1
		
		public static var angle:Number, power:Number
		public static var strokes:uint=0
		
		public static const onMousePress:Signal=new Signal, onMouseCancel:Signal=new Signal, onMouseRelease:Signal=new Signal
		public static const onBallBounce:Signal=new Signal(uint), onPutt:Signal=new Signal
		
		public function BallCtrl() 
		{
			if ( instance ) throw new Error('[pb2.game.ctrl.BallCtrl] Singleton class, use static property instance');
			
			var g:Graphics, mc:MovieClip, sp:Sprite, shp:Shape, txf:TextField, i:int, j:int, k:String, a:Array;
			
			_buffer = new Sprite;
			_buffer.name = 'ball ctrl';
			_buffer.visible = _buffer.mouseEnabled = _buffer.mouseChildren = false;
			
			
			_buffer.addChild( _clipAngle = PuttBase2.assets.createDisplayObject('mouse.ctrl.angle') as MovieClip ); _clipAngle.name = 'clip angle';
			_buffer.addChild( _clipPower = PuttBase2.assets.createDisplayObject('mouse.ctrl.power') as MovieClip ); _clipPower.name = 'clip power';
			
			_clipPower.addChild( _clipPwrMark = PuttBase2.assets.createDisplayObject('mouse.ctrl.powerMarker') as MovieClip );
			_clipPower.addChild( _clipPwrMark2 = PuttBase2.assets.createDisplayObject('mouse.ctrl.powerMarker') as MovieClip );
			_clipPwrMark.stop(); _clipPwrMark.name = 'clip power mark';
			_clipPwrMark2.stop(); _clipPwrMark2.name = 'clip power mark 2';
			_clipPower.addChild( _clipPwrMark.mask = PuttBase2.assets.createDisplayObject('mouse.ctrl.powerMask') as Sprite );
			_clipPower.addChild( _clipPwrMark2.mask = PuttBase2.assets.createDisplayObject('mouse.ctrl.powerMask') as Sprite );
			
			_buffer.addChild( _txfAngle = UIFactory.createFixedTextField('', 'ballNote', 'none', -15, -7) );
			_txfAngle.width = 30; _txfAngle.height = 12;
			
			_buffer.addChild( _clipSpin = PuttBase2.assets.createDisplayObject('mouse.ctrl.spin') as MovieClip );
			_clipSpin.name = 'clip ball'; _clipSpin.visible = false;
			
			
			for each ( mc in [_clipAngle, _clipPower, _clipSpin] ) {
				mc.stop();
				mc.blendMode = 'overlay';
			}
			
			_powerDelta = 1;
			_releaseTimer = new Timer( 100, 1 );
			_releaseTimer.addEventListener( TimerEvent.TIMER_COMPLETE, _releaseBall );
		}
		
		
		public function update():void
		{
			if ( _isMdown ) {
				var bx:int = _buffer.x = _ball.render.buffer.x;
				var by:int = _buffer.y = _ball.render.buffer.y;
				
				if ( _clipAngle.visible ) {
					var dx:int = _buffer.mouseX;
					var dy:int = _buffer.mouseY;
					var dist:int = Math.sqrt( dx*dx +dy*dy );
					
					angle = Math.round( Trigo.getAngle(dx, dy) );
					
					
					//power = (dist -_ball.radius)*.7 >>0;
					power = (dist -25)*.7 >>0;
					
					var input:UserInput = UserInput.instance;
					if ( input.isKeyDown(KeyCode.SHIFT) )
						power = power /2 >>0;
					else if ( input.isKeyDown(KeyCode.CONTROL) )
						power = power *2 >>0;
					else if ( input.isKeyDown(KeyCode.X) )
						power = 100;
					
					/*if ( UserInput.instance.isKeyDown(KeyCode.SHIFT) )
						power = (dist -_ball.radius*1.1) *.086 >>0;
					else if ( UserInput.instance.isKeyDown(KeyCode.CONTROL) )
						power = (dist -_ball.radius*1.1) *.2279 >>0// *.086 *2.65 >>0;
					else if ( UserInput.instance.isKeyDown(KeyCode.X) )
						power = 100;
					else
						power = (dist -_ball.radius)*.9;*/
						
					/*power = MathUtils.limit( power +POWER_SPEED*_powerDelta, 1, 100 );
					if ( power == 1 || power == 100 ) _powerDelta *= -1;/**/
					
					CONFIG::debug {
						_txfAngle.text = ((angle < 0? 360:0) +angle) +'°';
					}
					power = MathUtils.limit( power, 0, 100 );
					_clipAngle.rotation = _clipPower.rotation = angle;
					_clipAngle.gotoAndStop( 5 +Math.round(power/5) );
					//_clipAngle.gotoAndStop( Math.ceil((dist-Registry.ballRadius)/5) );
					_clipPower.gotoAndStop( Math.round(power) );
					
					//_clipSpin.gotoAndPlay( (_clipSpin.currentFrame+(power/7>>0)) %100 +1 );
					//_clipSpin.x = _buffer.mouseX;
					//_clipSpin.y = _buffer.mouseY;
					_clipSpin.visible = false;
					_clipSpin.scaleX = _clipSpin.scaleY = .7;
					
					/*var est:Number = Math.min( Math.max(dist -_ball.radius*1.1, 0)/1000, 1 ) *.84;
					_clipPwrMark.gotoAndStop( est*100 >>0 );
					_clipPwrMark2.gotoAndStop( Math.min(est * 265 >> 0, 100) );/**/
					
					
					if ( UserInput.instance.isMouseReleased ) {
						_isMdown = _buffer.visible = _clipSpin.visible = false;
						_clipSpin.stop();
						_clipSpin.scaleX = _clipSpin.scaleY = 1;
						Mouse.show();
						if ( release() ) {
							onMouseRelease.dispatch();
						} else {
							onMouseCancel.dispatch();
							CameraFocusCtrl.followMouse();
						}
					}
					
				} else
				if ( UserInput.instance.isMouseReleased ) {
					_isMdown = false;
					_clipSpin.scaleX = _clipSpin.scaleY = 1.1;
					CameraFocusCtrl.followMouse();
					onMouseCancel.dispatch();
					Mouse.show();
				}
				else {
					_clipSpin.visible = true;
					_clipSpin.scaleX = _clipSpin.scaleY = 1.1;
					_clipSpin.x = 0; _clipSpin.y = 0;
					//_clipSpin.gotoAndPlay( (_clipSpin.currentFrame+10) %100 +1 );
				}
				
			} else 
			if ( _buffer.visible && _ball ) {
				if ( _ball.render.isRendered ) {
					_buffer.x = _ball.render.buffer.x;
					_buffer.y = _ball.render.buffer.y;
				} else {
					_buffer.x = _buffer.y = -100;
				}
				_clipSpin.x = 0; _clipSpin.y = 0;
				_clipSpin.visible = _buffer.visible;
			}
			
		}
		
		
		public function activate( canvas:DisplayObjectContainer ):void
		{
			canvas.addChild( _buffer );
			
			angle = _clipAngle.rotation = _clipPower.rotation = MathUtils.randomInt( -179, 180 );
			_clipPower.gotoAndStop( power = 1 );
			
			_buffer.visible = _clipSpin.visible = false; _clipSpin.stop();
			_clipAngle.visible = _clipPower.visible = _txfAngle.visible = false;
			_clipSpin.x = 0; _clipSpin.y = 0;
			_buffer.x = _buffer.y = -100;
			
			Session.instance.onEntitiesMoveStop.add( _onAllStop );
			Session.instance.onEntityMoveStart.add( _onAllMove );
			Session.instance.onReset.add( _onRestart );
			strokes = 0;
		}
		public function deactivate():void
		{
			if ( _buffer.parent )
				_buffer.parent.removeChild( _buffer );
			
			setPrimary( null );
			
			Session.instance.onEntitiesMoveStop.remove( _onAllStop );
			Session.instance.onEntityMoveStart.remove( _onAllMove );
		}
		
		
		public function getPrimary():Ball
		{
			return _ball;
		}
		public function setPrimary( value:Ball ):void
		{
			if ( _ball && _ball != value ) {
				_ball.b2internal::unsetAsPrimary();
				_ball.ballRender.clip.removeEventListener( MouseEvent.MOUSE_DOWN, _md );
				_ball.ballRender.clip.removeEventListener( MouseEvent.MOUSE_OVER, _movr );
				_ball.ballRender.clip.removeEventListener( MouseEvent.MOUSE_OUT, _mout );
				_ball.onSolveContact.remove( _onBallSolveContact );
				_ball.onContact.remove( _onBallContact );
				//_ball.onContactEnd.remove( _onBallContact );
				
				if ( GameRoot.screen is EditorScreen )
					EditorScreen.onModeChange.remove( _onEditorModeToggle );
				_clipSpin.stop();
			}
			
			if ( value && _ball != value ) {
				value.b2internal::setAsPrimary();
				value.ballRender.clip.addEventListener( MouseEvent.MOUSE_DOWN, _md, false, 0, true );
				value.ballRender.clip.addEventListener( MouseEvent.MOUSE_OVER, _movr, false, 0, true );
				value.ballRender.clip.addEventListener( MouseEvent.MOUSE_OUT, _mout, false, 0, true );
				value.onSolveContact.add( _onBallSolveContact );
				value.onContact.add( _onBallContact );
				//value.onContactEnd.add( _onBallContact );
				
				if ( Session.isOnEditor )
					EditorScreen.onModeChange.add( _onEditorModeToggle );
				
				_buffer.visible = _clipSpin.visible = true; _clipSpin.play();
			}
			
			_ball = value;
		}
		public function isPrimary( value:b2Entity ):Boolean
		{
			return value != null && value == _ball;
		}
		
		
		public function getHole():Hole
		{
			return _hole;
		}
		public function setHole( value:Hole ):void
		{
			if ( value ) value.onPutt.add( _onBallPutt );
			else if ( _hole ) _hole.onPutt.remove( _onBallPutt );
			
			_hole = value;
		}
		
		
		public function release( e:MouseEvent=null ):Boolean
		{
			if ( Session.instance.isBusy || !_ball || _ball.body.IsAwake() || _ball.isOnHole || Session.instance.movingEntitiesCount )
				return false;
			if ( GameRoot.screen is EditorScreen && EditorScreen.editMode ) {
				EditorScreen( GameRoot.screen ).toolBar.test();
				return false;
			}
			if ( _releaseTimer.running || isNaN(angle) || !power || _mDownTime > getTimer() ) {
				_buffer.visible = _clipSpin.visible = true; _clipSpin.play();
				_clipAngle.visible = _clipPower.visible = _txfAngle.visible = false;
				return false;
			}
			
			if ( power > 70 )
				GameSounds.play( GameAudio.DRIVE3, 0, 0, (power-40)/60 );
			else if ( power > 30 )
				GameSounds.play( GameAudio.DRIVE2, 0, 0, power/70 );
			else
				GameSounds.play( GameAudio.DRIVE1, 0, 0, (power+30)/60 );
			
			_releaseTimer.start();
			return true;
		}
		
		
		public function getVolumeFromAfar( p:Vector2D ):Number
		{
			if ( !_ball ) return .95;
			
			return MathUtils.limit((650 - _ball.p.subtractedBy(p).length) / 650, 0, 0.95);
		}
		
			// -- private --
			
			private var _ball:Ball, _hole:Hole
			private var _buffer:Sprite, _clipSpin:MovieClip
			private var _clipAngle:MovieClip, _clipPower:MovieClip, _clipPwrMark:MovieClip, _clipPwrMark2:MovieClip, _txfAngle:TextField
			
			private var _releaseTimer:Timer, _isMdown:Boolean, _mDownTime:uint, _powerDelta:int
			
			
			private function _releaseBall( e:Event=null ):void
			{
				var r:Number = Trigo.DEG_TO_RAD *angle;//Trigo.getRadian( dx, dy );
				var f:Number = Registry.BALL_MaxSpeed *.95 *Math.round(power)/100;//Sine.easeIn(power, 0, 1, 1);
				
				_ball.body.SetLinearVelocity( new b2Vec2(FastMath.cos(r)*f, FastMath.sin(r)*f) );
				_ball.body.SetLinearDamping( Registry.BALL_b2BodyDef.linearDamping );
				_ball.body.SetAwake( true );
				
				CameraFocusCtrl.followBall( _ball );
				
				if ( HudGame.instance ) {
					HudGame.instance.onBallRelease.dispatch();
					HudGame.instance.markBallPosition( _ball, angle );
				}
				
				strokes++;
			}
			
			
			private function _md( e:MouseEvent ):void
			{
				if ( Session.instance.isBusy ) return;
				if ( !_ball || _ball.body.IsAwake() || _ball.isOnHole || Session.instance.movingEntitiesCount ) return;
				
				_mDownTime = getTimer() +250;
				_isMdown = true;
				CameraFocusCtrl.followMouseBall( _ball );
				Session.world.camera.signalCentered.remove( CameraFocusCtrl.followMouse );
				onMousePress.dispatch();
			}
			
			private function _movr( e:MouseEvent ):void
			{
				if ( Session.instance.isBusy ) return;
				if ( !_ball || _ball.body.IsAwake() || _ball.isOnHole || Session.instance.movingEntitiesCount ) return;
				
				if ( _isMdown ) {
					_clipAngle.visible = _clipPower.visible = _txfAngle.visible = false;
					Mouse.show();
					
				} else
					_clipSpin.scaleX = _clipSpin.scaleY = 1.1;
			}
			
			private function _mout( e:MouseEvent ):void
			{
				if ( Session.instance.isBusy ) return;
				if ( !_ball || _ball.body.IsAwake() || _ball.isOnHole || Session.instance.movingEntitiesCount ) return;
				
				if ( _isMdown ) {
					_clipAngle.visible = _clipPower.visible = _txfAngle.visible = true;
					power = 1;
					Mouse.hide();
					
				} else
					_clipSpin.scaleX = _clipSpin.scaleY = 1;
			}
			
			
			private function _onBallPutt( ball:Ball ):void
			{
				if ( ball == _ball )
					Session.instance.onPutt.dispatch();
			}
			
			private function _onBallSolveContact( normalImpulse:Number ):void
			{
				onBallBounce.dispatch( MathUtils.limit(normalImpulse *200 >>0, 0, 100) );
			}
			
			private function _onBallContact( contact:b2Contact, thisFixt:b2Fixture, fixt:b2Fixture ):void
			{
				if ( contact.IsSensor() ) return;
				
				if ( HudGame.instance )
					HudGame.instance.markBallPosition( _ball );
			}
			
			
			private function _onAllMove():void
			{
				_isMdown = _buffer.visible = _clipSpin.visible = false;
				_clipSpin.stop();
				_clipSpin.scaleX = _clipSpin.scaleY = 1;
				Mouse.show();
			}
			
			private function _onAllStop():void
			{
				if ( _ball && !_ball.isOnHole )
					if ( !Session.isOnEditor || !EditorScreen.editMode ) {
						_buffer.visible = _clipSpin.visible = true; _clipSpin.play();
						_clipAngle.visible = _clipPower.visible = _txfAngle.visible = false;
						_clipSpin.x = 0; _clipSpin.y = 0;
						if ( _ball.render.isRendered ) {
							_buffer.x = _ball.render.buffer.x;
							_buffer.y = _ball.render.buffer.y;
						} else {
							_buffer.x = _buffer.y = -100;
						}
						
						CameraFocusCtrl.followMouse();
						if ( HudGame.instance )
							HudGame.instance.markBallPosition( _ball );
					}
			}
			
			private function _onRestart():void
			{
				if ( _ball && (!Session.isOnEditor || !EditorScreen.editMode) ) {
					_buffer.visible = _clipSpin.visible = true; _clipSpin.play();
					_clipAngle.visible = _clipPower.visible = _txfAngle.visible = false;
					_clipSpin.x = 0; _clipSpin.y = 0;
					if ( _ball.render.isRendered ) {
						_buffer.x = _ball.render.buffer.x;
						_buffer.y = _ball.render.buffer.y;
					} else {
						_buffer.x = _buffer.y = -100;
					}
					
					Session.world.camera.signalCentered.addOnce( CameraFocusCtrl.followMouse );
					CameraFocusCtrl.followBall( _ball );
					//CameraFocusCtrl.followMouse();
				}
				strokes = 0;
			}
			
			
			private function _onEditorModeToggle():void
			{
				if ( EditorScreen.editMode )
					_buffer.visible = false;
			}
			
			
	}

}