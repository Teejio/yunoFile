package yuno;


import yuno.YunoFile.File;
import haxe.io.Bytes;



using StringTools;

class YunoWriter {
	private var _files:Array<File>;

	public var files(get, never):Array<File>;

	public function get_files() {
		return _files.copy();
	}

	public function new(entries:Array<File> = null) {
		if (entries == null) {
			_files = new Array<File>();
		} else {
			_files = entries;
		}
	}

	public function addFile(path:String) {
		var bytes:haxe.io.Bytes = haxe.zip.Compress.run(haxe.io.Bytes.ofData(sys.io.File.getBytes(path).getData()), 2);

		var pathByters = haxe.zip.Compress.run(haxe.io.Bytes.ofString(path), 2);
		
		 var entry:File = {
			 path: pathByters, 
		   dataSize: Std.int(bytes.length),
			 pathSize: pathByters.length, 
			 data: bytes,
		   fileType: 1
		 };
	 
		 _files.push(entry);
	}

	public function exportBytes(name:Null<String> = null):Bytes {
		if (name == null)
			name = "storage.yuno";

		if (!name.endsWith(".yuno"))
			name += ".yuno";

		name = name.substring(0, name.length - 5);

		var buffer:haxe.io.BytesBuffer = new haxe.io.BytesBuffer();

  buffer.addInt32(1); // version 1, because it includes both the ability to delete and ability to delete and path files and now compressed
  buffer.addInt32(name.length);
  buffer.addString(name);
  buffer.addInt32(_files.length);
  for (file in _files){
    buffer.addInt32( file.fileType );
    buffer.addInt32(file.pathSize);
    buffer.add(file.path);

    if (file.fileType == 1){
      buffer.addInt32(file.dataSize);
      buffer.add(file.data);
    }

  
    
  }


		var data:haxe.io.Bytes = buffer.getBytes();
		_files = new Array<File>();
        return haxe.zip.Compress.run(data,2);

		

  

	}


    public function exportToPath(name:Null<String> = null){

        if (name == null)
			name = "storage.yuno";

		if (!name.endsWith(".yuno"))
			name += ".yuno";

		name = name.substring(0, name.length - 5);



        sys.io.File.saveBytes(name, exportBytes(name));
        
    }

	public function addFolder(dir:String, ?refresh:Bool = false) {

     
      
		for(file in sys.FileSystem.readDirectory(dir)) {
			var path = haxe.io.Path.join([dir, file]);
			if (sys.FileSystem.isDirectory(path)) {
				  addFolder(path);
			} else {
  
			  addFile(path);
  
			}
		}
  
	  var pathByters = haxe.zip.Compress.run(haxe.io.Bytes.ofString(dir), 2);
  
  
	 if (!refresh) return;
	 var entry:File = {
	   path: pathByters, 
	 dataSize: null,
	   pathSize: pathByters.length, 
	   data: null,
	 fileType: 2
	 };
  
	 _files.push(entry);
  
	}

	public function toString() {
		return _files.toString();
	}
}
