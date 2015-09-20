package
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;

	public class PlaySoundList
	{
		protected var _urls:Vector.<String>;
		protected var _idleUrls:Vector.<String>;
		protected var _sound:Sound;
		protected var _channel:SoundChannel;
		public function PlaySoundList(urls:Vector.<String>)
		{
			_urls = urls;
			_idleUrls = new Vector.<String>;
			_sound = new Sound();
			play();
		}
		
		public function play(e:Event=null):void
		{
			if(_urls==null)
				return;
			if(_urls.length==0)
			{
				_urls = _idleUrls.concat();
				_urls.reverse();
			}
			var url:String = _urls.pop();
			_idleUrls.push(url);
			_sound.load(new URLRequest(url));
			
			_channel = _sound.play();
			_channel.addEventListener(Event.SOUND_COMPLETE, onPlayComplete);
		}
		
		protected function onPlayComplete(e:Event):void
		{
			if(_channel!=null)
				_channel.removeEventListener(Event.SOUND_COMPLETE, play);
			play();
		}
	}
}