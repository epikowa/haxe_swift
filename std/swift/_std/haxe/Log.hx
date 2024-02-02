package haxe;

import swift.Syntax;
import haxe.PosInfos;

class Log {
    public static function trace(v:Dynamic, ?pos:PosInfos):Void {
        Syntax.plainCode('print(${v})');
    }
}