package 
{	
	import flash.display.Graphics;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	/**
	 * 错误发生变化时派发
	 */
	[Event(name = "change", type = "flash.events.Event")]
	
	/**
	 * 扑捉未处理的全局错误
	 * @author Larry H.
	 * @createTime 2011-10-27 11:42
	 */
	public class UncaughtErrorCollector extends EventDispatcher
	{
		private static const NOTE_COLOR		:int = 0xFFFF00;
		private static const ERROR_COLOR	:int = 0xFF0000;
		private static const TITLE_COLOR	:int = 0xFF00FF;
		private static const NORMAL_COLOR	:int = 0x00FF00;
		
		private var _index:int;
		private var _layer:Sprite;
		private var _message:TextField;
		
		private var _mainTarget:Sprite;
		private var _loaderInfo:LoaderInfo;
		
		private var _errors:Array;
		private var _currentError:Object;
		
		private static const INIT_INFO:String = "initialize successfully!";
		
		/**
		 * 构造函数
		 * create a [UncaughtErrorCollector] object
		 * @param	$mainTarget		程序的入口，一般为[Main Object]
		 */
		public function UncaughtErrorCollector($mainTarget:Sprite = null)
		{
			_mainTarget = $mainTarget;
			_loaderInfo = _mainTarget.loaderInfo;
			
			initUI();
			
			var info:String = format("\n[Error Collector]", TITLE_COLOR);
			if(_loaderInfo.hasOwnProperty("uncaughtErrorEvents"))
			{
				setTimeout(function():void
				{
					if(ExternalInterface.available)
					{
						//throw new Error(INIT_INFO);
					}
				}, 0);
				
				info += format(INIT_INFO, NORMAL_COLOR);
				_loaderInfo["uncaughtErrorEvents"].addEventListener("uncaughtError", uncaughtErrorHandler);
			}
			else
			{
				info += "Flashplayer does not support! " + Capabilities.version;
			}
			
			appendText(info);
		}
		
		/**
		 * 追加文本
		 * @param	msg
		 * @return
		 */
		private function appendText(msg:String):void
		{
			var text:String = _message.htmlText + msg;
			_message.htmlText = text;
			
			_message.scrollV = _message.maxScrollV;
		}
		
		/**
		 * 系统信息
		 */
		private function get _systemInfo():String
		{
			var info:String = format("[System Info]", TITLE_COLOR);
			info += format("\nplatform\t", NOTE_COLOR) + format(decodeURIComponent(Capabilities.serverString), NORMAL_COLOR);
			if(ExternalInterface.available)
			{
				var script:String = "function(){return navigator.userAgent;}";
				info += format("\n\nexplorer\t", NOTE_COLOR) + format(ExternalInterface.call(wrapJs(script)), NORMAL_COLOR);
			}
			
			return info;
		}
		
		/**
		 * 添加颜色
		 * @param	content
		 * @param	color
		 * @return
		 */
		private static function format(content:*, color:int = NaN):String
		{
			return "<font color='#" + color.toString(16).toUpperCase() + "'>" + content + "</font>";
		}
		
		/**
		 * 格式化
		 */
		private static function wrapJs(js:String):XML
		{
			return new XML("<script><![CDATA[" + js + "]]></script>");
		}
		
		/**
		 * 处理扑捉到的未处理错误
		 * @param	event
		 */
        private function uncaughtErrorHandler(event:Object):void
        {
			// 阻止报错框弹出
			if (event is Event) Event(event).preventDefault();
			
			var msg:String = format((++_index) + ".[Uncaught Error]", TITLE_COLOR);
			
			_currentError = event.error;
			
			_errors ||= [];
			_errors.push(_currentError);
			
			var err:Error, errEvt:ErrorEvent;
            if (_currentError is Error)
            {
                err = _currentError as Error;
				msg += "error=" + err;
				msg += "\n" + err.getStackTrace();
            }
            else 
			if (_currentError is ErrorEvent)
            {
                errEvt = _currentError as ErrorEvent;
				msg += "target=" + errEvt.target + "\tmessage=" + errEvt;
            }
            else
            {
				msg += "Unknown Error=" + _currentError;
            }
			
			appendText("\n" + msg);
			
			dispatchEvent(new Event(Event.CHANGE));
        }
		
		/**
		 * 初始化界面
		 */
        private function initUI():void
        {
			// 信息框容器
			_layer = new Sprite();
			_layer.name = "log_layer";
			_layer.mouseEnabled = false;
			
			// 半透明背景
			var graphics:Graphics = _layer.graphics;
			graphics.clear();
			graphics.beginFill(0x000000, 0.6);
			graphics.drawRoundRectComplex(0, 0, 600, 200, 0, 0, 0, 10);
			graphics.endFill();
			
			// 信息框
			_message = new TextField();
			_message.width = 600;
			_message.height = 200;
			_message.multiline = true;
			_message.wordWrap = true;
			
			var format:TextFormat = new TextFormat("Lucida Console", 15, 0xFF0000);
			format.leftMargin = 5;
			format.leading = 2;
			
			_message.defaultTextFormat = format;
			_message.htmlText = _systemInfo;
			_layer.addChild(_message);
			
			//_mainTarget.addChild(_layer);
			
			if (_mainTarget.stage)
			{
				_mainTarget.stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			}
        }
		
		/**
		 * 处理键盘操作
		 * @param	e
		 */
		private function keyUpHandler(e:KeyboardEvent):void 
		{
			if (e.ctrlKey && e.shiftKey && e.keyCode == Keyboard.F12)
			{
				if (_layer.parent)
				{
					_layer.parent.removeChild(_layer);
				}
				else
				{
					_mainTarget.addChild(_layer);
					_message.scrollV = _message.maxScrollV;
				}
			}
			else
			if (e.keyCode == Keyboard.ESCAPE)
			{
				_layer.mouseChildren = !_layer.mouseChildren;
			}
		}
		
		/**
		 * 当前错误
		 */
		public function get currentError():Object { return _currentError; }
		
		/**
		 * 错误列表
		 */
		public function get errors():Array { return _errors; }
	}

}