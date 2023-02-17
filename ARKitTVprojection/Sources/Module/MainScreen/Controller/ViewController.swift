import ARKit
import SceneKit
import UIKit

final class ViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet private var sceneView: ARSCNView!
    var grids = [Grid]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        // Create a new scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    // MARK: - Public Methods
    
    private func addTV(_ hitTestResult: ARHitTestResult) {
        
        let scene = SCNScene(named: "art.scnassets/tv.scn")!
        let tvNode = scene.rootNode.childNode(withName: "tv_node", recursively: true)
        tvNode?.position = SCNVector3(hitTestResult.worldTransform.columns.3.x,
                                      hitTestResult.worldTransform.columns.3.y,
                                      hitTestResult.worldTransform.columns.3.z)
        
        let tvScreenPlaneNode = tvNode?.childNode(withName: "screen", recursively: true)
        let tvScreenPlaneNodeGeometry = tvScreenPlaneNode?.geometry as! SCNPlane
        // setup video
        let tvVideoNode = SKVideoNode(fileNamed: "video.mp4")
        let videoScene = SKScene(size: .init(width: tvScreenPlaneNodeGeometry.width * 1000,
                                             height: tvScreenPlaneNodeGeometry.height * 1000))
        videoScene.addChild(tvVideoNode)
        
        tvVideoNode.position = CGPoint(x: videoScene.size.width / 2,
                                       y: videoScene.size.height / 2)
        tvVideoNode.size = videoScene.size
        
        let tvScreenMaterial = tvScreenPlaneNodeGeometry.materials.first(where: { $0.name == "video" })
        tvScreenMaterial?.diffuse.contents = videoScene
        
        tvVideoNode.play()
        self.sceneView.scene.rootNode.addChildNode(tvNode!)
    }
    
    // MARK: - Action Methods
    
    @objc
    private func tapped(gesture: UITapGestureRecognizer) {
        // Get 2D position of touch event on screen
        let touchPosition = gesture.location(in: sceneView)
        
        // Translate those 2D points to 3D points using hitTest (existing plane)
        let hitTestResults = sceneView.hitTest(touchPosition, types: .existingPlaneUsingExtent)
        
        guard let hitTest = hitTestResults.first else {
            return
        }
        
        addTV(hitTest)
    }
}

// MARK: - ARSCNViewDelegate

 extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let grid = Grid(anchor: planeAnchor)
        self.grids.append(grid)
        node.addChildNode(grid)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let grid = self.grids.filter { grid in
            return grid.anchor.identifier == planeAnchor.identifier
        }.first
        
        guard let foundGrid = grid else {
            return
        }
        
        foundGrid.update(anchor: planeAnchor)
    }
}
