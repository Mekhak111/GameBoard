//
//  JengaViewController.swift
//  GameBoard
//
//  Created by Mekhak Ghapantsyan on 12/9/24.
//

import UIKit
import ARKit

class JengaViewController: UIViewController, ARSessionDelegate, ARSCNViewDelegate {
  
  private var sceneView: ARSCNView!
  private var currentSphereNode: SCNNode?
  private var isJengaTowerCreated: Bool = false
  private var chosenNode: SCNNode?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    sceneView = ARSCNView(frame: self.view.bounds)
    sceneView.delegate = self
    sceneView.session.delegate = self
    self.view.addSubview(sceneView)
    let touchGestureRecognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(handleTap)
    )
    sceneView.addGestureRecognizer(touchGestureRecognizer)
    addHandTracking()
    configuration()
    addPlane()
    addControlButtons()
  }
  
  private func addControlButtons() {
    let buttonSize: CGFloat = 50
    let spacing: CGFloat = 20
    let centerX = self.view.bounds.width / 2
    let bottomY = self.view.bounds.height - 200
    
    let leftButton = createButton(imageName: "arrow.left", action: #selector(moveLeft))
    let rightButton = createButton(imageName: "arrow.right", action: #selector(moveRight))
    let upButton = createButton(imageName: "arrow.up", action: #selector(moveUp))
    let downButton = createButton(imageName: "arrow.down", action: #selector(moveDown))
    
    leftButton.frame = CGRect(x: centerX - buttonSize - spacing, y: bottomY, width: buttonSize, height: buttonSize)
    rightButton.frame = CGRect(x: centerX + spacing, y: bottomY, width: buttonSize, height: buttonSize)
    upButton.frame = CGRect(x: centerX - buttonSize / 2, y: bottomY - buttonSize - spacing, width: buttonSize, height: buttonSize)
    downButton.frame = CGRect(x: centerX - buttonSize / 2, y: bottomY + buttonSize + spacing, width: buttonSize, height: buttonSize)
    
    self.view.addSubview(leftButton)
    self.view.addSubview(rightButton)
    self.view.addSubview(upButton)
    self.view.addSubview(downButton)
  }
  
  private func createButton(imageName: String, action: Selector) -> UIButton {
    let button = UIButton(type: .system)
    button.setImage(UIImage(systemName: imageName), for: .normal)
    button.tintColor = .white
    button.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    button.layer.cornerRadius = 25
    button.addTarget(self, action: action, for: .touchUpInside)
    return button
  }
  
  private func configuration() {
    let configuration = ARBodyTrackingConfiguration()
    configuration.isAutoFocusEnabled = true
    sceneView.session.run(configuration)
  }
  
  private func addJenga() {
    let eggSCene = SCNScene(named: "Jenga.scn")
    let eggNode = eggSCene?.rootNode.childNode(withName: "plane", recursively: false)
    eggNode?.position = SCNVector3(x: 0, y: 0, z: -1)
    sceneView.scene.rootNode.addChildNode(eggNode!)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    sceneView.session.pause()
  }
  
  func addHandTracking() {
    guard ARBodyTrackingConfiguration.isSupported else {
      print("Body tracking is not supported on this device.")
      return
    }
    
    let configuration = ARBodyTrackingConfiguration()
    configuration.isLightEstimationEnabled = true
    sceneView.session.run(configuration, options: [])
  }
  
  func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard let bodyAnchor = anchor as? ARBodyAnchor else { return }
    DispatchQueue.main.async {
      self.addSkeleton(for: bodyAnchor, to: node)
    }
  }
  
  private func addSkeleton(for bodyAnchor: ARBodyAnchor, to node: SCNNode) {
    let skeleton = bodyAnchor.skeleton
    for jointName in ARSkeletonDefinition.defaultBody3D.jointNames {
      if let jointTransform = skeleton.modelTransform(for: ARSkeleton.JointName(VNRecognizedPointKey(rawValue: jointName)) ?? ARSkeleton.JointName(rawValue: "")) {
        let jointNode = createJointNode()
        jointNode.simdTransform = jointTransform
        jointNode.name = jointName
        node.addChildNode(jointNode)
      }
    }
  }
  
  private func createJointNode() -> SCNNode {
    let sphere = SCNSphere(radius: 0.05)
    sphere.firstMaterial?.diffuse.contents = UIColor.red
    let node = SCNNode(geometry: sphere)
    node.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: SCNSphere(radius: 0.05)))
    node.physicsBody?.isAffectedByGravity = false
    return node
  }
  
  @objc func handleTap(sender: UITapGestureRecognizer) {
    if isJengaTowerCreated {
      selectBox(sender: sender)
    } else {
      createJengaTower()
    }
  }
  
  func selectBox(sender: UITapGestureRecognizer) {
    let location = sender.location(in: sceneView)
    let hitResults = sceneView.hitTest(location, options: nil)
    guard let hitResult = hitResults.first else { return }
      let tappedNode = hitResult.node
      if tappedNode.name != "plane" {
        chosenNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.random()
        chosenNode = tappedNode
        chosenNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.white
      }
  }
  
  func addPlane() {
    let plane = SCNPlane(width: 2.0, height: 2.0)
    plane.firstMaterial?.diffuse.contents = UIColor.green.withAlphaComponent(1)
    let planeNode = SCNNode(geometry: plane)
    planeNode.position = SCNVector3(0, 0, -1.0)
    planeNode.eulerAngles.x = -.pi / 2
    planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: plane))
    planeNode.name = "plane"
    sceneView.scene.rootNode.addChildNode(planeNode)
  }
  
  func createJengaTower() {
    let boxWidth: CGFloat = 0.2
    let boxHeight: CGFloat = 0.1
    let boxLength: CGFloat = 0.6
    let levels = 10
    
    for level in 0..<levels {
      for i in 0..<3 {
        let box = SCNBox(width: boxWidth, height: boxHeight, length: boxLength, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = UIColor.random()
        
        let boxNode = SCNNode(geometry: box)
        let xOffset =  level % 2 == 0 ? Float(i - 1) * Float(boxWidth) : 0
        let yOffset = Float(level) * Float(boxHeight) + 0.05
        let zOffset = level % 2 == 0 ? -1.0 : Float(i - 1) * Float(boxWidth) - 1
        if level % 2 == 1 {
          boxNode.eulerAngles.y = .pi / 2
        }
        boxNode.position = SCNVector3(xOffset , yOffset, zOffset )
        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: SCNBox(width: boxWidth, height: boxHeight, length: boxLength, chamferRadius: 0)))
        boxNode.physicsBody?.mass = 0.5
        boxNode.physicsBody?.friction = 0.8
        boxNode.physicsBody?.restitution = 0.2
        sceneView.scene.rootNode.addChildNode(boxNode)
      }
    }
    isJengaTowerCreated = true
  }
  
  @objc private func moveLeft() {
    chosenNode?.physicsBody?.applyForce(SCNVector3(-5, 0, 0), asImpulse: true)
  }

  @objc private func moveRight() {
    chosenNode?.physicsBody?.applyForce(SCNVector3(5, 0, 0), asImpulse: true)
  }
  
  @objc private func moveUp() {
    chosenNode?.physicsBody?.applyForce(SCNVector3(0, 0, -5), asImpulse: true)
  }
  
  @objc private func moveDown() {
    chosenNode?.physicsBody?.applyForce(SCNVector3(0, 0, 5), asImpulse: true)
  }
  
}

extension UIColor {
  static func random() -> UIColor {
    return UIColor(
      red:   .random(),
      green: .random(),
      blue:  .random(),
      alpha: 1.0
    )
  }
}

extension CGFloat {
  static func random() -> CGFloat {
    return CGFloat(arc4random()) / CGFloat(UInt32.max)
  }
}
