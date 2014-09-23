package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
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
	
	import ghostcat.display.GBase;
	import ghostcat.display.movieclip.GScriptMovieClip;
	import ghostcat.display.transfer.GBitmapEffect;
	import ghostcat.display.transfer.effect.MosaicHandler;
	import ghostcat.display.transfer.effect.SegmentHandler;
	import ghostcat.display.transfer.effect.ThresholdHandler;
	import ghostcat.display.transition.TransitionCacheLayer;
	import ghostcat.display.transition.TransitionLayerBase;
	import ghostcat.display.transition.TransitionMaskLayer;
	import ghostcat.display.transition.TransitionObjectLayer;
	import ghostcat.display.transition.TransitionSimpleLayer;
	import ghostcat.display.transition.TransitionTransferLayer;
	import ghostcat.display.transition.maskmovie.DissolveMaskHandler;
	import ghostcat.display.transition.maskmovie.GradientAlphaMaskHandler;
	import ghostcat.display.transition.maskmovie.ShutterDirectMaskHandler;
	import ghostcat.display.transition.maskmovie.ShutterMaskHandler;
	import ghostcat.ui.controls.GImage;
	import ghostcat.util.RandomUtil;
	import ghostcat.util.easing.Circ;
	
	//[Frame(factoryClass="ghostcat.ui.RootLoader")]
	/**
	 * 
	 * @author flashyiyi
	 * 
	 */
	public class Show extends GBase
	{
		
		public var t:TransitionLayerBase;
		
		private var _height:Number;
		private var _width:Number;
		private var _gImage:GImage;
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
		private function onAdded(e:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			readIni();
			
			if(_configs[3]!=null)
			{
				var loader:Loader = new Loader();
				loader.load(new URLRequest("dy/"+_configs[3]));
				addChild(loader);
			}
			
			init();
		}
		
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
			stage.stageWidth = _configs[0];
			stage.stageHeight = _configs[1];
			
			_height = stage.stageHeight;
			_width = stage.stageWidth;
			trace(_width, _height);
			
			
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
			_gImage = new GImage();
			switchImage();
			
			
			_sound = new Sound();
			_sound.load(new URLRequest("dy/qhc.mp3"));
			_sound.play(0, int.MAX_VALUE);
		}
		
		private var _id:int = -1;
		private function loadeImage(path:String):void
		{
			if(_loader==null)
			{
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			}else{
				_loader.unload();
			}
			_loader.load(new URLRequest(path));
			if(this.refreshInterval==0)
			{
				this.refreshInterval = _configs[4];
			}
		}
		
		public function autoFitSize(content:DisplayObject, iWidth:Number, iHeight:Number):void 		
		{
			if(content==null)
				return;
			var iScalex:Number = 0, iScaley:Number = 0, iMaxScale:Number = 0;
			if (iWidth != 0) 
			{
				content.width = iWidth; 
				iScalex = content.scaleX; 
			}
			if (iHeight != 0)
			{ 
				content.height = iHeight; 
				iScaley = content.scaleY;
			}		
			if (iScalex == 0 && iScaley != 0) 
				content.scaleX = content.scaleY = iScaley;	
			else if (iScalex != 0 && iScaley == 0) 
				content.scaleX = content.scaleY = iScalex;		
			else if (iScalex != iScaley) 
				content.scaleX = content.scaleY = (iScalex > iScaley?iScaley:iScalex);	//取小的
		}
		
		private function onComplete(e:Event):void
		{
			_gImage.source = _loader.content;
			//_gImage.x = _gImage.y = 0;
			_container.addChild(_gImage);
			autoFitSize(_loader.content,stage.stageWidth, stage.stageHeight);
			_gImage.x = (stage.stageWidth - _loader.content.width)/2;
			_gImage.y = (stage.stageHeight - _loader.content.height)/2;
		}
		
		protected override function updateDisplayList() : void
		{
			var v:int =  10 * Math.random();
			trace(v);
			switch (v)
			{
				case 0://差异值渐变
					new TransitionTransferLayer(switchImage,new GBitmapEffect(_gImage,new ThresholdHandler())).createTo(this);
					break;
				case 1://溶解渐变
					//new TransitionTransferLayer(switchImage,new GBitmapEffect(_gImage,new DissolveHandler(getTimer()))).createTo(_container);
					//break;
				case 2://切割渐变
					new TransitionTransferLayer(switchImage,new GBitmapEffect(_gImage,new SegmentHandler(int(Math.random() * 2)))).createTo(this);
					break;
				case 3://马赛克渐变
					new TransitionObjectLayer(switchImage,new GBitmapEffect(_gImage,new MosaicHandler()),_gImage,500,500).createTo(this);
					break;
				/*case 4://循环图元渐变
					var r:BackgroundLayer = new BackgroundLayer(600,450);
					var mat:Matrix = new Matrix();
					mat.scale(0.5,0.5);
					r.addLayer((step % 2 == 0)? new p1() : new p2(),mat);
					r.autoMove = new Point(50,50);
					new TransitionObjectLayer(switchImage,r,null,500,500).createTo(this);
					break;
				*/
				case 4://过渡渐变
					new TransitionCacheLayer(switchImage,_gImage).createTo(this);
					break;
				case 5://滑动渐变
					new TransitionCacheLayer(switchImage,_gImage,1000,{x:_width * ((Math.random() < 0.5)? 1 : -1),y:_height * ((Math.random() < 0.5)? 1 : -1),ease:Circ.easeIn}).createTo(this);
					break;
				case 6://方格渐变
					new TransitionMaskLayer(switchImage,_gImage,new GScriptMovieClip(new DissolveMaskHandler(20),_gImage.getBounds(_gImage.parent))).createTo(this);
					break;
				case 7://百叶窗渐变
					new TransitionMaskLayer(switchImage,_gImage,new GScriptMovieClip(new ShutterMaskHandler(),_gImage.getBounds(_gImage.parent))).createTo(this);
					break;
				case 8://百叶窗打开渐变
					new TransitionMaskLayer(switchImage,_gImage,new GScriptMovieClip(new ShutterDirectMaskHandler(50,Math.random() * 4),_gImage.getBounds(_gImage.parent))).createTo(this);
					break;
				case 9://方向性过度渐变
					new TransitionMaskLayer(switchImage,_gImage,new GScriptMovieClip(new GradientAlphaMaskHandler(Math.random() * 360),_gImage.getBounds(_gImage.parent))).createTo(this);
					break;
				case 10://白屏过渡渐变
					new TransitionSimpleLayer(switchImage,_width,_height,0xFFFFFF,RandomUtil.choose(BlendMode.NORMAL,BlendMode.ADD,BlendMode.SUBTRACT)).createTo(this);
					break; 
			}
		}
		
		private var _loader:Loader;
		protected function switchImage():void
		{
			var r:int = Math.random()*_configs[2]+1;
			loadeImage("dy/pic ("+r+").jpg");
			/*step++;
			_image.source = (step % 2 == 0)? p1 : p2;*/
		}
	}
}