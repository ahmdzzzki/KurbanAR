import SwiftUI
import RealityKit
import ARKit

struct AnimalSceneView: UIViewRepresentable {
    let isAR: Bool
    let resetToken: Int
    var onStatus: ((String) -> Void)? = nil

    func makeCoordinator() -> Coordinator { Coordinator(isAR: isAR, onStatus: onStatus) }
    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero, cameraMode: isAR ? .ar : .nonAR, automaticallyConfigureSession: false)
        context.coordinator.view = view
        if !isAR {
            view.environment.background = .color(UIColor(red: 0.87, green: 0.91, blue: 0.83, alpha: 1))
        }
        if isAR {
            view.session.delegate = context.coordinator
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal]
            view.session.run(config)
            let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.place(_:)))
            view.addGestureRecognizer(tap)
        } else {
            let anchor = AnchorEntity(world: .zero)
            let sheep = SheepFactory.make()
            sheep.orientation = simd_quatf(angle: -0.35, axis: [0, 1, 0])
            anchor.addChild(sheep)
            let camera = PerspectiveCamera()
            camera.camera.fieldOfViewInDegrees = 37
            camera.look(at: [0, 0.62, 0], from: [1.65, 1.3, 2.7], relativeTo: nil)
            anchor.addChild(camera)
            let light = DirectionalLight()
            light.light.intensity = 2200
            light.look(at: [0, 0, 0], from: [2, 4, 3], relativeTo: nil)
            anchor.addChild(light)
            view.scene.addAnchor(anchor)
            view.installGestures([.rotation, .scale], for: sheep)
        }
        return view
    }
    func updateUIView(_ uiView: ARView, context: Context) {
        if isAR && context.coordinator.lastReset != resetToken {
            context.coordinator.lastReset = resetToken
            context.coordinator.removeSheep()
        }
    }
    static func dismantleUIView(_ uiView: ARView, coordinator: Coordinator) {
        uiView.session.pause()
        uiView.session.delegate = nil
    }

    @MainActor final class Coordinator: NSObject, ARSessionDelegate {
        weak var view: ARView?
        let isAR: Bool
        let onStatus: ((String) -> Void)?
        var lastReset = 0
        var placedAnchor: AnchorEntity?
        var gestures: [EntityGestureRecognizer] = []
        init(isAR: Bool, onStatus: ((String) -> Void)?) {
            self.isAR = isAR
            self.onStatus = onStatus
        }
        func removeSheep() {
            placedAnchor?.removeFromParent()
            placedAnchor = nil
            if let view { gestures.forEach { view.removeGestureRecognizer($0) } }
            gestures.removeAll()
            onStatus?("Gerakkan kamera perlahan, lalu ketuk permukaan datar.")
        }
        @objc func place(_ recognizer: UITapGestureRecognizer) {
            guard let view, placedAnchor == nil else { return }
            let point = recognizer.location(in: view)
            guard let result = view.raycast(from: point, allowing: .existingPlaneGeometry, alignment: .horizontal).first else {
                onStatus?("Permukaan belum ditemukan. Arahkan kamera ke meja atau lantai yang terang.")
                return
            }
            let anchor = AnchorEntity(world: result.worldTransform)
            let sheep = SheepFactory.make()
            sheep.scale = [0.25, 0.25, 0.25]
            anchor.addChild(sheep)
            view.scene.addAnchor(anchor)
            gestures = view.installGestures([.rotation, .scale], for: sheep)
            placedAnchor = anchor
            onStatus?("Domba sudah hadir! Cubit untuk mengubah ukuran, putar dengan dua jari.")
        }
        nonisolated func session(_ session: ARSession, didFailWithError error: Error) {
            let message = error.localizedDescription
            Task { @MainActor [weak self] in self?.onStatus?("AR terhenti: \(message). Kembali ke preview dan coba lagi.") }
        }
        nonisolated func sessionWasInterrupted(_ session: ARSession) {
            Task { @MainActor [weak self] in self?.onStatus?("Kamera dijeda. Kembali ke preview lalu buka AR lagi.") }
        }
    }
}
