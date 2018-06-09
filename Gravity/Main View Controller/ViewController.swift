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
import MobileCoreServices

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, TextInputViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ObjectViewControllerDelegate, VideosViewControllerDelegate {
    
    var state: AppState = AppState() {
        didSet {
            // save state
            do {
                let data = try PropertyListEncoder().encode(self.state)
                try data.write(to: FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("data"))
            } catch {
                print(error)
            }
            setActionButton(forObject: state.currentObject)
        }
    }
    // VIDEO RECORDING
    var maximumRecordingDuration: TimeInterval = 30.0
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?
    private var videoRecorder: RecordAR?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load state
        if let data = try? Data(contentsOf: FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("data")) {
            state = (try? PropertyListDecoder().decode(AppState.self, from: data)) ?? AppState()
        }
        loadObjectMedia()
        // Video recording
        videoRecorder = RecordAR(ARSceneKit: sceneView)
        videoRecorder?.enableAdjsutEnvironmentLighting = true
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
    
    func objectViewController(didSelect object: Object) {
        // Reset current object state variables
        self.currentImage = nil
        self.state.currentObject = object
        switch object.type {
        case .media:
            loadObjectMedia()
            if self.currentImage == nil {
                presentImagePicker()
            }
        default:
            break
        }
    }
    
    func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
        DispatchQueue.main.async {
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            self.dismiss(animated: true, completion: nil)
        }
        guard let mediaType = info[UIImagePickerControllerMediaType] as? String else { return }
        var object = self.state.currentObject
        if mediaType == kUTTypeImage as String {
            object.identifier = UUID()
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
            guard let mediaURL = object.mediaURL else { return }
            do {
                try UIImageJPEGRepresentation(image, 1.0)?.write(to: mediaURL)
                object.type = .media(.image)
                self.state.currentObject = object
                loadObjectMedia()
            } catch {
                print(error)
            }
        }
    }
    
    func setActionButton(forObject object: Object) {
        switch object.type {
        case .text:
            self.actionButton.setImage(#imageLiteral(resourceName: "text"), for: .normal)
        case .shape(let shapeType):
            switch shapeType {
            case .arrow:
                self.actionButton.setImage(#imageLiteral(resourceName: "arrow"), for: .normal)
            case .location:
                self.actionButton.setImage(#imageLiteral(resourceName: "location"), for: .normal)
            }
        case .media(let mediaType):
            switch mediaType {
            case .image:
                self.actionButton.setImage(#imageLiteral(resourceName: "image"), for: .normal)
            }
        }
    }
    
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
    @IBOutlet weak var pinchGestureRecognizer: UIPinchGestureRecognizer!
    @IBOutlet weak var panGestureRecognizerForHorizontalMovement: UIPanGestureRecognizer!
    @IBOutlet weak var panGestureRecognizerForVerticalMovement: UIPanGestureRecognizer!
    
    private var anchors: [ARAnchor] = []
    private var currentRibbonNode: SCNNode?
    private var currentRibbon: SCNRibbon?
    private var currentRibbonMaterial: SCNMaterial?
    private var displayLink: CADisplayLink?
    private var needsHelpInfo: Bool = true
    private var currentNode: SCNNode?
    private var disableViewAutorotation = false
    private var currentImage: UIImage?
    
    func loadObjectMedia() {
        guard let mediaURL = state.currentObject.mediaURL else { return }
        guard let imageData = try? Data(contentsOf: mediaURL) else { return }
        self.currentImage = UIImage(data: imageData)?.fixedOrientation().scaled(to: CGSize(width: 1024, height: 1024), scalingMode: .aspectFit)
    }
    
    func videosViewController(_ viewController: VideosViewController, didSelectVideo url: URL) {
        let previewViewController = VideoPreviewViewController(fileURL: url)
        DispatchQueue.main.async {
            previewViewController.modalPresentationStyle = .overCurrentContext
            viewController.present(previewViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: Actions
    
    @IBAction func actionButtonPressed(sender: UIButton) {
        switch state.currentObject.type {
        case .text(let textType):
            self.presentTextInputViewController()
        case .shape(let shapeType):
            self.presentColorPicker()
        case .media(_):
            self.presentImagePicker()
        }
    }
    
    func presentColorPicker() {
        let popup = PopUp()
        let colorPicker = ColorPickerViewController()
        popup.presentingViewController = self
        popup.presentedViewController = colorPicker
        popup.present(from: CGPoint(x: self.view.frame.midX, y: self.buttonsContainerView.frame.minY - 90), preferredSize: CGSize(width: self.view.bounds.width-10, height: 60.0))
        //self.popUp = popup
        //popup.passthroughViews = [self.navigationBar]
        colorPicker.colors.removeFirst()
        colorPicker.didSelectColor = { color in
            self.dismiss(animated: true, completion: nil)
            self.state.currentObject.backgroundColor = color
        }
    }
    
    @IBAction func undoButtonPressed(sender: UIButton) {
        guard let lastAnchor = self.anchors.last else { return }
        self.sceneView.session.remove(anchor: lastAnchor)
    }
    
    @IBAction func objectButtonPressed(sender: UIButton) {
        let objectViewController = ObjectViewController(recentObjects: self.state.recentObjects)
        objectViewController.delegate = self
        objectViewController.modalPresentationStyle = .overCurrentContext
        self.present(objectViewController, animated: true, completion: nil)
    }
    
    @IBAction func videosButtonPressed(sender: UIButton) {
        let videosViewController = VideosViewController()
        videosViewController.delegate = self
        videosViewController.modalPresentationStyle = .overCurrentContext
        self.present(videosViewController, animated: true, completion: nil)
    }
    
    @IBAction func touchDownRecognized(sender: UILongPressGestureRecognizer) {
        guard sender.location(in: self.view).y < buttonsContainerView.frame.origin.y else { return }
        if sender.state == .began { disableViewAutorotation = true }
        else if sender.state == .ended { disableViewAutorotation = false }
        switch state.currentObject.type {
        case .text(let textType):
            switch textType {
            case .ribbon:
                if sender.state == .began { beginTouchForRibbon() }
                else if sender.state == .ended { endTouchForRibbon() }
            default:
                break
            }
        case .shape(let shapeType):
            if sender.state == .began { beginTouchForShape(shapeType) }
            else if sender.state == .ended { endTouchForShape() }
        case .media(_):
            if sender.state == .began { beginTouchForImage() }
            else if sender.state == .ended { endTouchForImage() }
        }
        addObjectToRecents()
    }
    
    private func addObjectToRecents() {
        let currentObject = state.currentObject
        if currentObject.type == .media(.image) && self.currentImage == nil {
            return
        }
        var recentObjects = state.recentObjects
        if let index = recentObjects.index(of: currentObject) {
            recentObjects.remove(at: index)
        }
        recentObjects.insert(currentObject, at: 0)
        state.recentObjects = recentObjects
    }
    
    @IBAction func panGestureForHorizontalMovementRecognized(sender: UIPanGestureRecognizer) {
        
    }
    
    @IBAction func pinchGestureRecognized(gestureRecognizer: UIPinchGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            guard let anchor = self.anchors.last, let node = sceneView.node(for: anchor) else { return }
            let scale = gestureRecognizer.scale
            node.scale = SCNVector3(scale, scale, scale)
            gestureRecognizer.scale = 1.0
        }
    }
    
    // MARK: Object > Media > Image
    func beginTouchForImage() {
        // Add shape to camera node
        let image = currentImage ?? #imageLiteral(resourceName: "Limit Point Logo")
        var height: CGFloat = 0.25
        var width: CGFloat = 0.25
        if image.size.width > image.size.height {
            height = image.size.height / image.size.width * width
        } else {
            width = image.size.width / image.size.height * height
        }
        let shape = SCNPlane(width: width, height: height)
        let material = SCNMaterial()
        material.diffuse.contents = image
        shape.materials = [material]
        let node = SCNNode(geometry: shape)
        //node.scale = SCNVector3(0.01, 0.01, 0.01)
        let cameraNode = sceneView.pointOfView
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        //parentNode.localRotate(by: SCNQuaternion(angle: .pi, axis: SCNVector3(0, 0, 1)))
        parentNode.position = SCNVector3(0, 0, -0.5)
        cameraNode?.addChildNode(parentNode)
        currentNode = parentNode
    }
    
    func endTouchForImage() {
        guard let transform = getCurrentCameraTransform() else { return }
        let anchor = ARAnchor(transform: transform.toSimd())
        sceneView.session.add(anchor: anchor)
    }
    
    func imageNode() -> SCNNode? {
        guard let shape = currentNode else { return nil }
        shape.removeFromParentNode()
        shape.transform = SCNMatrix4MakeRotation(.pi/2, 0, 0, 1)
        let node = SCNNode()
        node.addChildNode(shape)
        currentNode = nil
        return node
    }
    
    // MARK: Object > Shape > Arrow
    public enum GradientDirection {
        case Up
        case Left
        case UpLeft
        case UpRight
    }
    func gradientImage(size: CGSize, color1: UIColor, color2: UIColor, direction: GradientDirection = .Up) -> CGImage? {
        
        let _color1 = CIColor(color: color1)
        let _color2 = CIColor(color: color2)
        
        let context = CIContext(options: nil)
        let filter = CIFilter(name: "CILinearGradient")
        var startVector: CIVector
        var endVector: CIVector
        
        filter!.setDefaults()
        
        switch direction {
        case .Up:
            startVector = CIVector(x: size.width * 0.5, y: 0)
            endVector = CIVector(x: size.width * 0.5, y: size.height)
        case .Left:
            startVector = CIVector(x: size.width, y: size.height * 0.5)
            endVector = CIVector(x: 0, y: size.height * 0.5)
        case .UpLeft:
            startVector = CIVector(x: size.width, y: 0)
            endVector = CIVector(x: 0, y: size.height)
        case .UpRight:
            startVector = CIVector(x: 0, y: 0)
            endVector = CIVector(x: size.width, y: size.height)
        }
        
        filter!.setValue(startVector, forKey: "inputPoint0")
        filter!.setValue(endVector, forKey: "inputPoint1")
        filter!.setValue(_color1, forKey: "inputColor0")
        filter!.setValue(_color2, forKey: "inputColor1")
        
        let image = context.createCGImage(filter!.outputImage!, from: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        return image
    }
    
    func beginTouchForShape(_ type: ShapeObjectType) {
        // Add shape to camera node
        var shapePath: UIBezierPath = UIBezierPath()
        var extrusionDepth: CGFloat = 0.05
        var scale = 1.0
        switch type {
        case .arrow:
            shapePath = UIBezierPath.arrowShape(width: 0.1, height: 0.2, headWidthRatio: 0.5, headHeightRatio: 0.5)
        case .location:
            shapePath = UIBezierPath.locationSymbol(scale: 0.001)
            shapePath.flatness = 0.00001
            extrusionDepth = 0.01
            scale = 0.6
        }
        let shape = SCNShape(path: shapePath, extrusionDepth: extrusionDepth)
        let material = SCNMaterial()
        let color = self.state.currentObject.backgroundColor ?? UIColor.gravityBlue()
        let color2 = color.modified(withAdditionalHue: 0.67, additionalSaturation: 0.0, additionalBrightness: 0.0)//UIColor.color(33, 209, 89)
        let image = gradientImage(size: .init(width: 1, height: 300), color1: color, color2: color2)
        material.diffuse.contents = image
        shape.materials = [material]
        let node = SCNNode(geometry: shape)
        node.scale = SCNVector3(scale, scale, scale)
        //node.scale = SCNVector3(0.01, 0.01, 0.01)
        let cameraNode = sceneView.pointOfView
        let rotationAnimation = CABasicAnimation(keyPath: "rotation")
        // Animate one complete revolution around the node's Y axis.
        rotationAnimation.toValue = SCNVector4(0, 1, 0, Float.pi*2)
        rotationAnimation.duration = 10.0; // One revolution in ten seconds.
        rotationAnimation.repeatCount = .greatestFiniteMagnitude; // Repeat the animation forever.
        node.addAnimation(rotationAnimation, forKey: nil)
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        parentNode.localRotate(by: SCNQuaternion(angle: .pi, axis: SCNVector3(0, 0, 1)))
        parentNode.position = SCNVector3(0, 0, -0.5)
        cameraNode?.addChildNode(parentNode)
        currentNode = parentNode
    }
    
    func endTouchForShape() {
        guard let transform = getCurrentCameraTransform() else { return }
        let anchor = ARAnchor(transform: transform.toSimd())
        sceneView.session.add(anchor: anchor)
    }
    
    func shapeNode() -> SCNNode? {
        guard let shape = currentNode else { return nil }
        shape.removeFromParentNode()
        shape.transform = SCNMatrix4MakeRotation(-.pi/2, 0, 0, 1)
        let node = SCNNode()
        node.addChildNode(shape)
        currentNode = nil
        return node
    }
    
    // MARK: TEXT: Ribbon
    func beginTouchForRibbon() {
        // Add anchor
        let anchor = ARAnchor(transform: sceneView.scene.rootNode.simdTransform)
        sceneView.session.add(anchor: anchor)
        // Initialize display link
        displayLink = CADisplayLink(target: self, selector: #selector(updateRibbon(displayLink:)))
        displayLink?.preferredFramesPerSecond = 15
        displayLink?.add(to: .current, forMode: .defaultRunLoopMode)
    }
    
    func endTouchForRibbon() {
        currentRibbon = nil
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateRibbon(displayLink: CADisplayLink) {
        //return
        // get current end point
        guard let transform = getCurrentCameraTransform(), let currentRibbon = self.currentRibbon, let currentRibbonNode = self.currentRibbonNode, let currentRibbonMaterial = currentRibbonMaterial else { return }
        currentRibbon.append(rawTransform: transform)
        let geometry = currentRibbon.geometry
        geometry.materials = [currentRibbonMaterial]
        currentRibbonNode.geometry = geometry
    }
    
    
    func createRibbon() -> SCNNode? {
        let fontName = state.currentObject.fontName()
        let text = state.currentObject.getText()
        let fontSize = 400.0 as CGFloat
        let textSprite = SKLabelNode(fontNamed: fontName)
        textSprite.text = text
        textSprite.verticalAlignmentMode = .center
        textSprite.horizontalAlignmentMode = .center
        textSprite.lineBreakMode = .byWordWrapping
        textSprite.numberOfLines = 1
        textSprite.fontSize = fontSize
        textSprite.fontColor = state.currentObject.textColor()
        let textureWidth = textSprite.frame.width + 100
        let textureHeight = textSprite.frame.height + 40
        let materialScene = SKScene(size: CGSize(width: textureWidth, height: textureHeight))
        materialScene.anchorPoint = .init(x: 0.5, y: 0.5)
        textSprite.zRotation = .pi
        textSprite.xScale = -1.0
        let cropNode = SKCropNode()
        let texture = gradientImage(size: materialScene.size, color1: state.currentObject.textColor(), color2: state.currentObject.textColor().modified(withAdditionalHue: 0.67, additionalSaturation: 0, additionalBrightness: 0))
        let textureNode = SKSpriteNode(texture: SKTexture(cgImage: texture!))
        cropNode.addChild(textureNode)
        cropNode.maskNode = textSprite
        //materialScene.addChild(textSprite)
        materialScene.addChild(cropNode)
        materialScene.backgroundColor = state.currentObject.backgroundColor ?? .clear
        materialScene.scaleMode = .aspectFit
        
        // initialize
        guard let transform = getCurrentCameraTransform() else { return nil }
        let ribbon = SCNRibbon(width: fontSize/2000, transforms: [transform])
        ribbon.textureHorizontalScale = Double(2000 / textureWidth)
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
    
    // MARK: TextInputViewControllerDelegate
    func textInput(didFinishWith text: String, font: UIFont, color: UIColor, backgroundColor: UIColor?) {
        self.dismiss(animated: true, completion: nil)
        state.currentObject.text = text
        state.currentObject.textAttributes.fontName = font.fontName
        //state.currentObject.textAttributes?.fontSize = font.pointSize
        state.currentObject.textAttributes.textColor = color
        state.currentObject.backgroundColor = backgroundColor
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
        self.videoRecorder?.record(forDuration: 2.0, { (url) in
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print(error)
            }
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's AR session.
        //sceneView.session.pause()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if disableViewAutorotation {
            return self.interfaceOrientation.isPortrait ? UIInterfaceOrientationMask.portrait : UIInterfaceOrientationMask.landscape
        }
        return UIInterfaceOrientationMask.all
    }

    // MARK: - ARSCNViewDelegate
    
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
                return createRibbon()
            case .nth:
                break
            }
        case .shape(let shapeType):
            return shapeNode()
        case .media(let mediaType):
            switch mediaType {
            case .image:
                return imageNode()
            }
        }
        return nil
    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    }

    /// - Tag: UpdateARContent
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }

    // MARK: - ARSessionDelegate

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        self.anchors += anchors
        guard let frame = session.currentFrame else { return }
        needsHelpInfo = false
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        for anchor in anchors {
            if let index = self.anchors.index(of: anchor) {
                self.anchors.remove(at: index)
            }
        }
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
        func helpStringForMode(_ mode: ObjectType) -> String {
            switch mode {
            case .text(let textObjectType):
                switch textObjectType {
                case .ribbon:
                    return "Drag and move"
                default:
                    return "Tap to add"
                }
            default:
                return ""
            }
        }
        // Update the UI to provide feedback on the state of the AR experience.
        var message: String = ""
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        switch trackingState {
        case .normal:
            if needsHelpInfo {
                message = helpStringForMode(self.state.currentObject.type)
            }
            self.activityIndicator.isHidden = true
        case .notAvailable:
            message = "Tracking unavailable"
        case .limited(.excessiveMotion):
            message = "Move more slowly"
        case .limited(.insufficientFeatures):
            message = "Insufficient lighting or details in scene"
        case .limited(.initializing):
            message = "Move camera left and right"
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""
        }

        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }

    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func presentTextInputViewController() {
        let textInputViewController = TextInputViewController(object: state.currentObject)
        textInputViewController.delegate = self
        textInputViewController.modalPresentationStyle = .overCurrentContext
        self.present(textInputViewController, animated: true, completion: nil)
    }
    
    private func getCurrentCameraTransform(distanceInFront: Float=0.5) -> SCNMatrix4? {
        guard let transform = sceneView.session.currentFrame?.camera.transform else { return nil }
        let mat4 = SCNMatrix4(transform)
        let front = mat4.orientation().inverted().multiplied(by: distanceInFront)
        let t = mat4.translated(front)
        return t
        //let cameraTranslation = cameraNode.worldFront * 0.3
        //let transform = cameraNode.transform//SCNMatrix4Translate(cameraNode.transform, cameraTranslation.x, cameraTranslation.y, cameraTranslation.z)
    }

}
