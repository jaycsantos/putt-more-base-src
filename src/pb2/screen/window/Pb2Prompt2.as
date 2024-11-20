package pb2.screen.window 
{
	import com.jaycsantos.game.IGameObject;
	import com.jaycsantos.util.DisplayKit;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import pb2.screen.ui.SmallBtn1;
	import pb2.screen.ui.UIFactory;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Pb2Prompt2 extends Sprite implements IGameObject 
	{
		
		public function Pb2Prompt2( msg:String, w:uint, ...btns ) 
		{
			var txf:TextField
			addChild( txf = UIFactory.createFixedTextField(msg, 'promptText', 'left', 10, 6) );
			txf.wordWrap = true;
			txf.width = w;
			txf.height = txf.textHeight;
			
			var obj:Object, btn:SmallBtn1, wbtn:Number=0
			for ( var k:String in btns ) {
				obj = btns[k];
				if ( obj['name'] == undefined || obj['call'] == undefined ) continue;
				
				
				addChild( btn = new SmallBtn1(obj['name'], obj['width']) );
				wbtn += btn.width;
				_btnList.push( btn );
				_btnCalls.push( obj['call'] );
				if ( _btnList.length == 3 ) break;
			}
			
			for ( k in _btnList ) {
				_btnList[k].x = (w+20)/(_btnList.length+1)*(int(k)+1) -_btnList[k].width/2;
				_btnList[k].y = txf.y +txf.height +10;
			}
			
			var g:Graphics = graphics;
			g.beginFill( 0xE5E5E5 );
			g.lineStyle( 1.5, 0x0093B2 );
			g.drawRoundRect( 0, 0, 20 +w, this.height +16, 12, 12 );
			g.endFill();
			filters = [new GlowFilter(0x0093B2,1,12,12,1.5)];
			
			x = (PuttBase2.STAGE_WIDTH -width) /2;
			y = (PuttBase2.STAGE_HEIGHT -height) /2;
			
			var overlay:Sprite;
			addChildAt( overlay = new Sprite, 0 );
			overlay.graphics.beginFill( 0, 0 );
			overlay.graphics.drawRect( -x, -y, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			overlay.mouseEnabled = true;
			
			addEventListener( MouseEvent.CLICK, _click, false, 0, true );
		}
		
		public function dispose():void
		{
			if ( stage ) stage.focus = stage;
			if ( parent ) parent.removeChild( this );
			removeEventListener( MouseEvent.CLICK, _click );
			
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
			
			private var _btnList:Vector.<SmallBtn1> = new Vector.<SmallBtn1>;
			private var _btnCalls:Vector.<Function> = new Vector.<Function>;
			
			private function _click( e:MouseEvent ):void
			{
				var i:int = _btnList.indexOf( e.target );
				if ( i > -1 )
					_btnCalls[i].call();
			}
			
			
	}

}