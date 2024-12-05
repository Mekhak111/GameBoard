//
//  BodyViewController.swift
//  GameBoard
//
//  Created by Mekhak Ghapantsyan on 12/5/24.
//

import UIKit
import ARKit

class BodyViewController: UIViewController, ARSCNViewDelegate {
  private var sceneView: ARSCNView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    sceneView = ARSCNView(frame: view.bounds)
    sceneView.delegate = self
    sceneView.automaticallyUpdatesLighting = true
    view.addSubview(sceneView)
    
    let configuration = ARBodyTrackingConfiguration()
    configuration.isAutoFocusEnabled = true
    sceneView.session.run(configuration)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    sceneView.session.pause()
  }
    
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard let bodyAnchor = anchor as? ARBodyAnchor else { return }
    
    DispatchQueue.main.async {
      self.addSkeleton(for: bodyAnchor, to: node)
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    guard let bodyAnchor = anchor as? ARBodyAnchor else { return }
    
    DispatchQueue.main.async {
      self.updateSkeleton(for: bodyAnchor, on: node)
      guard node.childNodes.count > 1 else { return }
      self.detectDistanceofTwoJoints(node1: node.childNodes[1] , node2: node.childNodes[2])
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
  
  private func updateSkeleton(for bodyAnchor: ARBodyAnchor, on node: SCNNode) {
    let skeleton = bodyAnchor.skeleton
    for jointNode in node.childNodes {
      if let jointName = jointNode.name,
         let jointTransform = skeleton.modelTransform(for: ARSkeleton.JointName(VNRecognizedPointKey(rawValue: jointName)) ?? ARSkeleton.JointName(rawValue: "")) {
        jointNode.simdTransform = jointTransform
      }
    }
  }
  
  private func detectDistanceofTwoJoints(node1: SCNNode, node2: SCNNode) -> Float {
    let xDiff = node1.position.x - node2.position.x
    let ydiff = node1.position.y - node2.position.y
    let distance = hypot(xDiff, ydiff)
    print("Distance between \(node1.name) and \(node2.name) is \(distance)")
    return distance
  }
  
  private func createJointNode() -> SCNNode {
    let sphere = SCNSphere(radius: 0.01)
    sphere.firstMaterial?.diffuse.contents = UIColor.red
    let node = SCNNode(geometry: sphere)
    return node
  }
  
}

