import Foundation
class TestClass  {
 init(_:String) {

MySocket()
self.field = TestEnum.One
haxe_Log.trace(v : "Create Code class!", pos : [
"fileName": "test/Code.hx",
"lineNumber": 25,
"className": "TestClass",
"methodName": "new"
])
haxe_Log.trace(v : "Here is a Int " + Std.string(v : TestClass.giveMeAInt()), pos : [
"fileName": "test/Code.hx",
"lineNumber": 26,
"className": "TestClass",
"methodName": "new"
])
TestClass.test()
var e : HxEnumConstructor = TestEnum.One
haxe_Log.trace(v : "First value of field", pos : [
"fileName": "test/Code.hx",
"lineNumber": 30,
"className": "TestClass",
"methodName": "new"
])
haxe_Log.trace(v : self.field, pos : [
"fileName": "test/Code.hx",
"lineNumber": 31,
"className": "TestClass",
"methodName": "new"
])
self.increment()
haxe_Log.trace(v : "Second value of field", pos : [
"fileName": "test/Code.hx",
"lineNumber": 35,
"className": "TestClass",
"methodName": "new"
])
haxe_Log.trace(v : self.field, pos : [
"fileName": "test/Code.hx",
"lineNumber": 36,
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
"lineNumber": 43,
"className": "TestClass",
"methodName": "new"
])


break
case 1:
var _g : String! = comp.params[0]as! String

var id : String! = _g
haxe_Log.trace(v : "I got company " + id, pos : [
"fileName": "test/Code.hx",
"lineNumber": 45,
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
"lineNumber": 49,
"className": "TestClass",
"methodName": "new"
])
}
TestClass.callClosure(closure : clos)
var url : URL! = Foundation.URL(string :  "http://www.google.com")
haxe_Log.trace(v : "Mon URL " + url.absoluteString, pos : [
"fileName": "test/Code.hx",
"lineNumber": 55,
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
"lineNumber": 60,
"className": "TestClass",
"methodName": "callClosure"
])

								}
closure("running from callClosure")

			}
			
static func test() -> Void {
				
				
haxe_Log.trace(v : "Testing", pos : [
"fileName": "test/Code.hx",
"lineNumber": 66,
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