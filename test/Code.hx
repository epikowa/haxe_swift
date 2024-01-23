// A bit of code to compile with your custom compiler.
//
// This code has no relevance beyond testing purposes.
// Please modify and add your own test code!

package;

import MySocket.URL;

enum TestEnum {
	One;
	Two;
	Three;
	Four(extra:Int);
}

@:swiftImport('Foundation')
class TestClass implements IHaxeSwift {
	var field: TestEnum;
	public var name: String;

	public function new(_):Void {
		new MySocket();
		var test : TestStructure = new TestStructure('name', 'id', 'password');
		trace('test');
		trace(test.name);
		field = One;
		trace("Create Code class!");
		trace('Here is a Int ${Std.string(giveMeAInt())}');
		TestClass.test();
		var e = TestEnum.One;
		
		trace('First value of field');
		trace(field);

		increment();

		trace('Second value of field');
		trace(field);


		var comp = User('UserTest', 'MyName');

		switch (comp) {
			case User(name, surname):
				trace('I got a user ${name} ${surname}');
			case Company(id):
				trace('I got company ${id}');
		}

		var clos = (a:String) -> {
			trace('This is a closure');
		}

		callClosure(clos);

		Reflect.fields({});
		var url = new URL('http://www.google.com');
		trace('Mon URL ' + url.absoluteString);
	}

	static function callClosure(closure:String->Void) {
		closure = (a) -> {
			trace('polop ' + a);
		};
		closure('running from callClosure');
	}

	static function test() {
		trace('Testing');
	}

	static function giveMeAInt() {
		return 12;
	}

	public function increment() {
		switch(field) {
			case One: field = Two;
			case Two: field = Three;
			case _:
		}
	}
}

function main() {
	trace("Hello Haxe!");
	new TestClass('');
	Reflect.fields({});
	// final c = new TestClass("ha");
	// for(i in 0...3) {
	// 	c.increment();
	// }
}

enum ComplexEnum {
	User(name:String, surname: String);
	Company(id:String);
}

interface IHaxeSwift {
	var name:String;
}

@:struct class TestStructure {
	public var name:String;
	public var id:String;
	public var password:String;

	public function new(name:String, id:String, password:String) {
		this.name = name;
		this.id = id;
		this.password = password;
	}
}