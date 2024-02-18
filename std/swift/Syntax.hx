package swift;

/**
	Use this class to provide special features for your target's syntax.
	The implementations for these functions can be implemented in your compiler.

	For more info, visit:
		src/swiftcompiler/Compiler.hx
**/
class Syntax {
	public static function plainCode(code: String): Void {}
	public static function unwrap<T>(value: T): T { return null;}
	macro public static function code(initialString:String, eargs: ExprOf<Array<Any>>) {
		#if macro
		var args = switch (eargs.expr) {
			case EArrayDecl(values):
				values;
			default:
				haxe.macro.Context.fatalError('injectCode expects an Array here', haxe.macro.Context.currentPos());
				null;
		}

		var args = args.map(arg -> {
			switch (arg.expr) {
				case EConst(c):
					c;
				default:
					haxe.macro.Context.fatalError('Unsupported expression', haxe.macro.Context.currentPos());
			}
		});

		for (i in 0...args.length) {
			initialString = StringTools.replace(initialString, '{${i}}', switch (args[i]) {
				case CInt(v, _), CFloat(v, _):
					v;
				case CString(s, _):
					escapeStringConst(s);
				case CIdent(s):
					s;
				default:
					'';
			});
		}
		// trace(args[1]);
		// return macro test($v{args[1]});
		return macro $i{initialString};
		// return null;
		#end
	}

	public static function _isOfType<T>(v:Dynamic, t:Dynamic):Bool {
        var a:Bool =  swift.HxHelpers.isOfType(v, t);
		return a;
    }
}

private function escapeStringConst(string:String):String {
	#if macro
	string = StringTools.replace(string, '\n', '\\n');
	string = StringTools.replace(string, '"', '\"');

	return '"${string}"';
	#end
	return '';
}
