package;

import swift.Syntax;
import swift.Syntax;
import swift.HxOverrides.Substring;
import haxe.lang.Runtime;
import swift.HxOverrides;
import swift._native.Character;
import swift._native.UInt8;

/**
	Your target needs to provide custom implementations of every Haxe API class.
	How this is achieved is different for each target, so be sure to research and try different methods!

	To help you get started, this String.hx was provided.
	But you'll need to handle the rest from here!

	This file is based on the cross implementation for String:
	https://github.com/HaxeFoundation/haxe/blob/development/std/String.hx

	-- Examples --
	JavaScript  https://github.com/HaxeFoundation/haxe/tree/development/std/js/_std/String.hx
	Hashlink    https://github.com/HaxeFoundation/haxe/blob/development/std/hl/_std/String.hx
	Python      https://github.com/HaxeFoundation/haxe/blob/development/std/python/_std/String.hx
**/
extern class String {
	var length(default, null):Int;

	@:overload(function(_:Substring):Void {})
	@:overload(function(string:String):Void {})
	@:overload(function(char:Character):Void {})
	@:overload(function(char:Substring):Void {})
	function new(_:Character):Void;

	function toUpperCase():String;
	function toLowerCase():String;
	function charAt(index:Int):String;
	function charCodeAt(index:Int):Null<Int>;
	function indexOf(str:String, ?startIndex:Int = 0):Int;
	function lastIndexOf(str:String, ?startIndex:Int = 0):Int;
	function split(delimiter:String):Array<String>;
	function substr(pos:Int, ?len:Int):String;
	function substring(startIndex:Int, ?endIndex:Int):String;
	inline function toString():String {
		return new String(this);
	}

	@:pure static function fromCharCode(code:Int):String;
}
