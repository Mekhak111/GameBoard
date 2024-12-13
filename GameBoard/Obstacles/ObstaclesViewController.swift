//
//  ObstaclesViewController.swift
//  GameBoard
//
//  Created by Mekhak Ghapantsyan on 12/13/24.
//

import UIKit
import ARKit
import SceneKit

class ObstaclesViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
  
  private var arView: ARSCNView!
  private var accelerometr: AccelerometerManager = AccelerometerManager()
  private var sphere: SCNNode = SCNNode()
  private var areaNode: SCNNode = SCNNode()
  private var isHolding: Bool = false
  private var points: Int = 0
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let longPressRecognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(handleLongPress(_:))
    )
    setupARView()
    loadScene()
    accelerometr.startMonitoring()
    self.arView.addGestureRecognizer(longPressRecognizer)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    accelerometr.stopMonitoring()
  }
  
  private func setupARView() {
    arView = ARSCNView(frame: view.bounds)
    view.insertSubview(arView, at: 0)
    arView.delegate = self
    arView.session.delegate = self
    let configuration = ARWorldTrackingConfiguration()
    arView.debugOptions = [.showPhysicsShapes]
    arView.session.run(configuration)
    arView.scene.physicsWorld.contactDelegate = self
    arView.autoenablesDefaultLighting = true
  }
  
  private func loadScene() {
    let area = SCNScene(named: "Area.scn")
    guard let areaNode = area?.rootNode.childNode(withName: "Root", recursively: true) else {
      return
    }
    areaNode.position = SCNVector3(0, -0.5, -3)
    self.areaNode = areaNode
    arView.scene.rootNode.addChildNode(self.areaNode)
    guard let sphereNode = areaNode.childNode(withName: "sphere", recursively: true) else {
      return
    }
    sphere = sphereNode
  }
  
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    accelerometr.onRotationChange = { rotation in
      switch rotation {
      case "Rotating Right":
        self.sphere.physicsBody?.applyForce(SCNVector3(0.1, 0, 0), asImpulse: true)
      case "Rotating Left":
        self.sphere.physicsBody?.applyForce(SCNVector3(-0.1, 0, 0), asImpulse: true)
      case "Rotating back":
        self.sphere.physicsBody?.applyForce(SCNVector3(0, 0, 0.1), asImpulse: true)
      case "Rotating forward":
        self.sphere.physicsBody?.applyForce(SCNVector3(0, 0, -0.1), asImpulse: true)
      default:
        break
      }
    }
  }
  
  @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
    sphere.physicsBody?.applyForce(SCNVector3(0, 5, 0), asImpulse: true)
  }
  
  private func restartGame() {
    arView.scene.rootNode.enumerateChildNodes { node, _ in
      node.removeFromParentNode()
    }
    points = 0
    sphere = SCNNode()
    areaNode = SCNNode()
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.loadScene()
    }
  }
  
}

extension ObstaclesViewController: SCNPhysicsContactDelegate {
  
  func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
    let nodeA = contact.nodeA
    let nodeB = contact.nodeB
    if nodeA.physicsBody?.contactTestBitMask == 2 && nodeB.physicsBody?.contactTestBitMask == 1 {
      nodeB.removeFromParentNode()
    }
    if nodeA.physicsBody?.contactTestBitMask == 3 {
      restartGame()
    }
    if nodeB.physicsBody?.contactTestBitMask == 3 {
      restartGame()
    }
  }
  
}

