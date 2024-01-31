import haxe.lang.Runtime;
import ContentView;

class IfTest {
    public static function main() {
        var e:String = "";
        var i: Null<Int> = 1;
        var f:String = "";
        f = "";

        var u = f = "bim";
        Runtime.printNative(u);
        if (i > 0) {
            Runtime.printNative('Superieur a 1');
        }
        i = 0;
        if (i > 0) {
            Runtime.printNative('NON');
        } else {
            Runtime.printNative('Inferieur à 1');
        }

        new IfTest().mainn();
    }

    public function new() {}

    public function mainn() {
        var s = if ("bonjour".substring(0, 2) == "o") {
            true;
        } else {
            false;
        };
    }
}

// @:struct
// class IfTestStruct {
//     var monTest:String;
//     var mu(get, null):String;

//     function get_monTest() {
//         return monTest;
//     }

//     function set_monTest(value:String):String {
//         monTest = value;
//         return monTest;
//     }

//     function get_mu() {
//         return "";
//     }
//     var name:String = "plop";
// }