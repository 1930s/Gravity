/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import UIKit
import SceneKit
import SpriteKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    var state: AppState = AppState()
    var currentObjectType: ObjectType {
        get {
            guard let type = ObjectType(rawValue: (UserDefaultsManager.value(for: .currentObjectType) as? Int) ?? 0) else { return .text(.twoDimensional) }
            return type
        }
        set {
            UserDefaultsManager.set(value: newValue.rawValue, for: .currentObjectType)
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var touchDownGestureRecognizer: UILongPressGestureRecognizer!
    
    private var currentRibbonNode: SCNNode?
    private var currentRibbon: SCNRibbon?
    private var currentRibbonMaterial: SCNMaterial?
    private var displayLink: CADisplayLink?
    var didSet: Bool = false
    
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
    
    @IBAction func tapRecognized(sender: UITapGestureRecognizer) {
        return
        //guard let currentFrame = sceneView.session.currentFrame else { return }
        //var translationMatrix = matrix_identity_float4x4
        //translationMatrix.columns.3.z = -1.0  // Moves the object away from the camera
        //let transform = simd_mul(currentFrame.camera.transform, translationMatrix)
        guard let cameraNode = sceneView.pointOfView else { return }
        let cameraTranslation = cameraNode.simdWorldFront * 1.0
        
        switch sender.state {
        case .began:
            let transform = float4x4(SCNMatrix4Translate(cameraNode.transform, cameraTranslation.x, cameraTranslation.y, cameraTranslation.z))
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        case .changed:
            print(cameraTranslation)
        default:
            break
        }
    }

    // MARK: - View Life Cycle

    /// - Tag: StartARSession
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }

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
        sceneView.showsStatistics = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's AR session.
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    /// - Tag: PlaceARContent
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let textSprite = SKLabelNode(fontNamed: "PressStart2P-Regular")
        textSprite.text = "Hello World"
        textSprite.verticalAlignmentMode = .center
        textSprite.horizontalAlignmentMode = .center
        textSprite.lineBreakMode = .byWordWrapping
        textSprite.numberOfLines = 1
        textSprite.fontSize = 100
        let materialScene = SKScene(size: CGSize(width: 1200, height: 200))
        materialScene.anchorPoint = .init(x: 0.5, y: 0.5)
        textSprite.zRotation = .pi
        textSprite.xScale = -1.0
        textSprite.preferredMaxLayoutWidth = 1000
        materialScene.addChild(textSprite)
        materialScene.backgroundColor = .black
        materialScene.scaleMode = .aspectFit
        
        // initialize
        let ribbon = SCNRibbon(width: 0.2, transforms: [SCNMatrix4Identity])
        //let geometry = SCNPlane(width: 0.2, height: 0.2)//ribbon.geometry
        let geometry = ribbon.geometry
        let material = SCNMaterial()
        //material.diffuse.contentsTransform = SCNMatrix4MakeScale(0.5, 0.5, 1)
        material.isDoubleSided = true
        material.diffuse.contents = materialScene
        material.diffuse.wrapS = .repeat
        material.diffuse.wrapT = .repeat
        geometry.materials = [material]
        //return SCNNode(geometry: geometry)
        
        currentRibbon = ribbon
        currentRibbonMaterial = material
        currentRibbonNode = SCNNode(geometry: geometry)
        
        return currentRibbonNode
    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        
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
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
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
    private func addPositioningCube() {
        
        guard let cameraNode = sceneView.pointOfView else { return }
        
        let cube = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.0)
        let cubeNode = SCNNode(geometry: cube)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.gray
        material.transparency = 0.5
        cube.materials = [material]
        cubeNode.name = "tracker"
        cubeNode.position = SCNVector3Make(0, 0, -1.0)
        
        cameraNode.addChildNode(cubeNode)
        
        print("added tracker node")
        
    }
    
    private func removePositioningCube() {
        if let trackerNode = sceneView.pointOfView?.childNode(withName: "tracker", recursively: false) {
            trackerNode.removeFromParentNode()
        }
    }

    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        removePositioningCube()
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            message = "Tap to Add Cubes"
            // Add positioning cube
            addPositioningCube()
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
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
