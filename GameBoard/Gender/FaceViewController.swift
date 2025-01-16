//
//  FaceViewController.swift
//  GameBoard
//
//  Created by Mekhak Ghapantsyan on 12/11/24.
//

import UIKit
import ARKit
import Vision
import CoreML

class FaceViewController: UIViewController, ARSessionDelegate {
  
  var arView: ARSCNView!
  let textNode = SCNNode(geometry: SCNText(string: "", extrusionDepth: 0.1))
  
  let genderModel = GenderClassifier()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    arView = ARSCNView(frame: self.view.bounds)
    self.view.addSubview(arView)
    arView.session.delegate = self
    startARSession()
    setUpText()
  }
  
  func setUpText() {
    textNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
    textNode.scale = SCNVector3(0.005, 0.005, 0.005)
    arView.scene.rootNode.addChildNode(textNode)
  }
  
  func startARSession() {
    let configuration = ARWorldTrackingConfiguration()
    arView.session.run(configuration)
  }
  
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    processFrame(frame.capturedImage)
  }
  
  func processFrame(_ pixelBuffer: CVPixelBuffer) {
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
    runCoreMLModel(handler: imageRequestHandler)
  }
  
  func runCoreMLModel(handler: VNImageRequestHandler) {
    do {
      let visionModel = try VNCoreMLModel(for: genderModel.model)
      let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
        guard let results = request.results as? [VNClassificationObservation] else { return }
        if let topResult = results.first {
          if topResult.confidence > 0.9  {
            DispatchQueue.main.async {
              let detectedFaceText = "\(topResult.identifier): \(Int(topResult.confidence * 100))%"
              let text = topResult.identifier == "Background" ? "" : detectedFaceText
              self?.displayResult(text)
            }
          }
        }
      }
      
      try handler.perform([request])
    } catch {
      print("Error performing request: \(error)")
    }
  }
  
  func displayResult(_ text: String) {
    if let textGeometry = textNode.geometry as? SCNText {
      textGeometry.string = text
    }
    guard let pointOFView = arView.pointOfView else { return }
    let transform = pointOFView.transform
    let orientation = SCNVector3(-transform.m31 , -transform.m32, -transform.m33 )
    let location = SCNVector3(transform.m41 - 0.3, transform.m42, transform.m43)
    let position = location + orientation
    textNode.position = position
  }
  
}
