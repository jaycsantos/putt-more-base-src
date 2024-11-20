package pb2.screen.window 
{
	import com.greensock.easing.*;
	import com.jaycsantos.game.GameRoot;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.util.*;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.*;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import pb2.game.ctrl.MapImport;
	import pb2.game.ctrl.SaveDataMngr;
	import pb2.game.*;
	import pb2.screen.*;
	import pb2.screen.ui.UIFactory;
	import Playtomic.Log;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class PopLevels extends PopWindow
	{
		
		public function PopLevels( parentClass:Class ) 
		{
			_parentClass = parentClass;
			var g:Graphics, sp:Sprite, sp2:Sprite, shp:Shape, txf:TextField, m:Matrix, i:int, j:int, k:String, a:Array;
			
			{//-- title
				_bgClip.addChild( shp = new Shape );
				g = shp.graphics;
				g.lineStyle( 1, 0xB2B2B2 );
				g.beginFill( 0xC6C6C6 );
				g.drawRoundRect( 0, 12, 250, 17, 8, 8 );
				
				_bgClip.addChild( sp = PuttBase2.assets.createDisplayObject('screen.window.title') as Sprite );
				sp.x = -15; sp.y = 250;
				sp.addChild( txf = UIFactory.createTextField('<b>SELECT</b> HOLE', 'header2', 'left') );
				sp.addChild( sp2 = PuttBase2.assets.createDisplayObject('screen.ui.ico.golfTee') as Sprite );
				txf.cacheAsBitmap = true;
				txf.x = (sp.width -txf.width -sp2.width)/2 +sp2.width+1;
				sp2.x = txf.x -sp2.width/2 -1; sp2.y = 15;
				sp.rotation = -90;
			}
			
			{//-- tabs
				a = [L10n.t('Classic'), L10n.t('More Fun'), L10n.t('Complex')];
				_contents.addChild( _tabsClip = new Sprite );
				with( _tabsClip ) {
					mouseEnabled = false;
					addEventListener( MouseEvent.CLICK, _tabCk, false, 0, true );
					addEventListener( MouseEvent.MOUSE_OVER, _tabMovr, false, 0, true );
					addEventListener( MouseEvent.MOUSE_OUT, _tabMout, false, 0, true );
					x = 40; y = 12;
				}
				
				for each ( k in a ) {
					i = _tabsClip.numChildren;
					_tabsClip.addChild( sp = new Sprite );
					sp.buttonMode = true; sp.mouseChildren = false; sp.tabEnabled = false;
					sp.addChild( txf = UIFactory.createTextField(sp.name = k, 'levelsTabTxt', 'left', 0, 1) );
					if ( i > 0 ) {
						sp2 = _tabsClip.getChildAt( i-1 ) as Sprite;
						sp.x = sp2.x +(sp2.width>>0) +10;
					}
				}
				
			}
			
			{//-- levels
				var xml:XML = MapList.list;
				_contents.addChild( _lvlsClipShade = new Shape );
				_lvlsClipShade.graphics.beginFill( 0 );
				_lvlsClipShade.graphics.drawRoundRect( 0, 0, 88, 53, 5, 5 );
				_lvlsClipShade.filters = [new DropShadowFilter(3, 45, 0, 1, 4, 4, .25, 1, false, false, true)];
				_lvlsClipShade.visible = false;
				
				_contents.addChild( _lvlsClip = new Sprite );
				with ( _lvlsClip ) {
					name = 'levels list';
					mouseEnabled = false;
					addEventListener( MouseEvent.CLICK, _click, false, 0, true );
					addEventListener( MouseEvent.MOUSE_OVER, _movr, false, 0, true );
					addEventListener( MouseEvent.MOUSE_OUT, _mout, false, 0, true );
				}
				_lvlsBmps = new Vector.<BitmapData>;
				for ( i=0; i<12; i++ ) {
					_lvlsClip.addChild( sp = new Sprite );
					sp.buttonMode = true; sp.mouseChildren = false;
					sp.addChild( new Bitmap(new BitmapData(88, 53, true, 0)) );
					sp.x = 35 +100*(i%4);
					sp.y = 50 +60*(i/4>>0);
					
					_lvlsBmps.push( new BitmapData(88, 53, true, 0) );
				}
			}
			
			{//-- buttons
				_contents.addChild( _btnClose = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnClose') as SimpleButton );
				_btnClose.addEventListener( MouseEvent.CLICK, _close, false, 0, true );
				_btnClose.x = 443; _btnClose.y = 15;
			}
			
			{//-- pop ani
				_bg.addChild( _clip = PuttBase2.assets.createDisplayObject('screen.windows.popLevelSelect') as MovieClip );
				_clip.gotoAndStop( 1 );
				
				_animator.addSequenceSet( PLAY, MathUtils.intRangeA(1, 13, 1), 1, false, _showContents );
				_animator.addSequenceSet( END, MathUtils.intRangeA(13, 26, 1), 1, false, onHidden.dispatch );
				_animator.addMovieClip( _clip );
			}
			
			
			if ( parentClass != MenuActScreen ) {
				g = _overlay.graphics;
				g.clear();
				g.beginFill( 0, .3 );
				g.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
				g.endFill();
			}
			
		}
		
		override public function dispose():void 
		{
			_lvlsClip.removeEventListener( MouseEvent.CLICK, _click );
			_lvlsClip.removeEventListener( MouseEvent.MOUSE_OVER, _movr );
			_lvlsClip.removeEventListener( MouseEvent.MOUSE_OUT, _mout );
			
			_tabsClip.removeEventListener( MouseEvent.CLICK, _tabCk );
			_tabsClip.removeEventListener( MouseEvent.MOUSE_OVER, _tabMovr );
			_tabsClip.removeEventListener( MouseEvent.MOUSE_OUT, _tabMout );
			
			super.dispose();
		}
		
		
		
			// -- private --
			
			private var _parentClass:Class, _setIndex:uint
			private var _tabsClip:Sprite, _lvlsClip:Sprite, _lvlsClipShade:Shape, _btnClose:SimpleButton, _lvlsBmps:Vector.<BitmapData>
			
			override protected function _init( e:Event ):void 
			{
				_contents.x = 95; _contents.y = 45;
				
				var saveMngr:SaveDataMngr = SaveDataMngr.instance;
				saveMngr.validate( MapList.list );
				_setIndex = uint( saveMngr.getCustom('lastMapSet') );
				onPreShow.add( _populate );
				
				{//-- total score
					var total:XML = saveMngr.getTotalData();
					var score:uint = total.@score;
					var par:int = total.@par;
					_bgClip.addChild( UIFactory.createFixedTextField(score? MathUtils.toThousands(score,','): '', 'levelsTotalScore', 'right', 420, -5) );
					_bgClip.addChild( UIFactory.createTextField((par!=0?(par>0?par+' over':Math.abs(par)+' under'):'') +' par', 'levelsTotalPar', 'right', 420, 30) );
				}
				
				super._init( e );
				
			}
			
			private function _populate():void
			{
				var saveMngr:SaveDataMngr = SaveDataMngr.instance;
				var xml:XML = MapList.list;
				var xmlSave:XML, xmllist:XMLList = xml.level.(@sett == _setIndex);
				var i:int, j:int, w:uint, txf:TextField, sp:Sprite, g:Graphics;
				
				j = _tabsClip.numChildren;
				for ( i=0; i<j; i++ ) {
					sp = _tabsClip.getChildAt(i) as Sprite;
					sp.buttonMode = sp.mouseEnabled = true;
					g = sp.graphics;
					g.clear();
					w = TextField(sp.getChildAt(0)).width+10 >>0;
					if ( i == _setIndex ) {
						sp.buttonMode = sp.mouseEnabled = false;
						g.lineStyle( 1, 0xB2B2B2, 1 );
						g.beginFill( 0xE5E5E5 );
						g.drawRect( -5, 0, w, 17 );
					} else {
						g.beginFill( 0, 0 );
						g.drawRect( -5, 0, w, 17 );
					}
				}
				
				sp = new Sprite;
				with ( sp.addChild(new Bitmap) ) x = y = 4;
				sp.addChild( new Sprite );
				sp.addChild( UIFactory.createFixedTextField('', 'levelName', 'left') );
				sp.addChild( UIFactory.createTextField('', 'levelScore', 'right', 82, 22) );
				with ( sp.addChild(PuttBase2.assets.createDisplayObject('screen.ui.bg.lockedLvlBg')) ) x = y = 4;
				g = sp.graphics;
				g.beginFill( 0xCCCC99 );
				g.drawRoundRect( 0, 0, 88, 53, 5, 5 );
				
				
				var par:int, bmp:Bitmap, bmp2:Bitmap, pt:Point = new Point;
				for ( i=0; i<12; i++ ) {
					bmp = Sprite(_lvlsClip.getChildAt(i)).getChildAt( 0 ) as Bitmap;
					xml = xmllist[i];
					if ( xml != null ) {
						bmp.visible = true;
						bmp.parent.mouseEnabled = false;
						sp.getChildAt(4).visible = false;
						
						if ( !saveMngr.isLevelOpen(xml) ) {
							sp.getChildAt(4).visible = true;
							sp.getChildAt(0).visible = sp.getChildAt(1).visible = sp.getChildAt(2).visible = sp.getChildAt(3).visible = false;
							
							_lvlsBmps[i].fillRect( bmp.bitmapData.rect, 0 );
							_lvlsBmps[i].draw( sp );
							
							with ( bmp.bitmapData ) {
								lock();
								fillRect( rect, 0 );
								applyFilter( _lvlsBmps[i], rect, pt, ColorMatrixUtil.setSaturation(-75) );
								unlock();
							}
							
						}
						else {
							xmlSave = saveMngr.getLevelData( xml.@name, xml.@hash );
							bmp.parent.mouseEnabled = true;
							sp.getChildAt(0).visible = sp.getChildAt(1).visible = sp.getChildAt(2).visible = sp.getChildAt(3).visible = true;
							g = Sprite(sp.getChildAt(1)).graphics;
							g.clear();
							
							TextField(sp.getChildAt(2)).text = String(xml.@name).replace(/\-/g,' ');
							g.beginFill( 0xCCCC99 );
							g.drawRoundRect( 0, 0, sp.getChildAt(2).width, 15, 5, 5 );
							
							bmp2 = sp.getChildAt(0) as Bitmap;
							
							if ( bmp2.bitmapData ) {
								bmp2.bitmapData.dispose();
								bmp2.bitmapData = null;
							}
							if ( xml.child('clip').length() )
								bmp2.bitmapData = PuttBase2.assets.createBitmapData( xml.clip );
								
							
							if ( int(xmlSave.@score) ) {
								par = int(xmlSave.@par);
								TextField(sp.getChildAt(3)).htmlText = '<p class="levelPar">'+ (par>0?par+' over':(par<0?Math.abs(par)+' under':'')) +' par</p>\n<p class="levelScore">'+ int(xmlSave.@score) +'</p>\n';
								
								g.beginFill( 0, .5 );
								g.drawRect( 4, 25, 80, 25 );
								
							} else
								TextField(sp.getChildAt(3)).htmlText = '';
							
							_lvlsBmps[i].fillRect( bmp.bitmapData.rect, 0 );
							_lvlsBmps[i].draw( sp );
							
							with ( bmp.bitmapData ) {
								lock();
								fillRect( rect, 0 );
								applyFilter( _lvlsBmps[i], rect, pt, ColorMatrixUtil.setSaturation(-75) );
								unlock();
							}
							
						}
					}
					else {
						bmp.visible = false;
					}
				}
				
			}
			
			
			private function _close( e:MouseEvent ):void
			{
				hide();
			}
			
			
			private function _click( e:MouseEvent ):void
			{
				var xml:XML = MapList.list;
				var xmllist:XMLList = xml.level.(@sett == _setIndex);
				var i:int = _lvlsClip.getChildIndex( DisplayObject(e.target) );
				
				var saveMngr:SaveDataMngr = SaveDataMngr.instance;
				if ( ! saveMngr.isLevelOpen(xmllist[i]) ) return;
				
				saveMngr.saveCustom( 'lastMap', i, false );
				saveMngr.saveCustom( 'lastMapSet', _setIndex, true );
				
				var ses:Session = Session.instance;
				if ( _parentClass == MenuActScreen ) {
					Tracker.i.custom( 'btn_openlevel', 'mainmenu' );
					CONFIG::onFGL {
						Tracker.i.trackFGL( 'open level', 1, 'fr menu current '+ (i+_setIndex*12) ); }
					
				} else
				if ( _parentClass == SuccessWindow ) {
					Tracker.i.custom( 'btn_openlevel', 'result' );
					CONFIG::onFGL {
						Tracker.i.trackFGL( 'open level', 1, 'fr success current '+ (i+_setIndex*12) ); }
					
				} else
				if ( _parentClass == PauseWindow ) {
					Tracker.i.custom( 'btn_openlevel', 'paused' );
					if ( !ses.map.isCustom )
						Tracker.i.levelCounter( 'changelevel', ses.map.name );
					
					CONFIG::onFGL {
						Registry.FGL_TRACKER.endLevel( ses.map.levelIndex, 'open level', 'quit current '+ (i+_setIndex*12) ); }
					
					CONFIG::onFGL {
						Registry.FGL_TRACKER.customMsg( 'open level', 1, 'fr pause current '+ (i+_setIndex*12) ); }
				}
				
				ses.map = new MapData( xmllist[i], null, i+_setIndex*12 );
				
				CONFIG::debug {
					GameRoot.changeScreen( RelayScreen, UserInput.instance.isKeyDown(KeyCode.SPACEBAR)? EditorScreen: PlayScreen ); }
				CONFIG::release {
					GameRoot.changeScreen( RelayScreen, PlayScreen ); }
				
			}
			
			private function _movr( e:MouseEvent ):void
			{
				var i:int = _lvlsClip.getChildIndex( DisplayObject(e.target) );
				var bmp:Bitmap = Sprite(e.target).getChildAt( 0 ) as Bitmap;
				with ( bmp.bitmapData ) {
					lock();
					fillRect( rect, 0 );
					copyPixels( _lvlsBmps[i], rect, new Point );
					unlock();
				}
				
				_lvlsClipShade.visible = true;
				_lvlsClipShade.x = 35 +100*(i%4);
				_lvlsClipShade.y = 50 +60*(i/4>>0);
			}
			
			private function _mout( e:MouseEvent ):void
			{
				var i:int = _lvlsClip.getChildIndex( DisplayObject(e.target) );
				var bmp:Bitmap = Sprite(e.target).getChildAt( 0 ) as Bitmap;
				with ( bmp.bitmapData ) {
					lock();
					fillRect( rect, 0 );
					applyFilter( _lvlsBmps[i], rect, new Point, ColorMatrixUtil.setSaturation(-75) );
					unlock();
				}
				_lvlsClipShade.visible = false;
			}
			
			
			private function _tabCk( e:MouseEvent ):void
			{
				var i:int = _tabsClip.getChildIndex( e.target as Sprite );
				if ( i != _setIndex ) {
					_setIndex = i;
					_populate();
				}
				
			}
			
			private function _tabMovr( e:MouseEvent ):void
			{
				var g:Graphics, sp:Sprite = Sprite( e.target );
				var w:uint = TextField(sp.getChildAt(0)).width +10 >>0;
				g = sp.graphics;
				if ( _tabsClip.getChildIndex(sp) != _setIndex ) {
					g.clear();
					g.lineStyle( 1, 0xB2B2B2, 1 );
					g.beginFill( 0xDDDDDD );
					g.drawRect( -5, 0, w, 17 );
				}
				
			}
			
			private function _tabMout( e:MouseEvent ):void
			{
				var g:Graphics, sp:Sprite = Sprite( e.target );
				var w:uint = TextField(sp.getChildAt(0)).width +10 >>0;
				if ( _tabsClip.getChildIndex(sp) != _setIndex ) {
					g = sp.graphics;
					g.clear();
					g.beginFill( 0, 0 );
					g.drawRect( -5, 0, w, 17 );
				}
				
			}
			
			
	}

}