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
