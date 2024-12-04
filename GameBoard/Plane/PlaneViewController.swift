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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupSceneView()
    setupHandPoseDetection()
    startARSession()
  }
  
  // Setup ARSCNView
  func setupSceneView() {
    sceneView = ARSCNView(frame: view.frame)
    sceneView.autoenablesDefaultLighting = true
    sceneView.automaticallyUpdatesLighting = true
    view.addSubview(sceneView)
    
    sceneView.delegate = self
    sceneView.session.delegate = self
    sceneView.debugOptions = [.showFeaturePoints]
    DispatchQueue.main.async {
      self.createPLane(at: SCNVector3(0, 0, -2))
      let circle = SCNNode(geometry: SCNTorus(ringRadius: 0.6, pipeRadius: 0.1))
      circle.geometry?.firstMaterial?.diffuse.contents = UIColor.red
      circle.position = SCNVector3(0, 0, -3)
      circle.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
      self.sceneView.scene.rootNode.addChildNode(circle)
    }
  }
  
  // Setup Hand Pose Detection with Vision
  func setupHandPoseDetection() {
    handPoseRequest = VNDetectHumanHandPoseRequest()
    handPoseRequest.maximumHandCount = 1
    let configuration = ARWorldTrackingConfiguration()
    configuration.frameSemantics = .personSegmentationWithDepth
    configuration.planeDetection = .horizontal
    sceneView.session.run(configuration)
  }
  
  // Start AR session
  func startARSession() {
    sceneView.session.delegate = self
  }
  
  // Detect hand poses from AR session frames
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
  
  // Process detected hand pose and extract index finger tip position
  func processHandPose(_ observation: VNHumanHandPoseObservation) {
    handlePinchGesture(observation: observation)
  }
  
  // Handle AR session frame updates
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    let pixelBuffer = frame.capturedImage //else { return }
    detectHands(pixelBuffer: pixelBuffer)
  }
  
  // Create a Box in AR
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
  
  // Add AR session delegate method to handle AR updates
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
    if detectPinchGesture(observation: observation) {
      planeNode?.physicsBody?.clearAllForces()
      planeNode?.physicsBody?.applyForce(SCNVector3(0, 0, -4), asImpulse: true)
    } else if detectPinchWithMiddleGesture(observation: observation) {
      planeNode?.physicsBody?.clearAllForces()
      planeNode?.physicsBody?.applyForce(SCNVector3(0, 0, 4), asImpulse: true)
    } else if detectPinchWithRingGesture(observation: observation) {
      planeNode?.physicsBody?.clearAllForces()
      planeNode?.physicsBody?.applyForce(SCNVector3(0, -4, 0), asImpulse: true)
    }  else if detectPinchWithLittleGesture(observation: observation) {
      planeNode?.physicsBody?.clearAllForces()
      planeNode?.physicsBody?.applyForce(SCNVector3(0, 4, 0), asImpulse: true)
    } else {
      planeNode?.physicsBody?.clearAllForces()
    }
  }

}






extension PlaneViewController {
  
  func detectPinchGesture(observation: VNHumanHandPoseObservation) -> Bool {
    guard let thumbTip = try? observation.recognizedPoints(.thumb)[.thumbTip],
          let indexTip = try? observation.recognizedPoints(.indexFinger)[.indexTip] else { return false }
    
    let distance = hypot(thumbTip.x - indexTip.x, thumbTip.y - indexTip.y)
    
    return distance < 0.03
  }
  
  func detectPinchWithMiddleGesture(observation: VNHumanHandPoseObservation) -> Bool {
    guard let thumbTip = try? observation.recognizedPoints(.thumb)[.thumbTip],
          let midTIp = try? observation.recognizedPoints(.middleFinger)[.middleTip] else { return false }
    
    let distance = hypot(thumbTip.x - midTIp.x, thumbTip.y - midTIp.y)
    
    return distance < 0.03
  }
  
  func detectPinchWithRingGesture(observation: VNHumanHandPoseObservation) -> Bool {
    guard let thumbTip = try? observation.recognizedPoints(.thumb)[.thumbTip],
          let ringTIp = try? observation.recognizedPoints(.ringFinger)[.ringTip] else { return false }
    
    let distance = hypot(thumbTip.x - ringTIp.x, thumbTip.y - ringTIp.y)
    
    return distance < 0.03
  }
  
  func detectPinchWithLittleGesture(observation: VNHumanHandPoseObservation) -> Bool {
    guard let thumbTip = try? observation.recognizedPoints(.thumb)[.thumbTip],
          let littleTip = try? observation.recognizedPoints(.littleFinger)[.littleTip] else { return false }
    
    let distance = hypot(thumbTip.x - littleTip.x, thumbTip.y - littleTip.y)
    
    return distance < 0.03
  }
  func detectVictoryGesture(from observation: VNHumanHandPoseObservation) -> Bool {
      do {
          // Get all recognized points for each finger
          let thumb = try observation.recognizedPoints(.thumb)
          let index = try observation.recognizedPoints(.indexFinger)
          let middle = try observation.recognizedPoints(.middleFinger)
          let ring = try observation.recognizedPoints(.ringFinger)
          let pinky = try observation.recognizedPoints(.littleFinger)
          
          // Ensure points are valid and have a confidence > 0.5
        guard let thumbTip = thumb[.thumbTip]?.location, thumb[.thumbTip]?.confidence ?? 0 > 0.5,
                let indexTip = index[.indexTip]?.location, index[.indexTip]?.confidence ?? 0 > 0.5,
                let middleTip = middle[.middleTip]?.location, middle[.middleTip]?.confidence ?? 0 > 0.5,
                let ringTip = ring[.ringTip]?.location, ring[.ringTip]?.confidence ?? 0 > 0.5,
              let pinkyTip = pinky[.littleTip]?.location, pinky[.littleTip]?.confidence ?? 0 > 0.5,
              let indexMCP = index[.indexMCP]?.location, index[.indexMCP]?.confidence ?? 0 > 0.5,
              let middleMCP = middle[.middleMCP]?.location, middle[.middleMCP]?.confidence ?? 0 > 0.5,
              let ringMCP = ring[.ringMCP]?.location, ring[.ringMCP]?.confidence ?? 0 > 0.5,
              let pinkyMCP = pinky[.littleMCP]?.location, pinky[.littleMCP]?.confidence ?? 0 > 0.5 else {
              return false
          }
          
          // Check if index and middle fingers are extended
          let indexExtended = distance(from: indexTip, to: indexMCP) > 0.3
          let middleExtended = distance(from: middleTip, to: middleMCP) > 0.3
          
          // Check if thumb, ring, and pinky fingers are curled
        let thumbCurled = distance(from: thumbTip, to: thumb[.thumbMP]!.location) < 0.2
          let ringCurled = distance(from: ringTip, to: ringMCP) < 0.2
          let pinkyCurled = distance(from: pinkyTip, to: pinkyMCP) < 0.2
          
          // Check if the index and middle tips are separated
          let fingersSeparated = distance(from: indexTip, to: middleTip) > 0.1
          
          // Victory gesture: index and middle fingers extended and separated, others curled
          return indexExtended && middleExtended && fingersSeparated && thumbCurled && ringCurled && pinkyCurled
      } catch {
          print("Error detecting hand pose: \(error)")
          return false
      }
  }
  
  func detectThumbsUpGesture(from observation: VNHumanHandPoseObservation) -> Bool {
      do {
          // Get recognized points for the thumb and all fingers
          let thumb = try observation.recognizedPoints(.thumb)
          let index = try observation.recognizedPoints(.indexFinger)
          let middle = try observation.recognizedPoints(.middleFinger)
          let ring = try observation.recognizedPoints(.ringFinger)
          let pinky = try observation.recognizedPoints(.littleFinger)
          
          // Ensure points are valid and have sufficient confidence
          guard let thumbTip = thumb[.thumbTip]?.location, thumb[.thumbTip]?.confidence ?? 0 > 0.5,
                let thumbMP = thumb[.thumbMP]?.location, thumb[.thumbMP]?.confidence ?? 0 > 0.5,
                let indexTip = index[.indexTip]?.location, index[.indexTip]?.confidence ?? 0 > 0.5,
                let middleTip = middle[.middleTip]?.location, middle[.middleTip]?.confidence ?? 0 > 0.5,
                let ringTip = ring[.ringTip]?.location, ring[.ringTip]?.confidence ?? 0 > 0.5,
                let pinkyTip = pinky[.ringTip]?.location, pinky[.ringTip]?.confidence ?? 0 > 0.5,
                let indexMCP = index[.indexMCP]?.location, index[.indexMCP]?.confidence ?? 0 > 0.5,
                let middleMCP = middle[.middleMCP]?.location, middle[.middleMCP]?.confidence ?? 0 > 0.5,
                let ringMCP = ring[.ringMCP]?.location, ring[.ringMCP]?.confidence ?? 0 > 0.5,
                let pinkyMCP = pinky[.littleMCP]?.location, pinky[.littleMCP]?.confidence ?? 0 > 0.5 else {
              return false
          }
          
          // Check if thumb is extended
          let thumbExtended = distance(from: thumbTip, to: thumbMP) > 0.03
          
          // Check if other fingers are curled
          let indexCurled = distance(from: indexTip, to: indexMCP) < 0.2
          let middleCurled = distance(from: middleTip, to: middleMCP) < 0.2
          let ringCurled = distance(from: ringTip, to: ringMCP) < 0.2
          let pinkyCurled = distance(from: pinkyTip, to: pinkyMCP) < 0.2
          
          // Optional: Check thumb is higher than the other fingers
          let thumbAboveOthers = thumbTip.y < min(indexTip.y, middleTip.y, ringTip.y, pinkyTip.y)
          
          // Thumbs up: thumb extended and above others, other fingers curled
          return thumbExtended && thumbAboveOthers && indexCurled && middleCurled && ringCurled && pinkyCurled
      } catch {
          print("Error detecting hand pose: \(error)")
          return false
      }
  }
  
  func detectOpenHandGesture(from observation: VNHumanHandPoseObservation) -> Bool {
      do {
          // Get recognized points for each finger
          let thumb = try observation.recognizedPoints(.thumb)
          let index = try observation.recognizedPoints(.indexFinger)
          let middle = try observation.recognizedPoints(.middleFinger)
          let ring = try observation.recognizedPoints(.ringFinger)
          let pinky = try observation.recognizedPoints(.littleFinger)
          
          // Ensure points are valid and have sufficient confidence
          guard let thumbTip = thumb[.thumbTip]?.location, thumb[.thumbTip]?.confidence ?? 0 > 0.5,
                let indexTip = index[.indexTip]?.location, index[.indexTip]?.confidence ?? 0 > 0.5,
                let middleTip = middle[.middleTip]?.location, middle[.middleTip]?.confidence ?? 0 > 0.5,
                let ringTip = ring[.ringTip]?.location, ring[.ringTip]?.confidence ?? 0 > 0.5,
                let pinkyTip = pinky[.littleTip]?.location, pinky[.littleTip]?.confidence ?? 0 > 0.5,
                let thumbMP = thumb[.thumbMP]?.location,
                let indexMCP = index[.indexMCP]?.location,
                let middleMCP = middle[.middleMCP]?.location,
                let ringMCP = ring[.ringMCP]?.location,
                let pinkyMCP = pinky[.littleMCP]?.location else {
              return false
          }
          
          // Check if all fingers are extended
          let thumbExtended = distance(from: thumbTip, to: thumbMP) > 0.05
          let indexExtended = distance(from: indexTip, to: indexMCP) > 0.05
          let middleExtended = distance(from: middleTip, to: middleMCP) > 0.05
          let ringExtended = distance(from: ringTip, to: ringMCP) > 0.05
          let pinkyExtended = distance(from: pinkyTip, to: pinkyMCP) > 0.05
          
          // Check if fingers are spread apart
          let thumbToIndex = distance(from: thumbTip, to: indexTip)
          let indexToMiddle = distance(from: indexTip, to: middleTip)
          let middleToRing = distance(from: middleTip, to: ringTip)
          let ringToPinky = distance(from: ringTip, to: pinkyTip)
          
          let fingersSpread = thumbToIndex > 0.05 &&
                              indexToMiddle > 0.05 &&
                              middleToRing > 0.05 &&
                              ringToPinky > 0.05
          
          // Open hand gesture: all fingers extended and spread
          return thumbExtended && indexExtended && middleExtended && ringExtended && pinkyExtended && fingersSpread
      } catch {
          print("Error detecting hand pose: \(error)")
          return false
      }
  }
  
  func detectClosedHandGesture(from observation: VNHumanHandPoseObservation) -> Bool {
      do {
          // Get recognized points for each finger
          let thumb = try observation.recognizedPoints(.thumb)
          let index = try observation.recognizedPoints(.indexFinger)
          let middle = try observation.recognizedPoints(.middleFinger)
          let ring = try observation.recognizedPoints(.ringFinger)
          let pinky = try observation.recognizedPoints(.littleFinger)
          
          // Ensure points are valid and have sufficient confidence
          guard let thumbTip = thumb[.thumbTip]?.location, thumb[.thumbTip]?.confidence ?? 0 > 0.5,
                let indexTip = index[.indexTip]?.location, index[.indexTip]?.confidence ?? 0 > 0.5,
                let middleTip = middle[.middleTip]?.location, middle[.middleTip]?.confidence ?? 0 > 0.5,
                let ringTip = ring[.ringTip]?.location, ring[.ringTip]?.confidence ?? 0 > 0.5,
                let pinkyTip = pinky[.littleTip]?.location, pinky[.littleTip]?.confidence ?? 0 > 0.5,
                let thumbMP = thumb[.thumbMP]?.location,
                let indexMCP = index[.indexMCP]?.location,
                let middleMCP = middle[.middleMCP]?.location,
                let ringMCP = ring[.ringMCP]?.location,
                let pinkyMCP = pinky[.littleMCP]?.location else {
              return false
          }
          
          // Check if all fingers are curled
          let indexCurled = distance(from: indexTip, to: indexMCP) < 0.02
          let middleCurled = distance(from: middleTip, to: middleMCP) < 0.02
          let ringCurled = distance(from: ringTip, to: ringMCP) < 0.02
          let pinkyCurled = distance(from: pinkyTip, to: pinkyMCP) < 0.02
          
          // Check if the thumb is curled or extended (optional)
          let thumbExtended = distance(from: thumbTip, to: thumbMP) > 0.03
          
          // A closed hand gesture: index, middle, ring, and pinky fingers curled, and thumb could be extended or curled
          return indexCurled && middleCurled && ringCurled && pinkyCurled && (thumbExtended || !indexCurled)
      } catch {
          print("Error detecting hand pose: \(error)")
          return false
      }
  }
  
  func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
      return hypot(point1.x - point2.x, point1.y - point2.y)
  }

}
