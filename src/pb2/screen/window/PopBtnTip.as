package pb2.screen.window 
{
	import com.jaycsantos.math.MathUtils;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import pb2.screen.ui.UIFactory;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PopBtnTip extends PopWindow 
	{
		
		public function PopBtnTip() 
		{
			super();
			
			obstrusive = mouseEnabled = mouseChildren = false;
			_overlay.graphics.clear();
			
			{//-- contents
				_contents.addChild( _txf = UIFactory.createFixedTextField('', 'btnTipTxt', 'none', -23, 24) );
				_txf.width = 46; _txf.height = 17;
			}
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.windows.popBtnTip') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 20, 1).reverse(), 1, false, _showContents );
				_animator.addSequenceSet( END, MathUtils.intRangeA(1, 20, 1), 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
			}
			
			onHidden.remove( dispose );
		}
		
		public function pop( str:String, _x:int, _y:int ):void
		{
			x = _x; y = _y;
			show();
			_txf.text = str;
		}
		
		
		override public function show():void 
		{
			if ( stage ) stage.focus = stage;
			onPreShow.dispatch();
			
			visible = true;
			_overlay.alpha = 0;
			_contents.visible = _bgBmp.visible = false;
			_animator.playSet( PLAY, 20-_clip.currentFrame );
		}
		
		override public function hide():void 
		{
			if ( !visible ) return;
			
			onPreHide.dispatch();
			
			_contents.visible = _bgBmp.visible = false;
			_animator.playSet( END, _clip.currentFrame-1 );
		}
		
			// -- private --
			
			private var _txf:TextField
			
			override protected function _showContents():void 
			{
				onShown.dispatch();
				
				_contents.visible = _bgBmp.visible = true;
				_overlay.alpha = 1;
			}
			
			
	}

}