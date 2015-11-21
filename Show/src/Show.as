package
{
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.media.Sound;
	
	import foozuu.app.AppConfig;
	
	//[Frame(factoryClass="ghostcat.ui.RootLoader")]
	/**
	 * 
	 * @author flashyiyi
	 * 
	 */
	public class Show extends Sprite
	{
		
		public function Show()
		{
			if(stage==null)
			{
				addEventListener(Event.ADDED_TO_STAGE, onAdded);
			}else{
				onAdded();
			}
		}
		private var _sound:Sound;
		
		private var _config:AppConfig;
		private var _front:FilesInDir;
		private var _background:FilesInDir;
		private var _bgm:FilesInDir;
		private function onAdded(e:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			_config = new AppConfig(NativeApplication.nativeApplication, File.applicationDirectory.resolvePath("config.txt").nativePath);
			_front = new FilesInDir();
			_front.init(File.applicationDirectory.resolvePath(_config.getData("frontground").dir),["jpg"]);
			_background = new FilesInDir();
			_background.init(File.applicationDirectory.resolvePath(_config.getData("background").dir),["jpg"]);
			_bgm = new FilesInDir();
			_bgm.init(File.applicationDirectory.resolvePath(_config.getData("bgm").dir),["mp3"]);
			
			initStage();
		}
		
		protected function initStage() : void
		{
			stage.stageWidth = _config.getData("width");
			stage.stageHeight = _config.getData("height");
			stage.displayState = _config.getData("fullscreen")==1 ? StageDisplayState.FULL_SCREEN : null;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var background:Pictures = new Pictures(random(_background.urls), _config.getData("background").interval || 20, 1);
			addChild(background);
			background.play();
			
			var front:Pictures = new Pictures(random(_front.urls), _config.getData("frontground").interval || 20);
			addChild(front);
			front.play();
		
			var sound:PlaySoundList = new PlaySoundList(random(_bgm.urls));
		}
		
		protected function random(v:Vector.<String>):Vector.<String>
		{
			v = v.sort(rand);
			return v;
		}
		
		private function rand(a:*, b:*):int
		{
			return Math.random()>0.5 ? 1 : -1;
		}
		
	}
}