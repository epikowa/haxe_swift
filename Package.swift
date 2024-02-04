// swift-tools-version: 5.9
import PackageDescription


let package = Package(
    name: "MyLibrary",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        .executable(name: "MyLibrary", targets: ["MyLibrary"])
    ],
    dependencies: [
        
    ],
    targets: [
        .executableTarget(name: "MyLibrary"),
    ]
)