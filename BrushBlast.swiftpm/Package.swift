// swift-tools-version: 5.9

// Brush Blast — an iOS app playground.
// Open this folder in Xcode 15+ (or Swift Playgrounds on iPad/Mac) and press Run.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Brush Blast",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "Brush Blast",
            targets: ["AppModule"],
            bundleIdentifier: "com.example.brushblast",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .sparkle),
            accentColor: .presetColor(.pink),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
