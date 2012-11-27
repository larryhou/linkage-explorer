package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Larry H.
	 * @createTime 2009-11-22 16:58
	 */
	public class DemoMain extends Sprite
	{
		private var _explorer:AssetExplorer;
		
		/**
		 * 构造函数
		 * create a [DemoMain] object
		 */
		public function DemoMain() 
		{
			addChild(_explorer = new AssetExplorer());
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, completeHandler);
			loader.load(new URLRequest("data/pr_7.swf"));
		}
		
		private function completeHandler(e:Event):void 
		{
			_explorer.readBytes(e.currentTarget.data);
		}
		
	}

}