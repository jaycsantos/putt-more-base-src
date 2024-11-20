package pb2.game.entity.render 
{
	import Box2D.Common.Math.b2Vec2;
	import com.jaycsantos.display.animation.AnimationTiming;
	import com.jaycsantos.display.CachedAssets;
	import com.jaycsantos.display.CachedBmp;
	import com.jaycsantos.display.render.IAnimatedRender;
	import com.jaycsantos.entity.EntityArgs;
	import com.jaycsantos.math.MathUtils;
	import com.jaycsantos.math.Trigo;
	import com.jaycsantos.sound.GameSounds;
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import pb2.game.ctrl.BallCtrl;
	import pb2.game.entity.b2.b2EntBmpRender;
	import pb2.game.entity.b2.b2EntRender;
	import pb2.game.entity.Ball;
	import pb2.game.entity.Spinner;
	import pb2.game.Session;
	import pb2.GameAudio;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class SpinnerRender extends b2EntRender implements IAnimatedRender, IDragBaseDraw
	{
		public var clip:MovieClip, bmpClip:Bitmap, groundClip:MovieClip
		public var spinner:Spinner, speed:Number
		
		public function SpinnerRender( blk:Spinner, args:EntityArgs )
		{
			super( blk, args );
			
			blk.spinRender = this;
			spinner = blk;
			
			_animator = new AnimationTiming( [29], 100, 100 );
			var seq:Array = [];
			for ( var i:int = 28; i < 30; i++ ) seq.push( i );
			for ( i = 0; i < 28; i++ ) seq.push( i );
			_animator.addSequenceSet( 'spin', seq, 100, true, _tickSfx );
			_animator.addSequenceSet( 'slow', seq.concat(), 100, true );
			_animator.addSequenceSet( 'slowRev', seq.reverse(), 100, true );
			_animator.playSet( 'slow', 0 );
			//_animator.addIndexScript( 18, _tickSfx, 'spin' );
			_animator.stop();
			
			Sprite(buffer).addChild( clip = PuttBase2.assets.createDisplayObject('entity.block.'+ blk.type +'1') as MovieClip );
			clip.stop();
			
			Sprite(buffer).addChild( bmpClip = new Bitmap );
			bmpClip.visible = false;
			
			var shade:MovieClip = (clipShade = PuttBase2.assets.createDisplayObject('entity.block.spinner1')) as MovieClip;
			shade.transform.colorTransform = new ColorTransform(0, 0, 0, 1, 0, 0, 0, 0);
			shade.stop();
			_shadeOffX = _boundOffX *2;
			_shadeOffY = _boundOffY *2;
			Session.instance.shades.addShade( shade );
			
			Session.instance.ground.gndRender.clip.addChild( groundClip = PuttBase2.assets.createDisplayObject('entity.block.spinner.ground') as MovieClip );
			groundClip.blendMode = BlendMode.MULTIPLY;
		}
		
		override public function dispose():void 
		{
			groundClip.parent.removeChild( groundClip );
			Session.instance.ground.gndRender.drawPartial( spinner.defTileX, spinner.defTileY );
			
			// don't dispose, we cached it!
			bmpClip.bitmapData = null; bmpClip = null;
			clip = groundClip = null;
			
			super.dispose();
		}
		
		
		override public function update():void 
		{
			if ( _animator.isPlaying ) {
				if ( _animator.setName == 'spin' ) {
					if ( spinner.ball ) {
						var v:b2Vec2 = spinner.ball.body.GetLinearVelocity();
						speed = (clip.rotation%180? Math.abs(v.y): Math.abs(v.x)) * 100;
						
					} else if ( speed > 50 ) {
						speed *= .98;
						
					} else {
						if ( _animator.index > 15 )
							_animator.playSet( 'slow', _animator.index );
						else
							_animator.playSet( 'slowRev', 29-_animator.index );
					}
						
					_animator.step = speed << 0;
					
				} else {
					if ( _animator.frame == 28 ) {
						_animator.stop();
						clip.visible = false;
						bmpClip.visible = true;
					}
					_animator.step = speed << 0;
				}
				
				_animator.update();
				clip.gotoAndStop( _animator.frame );
				MovieClip(clipShade).gotoAndStop( _animator.frame );
			}
			
			super.update();
		}
		
		
		public function play( data:Object = null ):void
		{
			var v:b2Vec2 = spinner.ball.body.GetLinearVelocity();
			speed = (clip.rotation%180? Math.abs(v.y): Math.abs(v.x)) *100;
			_animator.playSet( 'spin', _animator.index );
			clip.visible = true;
			bmpClip.visible = false;
			spinner.onSpin.dispatch();
		}
		
		public function stop( data:Object = null ):void
		{
			reset();
			
			clip.gotoAndStop( _animator.frame );
			MovieClip(clipShade).gotoAndStop( _animator.frame );
			clip.visible = false;
			bmpClip.visible = true;
		}
		
		public function reset( data:Object = null ):void
		{
			_animator.playSet( 'slow', 0 );
			_animator.stop();
		}
		
		
		public function basedraw():DisplayObject
		{
			groundClip.visible = false;
			Session.instance.ground.gndRender.drawPartial( spinner.defTileX, spinner.defTileY );
			return clip;
		}
		
		
			// -- private -
			
			private var _animator:AnimationTiming
			
			override protected function _draw():void 
			{
				reset();
				
				clip.rotation = clipShade.rotation = spinner.defRa *Trigo.RAD_TO_DEG << 0;
				clip.gotoAndStop( _animator.frame );
				MovieClip(clipShade).gotoAndStop( _animator.frame );
				
				
				var cached:CachedBmp = CachedAssets.getClip( 'entity.block.'+spinner.type+'@'+ clip.rotation );
				if ( ! cached )
					cached = CachedAssets.instance.cacheTempClip( 'entity.block.'+spinner.type+'@'+ clip.rotation, clip, true );
				bmpClip.bitmapData = cached.data;
				bmpClip.x = cached.offX;
				bmpClip.y = cached.offY;
				
				groundClip.x = spinner.p.x;
				groundClip.y = spinner.p.y;
				groundClip.rotation = clip.rotation;
				groundClip.visible = true;
				Session.instance.ground.gndRender.drawPartial( spinner.defTileX, spinner.defTileY );
			}
			
			
			private function _tickSfx():void
			{
				var vol:Number = MathUtils.limit(speed / 600, 0, 1);
				if ( vol )
					GameSounds.play( GameAudio.FLICK, 0, 0, vol );// MathUtils.limit((650 - _entity.p.subtractedBy(BallCtrl.instance.getPrimary().p).length) / 650, 0, 0.95));
			}
			
			
	}

}