// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.



import PackageDescription

var exclude: [String] = []

#if os(Linux)
// Linux doesn't support CoreML, and will attempt to import the coreml source directory
exclude.append("coreml")
#endif

let package = Package(
    name: "WhisperPackage",
    platforms: [
        .iOS(.v13), // Set the minimum platform version for iOS to 13.0
        .macOS(.v12),
        .tvOS(.v15),
    ],
    products: [
        .library(name: "WhisperPackage", targets: ["WhisperPackage"])
    ],
    dependencies: [
        .package(url: "https://github.com/AudioKit/AudioKit", from: "5.0.0")
    ],
    targets: [
        .target(name: "WhisperPackage", dependencies: ["whisper_cpp", "AudioKit"]),
        .target(name: "whisper_cpp",
                exclude: exclude,
                cSettings: [
                    .define("GGML_USE_ACCELERATE", .when(platforms: [.macOS, .macCatalyst, .iOS])),
                    .define("WHISPER_USE_COREML", .when(platforms: [.macOS, .macCatalyst, .iOS])),
                    .define("WHISPER_COREML_ALLOW_FALLBACK", .when(platforms: [.macOS, .macCatalyst, .iOS]))
                ]),
        .testTarget(name: "WhisperPackageTests", dependencies: ["WhisperPackage"], resources: [.copy("TestResources/")])
    ],
    cxxLanguageStandard: CXXLanguageStandard.cxx11
)
