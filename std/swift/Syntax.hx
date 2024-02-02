package swift;

/**
	Use this class to provide special features for your target's syntax.
	The implementations for these functions can be implemented in your compiler.

	For more info, visit:
		src/swiftcompiler/Compiler.hx
**/
extern class Syntax {
	public static function plainCode(code: String): Void;
	public static function code(code:String, args:haxe.Rest<Dynamic>):Void;
	public static function unwrap<T>(value: T): T;
}
