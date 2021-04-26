// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "CollectionView",
    platforms: [
       .iOS(.v12),
    ],
    products: [
        .library(name: "CollectionView", targets: ["CollectionView"]),
    ],
    targets: [
        .target(name: "CollectionView"),
        .testTarget(name: "CollectionViewTests", dependencies: ["CollectionView"]),
    ]
)
