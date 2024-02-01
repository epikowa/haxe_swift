package swiftcompiler;

// Make sure this code only exists at compile-time.
import haxe.macro.Expr.Binop;
import haxe.macro.Expr.ExprDef;
#if (macro || swift_runtime)
import haxe.ds.GenericStack;
import haxe.rtti.Meta;
import sys.io.File;
import sys.FileSystem;
import reflaxe.helpers.Context;

// Import relevant Haxe macro types.
import haxe.macro.Type;

// Import Reflaxe types
import reflaxe.DirectToStringCompiler;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.data.EnumOptionData;

/**
	The class used to compile the Haxe AST into your target language's code.

	This must extend from `BaseCompiler`. `PluginCompiler<T>` is a child class
	that provides the ability for people to make plugins for your compiler.
**/
class Compiler extends DirectToStringCompiler {
	var currentClassUses = new Array<String>();
	var currentClass:ClassType;
	var currentFuncDetails(get, never):FuncDetails;
	var funcDetailsStack:GenericStack<FuncDetails> = new GenericStack();
	function get_currentFuncDetails():FuncDetails {
		return funcDetailsStack.first();
	}

	function funcDetailsToSignature(args:Array<{t:Type, opt: Bool, name: String}>, ret:Type) {
		return '(${args.map(arg -> Tools.typeToName(arg.t)).join(', ')}) -> ${Tools.typeToName(ret)}';
	}

	function funcDetailsToSignatureWithNames(args:Array<{t:Type, opt: Bool, name: String}>, ret:Type) {
		return '(${args.map(arg -> '${arg.name} : ${Tools.typeToName(arg.t)}').join(', ')}) -> ${Tools.typeToName(ret)}';
	}

	/**
		Returns a Map where keys are the parameter's name and value is the label.
	**/
	function getLabelsFromClassField(cf:ClassField):Map<String, String> {
		var meta = cf.meta;
		return getLabelsFromMeta(meta);
	}

	function getLabelsFromMeta(meta:MetaAccess):Map<String, String> {
		var map = new Map<String, String>();

		if (meta.has(':swiftLabels')) {
			for (entry in meta.extract(':swiftLabels')) {
				var fieldName:String = switch (entry.params[0].expr) {
					case EConst(c):
						switch (c) {
							case CIdent(s):
								s;
							default: 
								Context.error('First parameter of @:swiftLabels should be an identifier', Context.currentPos());
						}
					default: Context.error('First parameter of @:swiftLabels should be an identifier', Context.currentPos());
				}
				var label = switch (entry.params[1].expr) {
					case EConst(c):
						switch (c) {
							case CString(s):
								s;
							default: Context.error('Second parameter of @:swiftLabels should be a String', Context.currentPos());
						}
					default: Context.error('Second parameter of @:swiftLabels should be a String', Context.currentPos());
				}

				map.set(fieldName, label);
			}
		}

		return map;
	}

	/**
		Returns the label for the specified parameter.
		If no label has been specified, returns the parameter's name.
	**/
	function getLabelForParam(cf:ClassField, param:String):String {
		var map = getLabelsFromClassField(cf);
		
		return getLabelFromMap(map, param);
	}

	/**
		Returns the label for the specified parameter.
		If no label has been specified, returns the parameter's name.
	**/
	function getLabelFromMap(map:Map<String, String>, param:String) {
		if (!map.exists(param)) {
			return param;
		}

		return map.get(param);
	}

	/**
		This is the function from the BaseCompiler to override to compile Haxe classes.
		Given the haxe.macro.ClassType and its variables and fields, return the output String.
		If `null` is returned, the class is ignored and nothing is compiled for it.

		https://api.haxe.org/haxe/macro/ClassType.html
	**/
	public function compileClassImpl(classType: ClassType, varFields: Array<ClassVarData>, funcFields: Array<ClassFuncData>): Null<String> {
		currentClassUses = new Array();
		currentClass = classType;

		var fieldsStrings:Array<String> = [];

		var superClass:String = null;
		var hasSuperConstructor = false;
		if (classType.superClass != null) {
			hasSuperConstructor = classType.superClass.t.get().constructor != null;
			superClass = Tools.classTypeToSwiftName(classType.superClass.t.get());
		}

		var constructorParams = new Array<String>();
		switch (classType.constructor?.get().type) {
			case TFun(args, ret):
				for (arg in args) {
					constructorParams.push('${arg.name}:${Tools.typeToName(arg.t)}');
				}
			default:
		}

		if (classType.constructor?.get().expr() != null) {
			var throws = classType.constructor.get().meta.has(':throws');
			var rethrows = classType.constructor.get().meta.has(':rethrows');
			funcDetailsStack.add(new FuncDetails([classType.name, 'new'].join('.')));
			var funcBody = compileExpressionImpl(classType.constructor?.get().expr(), false);
			throws = throws || currentFuncDetails.throws;
			funcDetailsStack.pop();
			fieldsStrings.push('${hasSuperConstructor ? 'override ' : ' '}init(${constructorParams.join(', ')}) ${throws ? 'throws ' :''}${rethrows ? 'rethrows ' :''}{\n${funcBody}\n}\n');
		}
		for (func in funcFields) {
			if (func.field.name == 'new') {
				continue;
			}

			var labels = getLabelsFromMeta(func.field.meta);
			var paramsNames = new Array<String>();
			var paramsNamesOnly = new Array<String>();
			var paramsTypesOnly = new Array<String>();

			var paramLabelAndName = (paramName) -> {
				var label = getLabelFromMap(labels, paramName);
				if (label == paramName) return paramName;
				return '${label} ${paramName}';
			}

			for (param in func.args) {
				switch (param.type) {
					case TInst(t, params):
						paramsNamesOnly.push(param.name);
						paramsTypesOnly.push(Tools.typeToName(param.type));
						paramsNames.push('${paramLabelAndName(param.name)} : Optional<${Tools.typeToName(param.type)}>');
					case TDynamic(t):
						paramsNamesOnly.push(param.name);
						paramsTypesOnly.push('Any');
						paramsNames.push('${paramLabelAndName(param.name)} : Any');
					case TAbstract(t, params):
						// TODO: Handle abstracts
						if (Tools.isAbstractTypeNullT(t.get())) {
							paramsNamesOnly.push(param.name);
							paramsTypesOnly.push(Tools.typeToName(params[0]));
							paramsNames.push('${paramLabelAndName(param.name)} : Optional<${Tools.typeToName(params[0])}>');
						} else {
							paramsNamesOnly.push(param.name);
							paramsTypesOnly.push(Tools.typeToName(t.get().type));
							paramsNames.push('${paramLabelAndName(param.name)} : Optional<${Tools.typeToName(t.get().type)}>');
						}
					case TFun(args, ret):
						paramsNames.push('${paramLabelAndName(param.name)} : ${funcDetailsToSignature(args, ret)}');
						paramsNamesOnly.push(param.name);
						paramsTypesOnly.push(funcDetailsToSignature(args, ret));
					default:
						throw 'Parameters of type ${param.type.getName()} are not supported';
				}
			}
			var throws = func.field.meta.has(':throws');
			var rethrows = func.field.meta.has(':rethrows');
			var pS = func.field.params.map(p -> {
				'Optional<${Tools.typeToName(p.t)}>';
			}).join(', ');
			var hasParams = func.field.params.length > 0;


			funcDetailsStack.add(new FuncDetails([classType.name, func.field.name].join('.')));
			// var funcBody = compileExpressionImpl(func.field.expr(), false);

			$type(func.expr.expr);
			$type(func.field.expr().expr);

			var tfuncBody = func.expr.expr;
			var funcBody = switch (tfuncBody) {
				case TBlock(el):
					trace('+++++++++++++ ${func.field.name}');
					trace(el);
					el.map(v -> {
						compileExpressionImpl(v, false);
					}).join('\n');
				default:
					Context.fatalError('Function body should be TBlock (got ${tfuncBody.getName()})', func.field.expr().pos);
					null;
			}

			var initialThrows = throws;
			throws = throws || currentFuncDetails.throws;
			if (throws && !(func.field.meta.has(':throws'))) {
				trace('^^^^^^^', initialThrows, currentFuncDetails.throws);
				func.field.meta.add(':throws', [], Context.currentPos());
				trace('ADDING ', func.field.name, currentFuncDetails.name);
			}

			trace('((((((((())))))))) ${paramsNamesOnly}');
			trace('{{{{{{{{{}}}}}}}}} ${paramsNames}');

			var reassignedVars = new Array<String>();

			var i = 0;
			for (paramName in paramsNamesOnly) {
				reassignedVars.push('var ${paramName} : Optional<${paramsTypesOnly[i]}> = ${paramName}');
				i += 1;
			}

			fieldsStrings.push('${func.isStatic ? 'static ' :''}func ${func.field.name}${hasParams ? '<${pS}>' : ''}(${paramsNames.join(', ')}) ${throws ? 'throws ' :''}${rethrows ? 'rethrows ' :''}-> ${Tools.typeToName(func.ret, true)} {
				${reassignedVars.join('\n')}
				${funcBody}
			}
			');
			funcDetailsStack.pop();
		}

		for (field in classType.fields.get()) {
			switch (field.kind) {
				case FVar(read, write):
					var t = field.type;
					
					var typeString = Tools.varTypeToString(t);
					var actualType = null;
					if (Tools.isTypeSome(t)) {
						switch (read) {
							case AccCall:
							default:
								Context.fatalError('Members defined with swift.Some must have accessor using get or dynamic', Context.currentPos());
						}

						actualType = switch (t) {
							case TAbstract(t, params):
								params[0];
							default:
								null;
						}
					}
					if (actualType != null) {
						trace('::::::::::', actualType);
						trace(Tools.varTypeToString(actualType));
						var tStr = Tools.varTypeToString(actualType);
						//We need to remove the ! at the end
						tStr = tStr.substr(0, tStr.length - 1);
						typeString = 'some ${tStr}';
					}

					
					var defaultString = '';
					if (field.expr() != null) {
						defaultString = ' = ${compileExpressionImpl(field.expr(), false)}';
					}

					var getSetString = '';
					if (currentClass.isInterface) {
						getSetString = '{get set}';
					} else {
						switch ([read, write]) {
							case [AccNormal, AccNormal]:
							default:
								getSetString = '{${PropertyTools.generateGetter(field)} ${PropertyTools.generateSetter(field)}}';
						}
					}

					fieldsStrings.push('var ${field.name}:${typeString}${defaultString} ${getSetString}');
					compileExpressionImpl(field.expr(), true);
				case FMethod(k):
			}
		}

		var imports = new Array<String>();
		//swiftImport meta
		if (classType.meta.has(':swiftImport')) {
			imports = getMetaSwiftImports(classType.meta);
		}
		var importsString = currentClassUses.map(i -> 'import ${i}').join('\n') + '\n';

		var classKeyword = classType.isInterface ? 'protocol' : 'class';
		if (classType.meta.has(':struct')) {
			classKeyword = 'struct';
		}

		var superClassAndInterfaces:String;
		if (classType.superClass != null) {
			superClassAndInterfaces = Lambda.concat([superClass], classType.interfaces.map(int -> Tools.classTypeToSwiftName(int.t.get()))).join(', ');
		} else {
			superClassAndInterfaces = classType.interfaces.map(int -> Tools.classTypeToSwiftName(int.t.get())).join(', ');
		}

		return '${importsString}${classKeyword} ${Tools.classTypeToSwiftName(classType)} ${superClassAndInterfaces != '' ? ': ${superClassAndInterfaces}' : ''} {\n${fieldsStrings.join('\n')}\n}';
	}

	// public function typeToSwifthName(t:Type):String {
	// 	switch (t) {
	// 		case TEnum(t, params):
	// 			return enumTypeToSwiftName(t);
	// 		case TInst(t, params):
	// 			return classTypeToSwiftName(t.get());
	// 	}
	// }

	/**
		Works just like `compileClassImpl`, but for Haxe enums.
		Since we're returning `null` here, all Haxe enums are ignored.
		
		https://api.haxe.org/haxe/macro/EnumType.html
	**/
	public function compileEnumImpl(enumType: EnumType, constructs: Array<EnumOptionData>): Null<String> {
		// TODO: 
		var cases = new Array<String>();
		var constructIndex = 0;
		for (construct in constructs) {
			var paramsWithTypes = construct.args.map((arg) -> '${arg.name}:${Tools.typeToName(arg.type)}').join(', ');
			var params = construct.args.map((arg) -> '${arg.name}').join(', ');

			if (params.length > 0)
				cases.push('static func ${construct.name}(${paramsWithTypes}) -> HxEnumConstructor {
					return (_hx_name: "${construct.name}", _hx_index: ${constructIndex}, enum: "${enumType.name}", params: [${params}]);
				}');
			 else
				cases.push('static var ${construct.name}:HxEnumConstructor = (_hx_name: "${construct.name}", _hx_index: ${constructIndex}, enum: "${enumType.name}", params: [])');
				// 	cases.push('case ${construct.name}');
			 
			 constructIndex++;
		}
		return 'class ${enumType.name} {
			${cases.join('\n')}
		}';
		return '';
	}

	public function printCode(expr: TypedExpr) {
		switch (expr.expr) {
			case TConst(TString(s)):
				return s;
			case TLocal(v):
				return v.name;
			case TBinop(op, e1, e2):
				switch(op) {
					case OpAdd:
						return '${printCode(e1)} ${printCode(e2)}';
					default:
						throw 'Unsupported operator in swift.Syntax';
					}
			case TCall(e, el):
				trace('===================================================TCALL', e, el);
				var paramsString = new Array<String>();
				for (param in el) {
					paramsString.push(printCode(param));
				}

				var shouldAddTry = false;
				switch (e.expr) {
					case TField(_, FStatic(c, cf)):
						if (cf.get().meta.has(':throws')) {
							shouldAddTry = true;
							trace('≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠ YEAH');
						}
						if (c.toString() == "swift.Syntax" && cf.toString() == 'code') {
							return printCode(el[0]);
						} else if (c.toString() == "Std" && cf.toString() == 'string') {
							return 'String(describing: ${printCode(el[0])})';
						}
					case TField(_, FInstance(c, params, cf)):
						if (cf.get().meta.has(':throws')) {
							shouldAddTry = true;
							trace('≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠ YEAH');
						}
					default:
				}
				return '${shouldAddTry ? 'try ' : ''}${compileExpressionImpl(e, false)}(${paramsString.join(', ')})';
			default:
				throw 'Unsupported in swift.Syntax ${expr.expr.getName()}';
		}

		return '';
	}

	var mainGenerated = false;

	public function compileExpressionImplExplicit(expr: TypedExpr, topLevel: Bool, isAssignmentTarget:Bool = false): Null<String> {
		if (!mainGenerated) {
			mainGenerated = true;
			var mainExpr = Context.getMainExpr();
			var s = compileExpressionImpl(mainExpr, false);
			if (!FileSystem.exists(Context.definedValue('swift-output'))) {
				FileSystem.createDirectory(Context.definedValue('swift-output'));
			}

			var content = '@main\nclass _Main {\n\tstatic func main() throws ->Void {\n\t${s}\n\t}\n}\n';
			content += '\ntypealias HxEnumConstructor = (_hx_name: String, _hx_index: Int, enum: String, params: Array<Any>)';
			content += '\nclass HxError:Error {
				init(value:Any) {

				}
			}
			
			extension StringProtocol {
				subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
				subscript(range: Range<Int>) -> SubSequence {
					let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
					return self[startIndex..<index(startIndex, offsetBy: range.count)]
				}
				subscript(range: ClosedRange<Int>) -> SubSequence {
					let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
					return self[startIndex..<index(startIndex, offsetBy: range.count)]
				}
				subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
				subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
				subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
			}
			';
			File.saveContent('${Context.definedValue('swift-output')}/_Main.swift', content);
		}
		if (expr == null) {
			return '';
		}

		switch (expr.expr) {
			case TFunction(tfunc):
				return compileExpressionImpl(tfunc.expr, false);
			case TBlock(el):
				if (Tools.typeToName(expr.t) == 'Void') {
					var elReps = new Array<String>();
					for (expr in el) {
						elReps.push(compileExpressionImpl(expr, false));
					}
					return '\n${elReps.join('\n')}\n';
				}

				var last = el.pop();

				var elReps = new Array<String>();
				for (expr in el) {
					elReps.push(compileExpressionImpl(expr, false));
				}

				var requireReturn = true;
				requireReturn = switch (last.expr) {
					case TThrow(_), TReturn(_):
						false;
					default:
						requireReturn;
				}

				currentFuncDetails.throws = true;

				var lastStr = switch ([last.expr, requireReturn]) {
					case [TBinop(Binop.OpAssign, e1, e2), true]:
						'${compileExpressionImpl(last, false)}
						var __swiftTemp__ = ${compileExpressionImpl(e1, false)}
						return __swiftTemp__
						';
					default:
						'${requireReturn ? 'return ': ''}${compileExpressionImpl(last, false)}';
				}

				return 'try { () throws -> ${requireReturn ? Tools.typeToName(expr.t) : 'Void'} in
					if (false) {
						throw HxError(value: "")
					}
					${elReps.join('\n')}
					${lastStr}
				}()';
			case TCall(e, el):
				var shouldAddTry = false;
				var labelsMap = new Map<String, String>();
				switch (e.expr) {
					case TField(_, FStatic(c, cf)), TField(_, FInstance(c, _, cf)):
						labelsMap = getLabelsFromClassField(cf.get());
						if (cf.get().meta.has(':throws')) {
							shouldAddTry = true;
						}
					default:
				}
				var paramsNames = new Array<String>();
				switch (e.t) {
					case TFun(args, ret):
						for (arg in args) {
							paramsNames.push(arg.name);
						}
					default:
				}
				
				var paramsString = new Array<String>();
				var i = 0;
				for (param in el) {
					if (paramsNames[i] != null && paramsNames[i] != '') {
						var label = getLabelFromMap(labelsMap, paramsNames[i]);
						if (label != '_') {
							paramsString.push('${label} : ${compileExpressionImplExplicit(param, false)}');
						} else {
							paramsString.push('${compileExpressionImplExplicit(param, false, true)}');
						}
					} else {
						paramsString.push('${compileExpressionImplExplicit(param, false, true)}');
					}
					i++;
				}
				switch (e.expr) {
					case TIdent('__swift__'):
						var extractedStr = switch (el[0].expr) {
							case TConst(TString(s)):
								s;
							default:
								null;
						}
						if (extractedStr == null) {
							Context.fatalError('A string is needed here', e.pos);
						}
						return extractedStr;
					case TField(_, FStatic(c, cf)), TField(_, FInstance(c, _, cf)):
						if (c.toString() == "swift.Syntax" && cf.toString() == 'code') {
							return printCode(el[0]);
						}
						if (c.toString() == "swift.Syntax" && cf.toString() == 'unwrap') {
							return '${compileExpressionImplExplicit(el[0], false, true)}!';
						}
						// We need to call the function generation so that it gets marked with automatic metas (see explanations on throws in the README)
						funcDetailsStack.add(new FuncDetails([c.toString(), cf.toString()].join('.')));
						//For some reason Std.string is infinitely recursive.
						//Fortunately we kinda know that this function is not a problem.
						if (!(c.toString() == 'Std' && cf.toString() == 'string')) {
							compileExpressionImpl(cf.get().expr(), false);
							shouldAddTry = shouldAddTry || funcDetailsStack.first().throws;
						}
						funcDetailsStack.pop();
						if (currentFuncDetails != null) {
							currentFuncDetails.throws = currentFuncDetails.throws || shouldAddTry;
						}
					default:
				}
				//TODO: The call to Explicit should check if unwrapping is necessary or not
				return '${shouldAddTry ? 'try ' : ''}${compileExpressionImplExplicit(e, false, true)}(${paramsString.join(', ')})';
			case TField(e, fa):
				switch (fa) {
					case FInstance(c, params, cf):
						return '${compileExpressionImplExplicit(e, false, false)}.${cf.get().name}${isAssignmentTarget ? '': '!'}';
					case FStatic(c, cf):
						return '${compileExpressionImpl(e, false)}.${cf.get().name}${isAssignmentTarget ? '': '!'}';
					case FEnum(e, ef):
						return '${e.toString()}.${ef.name}';
					default:
						trace('***** Unsupported field access ${Type.enumConstructor(fa)}');
						return 'UNSUPPORTED';
				}
			case TTypeExpr(m):
				switch (m) {
					case TClassDecl(c):
						addSwiftImports(c.get());
						//currentClassUses.push(classTypeToSwiftName(c.get()));
						return Tools.classTypeToSwiftName(c.get());
					case TEnumDecl(e):
						return e.toString();
					default:
						trace('ttypeexpr not supported: ${Type.enumConstructor(m)}');
				}
			case TLocal(v):
				trace(v.t.getName());
				return '${v.name}${isAssignmentTarget ? '' : '!'}';
			case TConst(c):
				return switch (c) {
					case TInt(i): Std.string(i);
					case TFloat(s): Std.string(s);
					case TString(s): '"${Tools.escapeStringConst(s)}"';
					case TBool(b): b ? 'true' : 'false';
					case TNull: 'nil';
					case TSuper: 'super.init';
					case TThis: 'self';
				}
			case TObjectDecl(fields):
				var fieldsString = new Array<String>();
				for (field in fields) {
					fieldsString.push('"${field.name}": ${compileExpressionImpl(field.expr, false)}');
				}
				return '(\n${fieldsString.join(',\n')}\n)';
			case TBinop(op, e1, e2):
				// var unwrapIfNecessary = (t:Type) -> {
				// 	return '!';
				// 	if (Tools.isTypeNullable(t)) return '!';
				// 	return '';
				// };

				var unwrapExprIfNecessary = (e:TypedExpr) -> {
					switch (e.expr) {
						case TConst(c):
							return '';
						default:
							if (Tools.isTypeNullable(e.t))
								return '';
							else
								return '';
					}
				};

				switch (op) {
					case OpAssign:
						switch (e2.t) {
							case TFun(args, ret):
								return '${compileExpressionImplExplicit(e1, false, true)} = {${funcDetailsToSignatureWithNames(args, ret)} in
									${compileExpressionImpl(e2, false)}
								}';
							default:
						}
						if (Tools.isTypeNullable(e1.t) || Tools.isTypeNullable(e2.t)) {
							return '${compileExpressionImpl(e1, false)}${unwrapExprIfNecessary(e1)} = ${compileExpressionImpl(e2, false)}${unwrapExprIfNecessary(e2)}';
							}
						return '${compileExpressionImplExplicit(e1, false, true)} = ${compileExpressionImpl(e2, false)}';
					case OpLt:
						return '${compileExpressionImpl(e1, false)}${unwrapExprIfNecessary(e1)} < ${compileExpressionImpl(e2, false)}${unwrapExprIfNecessary(e2)}';
					case OpGt:
						var isNullType1 = false;
						return '${compileExpressionImpl(e1, false)}${unwrapExprIfNecessary(e1)} > ${compileExpressionImpl(e2, false)}${unwrapExprIfNecessary(e2)}';
					case OpAdd:
						return '${compileExpressionImpl(e1, false)}${unwrapExprIfNecessary(e1)} + ${compileExpressionImpl(e2, false)}${unwrapExprIfNecessary(e2)}';
					case OpSub:
						return '${compileExpressionImpl(e1, false)}${unwrapExprIfNecessary(e1)} - ${compileExpressionImpl(e2, false)}${unwrapExprIfNecessary(e2)}';
					case OpEq:
						return '${compileExpressionImpl(e1, false)} == ${compileExpressionImpl(e2, false)}';
					default:
						trace('operator ${Type.enumConstructor(op)} not implemented yet');
						return 'UNSUPPORTED${Type.enumConstructor(op)}';
				}
			case TUnop(op, postFix, e):
				switch (op) {
					case OpIncrement:
						if (postFix) {
							return '${compileExpressionImpl(e, false)}++';
						} else {
							return '++${compileExpressionImpl(e, false)}';
						}
					default:
						trace('Unary operator ${Type.enumConstructor(op)} not yet implemented');
						return 'UNSUPPORTED TUNop' + Type.enumConstructor(op);
				}
			case TMeta(m, e1):
				trace('-----------META');
				return '/* @${m.name}(${m.params.length}) */${compileExpressionImpl(e1, false)}';
			case TReturn(e):
				return 'return ${compileExpressionImpl(e, false)}';
			case TArray(e1, e2):
				return '${compileExpressionImpl(e1, false)}[${compileExpressionImpl(e2, false)}]';
			case TVar(v, expr):
				var exprString:Null<String> = null;
				if (expr != null) {
					exprString = compileExpressionImpl(expr, false);
				}
				// var isNullableExpected = expr == null || 
				trace('!!!!!!! ${v.meta.get().map(m -> m.name)}');
				var actualType = null;
				if (Tools.isTypeSome(v.t)) {
					actualType = switch (v.t) {
						case TAbstract(t, params):
							params[0];
						default:
							null;
					}
				}
				var expectedType = Tools.varTypeToString(v.t);

				if (actualType != null) {
					expectedType = 'some ${Tools.varTypeToString(actualType)}';
				}

				switch (v.t) {
					case TFun(args, ret):
						exprString = '{(${args.map(arg -> '${Tools.typeToName(arg.t)}').join(', ')}) in ${exprString}}';
					default:
						if (expr?.expr != null)
						switch (expr.expr) {
							// case TBlock(el):
							// 	var last = el.pop();

							// 	exprString = '{
							// 		${compileExpressionImpl(expr, false)}
							// 		return ${compileExpressionImpl(last, false)} as! ${expectedType}
							// 	}()';
							case TCast(e, m):
								exprString = '/* ${e.expr.getName()}*/ ${exprString}';
							default:
						}
				}
				
				trace('€€€€€€€€€€€€€€€ ${v.name}');
				var mustBeOptional = exprString == null || switch (expr.expr) {
					case TConst(TNull):
						true;
					default:
						false;
				}

				mustBeOptional = true;
				if (Tools.isTypeNullable(v.t)) mustBeOptional = false;

				return 'var ${v.name} : ${mustBeOptional ? 'Optional<${StringTools.replace(expectedType, '!', '')}>' : expectedType}${exprString != null ? ' = ${exprString}' : ' = nil'}';
			case TNew(c, params, el):
				var shouldAddTry = c.get().constructor.get().meta.has(':throws');

				// We need to call the function generation so that it gets marked with automatic metas (see explanations on throws in the README)
				funcDetailsStack.add(new FuncDetails([c.toString(), 'new'].join('.')));
				compileExpressionImpl(c.get().constructor.get().expr(), false);
				shouldAddTry = shouldAddTry || funcDetailsStack.first().throws;
				funcDetailsStack.pop();
				

				addSwiftImports(c.get());
				var constructorType = c.get().constructor.get().type;

				var labelsMap = getLabelsFromClassField(c.get().constructor.get());

				var paramsStrings = new Array<String>();
				switch(constructorType) {
					case TFun(args, ret):
						var i = 0;
						for (arg in args) {
							var name = arg.name;
							if (name != null && name != '') {
								name = getLabelFromMap(labelsMap, name);
							}
							var value = el[i];
							var t = name != null && name != '' && name != '_' ? '${name} : ' : '';
							paramsStrings.push('${t}${compileExpressionImpl(value, false)}');
							i++;
						}
					default:
				}


				var name = Tools.classTypeToSwiftName(c.get());
				if (c.get().meta.has(':native')) {
					switch (c.get().meta.extract(':native')[0].params[0].expr) {
						case EConst(c):
							switch (c) {
								case CString(s, kind):
									name = s;
								default:
							}
						default:
					}
				}
				// trace('££££££££££ ${el[0].expr.getName()}');
				//TODO: Implement params handling!
				var params:String = '';
				if (el != null) {
					el.map(el -> compileExpressionImpl(el, false)).join(', ');
				}
				currentFuncDetails.throws = currentFuncDetails.throws || shouldAddTry;
				
				return '${shouldAddTry ? 'try ' : ''}${name}(${paramsStrings.join(', ')})';
			case TParenthesis(e):
				return '(${compileExpressionImpl(e, false)})';
			case TIf(econd, eif, eelse):
				var elseStr: String = '';
				if (eelse != null) {
					elseStr = 'else {\n${compileExpressionImpl(eelse, false)}}';
				}
				return 'if (${compileExpressionImpl(econd, false)}) {\n${compileExpressionImpl(eif, false)}\n} ${elseStr}';
			case TEnumIndex(e1):
				return '${compileExpressionImpl(e1, false)}._hx_index';
			case TSwitch(e, cases, edef):
				var casesString = new Array<String>();
				for (casee in cases) {
					var exprString = '';
					if (casee.expr.expr.getName() != 'TBlock') {
						exprString = compileExpressionImpl(casee.expr, false);
					} else {
						switch (casee.expr.expr) {
							case TBlock(el):
								for (expr in el) {
									exprString += '${compileExpressionImpl(expr, false)}\n';
								}
							default:
						}
					}
					casesString.push('case ${casee.values.map((t) -> compileExpressionImpl(t, false)).join(', ')}:\n${exprString}\nbreak');
				}
				var defaultString = '';
				if (edef != null && edef.expr.getName() != 'TBlock') {
					defaultString = compileExpressionImpl(edef, false);
				} else if (edef != null) {
					switch (edef.expr) {
						case TBlock(el):
							for (expr in el) {
								defaultString += '${compileExpressionImpl(expr, false)}\n';
							}
						default:
					}
				}
				casesString.push('default:\n${defaultString}\nbreak');
				return 'switch (${compileExpressionImpl(e, false)}) {\n${casesString.join('\n')}\n}';
			case TEnumParameter(e1, ef, index):
				var paramString = switch (e1.t) {
					case TEnum(t, params):
						if (!t.get().constructs.exists(ef.name)) {
							'';
						} else {
							var param = t.get().constructs.get(ef.name);
							switch (param.type) {
								case TFun(args, ret):
									'as! ${Tools.typeToName(args[index].t)}';
								default: 'We should not reach that';
							}
						}
					default:
						throw 'We should not reach that';
				}
				return '${compileExpressionImpl(e1, false)}.params[${index}]${paramString}';
			case TThrow(e):
				currentFuncDetails.throws = true;
				return 'throw HxError(value: ${compileExpressionImpl(e, false)})';
			case TCast(e, m):
				var typeName = if (m == null) {
					return '${compileExpressionImpl(e, false)}';
				} else {
					switch (m) {
						case TClassDecl(c):
							Tools.classTypeToSwiftName(c.get());
						case TEnumDecl(e):
							e.get().name;
						case TTypeDecl(t):
							Context.fatalError('TTypeDecl casting is not handled', e.pos);
							'';
						case TAbstract(a):
							Context.fatalError('TAbstract casting is not handled', e.pos);
							'';
					}
				}
				return '${compileExpressionImpl(e, false)} as! ${typeName}';
			default:
				trace('expr not supported: ${Type.enumConstructor(expr?.expr)}');
				return 'expr not supported: ${Type.enumConstructor(expr?.expr)}';
		}
		// TODO: implement
		return '';
	}

	/**
		This is the final required function.
		It compiles the expressions generated from Haxe.
		
		PLEASE NOTE: to recusively compile sub-expressions:
			BaseCompiler.compileExpression(expr: TypedExpr): Null<String>
			BaseCompiler.compileExpressionOrError(expr: TypedExpr): String
		
		https://api.haxe.org/haxe/macro/TypedExpr.html
	**/
	public function compileExpressionImpl(expr: TypedExpr, topLevel: Bool): Null<String> {
		return compileExpressionImplExplicit(expr, topLevel);
	}

	override function compileTypedefImpl(typedefType:DefType) {
		switch (typedefType.type) {
			case TAnonymous(a):
				switch (a.get().status) {
					case AClosed:
						var pS = a.get().fields.map((f) -> {
							return '${f.name}:${Tools.typeToName(f.type)}';
						});
						//Swift doesn't allow tuples with only one member (but allows 0 members...)
						if (pS.length == 1) {
							pS.push('_:Void');
						}
						return 'typealias ${Tools.defTypeToSwiftName(typedefType)} = (${pS.join(', ')})';
					default:
				}
				return null;
				return a.get().status.getName();
			default:
				return null;
		}
		// return 'typealias ${typedefType.name} = () ${typedefType.type.getName()}';
	}

	function wrapInBlock(e:TypedExpr, representation:String) {
		if (e.expr.getName() != 'TBlock') {
			return '{\n${representation}}';
		}

		return representation;
	}

	function addSwiftImports(c:ClassType) {
		if (!c.meta.has(':swiftImport'))
			return;
		if (!c.isExtern)
			return;

		for (meta in getMetaSwiftImports(c.meta)) {
			currentClassUses.push(meta);
		}
	}

	function getMetaSwiftImports(meta:MetaAccess):Array<String> {
		var imports = new Array<String>();
		for (metaImport in meta.extract(':swiftImport')) {
			var metaImportName = metaImport.params[0];
			if (metaImportName == null) {
				Context.error('Meta :swiftImport requires a String constant', metaImport.pos);
			}
			switch (metaImport.params[0].expr) {
				case EConst(c):
					switch (c) {
						case CString(s, kind):
							imports.push('${s}');
						default:
							Context.error('Meta :swiftImport requires a String constant', metaImport.pos);
					}
				default:
					Context.error('Meta :swiftImport requires a String constant', metaImport.pos);
			}
		}
		return imports;
	}
}

class FuncDetails {
	public var name:String = '()';
	public var throws:Bool = false;

	public function new(?name:String) {
		if (name != null) {
			this.name = name;
		}
	}
}

class Tools {
    public static function escapeStringConst(string:String):String {
        string = StringTools.replace(string, '\n', '\\n');
        string = StringTools.replace(string, '"', '\"');

        return string;
    }

	public static function isTypeNullable(t:Type):Bool {
		switch (t) {
			case TAbstract(t, params):
				return isAbstractTypeNullT(t.get());
			default:
				return false;
		}
	};

	public static function isAbstractTypeNullT(abstractType:AbstractType) {
		return (
			abstractType.module == 'StdTypes'
			&& abstractType.pack.length == 0
			&& abstractType.name == 'Null'
		);
	}

	public static function isTypeSome(t:Type):Bool {
		switch (t) {
			case TAbstract(t, params):
				return isAbstractTypeSome(t.get());
			default:
				return false;
		}
	}

	public static function isAbstractTypeSome(abstractType:AbstractType) {
		return (
			abstractType.module == 'swift.Some'
			&& abstractType.pack[0] == 'swift'
			&& abstractType.pack.length == 1
			&& abstractType.name == 'Some'
		);
	}

	/**
		Returns the type representation for TVar/FVar
	**/
	public static function varTypeToString(t:haxe.macro.Type) {
		return switch (t) {
			case TAbstract(t, params):
				abstractTypeToName(t.get(), params);
			case TInst(t, params):
				'${classTypeToSwiftName(t.get())}!';
			case TEnum(t, params):
				'HxEnumConstructor';
				// enumTypeToSwiftName(t.get());
			case TFun(args, ret):
				var argsString = '(${args.map(arg -> typeToName(arg.t)).join(', ')})';
				'${argsString}->${typeToName(ret)}';
			case TType(t, params):
				'${defTypeToSwiftName(t.get())}!';
			case TDynamic(t):
				if (t == null) {
					'Any';
				} else {
					t.getName();
				}
			default:
				trace('Unsupported ${Type.enumConstructor(t)}');
				return 'UNSUPPORTED  ${Type.enumConstructor(t)}';
		}
	}

	public static function abstractTypeToName(t:AbstractType, params:Array<Type>):String {
		return switch (t.name) {
			case 'Null':
				var pS = params.map((p) -> {
					typeToName(p);
				}).join(', ');
				return 'Optional<${pS}>';
			default:
				return t.name;
		}
	}

	public static function classTypeToSwiftName(classType:ClassType) {
		if (classType.meta.has(':native')) {
			switch (classType.meta.extract(':native')[0].params[0].expr) {
				case EConst(c):
					switch (c) {
						case CString(s, kind):
							return s;
						default:
					}
				default:
			}
		}


		var comps = new Array<String>();
		// if (classType.module != null)
		// 	comps.push(classType.module);
		comps = comps.concat(classType.pack);
		comps.push(classType.name);
		return comps.join('_');
	}

	public static function typeToName(type:Type, printSome: Bool = false):String {
		var prefix = '';
		if (printSome && isTypeSome(type)) {
			prefix = 'some ';

			type = extractActualSomeType(type);
		}

		var getTypeString = (type) -> {
			switch (type) {
				case TInst(t, params):
					var p = new Array<String>();
					for (param in params) {
						p.push(typeToName(param));
					}
					if (p.length > 0) {
						return classTypeToSwiftName(t.get()) + '<${p.join(', ')}>';
					} 
					return classTypeToSwiftName(t.get());
				case TDynamic(t):
					return 'Any';
				case TAbstract(t, params):
					switch (t.get().name) {
						case 'Null':
							var pS = params.map((p) -> {
								typeToName(p);
							}).join(', ');
							return 'Optional<${pS}>';
						default:
							return t.get().name;
					}
				case TEnum(t, params):
					return enumTypeToSwiftName(t.get());
				case TFun(args, ret):
					return '(${args.map(arg -> typeToName(arg.t)).join(', ')}) -> ${typeToName(ret)}';
				case TType(t, params):
					return defTypeToSwiftName(t.get());
				default:
					return 'UNMATCHEDPATTERN ${type.getName()}';
			}
		}

		return '${prefix}${getTypeString(type)}';
	}

	public static function extractActualSomeType(someType:Type) {
		switch (someType) {
			case TAbstract(t, params):
				return params[0];
			default:
				return null;
		}

		return null;
	}

	public static function defTypeToSwiftName(defType:DefType):String {
		var comps = new Array<String>();
		// if (classType.module != null)
		// 	comps.push(classType.module);
		comps = comps.concat(defType.pack);
		if (comps[0] == 'Null') {
			trace('polop');
		}
		comps.push(defType.name);
		return comps.join('_');
	}

	public static function enumTypeToSwiftName(enumType:EnumType):String {
		trace('Module: ${enumType.module}, ${enumType.pack}, ${enumType.name}');
		var comps = new Array<String>();
		comps = comps.concat(enumType.pack);
		comps.push(enumType.name);
		return comps.join('_');
	}
}

class PropertyTools {
	public static function generateGetter(cf:ClassField) {
		switch (cf.kind) {
			case FVar(read, write):
				switch (read) {
					case AccNormal:
						Context.fatalError('Getter default is not yet supported', Context.currentPos());
					case AccNo:
						return '';
					case AccCall, AccCtor:
						return 'get { return get_${cf.name}() }';
					case AccInline:
						Context.fatalError('Getter inline is not yet supported', Context.currentPos());
					case AccNever:
						Context.fatalError('Getter never is not yet supported', Context.currentPos());
					case AccRequire(r, msg):
						Context.fatalError('Getter require is not yet supported', Context.currentPos());
					case AccResolve:
						Context.fatalError('Getter resolve is not yet supported', Context.currentPos());
				}
			default:
		}

		return '';
	}

	public static function generateSetter(cf:ClassField) {
		switch (cf.kind) {
			case FVar(read, write):
				switch (write) {
					case AccNormal:
						Context.fatalError('Setter default is not yet supported', cf.pos);
					case AccNo:
						return '';
					case AccCall, AccCtor:
						return 'set { set_${cf.name} }';
					case AccInline:
						Context.fatalError('Setter inline is not yet supported', cf.pos);
					case AccNever:
						return '';
						Context.fatalError('Setter never is not yet supported', cf.pos);
					case AccRequire(r, msg):
						Context.fatalError('Setter require is not yet supported', cf.pos);
					case AccResolve:
						Context.fatalError('Setter resolve is not yet supported', cf.pos);
				}
			default:
		}

		return '';
	}
}
#end
