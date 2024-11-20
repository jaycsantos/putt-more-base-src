package pb2.game 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Joints.b2PrismaticJointDef;
	import com.jaycsantos.math.Trigo;
	import FGL.GameTracker.GameTracker;
	import flash.external.ExternalInterface;
	
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class Registry 
	{
		public static const BUILD_DATE:String = CONFIG::timeStamp;
		public static const VERSION:String = CONFIG::version;
		
		public static var useDefaultSponsor:Boolean = false;
		//public static var useDefaultGameURL:Boolean = !ExternalInterface.available;
		public static var SPONSOR_NAME:String = 'Turbo Nuke'
		public static var SPONSOR_URL:String = 'http://www.turbonuke.com/?gamereferal=puttmorebase';
		public static var SPONSOR_URL_PLAIN:String = 'http://turbonuke.com';
		public static var SPONSOR_URL_ADDWEB:String = 'http://www.turbonuke.com/addgame.php?gamereferal=puttmorebase';
		public static var SPONSOR_GAME_URL:String = 'http://www.turbonuke.com/games.php?game=puttmorebase';
		public static var SPONSOR_GAME_URL_LVLID:String = 'http://www.turbonuke.com/games.php?game=puttmorebase&pb_';
		
		public static const FGL_TRACKER:GameTracker = new GameTracker;
		
		public static const PLAYTOMIC_LEADERBOARDS:String = 'highscores';
		public static const PLAYTOMIC_GLOBAL_LEADERBOARD:Boolean = true;
		public static const PLAYTOMIC_ERR_MSG:Object = {
				1:'Playtomic servers are unreachable',
				2:'Invalid game credentials',
				3:'Request timed out',
				4:'Invalid request', 
				300:'GameVars API disabled, server is overloaded',
				400:'Level Sharing API disabled, server is overloaded',
				401:'Invalid rating value',
				402:'Already rated',
				403:'Level name not provided',
				404:'Invalid image auth',
				405:'Invalid image auth',
				406:'Level already exists'
			};
		public static const PLAYTOMIC_VARS:Object = {
				HighscoreRankOffset: 0,
				ShowPlayerLvlPlays: 0,
				BlackListUrl: ''
			};
		public static var PLAYTOMIC_MSGS:Array = [];
		
		
		public static const b2Scale:int = 30;
		public static const b2RenderScale:int = 30;
		public static const b2NormalImpulseMin:Number = .015;
		public static const b2NormalImpulseMax:Number = .14;
		
		public static const tileSize:uint = 36;
		public static const b2TileScaleSize:Number = tileSize / b2Scale;
		
		public static const springPush:Number = 280 / b2Scale;
		public static const springBlockPush:Number = 280 / b2Scale;
		
		
		public static const STATIC_b2BodyDef:b2BodyDef = new b2BodyDef;
			STATIC_b2BodyDef.type = b2Body.b2_staticBody;
		public static const STATIC_b2FixtDef:b2FixtureDef = new b2FixtureDef;
			STATIC_b2FixtDef.density = 0;
			STATIC_b2FixtDef.friction = 0.1;
			STATIC_b2FixtDef.filter.categoryBits = 128;
		public static const STATIC_MOSS_b2FixtDef:b2FixtureDef = new b2FixtureDef;
			STATIC_MOSS_b2FixtDef.friction = .07;
			STATIC_MOSS_b2FixtDef.restitution = -.04;
			STATIC_MOSS_b2FixtDef.filter.categoryBits = STATIC_b2FixtDef.filter.categoryBits;
		public static const STATIC_RUBBER_b2FixtDef:b2FixtureDef = new b2FixtureDef;
			STATIC_RUBBER_b2FixtDef.friction = .01;
			STATIC_RUBBER_b2FixtDef.restitution = .915;
			STATIC_RUBBER_b2FixtDef.filter.categoryBits = STATIC_b2FixtDef.filter.categoryBits;
		
		public static const ALL_b2bodyDef:b2BodyDef = new b2BodyDef;
			ALL_b2bodyDef.type = b2Body.b2_dynamicBody;
			ALL_b2bodyDef.linearDamping = 1;
			ALL_b2bodyDef.angularDamping = 1.5;
		public static const ALL_b2FixtDef:b2FixtureDef = new b2FixtureDef;
			ALL_b2FixtDef.density = .6;
			//b2WoodFixtureDef.friction = 2;
			//b2WoodFixtureDef.restitution = .35;
			ALL_b2FixtDef.filter.categoryBits = 2;
		
		public static const SENSOR_b2FixtDef:b2FixtureDef = new b2FixtureDef;
			SENSOR_b2FixtDef.isSensor = true;
		
		public static const HOLE_Radius:uint = 14.5;
		public static const BALL_shakeImpulseMin:Number = b2NormalImpulseMax*2;
		public static const BALL_shakeIntensity:uint = 1;
		public static const BALL_shakeLength:uint = 3;
		public static const BALL_Radius:uint = 11;
		public static const BALL_MaxSpeed:Number = 460 / b2Scale;
		public static const BALL_b2BodyDef:b2BodyDef = new b2BodyDef;
			BALL_b2BodyDef.type = b2Body.b2_dynamicBody;
			BALL_b2BodyDef.linearDamping = .31;
			BALL_b2BodyDef.angularDamping = .7;
			BALL_b2BodyDef.bullet = true;
		public static const BALL_b2FixtDef:b2FixtureDef = new b2FixtureDef;
			BALL_b2FixtDef.density = .045;
			BALL_b2FixtDef.friction = .2;
			BALL_b2FixtDef.restitution = .78;
			BALL_b2FixtDef.filter.categoryBits = 1;
		
		public static const RUBBER_b2BodyDef:b2BodyDef = new b2BodyDef;
			RUBBER_b2BodyDef.type = b2Body.b2_dynamicBody;
			RUBBER_b2BodyDef.linearDamping = 2;
			RUBBER_b2BodyDef.angularDamping = 3;
		public static const RUBBER_b2FixtDef:b2FixtureDef = new b2FixtureDef;
			RUBBER_b2FixtDef.density = 2;
			RUBBER_b2FixtDef.friction = .02;
			RUBBER_b2FixtDef.restitution = .915;
			RUBBER_b2FixtDef.filter.categoryBits = ALL_b2FixtDef.filter.categoryBits;
		
		public static const JELLY_b2BodyDef:b2BodyDef = new b2BodyDef;
			JELLY_b2BodyDef.type = b2Body.b2_dynamicBody;
			JELLY_b2BodyDef.linearDamping = .6;
			JELLY_b2BodyDef.angularDamping = .9;
		public static const JELLY_b2FixtDef:b2FixtureDef = new b2FixtureDef;
			JELLY_b2FixtDef.density = .2;
			JELLY_b2FixtDef.friction = .0;
			JELLY_b2FixtDef.restitution = -.04;
			JELLY_b2FixtDef.filter.categoryBits = ALL_b2FixtDef.filter.categoryBits;
		
		public static const GLASS_b2ImpactMin:Number = b2NormalImpulseMin +(b2NormalImpulseMax-b2NormalImpulseMin)/4;
		public static const GLASS_b2FixtDef:b2FixtureDef = new b2FixtureDef;
			GLASS_b2FixtDef.density = .012;
			GLASS_b2FixtDef.filter.categoryBits = ALL_b2FixtDef.filter.categoryBits;
		
		public static const IRON_b2BodyDef:b2BodyDef = new b2BodyDef;
			IRON_b2BodyDef.type = b2Body.b2_dynamicBody;
			IRON_b2BodyDef.linearDamping = 2;
			IRON_b2BodyDef.angularDamping = 3;
		public static const IRON_b2FixtDef:b2FixtureDef = new b2FixtureDef;
			IRON_b2FixtDef.density = 1;
			IRON_b2FixtDef.filter.categoryBits = ALL_b2FixtDef.filter.categoryBits;
		
		public static const BOMB_Radius:uint = 14;
		public static const BOMB_Multiplier:Number = 1.3;
		public static const BOMB_shakeIntensity:uint = 8;
		public static const BOMB_shakeLength:uint = 10;
		
		public static const BLOWER_force:Number = 7 /b2Scale;
		public static const BLOWER_b2FixtDef:b2FixtureDef = new b2FixtureDef;
			BLOWER_b2FixtDef.isSensor = true;
			BLOWER_b2FixtDef.shape = b2PolygonShape.AsOrientedBox( b2TileScaleSize*9/18, b2TileScaleSize*6/18, new b2Vec2 );
			BLOWER_b2FixtDef.filter.categoryBits = 4096;
		
		public static const BUTTON_ToggleDelay:uint = 1000;
		public static const BUTTON_BumpRadius:uint = 15;
		public static const BUTTON_b2MotorSpeed:uint = 30/b2Scale;
		public static const BUTTON_b2FixtDef:b2FixtureDef = new b2FixtureDef;
			BUTTON_b2FixtDef.density = .1;
			BUTTON_b2FixtDef.filter.categoryBits = 2048;
			// should not collide with static walls & other buttons
			BUTTON_b2FixtDef.filter.maskBits = uint.MAX_VALUE & ~Registry.STATIC_b2FixtDef.filter.categoryBits & ~BUTTON_b2FixtDef.filter.categoryBits;
			BUTTON_b2FixtDef.shape = b2PolygonShape.AsOrientedBox( b2TileScaleSize/2*8/36, b2TileScaleSize/2*31/36, new b2Vec2(-b2TileScaleSize/2*14/18, 0) )
		public static const BUTTON_b2JointDef:b2PrismaticJointDef = new b2PrismaticJointDef;
			BUTTON_b2JointDef.lowerTranslation = -b2TileScaleSize/2*5/18;
			BUTTON_b2JointDef.upperTranslation = 0;
			BUTTON_b2JointDef.enableLimit = true;
			BUTTON_b2JointDef.enableMotor = true;
			BUTTON_b2JointDef.maxMotorForce = 1;
		
		public static const WALLGATE_breakLimit:uint = 3;
		public static const WALLGATE_b2MotorSpeed:uint = 30/b2Scale;
		public static const WALLGATE_b2BodyDef:b2BodyDef = new b2BodyDef;
			WALLGATE_b2BodyDef.type = b2Body.b2_dynamicBody;
			WALLGATE_b2BodyDef.linearDamping = 0;
			WALLGATE_b2BodyDef.angularDamping = 0;
		public static const WALLGATE_b2FixtDef:b2FixtureDef = new b2FixtureDef;
			WALLGATE_b2FixtDef.density = .1;
			WALLGATE_b2FixtDef.filter.categoryBits = BUTTON_b2FixtDef.filter.categoryBits;
			WALLGATE_b2FixtDef.filter.maskBits = BUTTON_b2FixtDef.filter.maskBits;
			WALLGATE_b2FixtDef.shape = b2PolygonShape.AsOrientedBox( b2TileScaleSize/2*32/36, b2TileScaleSize/2*30/36, new b2Vec2(-b2TileScaleSize/2*2/18, 0) )
		public static const WALLGATE_b2JointDef:b2PrismaticJointDef = new b2PrismaticJointDef;
			WALLGATE_b2JointDef.lowerTranslation = -b2TileScaleSize/2*30/18;
			WALLGATE_b2JointDef.upperTranslation = 0;
			WALLGATE_b2JointDef.enableLimit = true;
			WALLGATE_b2JointDef.enableMotor = true;
			WALLGATE_b2JointDef.maxMotorForce = .8;
		
		
		public static const PUNCH_shakeIntensity:uint = 4;
		public static const PUNCH_shakeLength:uint = 6;
		public static const PUNCH_b2MotorSpeed:uint = 500;
		public static const PUNCH_b2MotorSpeed_Return:uint = 1.3;
		public static const PUNCH_b2BodyDef:b2BodyDef = new b2BodyDef;
			PUNCH_b2BodyDef.type = b2Body.b2_dynamicBody;
		public static const PUNCH_b2FixtDef:b2FixtureDef = new b2FixtureDef;
			PUNCH_b2FixtDef.density = .1;
			PUNCH_b2FixtDef.friction = RUBBER_b2FixtDef.friction;
			PUNCH_b2FixtDef.restitution = RUBBER_b2FixtDef.restitution;
			PUNCH_b2FixtDef.filter.categoryBits = 512;
			// should not collide with static walls, other punches and not be blown by floor blower
			PUNCH_b2FixtDef.filter.maskBits = uint.MAX_VALUE & ~STATIC_b2FixtDef.filter.categoryBits & ~PUNCH_b2FixtDef.filter.categoryBits & ~BLOWER_b2FixtDef.filter.categoryBits;
		public static const PUNCH_b2JointDef:b2PrismaticJointDef = new b2PrismaticJointDef;
			PUNCH_b2JointDef.lowerTranslation = 0;
			PUNCH_b2JointDef.upperTranslation = b2TileScaleSize/2 *29/18;
			PUNCH_b2JointDef.enableLimit = true;
			PUNCH_b2JointDef.enableMotor = true;
			PUNCH_b2JointDef.maxMotorForce = 6;
		
		public static const PPUNCH_b2FixtDef:b2FixtureDef = new b2FixtureDef;
			PPUNCH_b2FixtDef.density = .1;
			PPUNCH_b2FixtDef.friction = RUBBER_b2FixtDef.friction;
			PPUNCH_b2FixtDef.restitution = RUBBER_b2FixtDef.restitution;
			PPUNCH_b2FixtDef.filter.categoryBits = 1024;
			// should not collide with other punches and not be blown by floor blower
			PPUNCH_b2FixtDef.filter.maskBits = uint.MAX_VALUE & ~PPUNCH_b2FixtDef.filter.categoryBits & ~BLOWER_b2FixtDef.filter.categoryBits;
		public static const PPUNCH_b2JointDef:b2PrismaticJointDef = new b2PrismaticJointDef;
			PPUNCH_b2JointDef.lowerTranslation = 0;
			PPUNCH_b2JointDef.upperTranslation = b2TileScaleSize/2 *16/18;
			PPUNCH_b2JointDef.enableLimit = true;
			PPUNCH_b2JointDef.enableMotor = true;
			PPUNCH_b2JointDef.maxMotorForce = 6;
		
		
		
			
		public static const MenuScreen_ENTER_DUR:uint = 400;
		public static const MenuScreen_EXIT_DUR:uint = 300;
		
		public static const PreEditorScreen_ENTER_DUR:uint = 2000;
		public static const PreEditorScreen_EXIT_DUR:uint = 200;
		
		
		public static const EDITOR_MAX_PAR:uint = 12;
		
		
		
	}

}