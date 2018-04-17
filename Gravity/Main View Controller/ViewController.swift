/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import UIKit
import SceneKit
import SpriteKit
import ARKit
import ARVideoKit
import AVKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, TextInputViewControllerDelegate {
    
    var state: AppState = AppState() {
        didSet {
            
        }
    }
    var maximumRecordingDuration: TimeInterval = 30.0
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?
    private var videoRecorder: RecordAR?
    
    // MARK: - IBOutlets
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var buttonsContainerView: UIView!
    @IBOutlet weak var buttonsVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var recordButton: RecordButton!
    @IBOutlet weak var objectButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var activityIndicator: InstagramActivityIndicator!
    @IBOutlet weak var touchDownGestureRecognizer: UILongPressGestureRecognizer!
    
    private var anchors: [ARAnchor] = []
    private var currentRibbonNode: SCNNode?
    private var currentRibbon: SCNRibbon?
    private var currentRibbonMaterial: SCNMaterial?
    private var displayLink: CADisplayLink?
    var didSet: Bool = false
    private var needsHelpInfo: Bool = true
    
    @IBAction func actionButtonPressed(sender: UIButton) {
        switch state.currentObject.type {
        case .text(let textType):
            self.presentTextInputViewController()
        }
    }
    
    @IBAction func undoButtonPressed(sender: UIButton) {
        guard let lastAnchor = anchors.last else { return }
        sceneView.session.remove(anchor: lastAnchor)
    }
    
    private func presentTextInputViewController() {
        let textInputViewController = TextInputViewController(object: state.currentObject)
        textInputViewController.delegate = self
        textInputViewController.modalPresentationStyle = .overCurrentContext
        self.present(textInputViewController, animated: true, completion: nil)
    }
    
    func textInput(didFinishWith text: String, font: UIFont, color: UIColor, backgroundColor: UIColor?) {
        self.dismiss(animated: true, completion: nil)
        state.currentObject.text = text
        state.currentObject.setFontName(font.fontName)
        //state.currentObject.textAttributes?.fontSize = font.pointSize
        //state.currentObject.textAttributes?.textColor = color
        //state.currentObject.backgroundColor = backgroundColor
    }
    
    @IBAction func touchDownRecognized(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            // Add anchor
            guard let cameraNode = sceneView.pointOfView else { return }
            let cameraTranslation = cameraNode.simdWorldFront * 1.0
            let transform = float4x4(SCNMatrix4Translate(cameraNode.transform, cameraTranslation.x, cameraTranslation.y, cameraTranslation.z))
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
            // Initialize display link
            displayLink = CADisplayLink(target: self, selector: #selector(updateRibbon(displayLink:)))
            displayLink?.preferredFramesPerSecond = 15
            displayLink?.add(to: .current, forMode: .defaultRunLoopMode)
        case .ended:
            currentRibbon = nil
            displayLink?.invalidate()
            displayLink = nil
        default:
            break
        }
    }
    
    @objc private func updateRibbon(displayLink: CADisplayLink) {
        //return
        // get current end point
        guard didSet == false else { return }
        guard let cameraNode = sceneView.pointOfView, let currentRibbonNode = currentRibbonNode, let currentRibbon = currentRibbon, let currentRibbonMaterial = currentRibbonMaterial else { return }
        let cameraTranslation = cameraNode.worldFront
        let transform = SCNMatrix4Translate(cameraNode.transform, cameraTranslation.x, cameraTranslation.y, cameraTranslation.z)
        // convert transform to ribbon coordinates
        let convertedTransform = currentRibbonNode.convertTransform(transform, from: nil)
        currentRibbon.append(transform: convertedTransform)
        let geometry = currentRibbon.geometry
        geometry.materials = [currentRibbonMaterial]
        currentRibbonNode.geometry = geometry
        
        //didSet = true
    }

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load state
        if let data = try? Data(contentsOf: FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("data")) {
            state = (try? PropertyListDecoder().decode(AppState.self, from: data)) ?? AppState()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil, queue: nil) { (notification) in
            do {
                let data = try PropertyListEncoder().encode(self.state)
                try data.write(to: FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("data"))
            } catch {
                print(error)
            }
        }
        // Video recording
        videoRecorder = RecordAR(ARSceneKit: sceneView)
        // Set up UI
        let shadowView = self.buttonsContainerView
        shadowView?.addShadowMotionEffects(intensity: 5.0, radius: 6.0)
        shadowView?.addParallaxMotionEffects(intensity: 10.0)
        let cornerRadiusView = self.buttonsVisualEffectView
        cornerRadiusView?.layer.cornerRadius = 14.0
        cornerRadiusView?.layer.masksToBounds = true
        recordButton.recordingStateDidChange = { recordButton in
            if recordButton.buttonState == .Recording {
                self.startRecording()
            } else {
                self.stopRecording()
            }
        }
    }
    
    private func startRecording() {
        self.videoRecorder?.record()
        self.recordingStartTime = Date()
        self.recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
            guard let startTime = self.recordingStartTime else { return }
            let duration = Date().timeIntervalSince(startTime)
            if duration >= self.maximumRecordingDuration {
                self.recordButton.buttonState = .Idle
            } else {
                self.recordButton.setProgress(newProgress: CGFloat(duration / self.maximumRecordingDuration))
            }
        })
    }
    
    private func stopRecording() {
        self.videoRecorder?.stop({ (url) in
            self.recordingTimer?.invalidate()
            self.recordingStartTime = nil
            self.recordingTimer = nil
            // send to preview
            let previewViewController = VideoPreviewViewController(fileURL: url)
            DispatchQueue.main.async {
                previewViewController.modalPresentationStyle = .overCurrentContext
                self.present(previewViewController, animated: true, completion: nil)
            }
        })
    }

    /// - Tag: StartARSession
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start the view's AR session with a configuration that uses the rear camera,
        // device position and orientation tracking, and plane detection.
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        sceneView.session.run(configuration)
        sceneView.autoenablesDefaultLighting = true
        
        // Set a delegate to track the number of plane anchors for providing UI feedback.
        sceneView.session.delegate = self
        
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Show debug UI to view performance metrics (e.g. frames per second).
        //sceneView.showsStatistics = true
        self.videoRecorder?.record(forDuration: 3.0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's AR session.
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    func createRibbon(for anchor: ARAnchor) -> SCNNode? {
        let fontName = state.currentObject.fontName()
        let text = state.currentObject.getText()
        let fontSize = 200.0 as CGFloat
        let textSprite = SKLabelNode(fontNamed: fontName)
        textSprite.text = text
        textSprite.verticalAlignmentMode = .center
        textSprite.horizontalAlignmentMode = .center
        textSprite.lineBreakMode = .byWordWrapping
        textSprite.numberOfLines = 1
        textSprite.fontSize = fontSize
        let textureWidth = textSprite.frame.width * 1.1
        let textureHeight = textSprite.frame.height * 1.1
        let materialScene = SKScene(size: CGSize(width: textureWidth, height: textureHeight))
        materialScene.anchorPoint = .init(x: 0.5, y: 0.5)
        textSprite.zRotation = .pi
        textSprite.xScale = -1.0
        materialScene.addChild(textSprite)
        materialScene.backgroundColor = state.currentObject.backgroundColor ?? .clear
        materialScene.scaleMode = .aspectFit
        
        // initialize
        let ribbon = SCNRibbon(width: fontSize/1000, transforms: [SCNMatrix4Identity])
        let geometry = ribbon.geometry
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = materialScene
        material.diffuse.wrapS = .repeat
        material.diffuse.wrapT = .repeat
        geometry.materials = [material]
        
        currentRibbon = ribbon
        currentRibbonMaterial = material
        currentRibbonNode = SCNNode(geometry: geometry)
        
        return currentRibbonNode
    }
    
    /// - Tag: PlaceARContent
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        switch state.currentObject.type {
        case .text(let textType):
            switch textType {
            case .twoDimensional:
                break
            case .threeDimensional:
                break
            case .ribbon:
                return createRibbon(for: anchor)
            case .nth:
                break
            }
        }
        return nil
    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("did add node")
        
        //cubeNode.simdTransform = anchor.transform
        //node.addChildNode(cubeNode)
        
        return
        
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        print(planeAnchor)

        // Create a SceneKit plane to visualize the plane anchor using its position and extent.
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        // `SCNPlane` is vertically oriented in its local coordinate space, so
        // rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
        planeNode.eulerAngles.x = -.pi / 2
        
        // Make the plane visualization semitransparent to clearly show real-world placement.
        planeNode.opacity = 0.25
        
        // Add the plane visualization to the ARKit-managed node so that it tracks
        // changes in the plane anchor as plane estimation continues.
        node.addChildNode(planeNode)
    }

    /// - Tag: UpdateARContent
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        //return
        
        // Update content only for plane anchors and nodes matching the setup created in `renderer(_:didAdd:for:)`.
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // Plane estimation may shift the center of a plane relative to its anchor's transform.
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        // Plane estimation may also extend planes, or remove one plane to merge its extent into another.
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }

    // MARK: - ARSessionDelegate

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        needsHelpInfo = false
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
        self.anchors += anchors
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }

    // MARK: - ARSessionObserver

    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
        resetTracking()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        resetTracking()
    }

    // MARK: - Private methods
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        var message: String = ""
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        switch trackingState {
        case .normal:
            if needsHelpInfo {
                message = "Drag and move."
            }
            self.activityIndicator.isHidden = true
        case .notAvailable:
            message = "Tracking unavailable."
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
        case .limited(.initializing):
            message = "Move camera left and right."
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""
        }

        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }

    private func resetTracking() {
        //let configuration = ARWorldTrackingConfiguration()
        //configuration.planeDetection = .horizontal
        //sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}
