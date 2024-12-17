//
//  TableViewController.swift
//  GameBoard
//
//  Created by Mekhak Ghapantsyan on 12/13/24.
//

import UIKit
import ARKit

class TableViewController: UIViewController, ARSessionDelegate, ARSCNViewDelegate, SCNPhysicsContactDelegate {
  
  private var arView: ARSCNView!
  private var accelerometr: AccelerometerManager = AccelerometerManager()
  private var sphere: SCNNode = SCNNode()
  private var areaNode: SCNNode = SCNNode()
  var timer: Timer?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupARView()
    loadScene()
    startTimer()
    accelerometr.startMonitoring()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    stopTimer()
    accelerometr.stopMonitoring()
  }
  
  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  func startTimer() {
    timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(managePlane), userInfo: nil, repeats: true)
  }
  
  private func setupARView() {
    arView = ARSCNView(frame: view.bounds)
    view.insertSubview(arView, at: 0)
    arView.delegate = self
    arView.session.delegate = self
    let configuration = ARWorldTrackingConfiguration()
    arView.session.run(configuration)
    arView.scene.physicsWorld.contactDelegate = self
    arView.autoenablesDefaultLighting = true
  }
  
  private func loadScene() {
    let area = SCNScene(named: "Table.scn")
    guard let areaNode = area?.rootNode.childNode(withName: "Root", recursively: true) else {
      return
    }
    areaNode.position = SCNVector3(0, -0.5, -3)
    self.areaNode = areaNode
    arView.scene.rootNode.addChildNode(self.areaNode)
    guard let sphereNode = areaNode.childNode(withName: "sphere", recursively: true) else {
      return
    }
    sphere = sphereNode
  }
  
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    manageBall()
  }
  
  func manageBall() {
    accelerometr.onRotationChange = { rotation in
      switch rotation {
      case "Rotating Right":
        self.sphere.physicsBody?.applyForce(SCNVector3(0.3, 0, 0), asImpulse: true)
      case "Rotating Left":
        self.sphere.physicsBody?.applyForce(SCNVector3(-0.3, 0, 0), asImpulse: true)
      default:
        break
      }
    }
  }
  
  @objc func managePlane() {
    areaNode.eulerAngles.z = 0.0
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.areaNode.eulerAngles.z = [0.0, 85].randomElement()!
    }
  }
  
}
