package pb2.game.entity.render 
{
	import com.demonsters.debugger.MonsterDebugger;
	import com.jaycsantos.display.animation.AnimationTiming;
	import com.jaycsantos.display.CachedAssets;
	import com.jaycsantos.display.CachedBmp;
	import com.jaycsantos.display.render.IAnimatedRender;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.Trigo;
	import com.jaycsantos.util.GameLoop;
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import pb2.game.entity.b2.b2EntBmpRender;
	import pb2.game.entity.b2.b2Entity;
	import pb2.game.entity.b2.b2EntRender;
	import pb2.game.entity.FloorGate;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class FloorGateRender extends b2EntBmpRender implements IDragBaseDraw, IAnimatedRender
	{
		public var groundDirt:Bitmap
		
		
		public function FloorGateRender( gate:FloorGate, args:EntityArgs ) 
		{
			super( gate, args );
			
			gate.gateRender = this;
			hasAlphaChannel = true;
			
			Session.instance.ground.gndRender.clip.addChild( groundDirt = new Bitmap );
			groundDirt.blendMode = BlendMode.MULTIPLY;
			
			_animator = new AnimationTiming( [1,10], GameLoop.instance.timeFrameRate*2.5 );
			_animator.addSequenceSet( 'openToClose', [10,9,8,7,6,5,4,3,2,1], _animator.frameSpeed, false );
			_animator.addSequenceSet( 'closeToOpen', [1,2,3,4,5,6,7,8,9,10], _animator.frameSpeed, false );
			
			
			
			//var cachedName:String, cached:CachedBmp = CachedAssets.getClip( cacheName = 'entity.block.gate.dirt'
		}
		
		override public function dispose():void 
		{
			var gate:FloorGate = _entity as FloorGate;
			groundDirt.parent.removeChild( groundDirt );
			Session.instance.ground.gndRender.drawPartial( gate.defTileX, gate.defTileY );
			
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
			
			super.update();
		}
		
		
		public function basedraw():DisplayObject
		{
			var gate:FloorGate = _entity as FloorGate;
			
			groundDirt.visible = false;
			Session.instance.ground.gndRender.drawPartial( gate.defTileX, gate.defTileY );
			
			var mc:MovieClip = Session.getDisplayAsset( 'entity.block.gate' ) as MovieClip;
			mc.rotation = Math.abs(gate.defRa * Trigo.RAD_TO_DEG) % 180;
			mc.gotoAndStop( _animator.frame-1 );
			return mc;
		}
		
		public function play( data:Object = null ):void
		{
			var gate:FloorGate = _entity as FloorGate;
			var doOpen:Boolean = gate.state;
			if ( gate.isReversed ) doOpen = !doOpen;
			if ( doOpen )
				_animator.playSet( 'closeToOpen' );
			else
				_animator.playSet( 'openToClose' );
		}
		
		public function stop( data:Object = null ):void {}
		
		public function reset( data:Object = null ):void
		{
			var gate:FloorGate = _entity as FloorGate;
			var isOpen:Boolean = gate.state;
			if ( gate.isReversed ) isOpen = !isOpen;
			if ( isOpen )
				_animator.playSet( 'closeToOpen' );
			else
				_animator.playSet( 'openToClose' );
			_animator.stop( _animator.length-1 );
			_drawFrame();
		}
		
		
		
			// -- private --
			
			protected var _animator:AnimationTiming
			
			
			override protected function _draw():void 
			{
				var gate:FloorGate = _entity as FloorGate;
				var rotation:int = Math.abs(gate.defRa * Trigo.RAD_TO_DEG) % 180;
				var completeName:String = 'entity.block.gate';
				
				var cacheName:String, cached:CachedBmp = CachedAssets.getClip( cacheName = completeName +'.dirt@'+ rotation );
				if ( ! cached ) {
					var mc:MovieClip = Session.getDisplayAsset( completeName +'.dirt' ) as MovieClip;
					mc.rotation = rotation;
					cached = CachedAssets.instance.cacheTempClip( completeName +'.dirt@'+ rotation, mc, true );
				}
				groundDirt.bitmapData = cached.data;
				groundDirt.x = _entity.p.x +cached.offX;
				groundDirt.y = _entity.p.y +cached.offY;
				groundDirt.visible = buffer.visible;
				
				Session.instance.ground.gndRender.drawPartial( gate.defTileX, gate.defTileY );
			}
			
			protected function _drawFrame():void
			{
				var gate:FloorGate = _entity as FloorGate;
				var rotation:int = Math.abs(gate.defRa * Trigo.RAD_TO_DEG) % 180;
				var completeName:String = 'entity.block.gate';
				var frame:int = _animator.frame;
				
				var mc:MovieClip, cacheName:String, cached:CachedBmp = CachedAssets.getClip( cacheName = completeName +'@'+ rotation +'@'+ frame );
				if ( ! cached ) {
					mc = Session.getDisplayAsset( completeName ) as MovieClip;
					mc.rotation = rotation;
					for ( var i:int; i < 10; i++ ) {
						mc.gotoAndStop( i + 1 );
						cached = CachedAssets.instance.cacheTempClip( completeName +'@'+ rotation +'@'+ (i+1), mc, true );
					}
					cached = CachedAssets.getClip( cacheName );
				}
				bufferBmp.bitmapData = bmp = cached.data;
				bmpOffX = cached.offX;
				bmpOffY = cached.offY;
			}
			
			
	}

}