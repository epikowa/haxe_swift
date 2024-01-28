# Reflaxe/swift

A compiler that compiles Haxe code into swift.

> [!WARNING]
> This is currently far from being production ready. Large parts of the Haxe language aren't supported yet and the target itself hasn't been extensively tested.

## Metadata

* :swiftImport('Foundation') : adds a `import Foundation` before compiling current class
* :struct : added before the `class` keyword it will generate a struct rather than a class. Note that you need to add an initializer that maps parameters to instance's fields. See the following example:  
  ```haxe
  @:struct 
  class TestStructure {
    public var name:String;
    public var id:String;

    public function new(name:String, id:String) {
        this.name = name;
        this.id = id;
    }
  }
  ```
  This may be modified in the future so that such initializer is automatically added.
* :throws : added before a function declaration it will declare this function with `throws`.
* :rethrows : added before a function declaration it will declare this function with `rethrows`.
> [!IMPORTANT]
> Regarding `throws` on functions' definitions:  
> Whenever a function uses the `throw` keyword it is automatically marked as `throws` in the swift code and the Haxe metadata `:throws` is automatically added to it.  
* :swiftLabels(param, 'label') : set `label` as the label for `param`. See the [Swift Labels section](#swift-labels) for explanations.

## <a name="swiftLabels"></a> Swift Labels
The swift language uses a weird concept of 'labels' that can somehow change parameters' names.  
Suppose the following code:

```swift
func testFunction(testLabel test:String) -> String {
  return test;
}
```

It would be called in the following way:
```swift
  testFunction(testLabel: "TestString")
```

As you can see, while the function code still uses `test` as the parameter's name, the call site will use the specified `testLabel` label.

But there's a catch : a special `_` label that specifies that the call site should not specify a label:

```swift
func testFunction(_ test:String) -> String {
  return test;
}

testFunction("TestString")
```

You can use the `@:swiftLabels(field, 'label')` meta in front of your functions to define labels:

```haxe
@:swiftLabels(param1, '_')
@:swiftLabels(param2, 'secondParam')
function testFunction(param1:String, param2:String, param3:String):Void {

}
```

Will result in the following being generated:

```swift
func testFunction(_ param1:String, secondParam param2:String, param3:String):Void {

}
```

which will then generate the following calls:

```swift
testFunction("First string", secondParam: "Second string", param3: "Third String")
```

## Casting
> [!WARNING]
> The `cast` keyword is partially implemented, however, at the moment only safe casting is supported (`cast` keyword used with a type).  
> Casting to `TTypeDecl` or `TAbstract` is not currently supported.

## Swift.Some  
Use the abstract `swift.Some<T>` for your `T` type to be annoted with `some `:

```haxe
function test() {
  var myVar:swift.Some<String> = "foo";
}
```

will become

```swift
var e : some String! = ""
```