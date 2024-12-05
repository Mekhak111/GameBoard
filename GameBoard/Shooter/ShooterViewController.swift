//
//  ShooterViewController.swift
//  GameBoard
//
//  Created by Mekhak Ghapantsyan on 12/4/24.
//

import UIKit
import ARKit
import Vision

class ShooterViewController: UIViewController, ARSessionDelegate, ARSCNViewDelegate {
  
  var arView: ARSCNView!
  var handPoseRequest: VNDetectHumanHandPoseRequest!
  private var shootsLabel: UILabel!
  
  var gestureManager: GestureManager = GestureManager()
  var shootsCount: Int = 0 {
    didSet {
      DispatchQueue.main.async { [weak self] in
        self?.shootsLabel.text = "Shoots: \( self?.shootsCount )"
      }
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupSceneView()
    setupHandPoseDetection()
    addrandomEggs()
    setupLABEL()
  }
  
  func setupLABEL() {
    shootsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
    shootsLabel.textColor = .white
    shootsLabel.textAlignment = .center
    shootsLabel.font = UIFont.systemFont(ofSize: 20)
    shootsLabel.backgroundColor = .red
    shootsLabel.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(shootsLabel)
    
    NSLayoutConstraint.activate([
      shootsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      shootsLabel.centerYAnchor.constraint(equalTo: view.topAnchor,constant: 100)
    ])
  }

  func setupSceneView() {
    arView = ARSCNView(frame: view.frame)
    arView.autoenablesDefaultLighting = true
    arView.automaticallyUpdatesLighting = true
    view.addSubview(arView)
    
    arView.delegate = self
    arView.session.delegate = self
    arView.debugOptions = [.showFeaturePoints]
    arView.scene.physicsWorld.contactDelegate = self
  }
  
  func setupHandPoseDetection() {
    handPoseRequest = VNDetectHumanHandPoseRequest()
    handPoseRequest.maximumHandCount = 1
    let configuration = ARWorldTrackingConfiguration()
    configuration.frameSemantics = .personSegmentationWithDepth
    configuration.planeDetection = .horizontal
    arView.session.run(configuration)
  }
  
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    let pixelBuffer = frame.capturedImage
    detectHands(pixelBuffer: pixelBuffer)
  }
  
  func detectHands(pixelBuffer: CVPixelBuffer) {
    let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
    
    do {
      try handler.perform([handPoseRequest])
      if let results = handPoseRequest.results {
        for observation in results {
          handlePinchGesture(observation: observation)
        }
      }
    } catch {
      print("Failed to detect hands: \(error)")
    }
  }
  
  func addrandomEggs() {
    for _ in 0..<10 {
      let x = Float.random(in: -40...40)
      let y = Float.random(in: -5...5)
      let z = Float.random(in: -40 ... -30)
      addEgg(x: x, y: y, z: z)
    }
  }
  
  func addEgg(x: Float, y: Float, z: Float) {
    let eggSCene = SCNScene(named: "egg.scn")
    let eggNode = eggSCene?.rootNode.childNode(withName: "egg", recursively: false)
    eggNode?.position = SCNVector3(x: x, y: y, z: z)
    
    let body = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: eggNode!))
    eggNode?.physicsBody = body
    eggNode?.physicsBody?.collisionBitMask = BitMaskCategory.taget.rawValue
    eggNode?.physicsBody?.contactTestBitMask = 2
    arView.scene.rootNode.addChildNode(eggNode!)
  }
  
  func handlePinchGesture(observation: VNHumanHandPoseObservation) {
    if gestureManager.detectPinchWithMiddleGesture(observation: observation) {
      guard let pointOFView = arView.pointOfView else { return }
      let transform = pointOFView.transform
      let orientation = SCNVector3(-transform.m31 , -transform.m32, -transform.m33 )
      let location = SCNVector3(transform.m41, transform.m42, transform.m43)
      let position = location + orientation
      
      let bulletNode = SCNNode(geometry: SCNSphere(radius: 0.3))
      bulletNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
      bulletNode.position = position
      
      let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bulletNode))
      body.isAffectedByGravity = false
      bulletNode.physicsBody = body
      let force:  Float = 40.0
      bulletNode.physicsBody!.applyForce(SCNVector3(orientation.x * force, orientation.y * force, orientation.z * force ), asImpulse: true)
      
      bulletNode.physicsBody?.categoryBitMask = 2
      bulletNode.physicsBody?.contactTestBitMask = 3
      
      arView.scene.rootNode.addChildNode(bulletNode)
    }
  }
  
}

extension ShooterViewController: SCNPhysicsContactDelegate {
  
  func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
    let nodeA = contact.nodeA
    let nodeB = contact.nodeB
    
    print(contact.nodeA)
    if nodeA.physicsBody?.collisionBitMask == BitMaskCategory.taget.rawValue {
      shootsCount += 1
      nodeA.removeFromParentNode()
      nodeB.removeFromParentNode()
    }
    
    if shootsCount == 10 {
      addrandomEggs()
      shootsCount = 0
    }
  }
  
}

enum BitMaskCategory: Int {
  case bullet = 2
  case taget = 3
}

