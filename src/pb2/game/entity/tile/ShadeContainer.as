package pb2.game.entity.tile 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.b2internal;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	import com.jaycsantos.entity.Entity;
	import com.jaycsantos.entity.EntityArgs;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import pb2.game.entity.b2.b2EntBmpRender;
	import pb2.game.entity.b2.b2Entity;
	import pb2.game.entity.b2.b2EntityTile;
	import pb2.game.entity.b2.b2EntRender;
	import pb2.game.Registry;
	import pb2.game.Session;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class ShadeContainer extends Entity 
	{
		public var shadeRender:ShadeRender
		
		
		public function ShadeContainer( args:EntityArgs = null ) 
		{
			super( args );
			
		}
		
		override public function dispose():void
		{
			super.dispose();
			shadeRender = null;
		}
		
		
		public function drawShade( g:Graphics, body:b2Body, local:Boolean = true, offX:Number = 0, offY:Number = 0, clear:Boolean = true, offSun:Number = 0 ):void
		{
			use namespace b2internal;
			
			var dp:Number, dp_prev:Number, v:b2Vec2, vertsOrig:Vector.<b2Vec2>, verts:Vector.<b2Vec2>, shaded:Vector.<b2Vec2>, marked:Boolean, i:int;
			
			var ses:Session = Session.instance, b2scale:Number = Registry.b2Scale;
			var sun:b2Vec2 = ses.sun_angle, sun_length:Number = ses.sun_length +offSun;
			
			// shadow angle projection
			var sp:b2Vec2 = new b2Vec2( -sun.y, sun.x );
			// shadow length offset
			var sl:b2Vec2 = new b2Vec2( sun.x *sun_length /b2scale, sun.y *sun_length /b2scale );
			
			var fixt:b2Fixture = body.GetFixtureList();
			var p:b2Vec2 = local ? new b2Vec2 : body.m_xf.position;
			
			if ( clear )
				g.clear();
			
			while ( fixt ) {
				g.beginFill( 0, 1 );	
				if ( fixt.m_shape.m_type == b2Shape.e_polygonShape && !fixt.m_isSensor ) {
					vertsOrig = b2PolygonShape( fixt.m_shape ).m_vertices;
					
					// get local rotation transformation
					verts = new Vector.<b2Vec2>();
					i = vertsOrig.length;
					while ( i-- )
						verts.push( b2Math.MulMV(body.m_xf.R, vertsOrig[i]) );
					verts.reverse();
					
					shaded = new Vector.<b2Vec2>();
					dp_prev = verts[verts.length-1].x *sp.x + verts[verts.length-1].y *sp.y;
					
					for ( i=0; i <= verts.length; i++ ) {
						v = verts[i%verts.length];
						// dot product on projection
						dp = v.x *sp.x + v.y *sp.y;
						
						// is the shaded part
						if ( dp_prev < dp ) {
							if ( ! marked )
								shaded.push( new b2Vec2(verts[(i==0?verts.length:i)-1].x +sl.x, verts[(i==0?verts.length:i)-1].y +sl.y) );
							
							shaded.push( new b2Vec2(v.x +sl.x, v.y +sl.y) );
							marked = true;
						} else {
							if ( marked )
								shaded.push( verts[(i==0?verts.length:i)-1] );
							
							shaded.push( v );
							marked = false;
						}
						dp_prev = dp;
					}
					
					i = shaded.length;
					g.moveTo( (shaded[0].x +p.x) *b2scale +offX, (shaded[0].y +p.y) *b2scale +offY );
					while ( i-- )
						g.lineTo( (shaded[i].x +p.x) *b2scale +offX, (shaded[i].y +p.y) *b2scale +offY );
				}
				g.endFill();
				fixt = fixt.GetNext();
			}
			
		}
		
		
		public function addShade( shade:DisplayObject ):DisplayObject
		{
			return shadeRender.clip.addChild( shade );
		}
		
		public function removeShade( shade:DisplayObject ):DisplayObject
		{
			return shadeRender.clip.removeChild( shade );
		}
		
		
	}

}