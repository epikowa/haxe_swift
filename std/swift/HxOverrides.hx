package swift;

class HxOverrides {
	public static function toUpperCase(s:String):String {
		var a:SwiftString = untyped s;
		return a.uppercased();
	}

	public static function toLowerCase(s:String):String {
		var a:SwiftString = untyped s;
		return a.lowercased();
	}

	public static function charAt(s:String, index:Int):String {
		//var a:SwiftString = untyped s;
		var e = stringSlicing(s, index, index+1);
		return e;
		//return new String(stringSlicing(s, index, index+1));
	}

	public static function stringSlicing(s:String, rangeStart:Int, rangeEnd:Int):String {
		var sub:Substring = untyped Syntax.code('${s}[${rangeStart}...${rangeEnd}]');

		return new String(sub);
	}
}

@:native('String')
extern class SwiftString {
	public function new(sub:Substring);
	public function uppercased():String;
	public function lowercased():String;
}

@:native('Substring')
extern class Substring {

}