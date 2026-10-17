import RealityKit
import UIKit

@MainActor
enum SheepFactory {
    static func make() -> ModelEntity {
        let root = ModelEntity()
        root.name = "Domba ilustratif"
        let wool = UIColor(red: 0.97, green: 0.94, blue: 0.84, alpha: 1)
        let face = UIColor(red: 0.32, green: 0.25, blue: 0.20, alpha: 1)
        let hoof = UIColor(red: 0.19, green: 0.17, blue: 0.14, alpha: 1)
        func ball(_ radius: Float, _ scale: SIMD3<Float>, _ position: SIMD3<Float>, _ color: UIColor) {
            let part = ModelEntity(mesh: .generateSphere(radius: radius), materials: [SimpleMaterial(color: color, roughness: 0.88, isMetallic: false)])
            part.scale = scale
            part.position = position
            root.addChild(part)
        }
        // All geometry is original and procedural. The model faces +Z.
        ball(0.40, [1.05, 0.92, 1.42], [0, 0.72, 0], wool)
        for side: Float in [-1, 1] {
            for z: Float in [-0.30, 0.30] {
                ball(0.10, [0.75, 2.2, 0.75], [side * 0.23, 0.27, z], face)
                ball(0.10, [0.85, 0.65, 0.95], [side * 0.23, 0.065, z + 0.015], hoof)
            }
            ball(0.12, [1.7, 0.42, 0.65], [side * 0.29, 1.03, 0.49], face)
            ball(0.065, [1, 1.15, 0.6], [side * 0.14, 1.06, 0.707], .white)
            ball(0.033, [1, 1, 0.7], [side * 0.14, 1.06, 0.746], hoof)
            ball(0.012, [1, 1, 1], [side * 0.14 - 0.008, 1.071, 0.765], .white)
        }
        ball(0.23, [0.90, 1.20, 0.92], [0, 0.96, 0.53], face)
        ball(0.095, [1.2, 0.7, 0.7], [0, 0.83, 0.72], hoof)
        for x: Float in [-0.16, 0, 0.16] {
            ball(0.12, [1, 0.9, 1], [x, 1.19, 0.49], wool)
        }
        for z: Float in [-0.35, -0.1, 0.15, 0.35] {
            for x: Float in [-0.24, 0, 0.24] {
                ball(0.16, [1, 0.85, 1], [x, 0.99, z], wool)
            }
        }
        ball(0.13, [0.7, 0.9, 1], [0, 0.8, -0.57], wool)
        root.generateCollisionShapes(recursive: true)
        return root
    }
}
