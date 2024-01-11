import swift.Syntax;

class Std {
    public static function string(v:Dynamic):String {
        //TODO: Implement
        return untyped Syntax.code('String(describing: ${v})');
    }
}