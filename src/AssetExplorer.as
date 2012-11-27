package  
{	
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.tags.ITag;
	import com.codeazur.as3swf.tags.TagDoABC;
	import com.codeazur.as3swf.tags.TagSymbolClass;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import mx.core.UIComponent;
	
	/**
	 * 素材浏览器
	 * @author Larry H.
	 * @createTime 2009-11-22 16:25
	 */
	public class AssetExplorer extends UIComponent
	{
		private var _library:AssetLibraryList;
		private var _explorer:SWF;
		
		/**
		 * 构造函数
		 * create a [AssetExplorer] object
		 */
		public function AssetExplorer() 
		{
			addChild(_library = new AssetLibraryList());
		}
		
		/**
		 * 加载完成
		 * @param	e
		 */
		public function readBytes(bytes:ByteArray):void 
		{
			_explorer = new SWF(bytes);			
			
			var loader:Loader = new Loader();
			var context:LoaderContext = new LoaderContext();
			context.applicationDomain = ApplicationDomain.currentDomain;
			context.allowCodeImport = true;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, contentReadyHandler);
			loader.loadBytes(bytes, context);
		}
		
		/**
		 * 素材加载完成
		 * @param	e
		 */
		private function contentReadyHandler(e:Event):void 
		{
			e.currentTarget.removeEventListener(e.type, arguments.callee);
			
			var tags:Array = [];
			var length:int = _explorer.tags.length;
			for (var i:int = 0, tag:ITag; i < length; i++)
			{
				tag = _explorer.tags[i];
				if (tag.type == TagSymbolClass.TYPE)
				{
					tags.push(tag);
				}
			}
			
			trace(tags);
			
			var symbol:TagSymbolClass;			
			var list:Array = [], linkage:String;
			
			for (var j:int = 0; j < tags.length;j++)
			{
				symbol = tags[j] as TagSymbolClass;
				for (i = 0, length = symbol.symbols.length; i < length; i++)
				{
					linkage = symbol.symbols[i].name;
					if (linkage)
					{
						list.push(new Asset(linkage));
					}
				}
			}
			
			_library.dataProvider = list;
		}
		
		override public function get width():Number { return _library.width; }
		
		override public function get height():Number { return _library.height; }
		
	}

}