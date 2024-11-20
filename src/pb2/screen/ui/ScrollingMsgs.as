package pb2.screen.ui 
{
	import com.jaycsantos.game.IGameObject;
	import com.jaycsantos.math.MathUtils;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import pb2.game.Registry;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class ScrollingMsgs extends Sprite implements IGameObject
	{
		
		public function ScrollingMsgs() 
		{
			_msgs = Registry.PLAYTOMIC_MSGS;
			
			visible = _msgs.length > 0;// && (Session.isOnMenu || (Session.isOnPlay && !Session.isRunning));
			
			var sp:Sprite
			addChild( sp = PuttBase2.assets.createDisplayObject('screen.hud.scrollingMsgs') as Sprite );
			sp.mouseEnabled = sp.mouseChildren = false;
			
			addChild( _txf = UIFactory.createTextField('', '', 'left', 310, 0) );
			_txf.mouseEnabled = true;
			_txf.addEventListener( TextEvent.LINK, _click, false, 0, true );
			
			var mask:Shape = new Shape;
			mask.graphics.beginFill( 0, 1 );
			mask.graphics.drawRect( 10, 0, 300, 14 );
			_txf.mask = mask;
			
			if ( _msgs.length == 1 )
				_txf.htmlText = _msgs[0];
			if ( _msgs.length > 1 )
				_txf.htmlText = String(_msgs[ MathUtils.randomInt(0, _msgs.length) ]);
			
			visible = _txf.htmlText.length>5 && _txf.textWidth>0 && Registry.useDefaultSponsor;
			mouseEnabled = false;
			
			if ( !Registry.useDefaultSponsor || CONFIG::onAndkon ) {
				_txf.htmlText = '';
				_txf.visible = false;
			}
		}
		
		public function dispose():void
		{
			_txf.removeEventListener( TextEvent.LINK, _click );
			_txf = null;
		}
		
		public function update():void
		{
			if ( !_txf.textWidth && visible ) visible = false;
			if ( !visible ) return;
			
			_txf.x -= .5;
			//_txf.x = 50;
			
			if ( _txf.x < -_txf.textWidth )
				_txf.x = 310;
		}
		
		
			// -- private --
			
			private var _msgs:Array
			private var _txf:TextField
			
			private function _click( e:TextEvent ):void
			{
				navigateToURL( new URLRequest(e.text), "_blank" );
			}
			
	}

}