package haxe.lang;

import swift.Syntax;

class Runtime {
    public static function getField(object:Any, fieldName:String):Null<Any> {
        return new Mirror(Syntax.unwrap(object)).descendant(fieldName);
    }

    @:swiftLabels(object, "_") public static function printNative(object:Any):Void {
        Syntax.code('print(object)');
    }
}

@:swiftImport('Foundation')
@:native('Mirror')
extern class Mirror {
    function new(reflecting:Null<Any>);
    @:swiftLabels(first, '_')
    function descendant(first:String):Null<Any>;
}