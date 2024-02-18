package swift;

// @:native('_hxHelpers')
class HxHelpers {
	public static function isOfType<T>(value:Any, type:Class<T>):Bool {
		return untyped Syntax.code('_hxHelpers.isOfType(value: {0}, type: {1})', [value, type]);
	}
}