package pb2.screen.tutorial 
{
	import com.jaycsantos.display.animation.AnimationTiming;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.math.Trigo;
	import flash.display.*;
	import pb2.game.Session;
	import pb2.screen.ui.HudGame;
	import pb2.screen.window.Window;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Tutorial01a extends ATutorial 
	{
		
		public function Tutorial01a() 
		{
			var g:Graphics, sp:Sprite, mc:MovieClip, shp:Shape, i:int, j:int, k:String, a:Array;
			
			mouseEnabled = mouseChildren = false;
			
			addChild( _tip1 = PuttBase2.assets.createDisplayObject('screen.tutorial.01aControls') as MovieClip );
			_tip1.stop(); _tip1.visible = false;
			_mouse = _tip1.getChildByName( '_clipMouse' ) as MovieClip;
			_showMouseNormal();
			
			_tip1.addChild( _angle = PuttBase2.assets.createDisplayObject('mouse.ctrl.angle') as MovieClip );
			_angle.addChild( _power = PuttBase2.assets.createDisplayObject('mouse.ctrl.power') as MovieClip );
			_tip1.addChild( _spin = PuttBase2.assets.createDisplayObject('mouse.ctrl.spin') as MovieClip );
			
			_angle.stop(); _power.stop(); _spin.stop();
			_angle.x = _spin.x = 242; 
			_angle.y = _spin.y = 142;
			_angle.alpha = _spin.alpha = .3;
			_angle.blendMode = _spin.blendMode = 'overlay';
			_angle.visible = _spin.visible = false;
			_powerDelta = 1;
			
			
			_animator = new AnimationTiming( MathUtils.intRangeA(321, 331, 1).reverse(), 1, 1 );
			_animator.addMovieClip( _tip1 );
			_animator.addSequenceSet( 'loop', MathUtils.intRangeA(1, 320, 1), 2, true );
			_animator.addSequenceSet( 'hide', MathUtils.intRangeA(321, 331, 1), 1, false );
			
			_animator.addIndexScript( 0, _startTip1, 'loop' );
			_animator.addIndexScript( 35, _showMousePointer, 'loop' );
			_animator.addIndexScript( 43, _ballClick, 'loop' );
			_animator.addIndexScript( 257, _ballRelease, 'loop' );
			
			
			
			addChild( _tip2 = PuttBase2.assets.createDisplayObject('screen.tutorial.04Par') as MovieClip );
			_tip2.stop(); _tip2.visible = false;
			
			_animator2 = new AnimationTiming( MathUtils.intRangeA(1, 11, 1), 1, 1 );
			_animator2.addSequenceSet( 'hide', MathUtils.intRangeA(11, 21, 1), 1, false );
			_animator2.addMovieClip( _tip2 );
		}
		
		override public function dispose():void 
		{
			_animator.dispose(); _animator = null;
			_animator2.dispose(); _animator2 = null;
			_tip1 = _tip2 = _mouse = _angle = _power = _spin = null;
			_process = null;
			
			super.dispose();
		}
		
		override public function update():void 
		{
			if ( _animator.isPlaying && !Window.instanceCount() ) {
				_animator.update();
				
				if ( _process != null ) _process.call();
			}
			if ( _animator2.isPlaying )
				_animator2.update();
			
		}
		
		
		override public function show():void 
		{
			_tip1.visible = true;
			_tip1.gotoAndStop( 331 );
			_animator.playSet();
			_animator.appendSet( 'loop' );
			
			HudGame.instance.onBallRelease.addOnce( _hideTip1 );
			Session.instance.onPutt.addOnce( _showTip2 );
		}
		
		override public function hide():void 
		{
			if ( _tip1.visible ) {
				_tip1.visible = false;
				_animator2.playSet( 'hide' );
			}
		}
		
		
			// -- private --
			
			private var _tip1:MovieClip, _tip2:MovieClip, _mouse:MovieClip
			private var _angle:MovieClip, _power:MovieClip, _spin:MovieClip, _process:Function, _powerDelta:int
			private var _animator:AnimationTiming, _animator2:AnimationTiming
			
			
			private function _startTip1():void
			{
				_angle.visible = false;
				_spin.visible = true; _spin.play();
				_spin.scaleX = _spin.scaleY = 1;
				_spin.x = 242; _spin.y = 142;
				_process = null;
			}
			
			private function _hideTip1():void
			{
				_angle.visible = _spin.visible = false;
				_spin.stop();
				_animator.playSet( 'hide' );
			}
			
			
			private function _showMouseNormal():void
			{
				_mouse.gotoAndStop( 5 );
				_process = null;
			}
			
			private function _showMousePointer():void
			{
				_mouse.gotoAndStop( 6 );
			}
			
			private function _showMouseClick():void
			{
				_mouse.gotoAndStop( 7 );
			}
			
			
			private function _ballClick():void
			{
				_spin.scaleX = _spin.scaleY = .7;
				_showMouseClick();
				_process = _ballAngleDrag;
				_angle.visible = true;
				_power.gotoAndStop( 1 );
			}
			
			private function _ballRelease():void
			{
				_angle.visible = _spin.visible = false;
				_spin.stop();
				_showMouseNormal();
				_process = null;
			}
			
			private function _ballAngleDrag():void
			{
				var dx:Number = _mouse.x -242;
				var dy:Number = _mouse.y -142;
				
				_angle.rotation = Trigo.getAngle( dx, dy );
				_angle.gotoAndStop( Math.ceil((Math.sqrt(dx*dx+dy*dy)-11)/5) );
				
				var power:int = _power.currentFrame;
				power = MathUtils.limit( power +_powerDelta, 1, 100 );
				if ( power == 1 || power == 100 ) _powerDelta *= -1;
				_power.gotoAndStop( power );
				
				_spin.x = _mouse.x;
				_spin.y = _mouse.y;
			}
			
			
			private function _showTip2():void
			{
				_tip2.visible = true;
				_animator2.playSet();
			}
			
			
	}

}