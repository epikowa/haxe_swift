package ;

import haxe.macro.Context;

class SSyntax {
    macro public static function code(initialString:String, eargs: ExprOf<Array<Any>>) {
		var args = switch (eargs.expr) {
			case EArrayDecl(values):
				values;
			default:
				haxe.macro.Context.fatalError('injectCode expects an Array here', Context.currentPos());
				null;
		}

		var args = args.map(arg -> {
			switch (arg.expr) {
				case EConst(c):
					c;
				default:
					haxe.macro.Context.fatalError('Unsupported expression', Context.currentPos());
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
	}


	private static function escapeStringConst(string:String):String {
        string = StringTools.replace(string, '\n', '\\n');
        string = StringTools.replace(string, '"', '\"');

        return '"${string}"';
    }
}