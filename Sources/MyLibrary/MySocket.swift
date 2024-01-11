import Foundation
class MySocket : NSObject {
override init() {

self.isConnected = false
super.init()
var e : URL! = Foundation.URL(string :  "mondomaine")

}

var isConnected:Bool! 
var socket:URLSessionWebSocketTask! 
}