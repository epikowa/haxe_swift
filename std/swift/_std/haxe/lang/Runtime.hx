package haxe.lang;

import swift.Syntax;

class Runtime {
    public static function getField(object:Any, fieldName:String):Null<Any> {
        return new Mirror(object).descendant(fieldName);
    }

    public static function printNative(@:label("bam") object:Any):Void {
        Syntax.code('print(object: object)');
    }
}

@:swiftImport('Foundation')
@:native('Mirror')
extern class Mirror {
    function new(reflecting:Null<Any>);
    function descendant(first:String):Null<Any>;
}