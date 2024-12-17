//
//  BodyViewController.swift
//  GameBoard
//
//  Created by Mekhak Ghapantsyan on 12/5/24.
//

import ARKit
import AVFoundation
import UIKit

class BodyViewController: UIViewController, ARSCNViewDelegate {
  
  private var scnView: ARSCNView!
  private var leftHandAudioPlayer: AVAudioPlayer?
  private var rightHandAudioPlayer: AVAudioPlayer?
  private var rightFootAudioPlayer: AVAudioPlayer?
  private var leftFootAudioPlayer: AVAudioPlayer?
  private var isLeftHandUp = false
  private var isRightHandUp = false
  private var isRightFootForward = false
  private var isLeftFootForward = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupSCNView()
    configuration()
    setUpPlayers()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    scnView.session.pause()
  }
  
  private func setupSCNView() {
    scnView = ARSCNView(frame: view.bounds)
    scnView.delegate = self
    scnView.automaticallyUpdatesLighting = true
    view.addSubview(scnView)
  }
  
  private func configuration() {
    let configuration = ARBodyTrackingConfiguration()
    configuration.isAutoFocusEnabled = true
    scnView.session.run(configuration)
  }
  
  private func setUpPlayers() {
    leftHandAudioPlayer = createAudioPlayer(for: "Do")
    rightHandAudioPlayer = createAudioPlayer(for: "Re")
    rightFootAudioPlayer = createAudioPlayer(for: "Mi")
    leftFootAudioPlayer = createAudioPlayer(for: "Fa")
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
    }
  }
  
  private func addSkeleton(for bodyAnchor: ARBodyAnchor, to node: SCNNode) {
    let skeleton = bodyAnchor.skeleton
    for jointName in ARSkeletonDefinition.defaultBody3D.jointNames {
      if let jointTransform = skeleton.modelTransform(
        for: ARSkeleton.JointName(VNRecognizedPointKey(rawValue: jointName))
        ?? ARSkeleton.JointName(rawValue: ""))
      {
        let jointNode = createJointNode()
        jointNode.simdTransform = jointTransform
        jointNode.name = jointName
        if jointName == "root" {
          jointNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        }
        node.addChildNode(jointNode)
      }
    }
  }
  
  private func updateSkeleton(for bodyAnchor: ARBodyAnchor, on node: SCNNode) {
    let skeleton = bodyAnchor.skeleton
    var jointPositions: [String: SCNVector3] = [:]
    for jointNode in node.childNodes {
      if let jointName = jointNode.name,
         let jointTransform = skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: jointName))
      {
        jointNode.simdTransform = jointTransform
        jointPositions[jointName] = jointNode.position
      }
    }
    playSoundsBased(on: jointPositions)
  }
  
  private func detectDistanceofTwoJoints(node1: SCNNode, node2: SCNNode) -> Float {
    let xDiff = node1.position.x - node2.position.x
    let ydiff = node1.position.y - node2.position.y
    let distance = hypot(xDiff, ydiff)
    return distance
  }
  
  private func createJointNode() -> SCNNode {
    let sphere = SCNSphere(radius: 0.01)
    sphere.firstMaterial?.diffuse.contents = UIColor.red
    let node = SCNNode(geometry: sphere)
    return node
  }
  
  private func createAudioPlayer(for filename: String) -> AVAudioPlayer? {
    guard let url = Bundle.main.url(forResource: filename, withExtension: "wav") else {
      return nil
    }
    do {
      let player = try AVAudioPlayer(contentsOf: url)
      player.prepareToPlay()
      return player
    } catch {
      return nil
    }
  }
  
  func playSoundsBased(on jointPositions: [String: SCNVector3]) {
    
    guard let leftHand = jointPositions["left_hand_joint"],
          let leftShoulder = jointPositions["left_shoulder_1_joint"],
          let rightHand = jointPositions["right_hand_joint"],
          let rightShoulder = jointPositions["right_shoulder_1_joint"],
          let rightFoot = jointPositions["right_foot_joint"],
          let leftFoot = jointPositions["left_foot_joint"]
    else { return }
    
    if leftHand.y - leftShoulder.y > 0.2, !isLeftHandUp {
      isLeftHandUp = true
      leftHandAudioPlayer?.play()
    } else if leftHand.y <= leftShoulder.y {
      isLeftHandUp = false
    }
    
    if rightHand.y - rightShoulder.y > 0.2, !isRightHandUp {
      isRightHandUp = true
      rightHandAudioPlayer?.play()
    } else if rightHand.y <= rightShoulder.y {
      isRightHandUp = false
    }
    
    if rightFoot.y - leftFoot.y > 0.2, !isRightFootForward {
      isRightFootForward = true
      rightFootAudioPlayer?.play()
    } else if rightFoot.y <= leftFoot.y {
      isRightFootForward = false
    }
    
    if leftFoot.y - rightFoot.y > 0.2, !isLeftFootForward {
      isLeftFootForward = true
      leftFootAudioPlayer?.play()
    } else if rightFoot.y <= leftFoot.y {
      isLeftFootForward = false
    }
  }
  
}

/*
 Optional("root")
 Optional("left_upLeg_joint")
 Optional("left_leg_joint")
 Optional("left_foot_joint")
 Optional("right_upLeg_joint")
 Optional("right_leg_joint")
 Optional("right_foot_joint")
 Optional("left_shoulder_1_joint")
 Optional("left_forearm_joint")
 Optional("left_hand_joint")
 Optional("neck_1_joint")
 Optional("head_joint")
 Optional("left_eye_joint")
 Optional("right_eye_joint")
 Optional("right_shoulder_1_joint")
 Optional("right_forearm_joint")
 Optional("right_hand_joint")
 */
