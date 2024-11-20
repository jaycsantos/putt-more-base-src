package pb2
{
	import com.jaycsantos.display.AbstractPreloader;
	import CPMStar.AdLoader;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	[SWF(width='650', height='400', backgroundColor='#191919', frameRate='45')]
	public class Preloader extends AbstractPreloader 
	{
		
		public function Preloader() 
		{
			_mainClassName = "pb2.PreloaderMain";
			
			graphics.beginFill( 0x191919 );
			graphics.drawRect( 0, 0, 650, 400 );
			
			addChild( _clip = new BackGround() );
			addChild( _clipAds = new MovieClip );
			addChild( _btn = new Bittun() );
			addChild( _btnSponsor = new PrimeLogo() );
			
			_clip.stop();
			_clip.addFrameScript( 130, _showBtn );
			_clip.addFrameScript( 149, _clip.stop );
			
			_clipAds.x = 320; _clipAds.y = 20;
			_clipAds.blendMode = 'layer';
			_clipAds.scrollRect = new Rectangle( 0, 0, 320, 250 );
			
			_btn.visible = false;
			_btn.addEventListener( MouseEvent.CLICK, _play, false, 0, true );
			_btn.x = 485; _btn.y = 330;
			
			addEventListener( Event.ADDED_TO_STAGE, _init, false, 0, true );
		}
		
			// -- private --
			
			[Embed(source="../../lib/pb2.preloader.swf", symbol="bg")]
			private var BackGround:Class
			
			[Embed(source="../../lib/pb2.preloader.swf", symbol="screen.ui.btn.btnGo")]
			private var Bittun:Class
			
			//[Embed(source="../../lib/pb2.preloader.swf", symbol="screen.ui.sponsor.AndkonLogo")]
			[Embed(source="../../lib/pb2.preloader.swf", symbol="screen.ui.sponsor.MbreakerLogo")]
			private var PrimeLogo:Class
			
			[Embed(source="../../lib/pb2.preloader.swf", symbol="screen.ui.sponsor.turboNukeLogo")]
			private var PrimeLogo2:Class
			
			
			private var _clip:MovieClip, _btn:SimpleButton, _btnSponsor:Sprite, _target:uint
			private var _onSiteLock:Boolean, _allowAds:Boolean, _clipAds:MovieClip, _startTime:uint
			
			
			private function _init( e:Event=null ):void
			{
				removeEventListener( Event.ADDED_TO_STAGE, _init );
				
				var url:String = loaderInfo.url;
				//url = 'http://jaycsantos.com/games/puttmorebase/?play';
				url = url.toLowerCase().split("://")[1].split("/")[0];
				
				var a:Array = String(CONFIG::sitelock).toLowerCase().split(',');
				var i:int = a.length;
				if ( i==0 ) _onSiteLock = true;
				while ( i-- )
					if ( url.indexOf(a[i]) > -1 ) {
						_onSiteLock = true;
						break;
					}
				
				if ( _onSiteLock ) {
					_btnSponsor.buttonMode = true;
					_btnSponsor.addEventListener( MouseEvent.CLICK, _gotoLockedSponsor, false, 0, true );
				}
				if ( !_onSiteLock ) {
					removeChild( _btnSponsor );
					addChild( _btnSponsor = new PrimeLogo2() );
					_btnSponsor.buttonMode = true;
					_btnSponsor.addEventListener( MouseEvent.CLICK, _gotoPrimeSponsor, false, 0, true );
					_btnSponsor.scaleX = _btnSponsor.scaleY = .5;
				}
				if ( CONFIG::allowLinks )
					MochiBot.track( this, "210840de" );
				
				
				
				a = String(CONFIG::siteAdFilter).toLowerCase().split(',');
				i = a.length;
				_allowAds = true;
				while ( i-- )
					if ( url.indexOf(a[i]) > -1 ) {
						_allowAds = false;
						break;
					}
				
				if ( _allowAds ) {
					//content spot id
					_clipAds.addChild( new AdLoader('6993Q296DEF3E') );
				}
				
				_startTime = getTimer();
			}
			
			override protected function _enterFrame( e:Event ):void 
			{
				var t:uint = getTimer();
				_target = (loaderInfo.bytesLoaded / loaderInfo.bytesTotal)*Math.min((t-_startTime)/1000,1)*100 >>0;
				
				if ( _clip.currentFrame < _target )
					_clip.gotoAndStop( _clip.currentFrame +1 );
				if ( _clip.currentFrame == 100 ) {
					_clip.play();
					removeEventListener( Event.ENTER_FRAME, _enterFrame );
				}
			}
			
			override protected function _preloadComplete():void 
			{
				//_clip.play();
			}
			
			private function _showBtn():void
			{
				_btn.visible = true;
			}
			
			private function _play( e:MouseEvent ):void
			{
				removeChild( _clip );
				removeChild( _btn );
				removeChild( _btnSponsor );
				removeChild( _clipAds );
				_btn.removeEventListener( MouseEvent.CLICK, _play );
				_btnSponsor.removeEventListener( MouseEvent.CLICK, _gotoPrimeSponsor );
				_clip = _clipAds = null; _btn = null; _btnSponsor = null;
				
				super._preloadComplete();
			}
			
			private function _gotoPrimeSponsor( e:MouseEvent ):void
			{
				//navigateToURL( new URLRequest('http://www.mousebreaker.com/'), '_blank' );
				//navigateToURL( new URLRequest('http://www.andkon.com/arcade/'), '_blank' );
				navigateToURL( new URLRequest('http://www.turbonuke.com/?gamereferal=puttmorebase'), '_blank' );
			}
			
			private function _gotoLockedSponsor( e:MouseEvent ):void
			{
				navigateToURL( new URLRequest('http://www.mousebreaker.com/'), '_blank' );
				//navigateToURL( new URLRequest('http://www.andkon.com/arcade/'), '_blank' );
				//navigateToURL( new URLRequest('http://www.turbonuke.com/?gamereferal=puttmorebase'), '_blank' );
			}
			
			
	}
	
}