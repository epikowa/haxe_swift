import swift._native.Character;
import haxe.lang.Runtime;
using swift._native.UInt8;

class Simple {
    public static function main() {
        // @:truc hello();
        // test();
        // new Simple().testThrow();
        // var a = {foo: "bar", plic: "ploc"};
        var a = @plop new User();
        a.name = "abc";
        // a.polop('haha');

        // var s:String = Runtime.getField(a, "name");
        // var foo = '';
        // Runtime.printNative(swift.Syntax.unwrap(s));
        // cast (foo, String);
        // trace(foo);
        // var t:Polop;
        // var bonjour:String = 'Bonjour';
        // trace(bonjour.toUpperCase());
        // trace(bonjour.toLowerCase());
        // trace(bonjour.charAt(3));
        // test();
        // new Throwing();
        // var pl = () -> {
        //     trace('Hello');
        // }
        // pl();
        // var plop:URL = new URL('plop');

        var c = new Character('a').asciiValue.toInt();
        Runtime.printNative(c);
        
        var s = "abc";
        Runtime.printNative(s);
        Runtime.printNative(s);
        var c1 = s.charCodeAt(0);
        var c2 = s.charCodeAt(1);
        var c3 = s.charCodeAt(3);
        Runtime.printNative(c1);
        Runtime.printNative(c2);
        Runtime.printNative(c3);

        var sub = s.substring(0, 2);
        Runtime.printNative(sub);
    }

    public static function hello() {
        1+1;
    }

    public static function test() {
        throw 'Foo';
    }

    public function new() {

    }

    public function testThrow() {
        throw 'Wait';
    }
}

class User {
    public var name:String;
    public function new() {}
    @:swiftLabels(bim, 'boum')
    public function polop(bim:String) {
        throw 'oop';
    }
}

class Throwing {
    public function new() {
        1+3;
    }
}

// @:swiftImport('Foundation')
// extern class URL {
//     public function new(string: String);
//     var absoluteString(default, never):String;
// }

typedef Polop = {
    name: String
}