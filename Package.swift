// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RideAssistPro",
    defaultLocalization: "vi",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "RideAssistProCore",
            targets: ["RideAssistProCore"]
        )
    ],
    targets: [
        .target(
            name: "RideAssistProCore",
            path: ".",
            exclude: [
                "Tests",
                "Documentation",
                "Widgets",
                "Resources",
                "RideAssistPro.xcodeproj",
                "project.yml"
            ],
            sources: [
                "Core",
                "Models",
                "Services",
                "ViewModels",
                "Views",
                "App"
            ]
        ),
        .testTarget(
            name: "RideAssistProTests",
            dependencies: ["RideAssistProCore"],
            path: "Tests"
        )
    ]
)
