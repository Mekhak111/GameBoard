//
//  BowlingViewController.swift
//  GameBoard
//
//  Created by Narek Aslanyan on 29.11.24.
//

import ARKit
import SwiftUI
import UIKit

class BowlingViewController: UIViewController {

  private var gameFloor = SCNNode()
  private var isPlaced: Bool = false
  private var figures = [SCNNode()]
  private let configuration = ARWorldTrackingConfiguration()

  private lazy var sceneView: ARSCNView = {
    let sceneView = ARSCNView()
    sceneView.translatesAutoresizingMaskIntoConstraints = false
    sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
    sceneView.delegate = self
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addBall))
    sceneView.addGestureRecognizer(tapGestureRecognizer)
    return sceneView
  }()

  private lazy var addFiguresButton: UIBarButtonItem = {
    var config = UIButton.Configuration.filled()
    config.title = "Add Figures"
    config.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
    config.baseBackgroundColor = .white
    config.baseForegroundColor = .black
    config.cornerStyle = .capsule

    let barButtonItem = UIBarButtonItem()
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.configuration = config
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    button.heightAnchor.constraint(equalToConstant: 40).isActive = true
    button.addTarget(self, action: #selector(createFigures), for: .touchUpInside)
    barButtonItem.customView = button
    return barButtonItem
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    setupSubViews()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    sceneView.session.run(configuration)
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    sceneView.session.pause()
  }

  private func setupSubViews() {
    view.backgroundColor = .red
    navigationItem.title = "Bowling Game"
    navigationItem.rightBarButtonItem = addFiguresButton
    view.addSubview(sceneView)
    sceneView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    configuration.planeDetection = .horizontal
  }

  private func createFloor(planeAnchor: ARPlaneAnchor) -> SCNNode {
    let floorNode = SCNNode(
      geometry: SCNBox(
        width: CGFloat(planeAnchor.extent.x * 2.0),
        height: 0.01,
        length: CGFloat(planeAnchor.extent.x * 2.0),
        chamferRadius: 0
      )
    )

    let planeMaterial = SCNMaterial()
    planeMaterial.isDoubleSided = true
    planeMaterial.diffuse.contents = UIColor.gray
    floorNode.geometry?.materials = [planeMaterial]

    floorNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
    floorNode.geometry?.firstMaterial?.isDoubleSided = true
    floorNode.position = SCNVector3(
      planeAnchor.center.x,
      planeAnchor.center.y,
      planeAnchor.center.z
    )
    floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
    floorNode.physicsBody?.isAffectedByGravity = false
    //    floorNode.physicsBody?.contactTestBitMask = 1
    return floorNode
  }

  @objc private func createFigures() {
    let scene = SCNScene(named: "BowlingPin.scn")
//    guard let figure = scene?.rootNode.childNode(withName: "figure", recursively: false) else { return }
    
    for index in 1...4 {
      guard let figure = scene?.rootNode.childNode(withName: "figure", recursively: false) else { return }

      figure.scale = .init(x: 0.0005, y: 0.0005, z: 0.0005)
      figure.position = .init(x: 0 + 0.07 * Float(index), y: 0.05 /*0.01*/, z: 0)
    figure.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
      figure.physicsBody?.contactTestBitMask = 2
      figure.physicsBody?.isAffectedByGravity = true
      figure.physicsBody?.friction = 0.5
      figures.append(figure)
      gameFloor.addChildNode(figure)
    
    }
  }

  private func createCube() {
    for index in 1...4 {
      let cube = SCNNode(
        geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.02))
      cube.position = .init(x: 0 + 0.15 * Float(index), y: 0.05, z: 0)
      cube.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
      cube.physicsBody?.contactTestBitMask = 2
      cube.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
      figures.append(cube)
      gameFloor.addChildNode(cube)
    }
  }

  @objc private func addBall() {
    let scene = SCNScene(named: "Ball.scn")
    guard let ball = scene?.rootNode.childNode(withName: "Ball", recursively: false)
    else { return }
    var gameFloorPosition = self.gameFloor.position
    if !figures.isEmpty {
      //      let transform = figures.first?.tra
      gameFloorPosition = figures.randomElement()?.position ?? gameFloorPosition
      for figure in figures {
        print("Figure Position: \(figure.position)")
      }
    }
    ball.scale = .init(x: 0.002, y: 0.002, z: 0.002)
    //    ball.position = SCNVector3(0, 0.5, 0)
    //    ball.position = SCNVector3(
    //      gameFloorPosition.x + Float(randomNumber(firstNum: -0.1, secondNum: 0.1)),
    //      0.5,
    //      gameFloorPosition.z + Float(randomNumber(firstNum: -0.1, secondNum: 0.1))
    //    )
    ball.position = SCNVector3(
      gameFloorPosition.x,
      0.1 + 1,
      gameFloorPosition.z
    )

    ball.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
    ball.physicsBody?.contactTestBitMask = 1
    //    ball.physicsBody?.isAffectedByGravity = true // Cube will fall due to gravity
    //    ball.physicsBody?.friction = 0.5 // Adjust friction for realistic movement
    gameFloor.addChildNode(ball)
  }

  private func randomNumber(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
    CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum)
      + min(firstNum, secondNum)
  }

}

extension BowlingViewController: ARSCNViewDelegate {

  func renderer(
    _ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor
  ) {
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    print("Horizontal plane is detected...")

    if !isPlaced {
      //      let gameFloorParent = SCNNode()
      let gameFloor = createFloor(planeAnchor: planeAnchor)
      //      gameFloorParent.addChildNode(gameFloor)
      self.gameFloor = gameFloor  // gameFloorParent
      sceneView.scene.rootNode.addChildNode(gameFloor)  // gameFloorParent)
      isPlaced = true
    }
  }

  //  func renderer(
  //    _ renderer: any SCNSceneRenderer, didUpdate node: SCNNode,
  //    for anchor: ARAnchor
  //  ) {
  //    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
  //    print("Updating Anchor...")
  //    node.enumerateChildNodes { childNode, _ in
  //      childNode.removeFromParentNode()
  //    }
  //
  //    let gameFloor = createFloor(planeAnchor: planeAnchor)
  //    node.addChildNode(gameFloor)
  //  }

}

extension Int {

  var degreesToRadians: Double { Double(self) * .pi / 180 }

}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
  SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
