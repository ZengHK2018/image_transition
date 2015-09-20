package
{
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	
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
		
		/**
		 * 
		 * @param urls
		 * @param interval in seconds
		 * 
		 */		
		public function Pictures(urls:Vector.<String>, interval:int)
		{
			_gImage = new GImage();
			addChild(_gImage);
			this.refreshInterval = interval * 1000;
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
					new TransitionCacheLayer(switchImage,_gImage,1000,{x:width * ((Math.random() < 0.5)? 1 : -1),y:height * ((Math.random() < 0.5)? 1 : -1),ease:Circ.easeIn}).createTo(this);
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
					new TransitionSimpleLayer(switchImage,width,height,0xFFFFFF,RandomUtil.choose(BlendMode.NORMAL,BlendMode.ADD,BlendMode.SUBTRACT)).createTo(this);
					break; 
			}
		}
		
		private var _loader:Loader;
		protected function switchImage():void
		{
			if(_urls==null)
				return;
			if(_urls.length==0 && _idleUrls!=null)
			{
				_urls = _idleUrls.concat();
				_idleUrls.length = 0;
			}
			_idleUrls ||= new Vector.<String>;
			var url:String = _urls.pop();
			_idleUrls.push(url);
			loadeImage(url);
		}
	}
}