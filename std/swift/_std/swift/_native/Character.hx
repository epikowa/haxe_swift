package swift._native;

@:native('Character')
extern class Character {
    @:swiftLabels(string, '_')
	public function new(string:String);
    var isASCII:Bool;
    var asciiValue:UInt8;
}
