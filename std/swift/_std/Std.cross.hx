import swift.HxHelpers;
import swift.Syntax;

class Std {
    public static function string(v:Dynamic):String {
        return untyped Syntax.code('String(describing: {0})', [v]);
    }

    @:native('_is')
    public static function is<T>(v:Dynamic, t:T) {
        return false;
        // return HxHelpers.isOfType(v, t);
        // return Syntax._isOfType(v, t);
    }

    public static function isOfType<T>(v:Dynamic, t:T) {
        return false;
        // return HxHelpers.isOfType(v, t);
        // return Syntax._isOfType(v, t);
    }

    // macro public static function isOfType(v:ExprOf<Dynamic>, t:ExprOf<Dynamic>):ExprOf<Bool> {
    //     return macro true;
    //     switch (t.expr) {
    //         case EConst(c):
    //             switch (c) {
    //                 case CIdent(s):
    //                     var t = haxe.macro.Context.getType(s);
    //                     switch (t) {
    //                         case TInst(t, params):
    //                             trace('Inst', t.toString());
    //                             // return macro {Std.isOfType($e{v}, $v{t});};
    //                         case TAbstract(t, params):
    //                             trace('Abstract', t.toString());
    //                           //  return macro Std.isOfType(v, t);


    //                         default:
    //                             trace('Polop');
    //                     }
    //                     trace(t);
    //                 default:
    //             }
    //         default:
    //     }
    //     trace(v);
    //     trace(t);
    //     return macro true;
    // }
}
