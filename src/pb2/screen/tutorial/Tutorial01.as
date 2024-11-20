package pb2.screen.tutorial 
{
	import com.jaycsantos.display.animation.AnimationTiming;
	import com.jaycsantos.display.animation.SimpleAnimationTiming;
	import com.jaycsantos.game.IGameObject;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.math.Trigo;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.ctrl.SaveDataMngr;
	import pb2.game.entity.Ball;
	import pb2.game.Session;
	import pb2.screen.ui.HudGame;
	import pb2.screen.window.Window;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Tutorial01 extends ATutorial
	{
		
		public function Tutorial01() 
		{
			mouseEnabled = mouseChildren = false;
			
			addChild( _clip = PuttBase2.assets.createDisplayObject('screen.tutorial.01Controls') as MovieClip );
			_clip.gotoAndStop( 1 );
			_clip.visible = _clip.mouseEnabled = _clip.mouseChildren = false;
			_mouse = _clip.getChildByName( '_clipMouse' ) as MovieClip;
			_showMouseNormal();
			
			_clip.addFrameScript( 1, _start );
			_clip.addFrameScript( 36, _showMousePointer );
			_clip.addFrameScript( 44, _followAngle );
			_clip.addFrameScript( 230, _showPowerBar );
			_clip.addFrameScript( 271, _showMousePointer );
			_clip.addFrameScript( 276, _followPower );
			_clip.addFrameScript( 373, _showMouseNormal );
			_clip.addFrameScript( 417, _showMousePointer );
			_clip.addFrameScript( 430, _showMouseClick );
			_clip.addFrameScript( 441, _hideAllMouse );
			_clip.addFrameScript( 516, _showMouseNormal );
			
			_animator = new SimpleAnimationTiming( MathUtils.intRangeA(1, 600, 1), 2, true, null, 1 );
			
			_clip.addChild( _arrow = PuttBase2.assets.createDisplayObject('mouse.ctrl.arrow') as MovieClip );
			_clip.addChild( _angle = PuttBase2.assets.createDisplayObject('mouse.ctrl.angle') as MovieClip );
			_clip.addChild( _power = PuttBase2.assets.createDisplayObject('mouse.ctrl.power') as MovieClip );
			
			_arrow.x = _angle.x = _power.x = 242;
			_arrow.y = _angle.y = _power.y = 142;
			_arrow.alpha = _angle.alpha = _power.alpha = .3;
			_arrow.blendMode = _angle.blendMode = _power.blendMode = 'overlay';
			_power.visible = false;
			_arrow.stop(); _angle.stop(); _power.stop();
			
			
			addChild( _clipReset = PuttBase2.assets.createDisplayObject('screen.tutorial.03Reset') as MovieClip );
			_clipReset.gotoAndStop( 1 );
			_clipReset.visible = _clipReset.mouseEnabled = _clipReset.mouseChildren = false;
			addChild( _clipPar = PuttBase2.assets.createDisplayObject('screen.tutorial.04Par') as MovieClip );
			_clipPar.gotoAndStop( 1 );
			_clipPar.visible = _clipPar.mouseEnabled = _clipPar.mouseChildren = false;
			
			_animatorReset = new AnimationTiming( MathUtils.intRangeA(1, 10, 1), 1, 1 );
			_animatorReset.addSequenceSet( 'hide', MathUtils.intRangeA(10, 20, 1), 1, false, _hideTip2 );
			
			
			Session.instance.onEntitiesMoveStop.add( _showResetTip );
			Session.instance.onPutt.add( _showParTip );
			HudGame.instance.onBallRelease.addOnce( _hideAnimation );
		}
		
		override public function dispose():void 
		{
			_clip = _mouse = _clipReset = _clipPar = null;
			_animator.dispose(); _animator = null;
			_animatorReset.dispose(); _animatorReset = null;
			super.dispose();
		}
		
		
		override public function update():void 
		{
			if ( _animator.isPlaying && !Window.instanceCount() ) {
				_animator.update();
				var f:int = _animator.frame;
				_clip.gotoAndStop( f );
				
				if ( _process != null ) _process.call();
			}
			if ( _animatorReset.isPlaying ) {
				_animatorReset.update();
				if ( _clipReset.visible )
					_clipReset.gotoAndStop( _animatorReset.frame );
				else if ( _clipPar.visible )
					_clipPar.gotoAndStop( _animatorReset.frame );
			}
			
		}
		
		
		override public function show():void 
		{
			_animator.playAt();
			_clip.visible = true;
			_showMouseNormal();
			_power.visible = false;
			
			_arrow.rotation = _angle.rotation = -135;
			_arrow.gotoAndStop( 1 );
			_angle.gotoAndStop( 1 );
			
			_process = null;
		}
		
		override public function hide():void 
		{
			_hideAnimation();
			_hideTip();
			//SaveDataMngr.instance.saveCustom( 'Tutorial01', 1, true );
		}
		
		
			// -- private --
			
			private var _clip:MovieClip, _mouse:MovieClip, _clipReset:MovieClip, _clipPar:MovieClip
			private var _animator:SimpleAnimationTiming, _animatorReset:AnimationTiming, _process:Function
			private var _arrow:MovieClip, _angle:MovieClip, _power:MovieClip
			
			
			private function _start():void
			{
				_arrow.rotation = _angle.rotation = -135;
				_arrow.visible = _angle.visible = true;
				_arrow.gotoAndStop( 1 );
				_angle.gotoAndStop( 1 );
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
			
			
			private function _setAngle():void
			{
				var dx:Number = _mouse.x -242;
				var dy:Number = _mouse.y -142;
				
				_power.rotation = _arrow.rotation = _angle.rotation = Trigo.getAngle( dx, dy );
				_angle.gotoAndStop( Math.ceil((Math.sqrt(dx*dx+dy*dy)-11)/5) );
			}
			
			private function _setPower():void
			{
				var dx:Number = _mouse.x -242;
				var dy:Number = _mouse.y -142;
				
				var angle:Number = _angle.rotation;
				var a:Number = angle -35;
				var b:Number = angle -202;
				var c:Number = Trigo.getAngle(dx, dy);
				if ( b > a ) b -= 360;
				if ( a < -180 ) { a += 360; b += 360; }
				if ( b < -180 && c > 0 ) c -= 360;
				
				var power:uint = MathUtils.limit( Math.round((-c +a) /1.67), 0, 100 );
				_arrow.gotoAndStop( power );
				_power.gotoAndStop( power );
			}
			
			
			private function _followAngle():void
			{
				_process = _setAngle;
				_showMouseClick();
			}
			
			private function _followPower():void
			{
				_process = _setPower;
				_showMouseClick();
			}
			
			private function _showPowerBar():void
			{
				_power.visible = true;
				_showMouseNormal();
			}
			
			private function _hideAllMouse():void
			{
				_arrow.visible = _angle.visible = _power.visible = false;
				_showMouseNormal();
				_power.gotoAndStop( 1 );
				_arrow.gotoAndStop( 1 );
			}
			
			
			private function _hideAnimation():void
			{
				_animator.stop();
				_clip.gotoAndStop( 1 );
				_clip.visible = false;
			}
			
			
			private function _showResetTip():void
			{
				var b:Ball = BallCtrl.instance.getPrimary();
				if ( b.isOnHole || !b.wasMoved ) return;
				
				_animatorReset.playSet();
				_clipReset.visible = true;
				_clipPar.visible = false;
				
				HudGame.instance.onReset.addOnce( _hideTip );
			}
			
			private function _showParTip():void
			{
				_animatorReset.playSet();
				_clipPar.visible = true;
				_clipReset.visible = false;
			}
			
			
			private function _hideTip():void
			{
				_animatorReset.playSet('hide');
			}
			private function _hideTip2():void
			{
				_clipReset.visible = false;
				_clipPar.visible = false;
			}
			
	}

}