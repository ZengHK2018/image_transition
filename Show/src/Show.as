package
{
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import foozuu.app.AppConfig;
	
	import ghostcat.display.GBase;
	import ghostcat.display.transition.TransitionLayerBase;
	
	//[Frame(factoryClass="ghostcat.ui.RootLoader")]
	/**
	 * 
	 * @author flashyiyi
	 * 
	 */
	public class Show extends GBase
	{
		
		public var t:TransitionLayerBase;
		
		public function Show()
		{
			if(stage==null)
			{
				addEventListener(Event.ADDED_TO_STAGE, onAdded);
			}else{
				onAdded();
			}
		}
		private var _container:Sprite;
		private var _cover:Sprite;
		private var _sound:Sound;
		
		private var _config:AppConfig;
		private var _front:FilesInDir;
		private var _background:FilesInDir;
		private var _bgm:FilesInDir;
		private function onAdded(e:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			_config = new AppConfig(NativeApplication.nativeApplication, File.applicationDirectory.resolvePath("config/config.json").nativePath);
			_front = new FilesInDir();
			_front.init(File.applicationDirectory.resolvePath(_config.getData("frontground").dir),["jpg"]);
			_background = new FilesInDir();
			_background.init(File.applicationDirectory.resolvePath(_config.getData("background").dir),["jpg"]);
			_bgm = new FilesInDir();
			_bgm.init(File.applicationDirectory.resolvePath(_config.getData("bgm").dir),["mp3"]);
			
			init();
		}
		
		protected override function init() : void
		{
			stage.stageWidth = _config.getData("width");
			stage.stageHeight = _config.getData("height");
			stage.allowsFullScreen = _config.getData("fullscreen");
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			var bg:Bitmap = new Bitmap();
			bg.bitmapData = new BitmapData(100,100, true, 0x00000000);//new Background();
			addChild(bg);
			_container = new Sprite();
			addChild(_container);
			_cover = new Sprite();
			addChild(_cover);
			//return;
			//_image.source = p1;
			
			//invalidateDisplayList();
			
			var front:Pictures = new Pictures(_front.urls, _config.getData("frontground").inverval || 20);
			addChild(front);
			
			
			_sound = new Sound();
			_sound.load(new URLRequest("dy/qhc.mp3"));
			_sound.play(0, int.MAX_VALUE);
		}
		
		
	}
}