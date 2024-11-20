package pb2.screen.tutorial 
{
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.math.Trigo;
	import flash.display.*;
	import pb2.game.Session;
	import pb2.screen.window.PopWindow;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class DemoControls extends PopWindow 
	{
		
		public function DemoControls() 
		{
			super();
			
			obstrusive = mouseEnabled = mouseChildren = false;
			_overlay.graphics.clear();
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.tutorial.demoControls') as MovieClip );
				_clip.gotoAndStop( 1 );
				_mouse = _clip.getChildByName( '_clipMouse' ) as MovieClip;
				_showMouseNormal();
				
				_clip.addChild( _angle = PuttBase2.assets.createDisplayObject('mouse.ctrl.angle') as MovieClip );
				_angle.addChild( _power = PuttBase2.assets.createDisplayObject('mouse.ctrl.power') as MovieClip );
				_clip.addChild( _spin = PuttBase2.assets.createDisplayObject('mouse.ctrl.spin') as MovieClip );
				
				_angle.stop(); _power.stop(); _spin.stop();
				_angle.x = _spin.x = 242; 
				_angle.y = _spin.y = 142;
				_angle.alpha = _spin.alpha = .3;
				_angle.blendMode = _spin.blendMode = 'overlay';
				_angle.visible = _spin.visible = false;
				_powerDelta = 1;
				
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 320, 1), 2, true );
				_animator.addSequenceSet( END, [321], 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
				
				_animator.addIndexScript( 0, _startTip1, PLAY );
				_animator.addIndexScript( 35, _showMousePointer, PLAY );
				_animator.addIndexScript( 43, _ballClick, PLAY );
				_animator.addIndexScript( 257, _ballRelease, PLAY );
			}
			
		}
		
		override public function dispose():void 
		{
			_mouse = _angle = _power = _spin = null;
			_process = null;
			
			super.dispose();
		}
		
		
		override public function update():void 
		{
			super.update();
			if ( _process != null ) _process.call();
		}
		
		
		override public function show():void 
		{
			super.show();
			
			Session.instance.onPutt.addOnce( hide );
		}
		
		override public function hide():void 
		{
			if ( !visible ) return;
			
			_angle.visible = _spin.visible = false;
			_spin.stop();
			super.hide();
		}
		
		
			// -- private --
			private var _mouse:MovieClip, _angle:MovieClip, _power:MovieClip, _spin:MovieClip, _process:Function, _powerDelta:int
			
			
			override protected function _showContents():void 
			{
				onShown.dispatch();
				
				_contents.visible = _bgBmp.visible = true;
				_overlay.alpha = 1;
			}
		
			
			private function _startTip1():void
			{
				_angle.visible = false;
				_spin.visible = true; _spin.play();
				_spin.scaleX = _spin.scaleY = 1;
				_spin.x = 242; _spin.y = 142;
				_process = null;
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
			
			
			
	}

}