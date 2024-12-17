//
//  PetViewController.swift
//  GameBoard
//
//  Created by Mekhak Ghapantsyan on 12/16/24.
//

import UIKit
import ARKit

class ZooViewController: UIViewController, ARSessionDelegate, ARSCNViewDelegate {
  
  private var arView: ARSCNView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpARView()
  }
  
  private func setUpARView() {
    arView = ARSCNView(frame: view.bounds)
    view.insertSubview(arView, at: 0)
    arView.delegate = self
    arView.session.delegate = self
    
    let configuration = ARWorldTrackingConfiguration()
    if let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) {
      configuration.detectionImages = referenceImages
    }
    
    arView.session.run(configuration)
  }
  
  func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard let imageAnchor = anchor as? ARImageAnchor else { return }
    
    let imageName = imageAnchor.referenceImage.name ?? ""
    
    if let modelNode = getModelNode(for: imageName) {
      modelNode.position = SCNVector3Zero
      modelNode.scale = SCNVector3(0.001, 0.001, 0.001)
      node.addChildNode(modelNode)
    }
  }
  
  private func getModelNode(for imageName: String) -> SCNNode? {
    let scene = SCNScene(named: "\(imageName).scn")
    return scene?.rootNode.childNode(withName: "scene", recursively: true)
  }

}
