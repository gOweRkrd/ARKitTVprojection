import ARKit
import Foundation
import SceneKit

final class Grid: SCNNode {
    
    // MARK: - Properties
    
    var anchor: ARPlaneAnchor
    var planeGeometry: SCNPlane!
    
    // MARK: - Lifecycle
    
    init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func update(anchor: ARPlaneAnchor) {
        planeGeometry.width = CGFloat(anchor.planeExtent.width)
        planeGeometry.height = CGFloat(anchor.planeExtent.height)
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        let planeNode = self.childNodes.first!
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
    }
    
    // MARK: - Private Methods
    
    private func setup() {
        planeGeometry = SCNPlane(width: CGFloat(self.anchor.planeExtent.width), height: CGFloat(self.anchor.planeExtent.height))
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "overlay_grid.png")
        
        planeGeometry.materials = [material]
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
        planeNode.physicsBody?.categoryBitMask = 2
        
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0)

        addChildNode(planeNode)
    }
}
