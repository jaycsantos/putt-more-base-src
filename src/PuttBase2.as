package  
{
	/**
	 * ...
	 * @author jaycsantos
	 */
	
	import com.demonsters.debugger.MonsterDebugger;
	import com.jaycsantos.*;
	import com.jaycsantos.display.*;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.util.UserInput;
	import com.newgrounds.API;
	import flash.display.*;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.getTimer;
	import pb2.game.ctrl.*;
	import pb2.game.entity.tile.Ground;
	import pb2.game.*;
	import pb2.GameAudio;
	import pb2.screen.*;
	import pb2.screen.ui.UIFactory;
	import Playtomic.*;
	import com.newgrounds.*;
	import com.newgrounds.components.MedalPopup;
	
	[SWF(width='650', height='400', backgroundColor='#191919', frameRate='46')]
	public class PuttBase2 extends Sprite
	{
		public static var STAGE_WIDTH:uint = 650;
		public static var STAGE_HEIGHT:uint = 400;
		
		public static var assets:AssetFactory;
		public static var gsf:GamerSafe;
		public static var kongregate:*;
		public static var ngApi:Boolean
		
		public function PuttBase2() 
		{
			//name = "PB2";
			mouseEnabled = tabEnabled = false;
			
			var sp:Sprite = new Sprite;
			sp.visible = false; sp.name = 'tracker container';
			addChild( sp );
			Tracker.i.init( sp );
			
			if ( stage ) _init();
			else addEventListener( Event.ADDED_TO_STAGE, _init );
		}
		
		
			// -- private --
			
			CONFIG::release
			{
				[Embed(source="/../lib/pb2.assets.swf", mimeType="application/octet-stream")]
				private static const Cargo:Class;
			}
			
			
			private function _init( e:Event = null ):void
			{
				removeEventListener( Event.ADDED_TO_STAGE, init );
				
				STAGE_WIDTH = Math.min( stage.stageWidth, 650 );
				STAGE_HEIGHT = Math.min( stage.stageHeight, 400 );
				//stage.align = StageAlign.TOP_LEFT;
				
				CONFIG::release
				{
					assets = new AssetFactory;
					assets.activate( PuttBase2.Cargo, _initAudio );
				}
				
				CONFIG::debug
				{
					assets = ExternalAssetFactory.instance;
					var ass:ExternalAssetFactory = assets as ExternalAssetFactory;
					
					ass.addSwfLibrary( "assets", "../lib/pb2.assets.swf" );
					ass.addSwfLibrary( "audio", "../lib/pb2.audio.swf" );
					ass.addXML( "levels", "../lib/pb2.levels.xml" );
					ass.load( _initAudio );
					
					MonsterDebugger.initialize( this );
				}
			}
			
			private function _initAudio():void
			{
				GameAudio.instance.init( _initRoot );
			}
			
			private function _initRoot():void
			{
				CONFIG::debug
				{
					ExternalAssetFactory(assets).defaultSwfLib = 'assets';
				}
				
				var root:GameRoot = new GameRoot;
				addChild( root );
				
				_initVars();
				//_initGame();
				root.addChild( LoadingOverlay.instance );
				
				//init ui factory
				UIFactory.init();
			}
			
			private function _initVars():void
			{
				CONFIG::usePlaytomic {
					GameVars.Load( _varsLoaded );
				}
				
				Session.instance.autoLoadLevelId = null;
				// look for embedded level
				if( ExternalInterface.available ) {
					try {
						var url:String = String(ExternalInterface.call("window.location.href.toString"));
						//trace(url);
						
						if ( url.indexOf("pb_") > -1 ) {
							/*var levelid:String = url.substring(url.indexOf("?") + 1);
							
							if ( levelid.indexOf("&") > -1 )
							levelid = levelid.substring(0, levelid.indexOf("&"));
							
							if ( levelid.indexOf("#") > -1 )
							levelid = levelid.substring(0, levelid.indexOf("#"));*/
							
							var levelid:String = url.substring(url.indexOf("pb_") + 3);
							if ( levelid.indexOf("&") > -1 )
							levelid = levelid.substring(0, levelid.indexOf("&"));
							if ( levelid.indexOf("/") > -1 )
							levelid = levelid.substring(0, levelid.indexOf("/"));
							if ( levelid.indexOf("#") > -1 )
							levelid = levelid.substring(0, levelid.indexOf("#"));
							
							Session.instance.autoLoadLevelId = levelid;
						}
						
						/*var gurl:String = url.replace(/(pb_[0-9]*[&]?){1}/, '');
						Registry.SPONSOR_GAME_URL = gurl;
						Registry.SPONSOR_GAME_URL_LVLID = url.indexOf('?')>-1 ? gurl+'&pb_' : gurl+'?pb_';*/
						
					} catch(s:Error) {
						/*Registry.useDefaultGameURL = true;
						Registry.SPONSOR_GAME_URL = 'http://www.turbonuke.com/games.php?game=puttmorebase';
						Registry.SPONSOR_GAME_URL_LVLID = 'http://www.turbonuke.com/games.php?game=puttmorebase&pb_';*/
					}
				}
				//Session.instance.autoLoadLevelId = '477416';
				
				_initGame();
			}
			
			private function _initGame():void
			{
					/*var ses:Session = Session.instance;
					var xml:XML = MapDataMngr.instance.getEditMap();
					if ( xml != null ) {
						ses.map = new MapData( xml );
					} else {
						ses.cols = 14; ses.rows = 8;
						ses.bgColorIdx = MathUtils.randomInt( 0, Ground.COLORS.length-1 );
						ses.map = null;
					}
					GameRoot.changeScreen( EditorScreen ); }/**/
				
				CONFIG::debug {
					GameRoot.toggleAllowBreakPoints();
					
					var s:Stats = new Stats;
					addChild( s );
					
					addChild( new DOutput );
				}
				
				CONFIG::useGamersafe {
					var sp:Sprite = addChild( new Sprite ) as Sprite;
					gsf = new GamerSafe( sp );
					gsf.onApiReady = function():void {
						GamerSafeHelper.i.init();
						gsf.hideInterface();
						
						if ( !SaveDataMngr.instance.getCustom('highscore_name') ) {
							gsf.onUnregisteredName = function(e:Event):void { SaveDataMngr.instance.saveCustom( 'highscore_name_temp', GamerSafe.api.unregisteredName ); };
							gsf.requestUnregisteredName();
						}
					}
				}
				
				CONFIG::onKong {
					// Pull the API path from the FlashVars
					var paramObj:Object = LoaderInfo(root.loaderInfo).parameters;
					
					// The API path. The "shadow" API will load if testing locally. 
					var apiPath:String = paramObj.kongregate_api_path || "http://www.kongregate.com/flash/API_AS3_Local.swf";
					
					// Allow the API access to this SWF
					Security.allowDomain( apiPath );
					
					// Load the API
					var request:URLRequest = new URLRequest( apiPath );
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener( Event.COMPLETE, _kongLoaded );
					loader.load( request );
					this.addChild( loader );
				}
				
				CONFIG::onNG {
					API.addEventListener( APIEvent.API_CONNECTED, _ngLoaded );
					API.connect( root, '' , '' );
				}
				
				
				CONFIG::release {
					var url:String = loaderInfo.url;
					//url = 'http://www.mousebreaker.com/games/puttmorebase/';
					url = url.toLowerCase().split("://")[1].split("/")[0];
					
					var a:Array = String(CONFIG::sitelock).toLowerCase().split(',');
					var i:int = a.length;
					//if ( i==0 ) return;
					while ( i-- )
						if ( url.indexOf(a[i]) > -1 ) {
							GameRoot.changeScreen( SplashTurboScreen );
							CONFIG::onAndkon { GameRoot.changeScreen( SplashAndkonScreen ); }
							CONFIG::onMbreaker { GameRoot.changeScreen( SplashMBreakerScreen ); }
							return;
						}
					
					GameRoot.changeScreen( SplashTurboScreen );
					CONFIG::onAndkon { GameRoot.changeScreen( SplashAndkonScreen ); }
				}
				CONFIG::debug {
					GameRoot.changeScreen( MenuActScreen );
					//GameRoot.changeScreen( SplashMBreakerScreen );
					//GameRoot.changeScreen( SplashAndkonScreen );
					//GameRoot.changeScreen( SplashTurboScreen );
				}
				
			}
			
			
			private function _varsLoaded( vars:Object, response:Object ):void
			{
				if ( response.Success )
					for ( var k:String in vars )
						if ( k == 'Message' ) {
							if ( String(vars[k]).length > 10 ) {
								var a:Array = String(vars[k]).split('|');
								var i:int = a.length;
								while ( i-- )
									Registry.PLAYTOMIC_MSGS.push( a[i] );
							}
						} else {
							Registry.PLAYTOMIC_VARS[k] = vars[k];
						}
			}
			
			
			// This function is called when loading is complete
			private function _kongLoaded( event:Event ):void
			{
				// Save Kongregate API reference
				kongregate = event.target.content;
				
				// Connect to the back-end
				kongregate.services.connect();
				
				// You can now access the API via:
				// kongregate.services
				// kongregate.user
				// kongregate.scores
				// kongregate.stats
				// etc...
			}
			
			private function _ngLoaded( event:Event ):void
			{
				ngApi = true;
				if ( API.isNewgrounds ) {
					var medal:MedalPopup = new MedalPopup;
					addChild( medal );
				}
			}
			
			
	}

}