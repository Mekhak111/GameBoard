//
//  NumberViewController.swift
//  GameBoard
//
//  Created by Mekhak Ghapantsyan on 12/11/24.
//

import UIKit
import ARKit

class NumberViewController: UIViewController, ARSessionDelegate {
  
  private var arView: ARSCNView!
  private var drawButton: UIButton!
  private let digitMLModel = try? NumberClassifier_1(configuration: .init())
  private var confidenceDict: [String : Float] = ["0":0, "1":0, "2":0, "3":0, "4":0, "5":0, "6":0, "7":0, "8":0, "9":0]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    arView = ARSCNView(frame: self.view.bounds)
    self.view.addSubview(arView)
    arView.session.delegate = self
    arView.delegate = self
    let configuration = ARWorldTrackingConfiguration()
    arView.session.run(configuration)
    createButton()
  }
  
  private func createButton() {
    drawButton = UIButton(type: .system)
    drawButton.setTitle("Draw", for: .normal)
    drawButton.backgroundColor = .systemBlue
    drawButton.setTitleColor(.white, for: .normal)
    drawButton.layer.cornerRadius = 10
    drawButton.clipsToBounds = true
    
    drawButton.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(drawButton)
    
    NSLayoutConstraint.activate([
      drawButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      drawButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
    drawButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    
    let analyzeButton = UIButton(type: .system)
    analyzeButton.setTitle("Analyze", for: .normal)
    analyzeButton.backgroundColor = .systemBlue
    analyzeButton.setTitleColor(.white, for: .normal)
    analyzeButton.layer.cornerRadius = 10
    analyzeButton.clipsToBounds = true
    
    analyzeButton.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(analyzeButton)
    
    NSLayoutConstraint.activate([
      analyzeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      analyzeButton.topAnchor.constraint(equalTo: drawButton.bottomAnchor, constant:20),
    ])
    analyzeButton.addTarget(self, action: #selector(analyzeTapped), for: .touchUpInside)
    
  }

  private func processFrame() {
    arView.isOpaque = false
    let temp = arView.scene.background.contents
    arView.scene.background.contents = UIColor.clear
    let image = arView.snapshot()
    arView.isOpaque = true
    arView.scene.background.contents = temp
    guard let ciiImage = CIImage(image: image) else { return }
    let imageRequestHandler = VNImageRequestHandler(ciImage: ciiImage)
    runCoreMLModel(handler: imageRequestHandler)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      print(self.confidenceDict)
    }
  }
  
  @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    if let error = error {
      print("Error saving screenshot: \(error.localizedDescription)")
    } else {
      print("Screenshot saved successfully!")
    }
  }
  
  private func runCoreMLModel(handler: VNImageRequestHandler) {
    do {
      guard let model = digitMLModel?.model else { return }
      let visionModel = try VNCoreMLModel(for: model)
      let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
        guard let results = request.results as? [VNClassificationObservation] else { return }
        results.forEach { res in
          print(res.identifier, res.confidence)
          self?.confidenceDict[res.identifier] = res.confidence
        }
        if let max = results.max(by:{ $0.confidence < $1.confidence } ) {
          print("Max \(max)")
        }
        
      }
      try handler.perform([request])
    } catch {
      print("Error performing request: \(error)")
    }
  }
  
  @objc func buttonTapped() {
    
  }
  
  @objc func analyzeTapped() {
    processFrame()
  }
  
}

extension NumberViewController: ARSCNViewDelegate {
  
   func renderer(_ renderer: any SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
    
    guard let pointOFView = arView.pointOfView else { return }
    let transform = pointOFView.transform
    let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
    let location = SCNVector3(transform.m41, transform.m42, transform.m43)
    let currentPositionOfCamera = orientation + location
    DispatchQueue.main.async {
      if self.drawButton.isHighlighted {
        let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.01))
        sphereNode.position = currentPositionOfCamera
        sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        self.arView.scene.rootNode.addChildNode(sphereNode)
      } else {
        let pointer = SCNNode(geometry: SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0.01/2) )
        pointer.position = currentPositionOfCamera
        pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        self.arView.scene.rootNode.enumerateChildNodes { (node, _) in
          if node.geometry is SCNBox {
            node.removeFromParentNode()
          }
        }
        self.arView.scene.rootNode.addChildNode(pointer)
      }
    }
  }
  
}
