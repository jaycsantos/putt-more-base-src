package pb2.screen.tutorial 
{
	import com.jaycsantos.math.MathUtils;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import pb2.game.ctrl.CameraFocusCtrl;
	import pb2.game.ctrl.SaveDataMngr;
	import pb2.game.Session;
	import pb2.screen.ui.UIFactory;
	import pb2.screen.window.PopWindow;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PopInfoEditor extends PopWindow 
	{
		public static var i:PopInfoEditor
		
		public static function open( page:uint ):Boolean
		{
			var bit:uint = 1 << (page/2);
			if ( (i._flag & bit) == 0 ) {
				i._pages.gotoAndStop( page );
				i._flag |= bit;
				if ( !i.visible && !i._animator.isPlaying )
					i.show();
				SaveDataMngr.instance.saveCustom( 'editorTutFlags', i._flag, true );
				return true;
			}
			return false;
		}
		
		
		public function PopInfoEditor() 
		{
			super();
			
			if ( i ) i.dispose();
			i = this;
			_flag = uint(SaveDataMngr.instance.getCustom( 'editorTutFlags' ));
			
			mouseEnabled = buttonMode = true;
			obstrusive = mouseChildren = false;
			
			_overlay.graphics.clear();
			_overlay.graphics.beginFill( 0, .5 );
			_overlay.graphics.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			_overlay.graphics.endFill();
			
			{//-- contents
				_contents.addChild( _pages = PuttBase2.assets.createDisplayObject('screen.tutorial.editorHelpPages') as MovieClip );
				_pages.gotoAndStop( 1 );
			}
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.tutorial.popInfoEditor') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 10, 1).reverse(), 1, false, _showContents );
				_animator.addSequenceSet( END, MathUtils.intRangeA(1, 10, 1), 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
			}
			
			
			addEventListener( MouseEvent.CLICK, _click, false, 0, true );
			onShown.add( Session.instance.stop );
			onPreShow.add( CameraFocusCtrl.instance.disable );
			onHidden.add( Session.instance.start );
			onHidden.add( CameraFocusCtrl.instance.enable );
			onHidden.add( _onHidden );
			onHidden.remove( dispose );
		}
		
		override public function dispose():void 
		{
			if ( i == this ) i = null;
			removeEventListener( MouseEvent.CLICK, _click );
			
			super.dispose();
		}
		
		
		override public function show():void 
		{
			obstrusive = true;
			super.show();
		}
		
		override public function hide():void 
		{
			obstrusive = false;
			super.hide();
		}
		
		
			// -- private --
			
			private var _pages:MovieClip, _flag:uint
			
			private function _click( e:MouseEvent ):void
			{
				hide();
				
				/*switch ( _pages.currentFrame ) {
					case 8: // extra items marking
						_pages.gotoAndStop( _pages.currentFrame +2 );
						SaveDataMngr.instance.saveCustom( 'editorTutFlags', i._flag | (1 << (_pages.currentFrame/2)), true );
						break;
					
					case 2: // golf & hole
					case 4: // auto save
					case 6: // 2x putt
					case 10: // shift extra item marking
					case 12: // item limit
					case 14: // buttons & gates
					case 16: // portals
					case 18: // floor textures
					default:
						hide();
						break;
				}*/
			}
			
			
			private function _onHidden():void
			{
				visible = false;
			}
			
		
	}

}