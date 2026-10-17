import SwiftUI
import RealityKit
import ARKit
import Combine

struct SceneFeedback: Equatable {
    enum Phase { case loading, preview, starting, scanning, ready, placed, interrupted, failed }
    let phase: Phase
    let message: String
}

struct AnimalSceneView: UIViewRepresentable {
    var species: AnimalSpecies = .sheep
    var isAR = false
    var resetToken = 0
    var autoRotate = false
    var observation: AnimalObservation? = nil
    var onFeedback: ((SceneFeedback) -> Void)? = nil

    func makeCoordinator() -> Coordinator { Coordinator(owner: self) }
    func makeUIView(context: Context) -> MountedARView {
        let view = MountedARView(frame: .zero, cameraMode: isAR ? .ar : .nonAR, automaticallyConfigureSession: false)
        let c = context.coordinator
        c.view = view
        view.renderOptions.insert(.disableMotionBlur)
        view.renderOptions.insert(.disableDepthOfField)
        if isAR {
            // Explicitly select the live camera feed; do not inherit the studio's solid background.
            view.environment.background = .cameraFeed()
            view.session.delegateQueue = .main
            view.session.delegate = c
            view.onMounted = { [weak c] in c?.startSession() }
            view.addGestureRecognizer(UITapGestureRecognizer(target: c, action: #selector(Coordinator.place(_:))))
        } else {
            view.environment.background = .color(UIColor(red: 0.075, green: 0.13, blue: 0.105, alpha: 1))
            let anchor = AnchorEntity(world: .zero)
            c.previewAnchor = anchor
            anchor.addChild(HabitatFactory.make())
            anchor.addChild(c.camera)
            view.scene.addAnchor(anchor)
            c.updateCamera()
            view.addGestureRecognizer(UIPanGestureRecognizer(target: c, action: #selector(Coordinator.orbit(_:))))
            view.addGestureRecognizer(UIPinchGestureRecognizer(target: c, action: #selector(Coordinator.zoom(_:))))
        }
        c.ticks = view.scene.subscribe(to: SceneEvents.Update.self) { [weak c] event in
            c?.animate(delta: Float(event.deltaTime))
        }
        c.load(species)
        return view
    }
    func updateUIView(_ view: MountedARView, context: Context) {
        let c = context.coordinator
        c.owner = self
        if c.species != species { c.load(species) }
        if c.lastReset != resetToken {
            c.lastReset = resetToken
            if isAR { c.restartSession() } else { c.yaw = 0.75; c.distance = 4.8; c.updateCamera() }
        }
        if c.observation != observation { c.focus(observation) }
    }
    static func dismantleUIView(_ view: MountedARView, coordinator: Coordinator) {
        view.onMounted = nil
        coordinator.loadTask?.cancel()
        coordinator.watchdog?.cancel()
        coordinator.ticks?.cancel()
        view.session.pause()
        view.session.delegate = nil
    }

    @MainActor final class Coordinator: NSObject, ARSessionDelegate {
        var owner: AnimalSceneView
        weak var view: MountedARView?
        var species: AnimalSpecies?
        var observation: AnimalObservation?
        var lastReset = 0
        var previewAnchor: AnchorEntity?
        var placedAnchor: AnchorEntity?
        var animal: Entity?
        var marker: ModelEntity?
        let camera = PerspectiveCamera()
        var yaw: Float = 0.75
        var pitch: Float = 0.19
        var distance: Float = 4.8
        var time: Float = 0
        var previewFrames = 0
        var awaitingPreview = false
        var sessionRunning = false
        var receivedFrame = false
        var surfaceFound = false
        var feedback: SceneFeedback?
        var loadTask: Task<Void, Never>?
        var watchdog: Task<Void, Never>?
        var ticks: Cancellable?
        var gestures: [EntityGestureRecognizer] = []
        init(owner: AnimalSceneView) { self.owner = owner }
        func report(_ phase: SceneFeedback.Phase, _ message: String) {
            let next = SceneFeedback(phase: phase, message: message)
            guard feedback != next else { return }
            feedback = next
            #if DEBUG
            NSLog("[KurbanAR] \(phase): \(message)")
            #endif
            DispatchQueue.main.async { [weak self] in self?.owner.onFeedback?(next) }
        }
        func load(_ next: AnimalSpecies) {
            species = next
            loadTask?.cancel()
            report(.loading, "Menyiapkan model \(next.title.lowercased())…")
            loadTask = Task { @MainActor [weak self] in
                do {
                    let model = try await AnimalModelLibrary.shared.load(next)
                    guard let self, !Task.isCancelled, self.species == next else { return }
                    self.animal?.removeFromParent()
                    self.animal = model
                    if self.owner.isAR {
                        if let anchor = self.placedAnchor { self.attachForAR(model, to: anchor) }
                        else if self.receivedFrame {
                            self.report(self.surfaceFound ? .ready : .scanning, self.surfaceFound
                                ? "Permukaan ditemukan. Ketuk area datar untuk menaruh hewan."
                                : "Kamera aktif. Gerakkan perlahan untuk menemukan meja atau lantai.")
                        }
                    } else {
                        self.previewAnchor?.addChild(model)
                        self.updateCamera()
                        self.previewFrames = 0
                        self.awaitingPreview = true
                    }
                    self.focus(self.owner.observation)

                } catch {
                    guard !Task.isCancelled else { return }
                    self?.report(.failed, "Model belum berhasil dimuat. Coba mulai ulang studio.")
                }
            }
        }
        func updateCamera() {
            camera.camera.fieldOfViewInDegrees = 40
            let height = species?.modelHeight ?? 1.3
            let target = SIMD3<Float>(0,height * 0.44,0)
            camera.look(at: target, from: target + [sin(yaw)*distance, distance*(pitch+0.10), cos(yaw)*distance], relativeTo: nil)
        }
        func animate(delta: Float) {
            time += min(delta,0.1)
            guard !owner.isAR else { return }
            if awaitingPreview && animal != nil {
                previewFrames += 1
                if previewFrames >= 8 {
                    awaitingPreview = false
                    report(.preview, "Geser satu jari untuk berkeliling. Cubit untuk mendekat.")
                }
            }
            animal?.scale.y = 1 + sin(time*1.6)*0.0025
            if owner.autoRotate { yaw += delta*0.12; updateCamera() }
        }
        @objc func orbit(_ gesture: UIPanGestureRecognizer) {
            guard let view else { return }
            let d = gesture.translation(in: view)
            yaw -= Float(d.x)*0.007
            pitch = min(0.7,max(-0.05,pitch+Float(d.y)*0.003))
            gesture.setTranslation(.zero,in: view); updateCamera()
        }
        @objc func zoom(_ gesture: UIPinchGestureRecognizer) {
            distance = min(7,max(2.3,distance/Float(gesture.scale)))
            gesture.scale = 1; updateCamera()
        }
        func focus(_ point: AnimalObservation?) {
            observation = point
            marker?.removeFromParent();marker = nil
            guard let point, let animal else { return }
            let bounds = animal.visualBounds(relativeTo: animal)
            let h = bounds.extents.y
            let position: SIMD3<Float>
            switch point {
            case .head: position = [bounds.max.x*0.80,h*0.80,0.12]
            case .body: position = [0,h*0.58,bounds.max.z+0.05]
            case .feet: position = [bounds.max.x*0.35,h*0.08,bounds.max.z*0.75]
            }
            let dot = ModelEntity(mesh: .generateSphere(radius: 0.035), materials: [UnlitMaterial(color: UIColor(red: 0.92,green: 0.75,blue: 0.40,alpha: 1))])
            dot.position = position
            animal.addChild(dot);marker = dot
            if !owner.isAR { distance = point == .feet ? 3.3 : 4.4; updateCamera() }
        }
        func startSession() {
            guard owner.isAR, !sessionRunning, let view, view.window != nil else { return }
            sessionRunning = true;receivedFrame = false;surfaceFound = false
            report(.starting,"Menghubungkan kamera…")
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal]
            config.environmentTexturing = .automatic
            config.isLightEstimationEnabled = true
            view.session.run(config, options: [.resetTracking,.removeExistingAnchors])
            watchdog?.cancel()
            watchdog = Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(8))
                guard let self, !Task.isCancelled, !self.receivedFrame else { return }
                self.report(.failed,"Kamera belum mengirim gambar. Tekan Mulai ulang AR; periksa izin kamera jika tetap kosong.")
            }
        }
        func restartSession() {
            removePlacement()
            view?.session.pause();sessionRunning = false
            if owner.isAR { startSession() }
        }
        func removePlacement() {
            placedAnchor?.removeFromParent();placedAnchor = nil
            if let view { gestures.forEach { view.removeGestureRecognizer($0) } }
            gestures.removeAll()
        }
        func attachForAR(_ model: Entity, to anchor: AnchorEntity) {
            if let view { gestures.forEach { view.removeGestureRecognizer($0) } }
            let holder = ModelEntity()
            holder.name = "Animal interaction"
            model.scale = .init(repeating: 0.30)
            holder.addChild(model)
            let bounds = holder.visualBounds(relativeTo: holder)
            holder.collision = CollisionComponent(shapes: [.generateBox(size: bounds.extents).offsetBy(translation: bounds.center)])
            anchor.children.removeAll()
            anchor.addChild(holder)
            if let view { gestures = view.installGestures([.rotation,.scale,.translation],for: holder) }
            report(.placed,"\(species?.title ?? "Hewan") sudah hadir. Geser, cubit, atau putar dengan dua jari.")
        }
        @objc func place(_ recognizer: UITapGestureRecognizer) {
            guard placedAnchor == nil, let view, let animal else { return }
            let point = recognizer.location(in: view)
            let results = view.raycast(from: point,allowing: .existingPlaneInfinite,alignment: .horizontal)
            let fallback = results.isEmpty ? view.raycast(from: point,allowing: .estimatedPlane,alignment: .horizontal) : results
            guard let result = fallback.first else {
                report(.scanning,"Arahkan ke meja atau lantai, lalu gerakkan iPhone perlahan.");return
            }
            let anchor = AnchorEntity(world: result.worldTransform)
            view.scene.addAnchor(anchor);placedAnchor = anchor
            attachForAR(animal,to: anchor)
        }
        nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // ARSession is explicitly configured to deliver its delegate on the main queue.
            MainActor.assumeIsolated {
                if !receivedFrame {
                    receivedFrame = true;watchdog?.cancel()
                    report(.scanning,"Kamera aktif. Gerakkan perlahan untuk menemukan meja atau lantai.")
                }
            }
        }
        nonisolated func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            let hasPlane = anchors.contains { $0 is ARPlaneAnchor }
            MainActor.assumeIsolated {
                if hasPlane && placedAnchor == nil {
                    surfaceFound = true
                    report(.ready,"Permukaan ditemukan. Ketuk area datar untuk menaruh hewan.")
                }
            }
        }
        nonisolated func session(_ session: ARSession, didFailWithError error: Error) {
            let message = error.localizedDescription
            MainActor.assumeIsolated { watchdog?.cancel();sessionRunning = false;report(.failed,"AR terhenti: \(message)") }
        }
        nonisolated func sessionWasInterrupted(_ session: ARSession) {
            MainActor.assumeIsolated { report(.interrupted,"Kamera dijeda oleh sistem. AR akan dilanjutkan setelah jeda.") }
        }
        nonisolated func sessionInterruptionEnded(_ session: ARSession) {
            MainActor.assumeIsolated { restartSession() }
        }
    }
}

final class MountedARView: ARView {
    var onMounted: (() -> Void)?
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil { onMounted?() }
    }
}
