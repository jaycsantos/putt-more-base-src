package pb2.game.ctrl 
{
	import com.adobe.crypto.MD5;
	import com.jaycsantos.entity.Entity;
	import com.jaycsantos.math.MathUtils;
	import pb2.game.entity.*;
	import pb2.game.Session;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class AwesomenessCtrl 
	{
		public static const i:AwesomenessCtrl = new AwesomenessCtrl;
		
		
		public function AwesomenessCtrl() 
		{
			if ( i ) throw new Error('[pb2.game.ctrl.AwesomenessCtrl] Singleton class, use static property instance');
			
		}
		
		public function init():void
		{
			_xml = new XML('<list><shot value="0"/><aces value="0"/><bounce value="0"/><glass value="0"/><spring value="0"/><spin value="0"/><beep value="0"/><warp value="0"/><boom value="0"/></list>');
			Session.factory.onSpawn.add( _onEntitySpawn );
			BallCtrl.onBallBounce.add( _onBallBounce );
			BallCtrl.onMouseRelease.add( _onBallRelease );
			Session.instance.onReset.add( _onReset );
		}
		
		public function clear():void
		{
			_xml = null;
			Session.factory.onSpawn.remove( _onEntitySpawn );
			BallCtrl.onBallBounce.remove( _onBallBounce );
			BallCtrl.onMouseRelease.remove( _onBallRelease );
			Session.instance.onReset.remove( _onReset );
		}
		
		public function get shot():uint
		{
			return uint(_xml.shot[0].@value);
		}
		public function get bounce():uint
		{
			return uint(_xml.bounce[0].@value);
		}
		public function get glass():uint
		{
			return uint(_xml.glass[0].@value);
		}
		public function get spring():uint
		{
			return uint(_xml.spring[0].@value);
		}
		public function get spin():uint
		{
			return uint(_xml.spin[0].@value);
		}
		public function get beep():uint
		{
			return uint(_xml.beep[0].@value);
		}
		public function get warp():uint
		{
			return uint(_xml.warp[0].@value);
		}
		public function get boom():uint
		{
			return uint(_xml.boom[0].@value);
		}
		
		public function hasAwesome():Boolean
		{
			return Boolean(String(_xml.@ok));
		}
		
			// -- private --
			
			private var _xml:XML, _hash:String;
			
			
			private function _onEntitySpawn( e:Entity ):void
			{
				switch( true ) { 
					case e is Glass: Glass(e).onBreak.add( _onGlassBreak ); break;
					case e is Puncher2: Puncher2(e).onSprung.add( _onSpringSprung ); break;
					case e is PPuncher: PPuncher(e).onSprung.add( _onSpringSprung ); break;
					case e is Spinner: Spinner(e).onSpin.add( _onSpin ); break;
					case e is RelayBlock: RelayBlock(e).onBeep.add( _onButtonBeep ); break;
					case e is Portal: Portal(e).onWarp.add( _onPortalWarp ); break;
					case e is Bomb: Bomb(e).onExplode.add( _onBombBoom ); break;
				}
			}
			
			private function _onReset():void
			{
				_xml.shot[0].@value = 0;
				_xml.aces[0].@value = 0;
				_xml.bounce[0].@value = 0;
				_xml.glass[0].@value = 0;
				_xml.spring[0].@value = 0;
				_xml.spin[0].@value = 0;
				_xml.beep[0].@value = 0;
				_xml.warp[0].@value = 0;
				_xml.boom[0].@value = 0;
			}
			
			
			private function _onBallRelease():void
			{
				_xml.shot[0].@value = uint(_xml.shot[0].@value) +1;
				//_hash = MD5.hash( _xml.toXMLString() );
			}
			
			private function _onBallBounce( n:uint ):void
			{
				if ( n > 6 && BallCtrl.instance.getPrimary().body.GetLinearVelocity().Length() > 1.12 ) {
					_xml.bounce[0].@value = uint(_xml.bounce[0].@value) +1;
					_xml.@ok = '1';
					trace( '4:bounce #'+ _xml.bounce[0].@value, n, BallCtrl.instance.getPrimary().body.GetLinearVelocity().Length() );
				}
			}
			
			private function _onGlassBreak():void
			{
				_xml.glass[0].@value = uint(_xml.glass[0].@value) +1;
				_xml.@ok = '1';
			}
			
			private function _onSpringSprung():void
			{
				_xml.spring[0].@value = uint(_xml.spring[0].@value) +1;
				_xml.@ok = '1';
			}
			
			private function _onSpin():void
			{
				_xml.spin[0].@value = uint(_xml.spin[0].@value) +1;
				_xml.@ok = '1';
			}
			
			private function _onButtonBeep():void
			{
				_xml.beep[0].@value = uint(_xml.beep[0].@value) +1;
				_xml.@ok = '1';
			}
			
			private function _onPortalWarp():void
			{
				_xml.warp[0].@value = uint(_xml.warp[0].@value) +1;
				_xml.@ok = '1';
			}
			
			private function _onBombBoom():void
			{
				_xml.boom[0].@value = uint(_xml.boom[0].@value) +1;
				_xml.@ok = '1';
			}
			
			
		
	}

}