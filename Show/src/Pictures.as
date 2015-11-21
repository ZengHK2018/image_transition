package
{
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	
	import ghostcat.display.GBase;
	import ghostcat.display.movieclip.GScriptMovieClip;
	import ghostcat.display.transfer.GBitmapEffect;
	import ghostcat.display.transfer.effect.MosaicHandler;
	import ghostcat.display.transfer.effect.SegmentHandler;
	import ghostcat.display.transfer.effect.ThresholdHandler;
	import ghostcat.display.transition.TransitionCacheLayer;
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
	
	public class Pictures extends GBase
	{
		private var _gImage:GImage;
		private var _urls:Vector.<String>;
		private var _idleUrls:Vector.<String>;
		private var _fit:uint;
		
		/**
		 * 
		 * @param urls
		 * @param interval in seconds
		 * 
		 */		
		public function Pictures(urls:Vector.<String>, interval:int, fit:uint=0)
		{
			_fit = fit;
			_urls = urls;
			_gImage = new GImage();
			addChild(_gImage);
			refreshInterval = interval * 1000;
			_gImage.enabledAutoSize = true;
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		protected function onAdded(event:Event):void
		{
			stage.addEventListener(Event.RESIZE, onStageHandler);
		}
		
		protected function onStageHandler(event:Event):void
		{
			if(stage==null)
				return;
			autoFitSize(_gImage.content, stage.stageWidth, stage.stageHeight);
			_gImage.x = stage.stageWidth/2 - _gImage.content.width/2;
			_gImage.y = stage.stageHeight/2 - _gImage.content.height/2;
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
			if(_fit==0)
				content.scaleX = content.scaleY = (iScalex > iScaley?iScaley:iScalex);	
			else
				content.scaleX = content.scaleY = (iScalex < iScaley?iScaley:iScalex);	
		}
		
		protected override function updateDisplayList() : void
		{
			if(_gImage==null || _gImage.width==0 || _gImage.height==0)
				return;
			trans();
		}
		
		private function trans():void
		{
			var v:int =  11 * Math.random();
			trace(v);
			switch (v)
			{
				case 0://差异值渐变
					new TransitionTransferLayer(play,new GBitmapEffect(_gImage,new ThresholdHandler())).createTo(this);
					break;
				case 1://溶解渐变
					//new TransitionTransferLayer(play,new GBitmapEffect(_gImage,new DissolveHandler(getTimer()))).createTo(_container);
					//break;
				case 2://切割渐变
					new TransitionTransferLayer(play,new GBitmapEffect(_gImage,new SegmentHandler(int(Math.random() * 2)))).createTo(this);
					break;
				case 3://马赛克渐变
					new TransitionObjectLayer(play,new GBitmapEffect(_gImage,new MosaicHandler()),_gImage,500,500).createTo(this);
					break;
				/*case 4://循环图元渐变
				var r:BackgroundLayer = new BackgroundLayer(600,450);
				var mat:Matrix = new Matrix();
				mat.scale(0.5,0.5);
				r.addLayer((step % 2 == 0)? new p1() : new p2(),mat);
				r.autoMove = new Point(50,50);
				new TransitionObjectLayer(play,r,null,500,500).createTo(this);
				break;
				*/
				case 4://过渡渐变
					new TransitionCacheLayer(play,_gImage).createTo(this);
					break;
				case 5://滑动渐变
					new TransitionCacheLayer(play,_gImage,1000,{x:_gImage.width * ((Math.random() < 0.5)? 1 : -1),y:_gImage.height * ((Math.random() < 0.5)? 1 : -1),ease:Circ.easeIn}).createTo(this);
					break;
				case 6://方格渐变
					new TransitionMaskLayer(play,_gImage,new GScriptMovieClip(new DissolveMaskHandler(20),_gImage.getBounds(_gImage.parent))).createTo(this);
					break;
				case 7://百叶窗渐变
					new TransitionMaskLayer(play,_gImage,new GScriptMovieClip(new ShutterMaskHandler(),_gImage.getBounds(_gImage.parent))).createTo(this);
					break;
				case 8://百叶窗打开渐变
					new TransitionMaskLayer(play,_gImage,new GScriptMovieClip(new ShutterDirectMaskHandler(50,Math.random() * 4),_gImage.getBounds(_gImage.parent))).createTo(this);
					break;
				case 9://方向性过度渐变
					new TransitionMaskLayer(play,_gImage,new GScriptMovieClip(new GradientAlphaMaskHandler(Math.random() * 360),_gImage.getBounds(_gImage.parent))).createTo(this);
					break;
				case 10://白屏过渡渐变
					new TransitionSimpleLayer(play,width,height,0xFFFFFF,RandomUtil.choose(BlendMode.NORMAL,BlendMode.ADD,BlendMode.SUBTRACT)).createTo(_gImage);
					break; 
			}
		}
		
		private var _loader:Loader;
		public function play():void
		{
			if(_urls==null)
				return;
			if(_urls.length==0 && _idleUrls!=null)
			{
				_urls = _idleUrls.concat();
				_urls = _urls.reverse();
				_idleUrls.length = 0;
			}
			_idleUrls ||= new Vector.<String>;
			var url:String = _urls.pop();
			_idleUrls.push(url);
			_gImage.addEventListener(Event.COMPLETE, onLoad);
			_gImage.source = url;
		/*	_gImage.autoDestoryContent = true;
			_gImage.scaleContent = true;
			_gImage.scaleType = UIConst.UNIFORM;
			_gImage.width = stage.stageWidth/2;
			_gImage.height = stage.stageHeight/2;*/
		}
		
		protected function onLoad(event:Event):void
		{
			onStageHandler(null);
		}
	}
}