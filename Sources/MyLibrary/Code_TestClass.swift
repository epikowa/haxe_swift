import Foundation
class TestClass  {
 init(_:String) {

MySocket()
var test : TestStructure! = TestStructure(name :  "name", id :  "id", password :  "password")
haxe_Log.trace(v : "test", pos : [
"fileName": "test/Code.hx",
"lineNumber": 25,
"className": "TestClass",
"methodName": "new"
])
haxe_Log.trace(v : test.name, pos : [
"fileName": "test/Code.hx",
"lineNumber": 26,
"className": "TestClass",
"methodName": "new"
])
self.field = TestEnum.One
haxe_Log.trace(v : "Create Code class!", pos : [
"fileName": "test/Code.hx",
"lineNumber": 28,
"className": "TestClass",
"methodName": "new"
])
haxe_Log.trace(v : "Here is a Int " + Std.string(v : TestClass.giveMeAInt()), pos : [
"fileName": "test/Code.hx",
"lineNumber": 29,
"className": "TestClass",
"methodName": "new"
])
TestClass.test()
var e : HxEnumConstructor = TestEnum.One
haxe_Log.trace(v : "First value of field", pos : [
"fileName": "test/Code.hx",
"lineNumber": 33,
"className": "TestClass",
"methodName": "new"
])
haxe_Log.trace(v : self.field, pos : [
"fileName": "test/Code.hx",
"lineNumber": 34,
"className": "TestClass",
"methodName": "new"
])
self.increment()
haxe_Log.trace(v : "Second value of field", pos : [
"fileName": "test/Code.hx",
"lineNumber": 38,
"className": "TestClass",
"methodName": "new"
])
haxe_Log.trace(v : self.field, pos : [
"fileName": "test/Code.hx",
"lineNumber": 39,
"className": "TestClass",
"methodName": "new"
])
var comp : HxEnumConstructor = ComplexEnum.User(name : "UserTest", surname : "MyName")
//@:ast
switch ((//@:exhaustive
comp._hx_index)) {
case 0:
var _g : String! = comp.params[0]as! String
var _g1 : String! = comp.params[1]as! String

var name : String! = _g
var surname : String! = _g1
haxe_Log.trace(v : "I got a user " + name + " " + surname, pos : [
"fileName": "test/Code.hx",
"lineNumber": 46,
"className": "TestClass",
"methodName": "new"
])


break
case 1:
var _g : String! = comp.params[0]as! String

var id : String! = _g
haxe_Log.trace(v : "I got company " + id, pos : [
"fileName": "test/Code.hx",
"lineNumber": 48,
"className": "TestClass",
"methodName": "new"
])


break
default:

break
}
var clos : (String)->Void = {(String) in 
haxe_Log.trace(v : "This is a closure", pos : [
"fileName": "test/Code.hx",
"lineNumber": 52,
"className": "TestClass",
"methodName": "new"
])
}
TestClass.callClosure(closure : clos)
var url : URL! = Foundation.URL(string :  "http://www.google.com")
haxe_Log.trace(v : "Mon URL " + url.absoluteString, pos : [
"fileName": "test/Code.hx",
"lineNumber": 58,
"className": "TestClass",
"methodName": "new"
])

}

 func increment() -> Void {
				
				
//@:ast

var _g : HxEnumConstructor = self.field
switch ((_g._hx_index)) {
case 0:
self.field = TestEnum.Two
break
case 1:
self.field = TestEnum.Three
break
default:

break
}


			}
			
static func callClosure(closure : (String) -> Void) -> Void {
				var closure = closure
				
closure = {(a : String) -> Void in
									
haxe_Log.trace(v : "polop " + a, pos : [
"fileName": "test/Code.hx",
"lineNumber": 63,
"className": "TestClass",
"methodName": "callClosure"
])

								}
closure("running from callClosure")

			}
			
static func test() -> Void {
				
				
haxe_Log.trace(v : "Testing", pos : [
"fileName": "test/Code.hx",
"lineNumber": 69,
"className": "TestClass",
"methodName": "test"
])

			}
			
static func giveMeAInt() -> Int {
				
				
return 12

			}
			
var field:HxEnumConstructor! 
var name:String! 
}