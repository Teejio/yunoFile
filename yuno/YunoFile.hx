package yuno;

typedef File = {

  var path:haxe.io.Bytes;
  var pathSize:Int;
  var dataSize:Null<Int>;
  var data:Null<haxe.io.Bytes>;
  var fileType:Int;
}