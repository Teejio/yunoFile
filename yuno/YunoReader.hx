package yuno;

using StringTools;

import haxe.io.Bytes;
import haxe.io.Path;

class YunoReader {



	private var version:Int  = 1;
	private var pos:Int = 4;
	private var nameLength:Int = 4;
	private var name:String;
	private var numFiles:Int;
	private var bytes:Bytes;

	private var rename:Map<String, String> = [];


	public var paths:Array<String> = [];

	public function new(data:Null<Bytes> = null) {
		if (data != null) {
			run(data);
		}
	}


	public function setRename(target:String, dst:String){

		rename.set(target, dst);
	}


	public function destroy(){ 
		for (i in 0...paths.length){
	
		  paths.pop();
		}
	  }

	  public function deletePath(path:String, ?skibidi:Bool = false){
		for(file in sys.FileSystem.readDirectory(path)) {
		  var dir = haxe.io.Path.join([path, file]);
		  //trace(dir);
		  if (sys.FileSystem.isDirectory(dir)) {
			  deletePath(dir);
		  } else {
	
			
		  if (  !(skibidi && paths.contains(dir)) /* thanks DeMorgan*/) sys.FileSystem.deleteFile(dir);
	
		  }
		  
		}
		if (!skibidi) sys.FileSystem.deleteDirectory(path);
		
	  }

	public function getPathToWrite(path:String):String{



		for (key in rename.keys()){

			path = path.replace(key, rename[key]);
		}

		return path;
	}

	public function importFile(path:String, ?entryFolder:String = ""){

		run( Bytes.ofData(sys.io.File.getBytes(path).getData()), entryFolder);

	}


	private function getHeader(){

		trace(version);
		pos = 4;
	   nameLength = bytes.getInt32(4);

	   pos += 4;
	   name = bytes.getString(pos, nameLength);

	   trace(name);
	   pos += nameLength;

	   trace(name);

		numFiles = bytes.getInt32(pos);
	   pos += 4;

	   trace(numFiles);

	}

	private function runV1(entryFolder:String){
		getHeader();

		var fileType = 0;
		var pathLength = 0;
		for (i in 0...numFiles){

			//trace("testing if verisonLogicWorks");

			fileType = bytes.getInt32(pos);
			pos += 4;
			pathLength = bytes.getInt32(pos);
			pos += 4;
			var path = getPathToWrite(haxe.zip.Uncompress.run( bytes.sub(pos, pathLength)).toString());
			pos += pathLength;
			trace(path);
			trace(fileType);
			path =Path.join([entryFolder, path]);
			if ( fileType == 0){ // i flipped when writing teehee
	  
	  
			  if (!sys.FileSystem.exists(path)) continue;
			  
			  if (path.contains(".")){
				sys.FileSystem.deleteFile(path);
				continue;
			  }
	  
			  deletePath(path);
			 
	  
			  
			}
			else if (fileType == 1){
			   pathLength = bytes.getInt32(pos);
			 pos += 4;
			  var data = haxe.zip.Uncompress.run( bytes.sub(pos, pathLength) );
			  pos += pathLength;
	  
			  if (! sys.FileSystem.exists(haxe.io.Path.directory(path))){
				sys.FileSystem.createDirectory(haxe.io.Path.directory(path));
			  }
			  paths.push(path);
			  sys.io.File.saveBytes(path, data);
			}
			else{
	  
			  trace(path);
			  
			   deletePath(path, true);
			}

		}

	}
	private function runV0(entryFolder:String){

		
		getHeader();

		for (i in 0...numFiles) {
			var pathLength = bytes.getInt32(pos);
			pos += 4;
			var path = bytes.getString(pos, pathLength);
			pos += pathLength;
			pathLength = bytes.getInt32(pos);
			pos += 4;
			var data = haxe.zip.Uncompress.run(bytes.sub(pos, pathLength));
			pos += pathLength;

			var truePath = Path.join([entryFolder, path]);
			if (!sys.FileSystem.exists(Path.directory(truePath))) {
				sys.FileSystem.createDirectory(haxe.io.Path.directory(truePath));
			}
			sys.io.File.saveBytes(truePath, data);
		}

	}
	public function run(data:Bytes, ?entryFolder:String = "") {
		trace("run Deployed");
		bytes = haxe.zip.Uncompress.run(data);


		trace(bytes);
		

    version = bytes.getInt32(0); 

	Reflect.callMethod(this, Reflect.field(this, 'runV${Std.string(version) }'), [ entryFolder]); // look ma no switches
	}

}
