class Simple {
    public static function main() {
        hello();
        test();
        new Throwing();
    }

    public static function hello() {
        1+1;
    }

    public static function test() {
        throw 'Foo';
    }
}

class Throwing {
    public function new() {
        1+3;
    }
}