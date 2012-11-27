package  
{
	import com.larrio.controls.layout.VDragLayout;
	
	import flash.display.Sprite;
	
	/**
	 * 素材列表库
	 * @author Larry H.
	 * @createTime 2009-11-22 15:59
	 */
	public class AssetLibraryList extends Sprite
	{
		private var _layout:VDragLayout;
		
		private var _rows:int = 2;
		private var _columns:int = 3;
		
		private var _gap:Number = 5;
		
		private var _width:Number;
		private var _height:Number;
		
		private var _dataProvider:Array;
		
		/**
		 * 构造函数
		 * create a [AssetLibraryList] object
		 */
		public function AssetLibraryList() 
		{
			_height = _rows * (ItemRenderer.item_height + _gap) - _gap + 10;
			_width = _columns * (ItemRenderer.item_width + _gap) - _gap + 10;
			
			init();
		}
		
		/**
		 * 初始化
		 */
		private function init():void 
		{
			graphics.clear();
			graphics.beginFill(0x000000, 0.05);
			graphics.lineStyle(0.1, 0xCCCCCC);
			graphics.drawRoundRectComplex(0, 0, _width, _height, 5, 5, 5, 5);
			graphics.endFill();
			
			_layout = new VDragLayout(_rows, _columns, _gap, _gap);
			_layout.itemRenderClass = ItemRenderer;
			_layout.dataProvider = null;
			//_layout.allowSameValue = true;
			_layout.scale = 30;
			addChild(_layout);
			
			_layout.x = (_width - _layout.width) / 2;
			_layout.y = (_height - _layout.height) / 2;
			
			_layout.enabled = true;
		}
		
		/**
		 * 设置列表数据
		 */
		public function get dataProvider():Array { return _layout.dataProvider; }
		public function set dataProvider(value:Array):void 
		{
			_layout.dataProvider = value;
			_layout.value = 0;
		}
		
		override public function get width():Number { return _width; }
		
		override public function get height():Number { return _height; }
		
	}

}