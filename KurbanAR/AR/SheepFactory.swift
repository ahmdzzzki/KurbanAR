import RealityKit
import UIKit

@MainActor
final class AnimalModelLibrary {
    static let shared = AnimalModelLibrary()
    private var templates: [AnimalSpecies: Entity] = [:]

    func load(_ species: AnimalSpecies) async throws -> Entity {
        if let template = templates[species] { return template.clone(recursive: true) }
        guard let url = Bundle.main.url(forResource: species.rawValue, withExtension: "usdz", subdirectory: "Models") else {
            throw CocoaError(.fileNoSuchFile)
        }
        let entity = try await Entity(contentsOf: url)
        // USD records its source up axis. RealityKit imports it into the Y-up scene.
        let bounds = entity.visualBounds(relativeTo: nil)
        let height = max(bounds.extents.y, 0.001)
        entity.scale *= species.modelHeight / height
        let normalized = entity.visualBounds(relativeTo: nil)
        entity.position -= [normalized.center.x, normalized.min.y, normalized.center.z]
        let wrapper = Entity()
        wrapper.addChild(entity)
        wrapper.name = species.title
        templates[species] = wrapper
        return wrapper.clone(recursive: true)
    }
}

@MainActor
enum HabitatFactory {
    static func make() -> Entity {
        let root = Entity()
        func model(_ mesh: MeshResource, _ color: UIColor, _ position: SIMD3<Float>) -> ModelEntity {
            let e = ModelEntity(mesh: mesh, materials: [SimpleMaterial(color: color, roughness: 0.95, isMetallic: false)])
            e.position = position; root.addChild(e); return e
        }
        let ground = model(.generateCylinder(height: 0.07, radius: 1.65), UIColor(red: 0.28, green: 0.34, blue: 0.23, alpha: 1), [0,-0.045,0])
        ground.name = "Studio plinth"
        // Inset rings make an exhibit rather than a floating object on a flat card.
        _ = model(.generateCylinder(height: 0.035, radius: 1.7), UIColor(red: 0.19, green: 0.25, blue: 0.17, alpha: 1), [0,-0.095,0])
        for i in 0..<58 {
            let angle = Float(i) * 2.39996
            let r = 1.35 + Float(i % 6) * 0.035
            let blade = model(.generateCone(height: 0.10 + Float(i % 5) * 0.018, radius: 0.017), UIColor(red: 0.36, green: 0.43, blue: 0.24, alpha: 1), [cos(angle)*r, 0.035, sin(angle)*r])
            blade.orientation = simd_quatf(angle: 0.2, axis: [1,0,0])
        }
        let light = DirectionalLight()
        light.light.color = UIColor(red: 1, green: 0.89, blue: 0.70, alpha: 1)
        light.light.intensity = 3300
        light.shadow = DirectionalLightComponent.Shadow(maximumDistance: 12, depthBias: 1)
        light.look(at: [0,0.5,0], from: [3,6,4], relativeTo: nil)
        root.addChild(light)
        let fill = PointLight()
        fill.light.intensity = 850
        fill.light.attenuationRadius = 12
        fill.light.color = UIColor(red: 0.75, green: 0.84, blue: 1, alpha: 1)
        fill.position = [-3,3,1]
        root.addChild(fill)
        return root
    }
}
