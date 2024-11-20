package pb2.screen.window 
{
	import com.jaycsantos.game.IGameObject;
	import com.jaycsantos.sound.GameSounds;
	import com.jaycsantos.util.DisplayKit;
	import com.jaycsantos.util.GameLoop;
	import com.jaycsantos.util.ns.internalGameloop;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import pb2.GameAudio;
	import pb2.screen.ui.SmallBtn1;
	import pb2.screen.ui.UIFactory;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PopPrompt extends Sprite implements IGameObject
	{
		public static function create( msg:String, w:uint, ...btns ):PopPrompt
		{
			if ( _i ) _i.dispose();
			
			_i = new PopPrompt( msg, w, btns )
			GameLoop.instance.internalGameloop::addCallback( _i.update );
			
			return _i;
		}
			private static var _i:PopPrompt
		
		public static function hide():void
		{
			if ( _i ) _i._hide();
		}
		
		public static function remove():void
		{
			if ( _i ) _i.dispose();
		}
		
		public static function get instance():PopPrompt
		{
			return _i;
		}
		
		
		public function PopPrompt( msg:String, w:uint, btns:Array ) 
		{
			var sp:Sprite = new Sprite;
			addChild( sp );
			sp.graphics.beginFill( 0, 0 );
			sp.graphics.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			sp.mouseEnabled = true;
			
			addChild( _canvas = new Sprite );
			_canvas.visible = false;
			_canvas.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
			
			{//-- text
				var txf:TextField;
				_canvas.addChild( txf = UIFactory.createFixedTextField(msg, 'promptText', 'left', 10, 6) );
				txf.wordWrap = true;
				txf.width = w;
				txf.height = txf.textHeight;
			}
			
			{//-- buttons
				var obj:Object, btn:SmallBtn1, wbtn:Number=0
				for ( var k:String in btns ) {
					obj = btns[k];
					if ( obj['name'] == undefined ) continue;
					
					
					_canvas.addChild( btn = new SmallBtn1(obj['name'], obj['width']) );
					wbtn += btn.width;
					_btnList.push( btn );
					if ( obj['call'] != undefined )
						_btnCalls.push( obj['call'] );
					else
						_btnCalls.push( _hide );
						
					if ( _btnList.length == 3 ) break;
				}
				
				for ( k in _btnList ) {
					_btnList[k].x = (w+20)/(_btnList.length+1)*(int(k)+1) -_btnList[k].width/2;
					_btnList[k].y = txf.y +txf.height +10;
				}
			}
			
			{//-- canvas
				var g:Graphics = _canvas.graphics;
				g.beginFill( 0x3F3F3F );
				g.lineStyle( 1.5, 0x0093B2 );
				g.drawRoundRect( 0, 0, 20 +w, _canvas.height +16, 12, 12 );
				g.endFill();
				
				_canvas.filters = [new GlowFilter(0x0093B2,1,12,12,1.5)];
				_canvas.x = (PuttBase2.STAGE_WIDTH -_canvas.width) /2;
				_canvas.y = (PuttBase2.STAGE_HEIGHT -_canvas.height) /2;
			}
			
			addChild( _puff = PuttBase2.assets.createDisplayObject('screen.ui.ani.puff2') as MovieClip );
			_puff.gotoAndStop( 1 ); _puff.x = (PuttBase2.STAGE_WIDTH -93) /2; _puff.y = (PuttBase2.STAGE_HEIGHT -75) /2;
			_puff.addFrameScript( 5, _showCanvas );
			_puff.addFrameScript( 28, _puff.stop );
			addEventListener( Event.ADDED_TO_STAGE, _playPuff, false, 0, true );
		}
		
		public function dispose():void
		{
			if ( _i == this ) {
				GameLoop.instance.internalGameloop::removeCallback( update );
				_i = null;
			}
			if ( stage ) stage.focus = stage;
			if ( parent ) parent.removeChild( this );
			_canvas.removeEventListener( MouseEvent.CLICK, _click );
			removeEventListener( Event.ADDED_TO_STAGE, _playPuff );
			
			var i:int = _btnList.length;
			while ( i-- ) _btnList[i].dispose();
			_btnCalls.splice( 0, _btnCalls.length );
			
			DisplayKit.removeAllChildren( this, 2 );
		}
		
		public function update():void
		{
			for each( var btn:SmallBtn1 in _btnList ) btn.update();
		}
		
			// -- private --
			
			private var _canvas:Sprite, _puff:MovieClip
			private var _btnList:Vector.<SmallBtn1> = new Vector.<SmallBtn1>;
			private var _btnCalls:Vector.<Function> = new Vector.<Function>;
			
			private function _click( e:MouseEvent ):void
			{
				var i:int = _btnList.indexOf( e.target );
				if ( i > -1 )
					_btnCalls[i].call();
			}
			
			
			private function _playPuff( e:Event ):void
			{
				removeEventListener( Event.ADDED_TO_STAGE, _playPuff );
				_puff.gotoAndPlay( 1 );
				GameSounds.play( GameAudio.POP );
			}
			
			private function _hide():void
			{
				_puff.gotoAndPlay( 1 );
				GameSounds.play( GameAudio.POP );
				_puff.addFrameScript( 5, _hideCanvas );
				_puff.addFrameScript( 28, dispose );
			}
			
			private function _showCanvas():void
			{
				_canvas.visible = true;
			}
			
			private function _hideCanvas():void
			{
				_canvas.visible = false;
			}
			
			
	}

}