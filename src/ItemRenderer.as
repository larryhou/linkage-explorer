package
{
	import com.larrio.controls.interfaces.IRenderer;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.text.TextField;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;
	
	import asset.explorer.ItemRendererView;
	
	/**
	 * 渲染器
	 * @author Larry H.
	 * @createTime 2009-11-22 16:03
	 */
	public class ItemRenderer extends Sprite implements IRenderer
	{
		private static const update_interval:int = 2000;
		
		public static const item_width:Number = 202;
		public static const item_height:Number = 230;
		
		private var _data:Asset;
		
		private var _icon:DisplayObject;
		private var _view:Sprite;
		
		private var _label:TextField;
		
		private var _timestamp:int = 0;
		
		private var _sound:Sound;
		private var _chanel:SoundChannel;
		
		/**
		 * 构造函数
		 * create a [ItemRenderer] object
		 */
		public function ItemRenderer()
		{		
			addChild(_view = new ItemRendererView());
			
			_label = _view["label"];
			
			this.mouseChildren = false;
			
			addEventListener(Event.ENTER_FRAME, frameHandler);
			
			addEventListener(MouseEvent.ROLL_OVER, mouseHandler);
			addEventListener(MouseEvent.ROLL_OUT, mouseHandler);
		}
		
		private function mouseHandler(e:MouseEvent):void
		{
			if(!_sound)return;
			
			if(e.type == MouseEvent.ROLL_OVER)
			{
				_chanel = _sound.play(0,1);				
			}
			else
			{
				_chanel.stop();
			}
		}
		
		/**
		 * 
		 * @param	e
		 */
		private function frameHandler(e:Event):void 
		{
			var time:int = getTimer();
			if (time - _timestamp < update_interval) return;
			
			_timestamp = time;
			
			if (!_icon || !(_icon is MovieClip)) return;
			
			var clip:MovieClip = _icon as MovieClip;
			if (clip.totalFrames == 1) return;
			
			try
			{
				if (clip.currentFrame < clip.totalFrames)
				{
					clip.gotoAndStop(clip.currentFrame + 1);
				}
				else
				{
					clip.gotoAndStop(1);
				}
			}
			catch(err:Error){}
		}
		
		/**
		 * 数据
		 */
		public function get data():Object { return _data; }
		public function set data(value:Object):void
		{
			_data = value as Asset;
			_icon && _icon.parent && _icon.parent.removeChild(_icon);
			
			if (!_data) return;
			
			_label.text = _data.linkage;
			
			var cls:Class = getDefinitionByName(_data.linkage) as Class;
			
			var extcls:String = describeType(cls).factory[0].extendsClass..@type.toXMLString();		
			
			if(_chanel) _chanel.stop();
			if(extcls.indexOf("flash.media::Sound") >= 0)
			{
				_sound = new cls();	return;
			}
			
			_sound = null;			
			if(extcls.indexOf("flash.display::BitmapData") >= 0)
			{
				_icon = new Bitmap(new cls(1,1));
			}
			else
			{
				_icon = new cls() as DisplayObject;
			}		
			
			if(!_icon) trace(extcls);
			
			if(_icon is DisplayObject == false)return;
			
			if (_icon is MovieClip) MovieClip(_icon).gotoAndStop(1);
			var max:Number = item_width - 20;
			if (_icon.width > _icon.height)
			{
				_icon.width = max; _icon.scaleY = _icon.scaleX;
			}
			else
			{
				_icon.height = max; _icon.scaleX = _icon.scaleY;
			}
			
			var bounds:Rectangle = _icon.getBounds(_icon);
			_icon.x = (item_width - _icon.width) / 2 - bounds.x * _icon.scaleX;
			_icon.y = (item_width - _icon.height) / 2 - bounds.y * _icon.scaleY;
			
			_view.addChildAt(_icon, 1);
		}
		
		/**
		 * 复写高度
		 */
		override public function get height():Number { return item_height; }
		override public function set height(value:Number):void { }
		
		/**
		 * 宽度
		 */
		override public function get width():Number { return item_width; }
		override public function set width(value:Number):void { }
		
	}

}