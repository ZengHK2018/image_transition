package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import ghostcat.display.GBase;
	
	//[Frame(factoryClass="ghostcat.ui.RootLoader")]
	/**
	 * 
	 * @author flashyiyi
	 * 
	 */
	public class Show extends GBase
	{
		
		public function Show()
		{
		}
		private var _sound:Sound;
		
		private var _configs:Array;
		
		private function readIni():void
		{
			var path:String = "dy/ini.txt";
			var file:File = File.applicationDirectory.resolvePath(path);
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			stream.position = 0;
			var content:String;
			var ba:ByteArray = new ByteArray();
			stream.readBytes(ba, 0, ba.length);
			content = ba.readUTFBytes(ba.bytesAvailable);
			stream.close();
			_configs = content.split(",");
		}
		
		protected override function init() : void
		{
			readIni();
			
			stage.stageWidth = _configs.shift();
			stage.stageHeight = _configs.shift();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var length:uint = _configs.length/2;
			
			var back:Picture = new Picture(_configs.slice(length).concat(), stage.stageWidth, stage.stageHeight);
			cont = new Sprite();
			addChild(cont);
			cont.addChild(back);
			
			var front:Picture = new Picture(_configs.slice(0, length).concat(), stage.stageWidth, stage.stageHeight);
			var cont:Sprite = new Sprite();
			addChild(cont);
			cont.addChild(front);
			
			
			
			_sound = new Sound();
			_sound.load(new URLRequest("dy/qhc.mp3"));
			_sound.play(0, int.MAX_VALUE);
		}
		
		
	}
}