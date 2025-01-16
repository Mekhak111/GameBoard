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
  
  private var arView: ARSCNView!
  private let genderModel = GenderClassifier()
  
  private lazy var textLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 32)
    label.textAlignment = .center
    label.backgroundColor = .white
    return label
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    arView = ARSCNView(frame: self.view.bounds)
    self.view.addSubview(arView)
    arView.session.delegate = self
    startARSession()
    setUpText()
  }
  
  func setUpText() {
    arView.addSubview(textLabel)
    
    NSLayoutConstraint.activate([
      textLabel.leftAnchor.constraint(equalTo: arView.leftAnchor),
      textLabel.rightAnchor.constraint(equalTo: arView.rightAnchor),
      textLabel.centerYAnchor.constraint(equalTo: arView.topAnchor, constant: 120)
    ])
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
    textLabel.text = text
  }
  
}
