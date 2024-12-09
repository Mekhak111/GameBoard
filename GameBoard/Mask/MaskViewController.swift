//
//  MaskViewController.swift
//  GameBoard
//
//  Created by Mekhak Ghapantsyan on 12/4/24.
//

import UIKit
import ARKit

class MaskViewController: UIViewController, ARSessionDelegate, ARSCNViewDelegate {
  
  private var arView: ARSCNView!
  private var pickerView: UIPickerView!
  private var selectedMask: String = ""
  private let masks = ["Bone.scn", "Joker.scn", "Devil.scn", "WoodTexture", "Grass", "Rainbow"]
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupARView()
    setupPickerView()
  }
  
  private func setupARView() {
    arView = ARSCNView(frame: view.bounds)
    view.insertSubview(arView, at: 0)
    
    guard ARFaceTrackingConfiguration.isSupported else {
      fatalError("Face tracking is not supported on this device.")
    }
    
    arView.delegate = self
    arView.session.delegate = self
    let configuration = ARFaceTrackingConfiguration()
    arView.session.run(configuration)
  }
  
  private func setupPickerView() {
    pickerView = UIPickerView()
    pickerView.translatesAutoresizingMaskIntoConstraints = false
    pickerView.delegate = self
    pickerView.dataSource = self
    pickerView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.9)
    
    view.addSubview(pickerView)
    
    NSLayoutConstraint.activate([
      pickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      pickerView.heightAnchor.constraint(equalToConstant: 150)
    ])
  }
  
  
  func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    guard anchor is ARFaceAnchor else { return nil }
    
    let faceNode = SCNNode()
    
    if selectedMask.contains(".scn") {
      if let maskScene = SCNScene(named: selectedMask),
         let maskNode = maskScene.rootNode.childNode(withName: "mask", recursively: true) {
        faceNode.addChildNode(maskNode)
      }
    } else if selectedMask != "" {
      let faceGeometry = ARSCNFaceGeometry(device: arView.device!)!
      faceGeometry.firstMaterial?.diffuse.contents = UIImage(named: selectedMask)
      faceGeometry.firstMaterial?.lightingModel = .physicallyBased
      let geometryNode = SCNNode(geometry: faceGeometry)
      faceNode.addChildNode(geometryNode)
    }
    
    return faceNode
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    guard anchor is ARFaceAnchor else { return }
    
    node.childNodes.forEach { $0.removeFromParentNode() }
    if selectedMask.contains(".scn") {
      if let maskScene = SCNScene(named: selectedMask),
         let maskNode = maskScene.rootNode.childNode(withName: "mask", recursively: true) {
        node.addChildNode(maskNode)
      }
    } else if selectedMask != "" {
      let faceGeometry = ARSCNFaceGeometry(device: arView.device!)!
      faceGeometry.firstMaterial?.diffuse.contents = UIImage(named: selectedMask)
      faceGeometry.firstMaterial?.lightingModel = .physicallyBased
      let geometryNode = SCNNode(geometry: faceGeometry)
      node.addChildNode(geometryNode)
    }
  }
  
}

extension MaskViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    masks.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return masks[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    selectedMask = masks[row]
    print("Selected Mask: \(selectedMask)")
  }
  
}
