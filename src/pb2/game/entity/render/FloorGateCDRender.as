package pb2.game.entity.render 
{
	import Box2D.Common.Math.b2Vec2;
	import com.jaycsantos.display.*;
	import com.jaycsantos.display.animation.AnimationTiming;
	import com.jaycsantos.display.render.IAnimatedRender;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.Trigo;
	import flash.display.*;
	import flash.geom.Matrix;
	import pb2.game.entity.b2.*;
	import pb2.game.entity.FloorGateCD;
	import pb2.game.Session;
	import pb2.screen.EditorScreen;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class FloorGateCDRender extends b2EntBmpRender implements IDragBaseDraw, IAnimatedRender
	{
		public var groundDirt:Bitmap
		
		public function FloorGateCDRender( gate:FloorGateCD, args:EntityArgs )
		{
			super( gate, args );
			
			gate.gateRender = this;
			hasAlphaChannel = true;
			
			Session.instance.ground.gndRender.clip.addChild( groundDirt = new Bitmap );
			groundDirt.blendMode = 'multiply';
			
			_animator = new AnimationTiming( [1,10], 2, 1 );
			_animator.addSequenceSet( SHOW, [10,9,8,7,6,5,4,3,2,1], 1, false );
			_animator.addSequenceSet( HIDE, [1,2,3,4,5,6,7,8,9,10], 1, false );
			
			_animator.addIndexScript( 5, _enableBody, SHOW );
			_animator.addIndexScript( 5, _disableBody, HIDE );
		}
		
		override public function dispose():void 
		{
			var gate:FloorGateCD = _entity as FloorGateCD;
			groundDirt.parent.removeChild( groundDirt );
			Session.instance.ground.gndRender.drawPartial( gate.defTileX, gate.defTileY );
			
			_animator.dispose(); _animator = null;
			// don't dispose, we cached it!
			bufferBmp.bitmapData = bmp = null;
			
			super.dispose();
		}
		
		
		override public function update():void 
		{
			if ( _animator.isPlaying ) {
				_animator.update();
				_drawFrame();
				
			}
			if ( !(Session.isOnEditor && EditorScreen.editMode) ) {
				if ( _ctr++ > FRAME_DELAY ) {
					if ( _animator.setName == HIDE ) _animator.playSet( SHOW );
					else _animator.playSet( HIDE );
					_ctr = 0;
				}
			}
			
			super.update();
		}
		
		
		public function basedraw():DisplayObject
		{
			var gate:FloorGateCD = _entity as FloorGateCD;
			
			groundDirt.visible = false;
			Session.instance.ground.gndRender.drawPartial( gate.defTileX, gate.defTileY );
			
			return Session.getDisplayAsset( 'entity.block.'+gate.type );
		}
		
		public function play( data:Object=null ):void {}
		public function stop( data:Object=null ):void {}
		public function reset( data:Object=null ):void
		{
			var gate:FloorGateCD = _entity as FloorGateCD;
			if ( gate.isReversed ) {
				_disableBody();
				_animator.playSet( HIDE, 9 );
			} else {
				_enableBody();
				_animator.playSet( SHOW, 9 );
			}
			_ctr = 0;
			_drawFrame();
		}
		
		
		
			// -- private --
			
			protected static const SHOW:String = 'show', HIDE:String = 'hide'
			protected static const FRAME_DELAY:uint = 100
			
			
			protected var _animator:AnimationTiming, _ctr:int
			
			
			override protected function _draw():void 
			{
				var gate:FloorGateCD = _entity as FloorGateCD;
				var completeName:String = 'entity.block.gatePop';
				
				var cacheName:String, cached:CachedBmp = CachedAssets.getClip( cacheName = completeName +'.dirt' );
				if ( ! cached ) {
					var mc:MovieClip = Session.getDisplayAsset( completeName +'.dirt' ) as MovieClip;
					cached = CachedAssets.instance.cacheTempClip( completeName +'.dirt', mc, true );
				}
				groundDirt.bitmapData = cached.data;
				groundDirt.x = _entity.p.x +cached.offX;
				groundDirt.y = _entity.p.y +cached.offY;
				groundDirt.visible = buffer.visible;
				
				Session.instance.ground.gndRender.drawPartial( gate.defTileX, gate.defTileY );
			}
			
			protected function _drawFrame():void
			{
				var gate:FloorGateCD = _entity as FloorGateCD;
				var completeName:String = 'entity.block.gatePop';
				var frame:int = _animator.frame;
				
				var mc:MovieClip, cacheName:String, cached:CachedBmp = CachedAssets.getClip( cacheName = completeName +'@'+ frame );
				if ( ! cached ) {
					var ses:Session = Session.instance, sun:b2Vec2 = ses.sun_angle.Copy(); sun.Multiply( ses.sun_length );
					var sunAngle:int = Trigo.getAngle(sun.x, sun.y) << 0;
					var shade:Sprite = new Sprite, shp:Shape, g:Graphics = Shape(shade.addChild( shp=new Shape )).graphics;
					g.beginFill( 0 );
					g.drawCircle( 0, 0, FloorGateCD.RADIUS );
					
					for ( var i:int; i < 10; i++ ) {
						shp.transform.matrix = new Matrix;
						shp.width = FloorGateCD.RADIUS*2 +ses.sun_length*(9-i)/18;
						shp.rotation = sunAngle;
						shp.x = sun.x/4 *(9-i)/9; shp.y = sun.y/4 *(9-i)/9;
						cached = CachedAssets.instance.cacheTempClip( completeName +'.shade@'+ (i+1), shade, true );
					}
					
					mc = Session.getDisplayAsset( completeName ) as MovieClip;
					for ( i=0; i < 10; i++ ) {
						mc.gotoAndStop( i + 1 );
						cached = CachedAssets.instance.cacheTempClip( completeName +'@'+ (i+1), mc, true );
					}
					cached = CachedAssets.getClip( cacheName );
				}
				bufferBmp.bitmapData = bmp = cached.data;
				bmpOffX = cached.offX;
				bmpOffY = cached.offY;
				
				cached = CachedAssets.getClip( completeName +'.shade@'+ frame );
				clipShade.bitmapData = cached.data;
				_shadeOffX = cached.offX;
				_shadeOffY = cached.offY;
			}
			
			private function _disableBody():void
			{
				FloorGateCD(_entity).body.SetActive( false );
			}
			
			private function _enableBody():void
			{
				FloorGateCD(_entity).body.SetActive( true );
			}
			
			
			
	}

}