package pb2.screen.ui 
{
	import com.demonsters.debugger.MonsterDebugger;
	import com.jaycsantos.display.SimplierButton;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import pb2.font.embed.*;
	/**
	 * ...
	 * @author jaycsantos
	 */
	public class UIFactory 
	{
		public static const css:StyleSheet = new StyleSheet
		public static var textFormat:TextFormat
		
		
		public static function init():void
		{
			new Candara; new CandaraBold; new Impact;
			
			CONFIG::debug {
				var f:Font, a:Array = Font.enumerateFonts();
				a.sortOn( 'fontName', Array.CASEINSENSITIVE );
				for each( f in a )
					trace( '[font '+ f.fontType +'] '+ f.fontName +' '+ f.fontStyle );
			}
			
			css.parseCSS( String(new CSS_LOAD) );
			
			var tmp:TextField = new TextField;
			tmp.styleSheet = css;
			tmp.htmlText = '<p>i</p>';
			textFormat = tmp.getTextFormat();
			
			
			
		}
		
		
		public static function createTextField( text:String, style:String = '', autosize:String = 'left', x:Number =0, y:Number =0 ):TextField
		{
			var txf:TextField = new TextField;
			txf.mouseEnabled = false;
			txf.styleSheet = css;
			txf.antiAliasType = AntiAliasType.ADVANCED;
			txf.selectable = false;
			txf.autoSize = autosize;
			txf.embedFonts = true;
			txf.mouseEnabled = false;
			txf.tabEnabled = false;
			
			var o:Object = css.getStyle( '.'+style );
			if ( o.border ) txf.border = true;
			if ( o.borderColor ) txf.borderColor = uint('0x'+String(o.borderColor).substr(1));
			if ( o.backgroundColor ) { txf.background = true; txf.backgroundColor = uint('0x'+String(o.backgroundColor).substr(1)); }
			
			txf.x = x; txf.y = y;
			txf.htmlText = '<p class="'+ style +'">'+ text +'</p>';
			
			return txf;
		}
		
		public static function createFixedTextField( text:String, style:String='', autosize:String='left', x:Number=0, y:Number=0 ):TextField
		{
			var txf:TextField = new TextField;
			txf.mouseEnabled = false;
			txf.styleSheet = css;
			txf.antiAliasType = AntiAliasType.ADVANCED;
			txf.selectable = false;
			txf.autoSize = autosize;
			txf.embedFonts = true;
			txf.mouseEnabled = false;
			txf.tabEnabled = false;
			
			var o:Object = css.getStyle( '.'+style );
			if ( o.border ) txf.border = true;
			if ( o.borderColor ) txf.borderColor = uint('0x'+String(o.borderColor).substr(1));
			if ( o.backgroundColor ) { txf.background = true; txf.backgroundColor = uint('0x'+String(o.backgroundColor).substr(1)); }
			
			txf.x = x; txf.y = y;
			
			txf.styleSheet = css;
			txf.htmlText = '<p class="'+ style +'">1</p>';
			var tf:TextFormat = txf.getTextFormat(0, 1);
			txf.styleSheet = null;
			txf.defaultTextFormat = tf;
			
			txf.text = text;
			
			return txf;
		}
		
		public static function createInputField( name:String, style:String = '' ):TextField
		{
			var txf:TextField = new TextField;
			txf.type = TextFieldType.INPUT;
			txf.antiAliasType = AntiAliasType.ADVANCED;
			txf.selectable = true;
			txf.embedFonts = true;
			txf.wordWrap = false;
			txf.multiline = false;
			
			txf.styleSheet = css;
			txf.htmlText = '<p class="'+ style +'">1</p>';
			var tf:TextFormat = txf.getTextFormat(0, 1);
			txf.styleSheet = null;
			txf.defaultTextFormat = tf;
			
			var o:Object = css.getStyle( '.'+style );
			if ( o.border ) txf.border = true;
			if ( o.borderColor ) txf.borderColor = uint('0x'+String(o.borderColor).substr(1));
			if ( o.backgroundColor ) { txf.background = true; txf.backgroundColor = uint('0x'+String(o.backgroundColor).substr(1)); }
			
			txf.name = name;
			return txf;
		}
		
		
		public static function createBtnType1( text:String, w:int=120, h:int=24, style:String='' ):SimplierButton
		{
			var sp:Sprite, txf:TextField;
			var btn:SimplierButton = new SimplierButton;
			btn.name = text;
			
			btn.upState = sp = new Sprite;
			sp.addChild( txf = createTextField('<span class="'+style+'">'+text+'</span>', 'btn1', 'none') );
			txf.width = w; txf.height = h;
			
			btn.overState = sp = new Sprite;
			sp.graphics.beginFill( 0x4C4100 );
			sp.graphics.drawRect( 2, 2, w-4, h-4 );
			sp.graphics.endFill();
			sp.addChild( txf = createTextField('<span class="">'+text+'</span>', 'btn1', 'none') );
			txf.width = w; txf.height = h;
			
			btn.downState = btn.lockState = sp = new Sprite;
			sp.graphics.beginFill( 0x997E00 );
			sp.graphics.drawRect( 2, 2, w-4, h-4 );
			sp.graphics.endFill();
			sp.addChild( txf = createTextField('<span class="btn1_down">'+text+'</span>', 'btn1', 'none') );
			txf.width = w; txf.height = h;
			
			btn.hitTestState = btn.disableState = sp = new Sprite;
			sp.graphics.beginFill( 0, 0 );
			sp.graphics.drawRect( 0, 0, w, h );
			sp.graphics.endFill();
			sp.addChild( txf = createTextField('<span class="btn1_inactive">'+text+'</span>', 'btn1', 'none') );
			txf.width = w; txf.height = h;
			
			return btn;
		}
		
		
		
			// -- private --
			
			[Embed(source="/../lib/style.css", mimeType="application/octet-stream")]
			private static const CSS_LOAD:Class
			
			
		
	}

}