// swift-tools-version: 5.9
import PackageDescription


let package = Package(
    name: "MyLibrary",
    platforms: [
        .macOS(.v10_15),
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