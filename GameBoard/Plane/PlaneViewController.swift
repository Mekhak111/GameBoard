//
//  PlaneViewController.swift
//  GameBoard
//
//  Created by Mekhak Ghapantsyan on 12/2/24.
//

import UIKit
import SceneKit
import ARKit
import Vision
import SwiftUI

class PlaneViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
  
  var sceneView: ARSCNView!
  var handPoseRequest: VNDetectHumanHandPoseRequest!
  var planeNode: SCNNode?
  let gestureManager: GestureManager = GestureManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupSceneView()
    setupHandPoseDetection()
    startARSession()
  }
  
  func setupSceneView() {
    sceneView = ARSCNView(frame: view.frame)
    sceneView.autoenablesDefaultLighting = true
    sceneView.automaticallyUpdatesLighting = true
    view.addSubview(sceneView)
    
    sceneView.delegate = self
    sceneView.session.delegate = self
    DispatchQueue.main.async {
      self.createPLane(at: SCNVector3(0, 0, -2))
    }
  }
  
  func setupHandPoseDetection() {
    handPoseRequest = VNDetectHumanHandPoseRequest()
    handPoseRequest.maximumHandCount = 1
    let configuration = ARWorldTrackingConfiguration()
    configuration.frameSemantics = .personSegmentationWithDepth
    configuration.planeDetection = .horizontal
    sceneView.session.run(configuration)
  }
  
  func startARSession() {
    sceneView.session.delegate = self
  }
  
  func detectHands(pixelBuffer: CVPixelBuffer) {
    let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
    
    do {
      try handler.perform([handPoseRequest])
      if let results = handPoseRequest.results {
        for observation in results {
          processHandPose(observation)
        }
      } else {
        planeNode?.physicsBody?.clearAllForces()
      }
    } catch {
      print("Failed to detect hands: \(error)")
    }
  }
  
  func processHandPose(_ observation: VNHumanHandPoseObservation) {
    handlePinchGesture(observation: observation)
  }
  
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    let pixelBuffer = frame.capturedImage //else { return }
    detectHands(pixelBuffer: pixelBuffer)
  }
  
  func createPLane(at position: SCNVector3) {
    let scene = SCNScene(named: "Plane.scn")
    guard let plane = scene?.rootNode.childNode(withName: "Plane", recursively: false) else { return }
    plane.position = position
    
    plane.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: plane.geometry ?? SCNGeometry(), options: nil))
    plane.physicsBody?.mass = 10.0
    plane.physicsBody?.isAffectedByGravity = false
    self.planeNode = plane
    
    sceneView.scene.rootNode.addChildNode(planeNode!)
  }
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    print("AR session failed with error: \(error.localizedDescription)")
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    print("AR session was interrupted")
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    print("AR session interruption ended")
    startARSession()
  }
  
  func handlePinchGesture(observation: VNHumanHandPoseObservation) {
    if gestureManager.detectPinchGesture(observation: observation) {
      planeNode?.physicsBody?.clearAllForces()
      planeNode?.physicsBody?.applyForce(SCNVector3(0, 0, -4), asImpulse: true)
    } else if gestureManager.detectPinchWithMiddleGesture(observation: observation) {
      planeNode?.physicsBody?.clearAllForces()
      planeNode?.physicsBody?.applyForce(SCNVector3(0, 0, 4), asImpulse: true)
    } else if gestureManager.detectPinchWithRingGesture(observation: observation) {
      planeNode?.physicsBody?.clearAllForces()
      planeNode?.physicsBody?.applyForce(SCNVector3(0, -4, 0), asImpulse: true)
    }  else if gestureManager.detectPinchWithLittleGesture(observation: observation) {
      planeNode?.physicsBody?.clearAllForces()
      planeNode?.physicsBody?.applyForce(SCNVector3(0, 4, 0), asImpulse: true)
    } else {
      planeNode?.physicsBody?.clearAllForces()
    }
  }
  
}
