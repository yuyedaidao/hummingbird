import PackageDescription

let package = Package(
    name: "hummingbird",
    targets: [
        Target(name: "hummingbirdKit", dependencies: []),
        Target(name: "hummingbird", dependencies: ["hummingbirdKit"])
    ],
    dependencies: [
        .Package(url: "https://github.com/jatoben/CommandLine.git","3.0.0-pre1"),
        .Package(url: "https://github.com/onevcat/Rainbow.git", majorVersion: 2),
        .Package(url: "https://github.com/kylef/Spectre.git", majorVersion:0, minor: 7),
        .Package(url: "https://github.com/kylef/PathKit.git", majorVersion: 0, minor: 8)
    ],
    exclude: ["Tests/Fixtures"]
)
