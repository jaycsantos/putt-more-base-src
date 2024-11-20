package pb2.screen.window 
{
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import pb2.game.ctrl.SaveDataMngr;
	import pb2.screen.MenuActScreen;
	import pb2.screen.ui.UIFactory;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class GetNameWindow extends Pb2Window2a 
	{
		
		public var text:TextField
		
		public function GetNameWindow( parentClass:Class ) 
		{
			var g:Graphics, sp:Sprite, sp2:Sprite, shp:Shape, txf:TextField, i:int, j:int, k:String, a:Array;
			
			super();
			
			_bg2.width = 190; _bg2.height = 65;
			switch( parentClass ) {
				case LevelSelect:
					_contents.x = _bgClip.x = 428;
					_contents.y = _bgClip.y = 272;
					break;
				case MenuActScreen:
					_contents.x = _bgClip.x = 266;
					_contents.y = _bgClip.y = 290;
					break;
				case PopSuccess:
					_contents.x = _bgClip.x = 320;
					_contents.y = _bgClip.y = 230;
					break;
				case PopLeaderboards:
					_contents.x = _bgClip.x = 360;
					_contents.y = _bgClip.y = 250;
					break;
				default:
					_contents.x = _bgClip.x = (PuttBase2.STAGE_WIDTH-_bg2.width) /2 >>0;
					_contents.y = _bgClip.y = (PuttBase2.STAGE_HEIGHT-_bg2.height) /2 >>0;
					break;
			}
			
			mouseEnabled = true;
			g = _overlay.graphics;
			g.clear();
			//g.beginFill( 0, 0 );
			//g.drawRect( 0, 0, PuttBase2.STAGE_WIDTH, PuttBase2.STAGE_HEIGHT );
			
			_bgClip.addChild( UIFactory.createTextField('Enter Name', 'header', 'left', 10, 5) );
			
			_contents.addChild( text = UIFactory.createInputField('name', 'clevel2URL') );
			text.width = 130; text.height = 18;
			text.x = 13; text.y = 35;
			text.maxChars = 18; text.restrict = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 0987654321_';
			k = SaveDataMngr.instance.getCustom('highscore_name');
			text.text = k?k:'';
			
			_contents.addChild( _btnGo = PuttBase2.assets.createDisplayObject('screen.ui.btn.btnSave') as SimpleButton );
			_btnGo.addEventListener( MouseEvent.CLICK, _click, false, 0, true );
			_btnGo.x = 165; _btnGo.y = 40;
		}
		
		override public function dispose():void 
		{
			_btnGo.removeEventListener( MouseEvent.CLICK, _click );
			
			super.dispose();
		}
		
		
			// -- private --
			
			private var _btnGo:SimpleButton
			
			private function _click( e:MouseEvent ):void
			{
				if ( text.text.length < 3 ) {
					parent.addChild( parent['prompt'] = new Pb2Prompt2('Name must be more than 2 characters', 150, { name:'OK', call:parent['removePrompt'] } ) );
				
				} else {
					SaveDataMngr.instance.saveCustom( 'highscore_name', text.text.replace(/\s+/g,' '), true );
					hide();
				}
				
			}
		
		
	}

}