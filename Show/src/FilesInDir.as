package
{
	import flash.filesystem.File;

	public class FilesInDir
	{
		protected var _urls:Vector.<String>;
		protected var _vFiles:Vector.<File>;
		public function FilesInDir()
		{
		}
		
		public function get urls():Vector.<String>
		{
			return _urls;
		}

		public function get vFiles():Vector.<File>
		{
			return _vFiles;
		}

		public function init(path:File, extendsions:Array=null):void
		{
			if(_vFiles==null)
				_vFiles = new Vector.<File>;
			else
				_vFiles.length = 0;
			
			if(_urls==null)
				_urls = new Vector.<String>;
			else
				_urls.length = 0;
			if(path==null)
				return;
			findFiles(path.getDirectoryListing(), _vFiles, extendsions);
		}
		
		private function findFiles(childrenFiles:Array, saveList:Vector.<File>, extendsions:Array):void
		{
			while(childrenFiles!=null && childrenFiles.length>0)
			{
				var child:File = childrenFiles.pop();
				if(child.isDirectory==true)
				{
					findFiles(child.getDirectoryListing(), saveList, extendsions);
				}else{
					if(saveList!=null)
					{
						if(extendsions!=null && extendsions.length>0)
						{
							if(extendsions.indexOf( child.extension) >=0)
							{
								saveList.push(child);
								_urls.push(child.url);
							}
						}else{
							saveList.push(child);
							_urls.push(child.url);
						}
					}
				}
			}
		}
	}
}