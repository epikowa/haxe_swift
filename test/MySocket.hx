package;

class MySocket implements URLSessionDelegate {
    var isConnected:Bool;
    var socket:URLSessionWebSocketTask;

    public function new() {
        // super();

        // var e = new URL("mondomaine");
    }
}

extern class NSObject {
    public function new();
}

extern interface URLSessionDelegate {}

extern class URLSessionWebSocketTask {

}

@:native("Foundation.URL")
@:swiftImport('Foundation')
extern class URL {
    public function new(string: String);
    var absoluteString(default, never):String;
}