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

  private let viewModel = BowlingViewModel()

  private lazy var sceneView: ARSCNView = {
    let sceneView = ARSCNView()
    sceneView.translatesAutoresizingMaskIntoConstraints = false
    sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints, .showPhysicsShapes]
    sceneView.delegate = self
    sceneView.scene.physicsWorld.contactDelegate = self
    return sceneView
  }()

  private lazy var rightBarButtonItem: UIBarButtonItem = {
    let barButtonItem = UIBarButtonItem()
    let hStack = UIStackView(arrangedSubviews: [addPinsButton, resetPinsButton])
    hStack.axis = .horizontal
    hStack.spacing = 10
    barButtonItem.customView = hStack
    return barButtonItem
  }()

  private lazy var addPinsButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.image = UIImage(systemName: "plus.circle.fill")
    config.baseBackgroundColor = .white
    config.baseForegroundColor = .black
    config.cornerStyle = .capsule

    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.configuration = config
    button.heightAnchor.constraint(equalToConstant: 40).isActive = true
    button.widthAnchor.constraint(equalToConstant: 40).isActive = true
    button.addTarget(self, action: #selector(createPins), for: .touchUpInside)
    return button
  }()

  private lazy var resetPinsButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.image = UIImage(systemName: "arrow.clockwise.circle.fill")
    config.baseBackgroundColor = .white
    config.baseForegroundColor = .black
    config.cornerStyle = .capsule

    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.configuration = config
    button.heightAnchor.constraint(equalToConstant: 40).isActive = true
    button.widthAnchor.constraint(equalToConstant: 40).isActive = true
    button.addTarget(self, action: #selector(resetPins), for: .touchUpInside)
    return button
  }()

  private lazy var throwBallButton: UIButton = {
    var config = UIButton.Configuration.filled()
    let image = UIImage()
    config.image = UIImage(systemName: "figure.bowling.circle.fill")
    config.baseBackgroundColor = .white
    config.baseForegroundColor = .black
    config.cornerStyle = .capsule

    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.configuration = config
    button.heightAnchor.constraint(equalToConstant: 80).isActive = true
    button.widthAnchor.constraint(equalToConstant: 80).isActive = true
    button.addTarget(self, action: #selector(addBall), for: .touchUpInside)
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    setupSubViews()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    sceneView.session.run(viewModel.configuration)
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    sceneView.session.pause()
  }

  private func setupSubViews() {
    view.backgroundColor = .red
    navigationItem.title = "Bowling"
    navigationItem.rightBarButtonItem = rightBarButtonItem
    view.addSubview(sceneView)
    sceneView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    sceneView.autoenablesDefaultLighting = true
    viewModel.configuration.planeDetection = .horizontal

    sceneView.addSubview(throwBallButton)
    throwBallButton.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: -40)
      .isActive = true
    throwBallButton.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor, constant: -16)
      .isActive = true
  }

  @objc private func resetPins() {
    viewModel.resetPins()
  }

  @objc private func createPins() {
    let scene = SCNScene(named: "BowlingPin.scn")
    viewModel.createPins(from: scene)
  }

  @objc private func addBall() {
    let scene = SCNScene(named: "Ball.scn")
    guard let ball = scene?.rootNode.childNode(withName: "Ball", recursively: false) else { return }

    guard let pinParent = viewModel.gameFloor.childNode(withName: "PinParent", recursively: true)
    else {
      return
    }
    let gameFloorPosition = pinParent.position
    let scale: Float = 0.05

    ball.scale = .init(x: scale, y: scale, z: scale)
    ball.position = SCNVector3(
      gameFloorPosition.x + Float(randomNumber(firstNum: -2, secondNum: 2)),
      0.2,
      gameFloorPosition.z + 3
    )
    ball.pivot = SCNMatrix4MakeTranslation(
      ball.boundingSphere.center.x / 2,
      ball.boundingSphere.center.y / 2,
      ball.boundingSphere.center.z / 2
    )

    let sphere = SCNSphere(radius: 0.02 * CGFloat(ball.boundingSphere.radius))
    let updatedSphere = SCNNode(geometry: sphere)
    let sphereShape = SCNPhysicsShape(geometry: updatedSphere.geometry!)

    let physicsBody = SCNPhysicsBody(type: .dynamic, shape: sphereShape)
    physicsBody.damping = 0.5
    physicsBody.mass = 8
    physicsBody.applyForce(.init(0, 0, -80), asImpulse: true)
    physicsBody.contactTestBitMask = 30
    physicsBody.categoryBitMask = 10
    ball.physicsBody = physicsBody
    ball.name = "givenBall"
    pinParent.addChildNode(ball)
    giveBall()
  }
  
  @objc private func giveBall() {
    let scene = SCNScene(named: "Ball.scn")
    guard let ball = scene?.rootNode.childNode(withName: "Ball", recursively: false) else { return }

    guard let startNode = viewModel.gameFloor.childNode(withName: "start", recursively: true)
    else {
      return
    }
    
    let ballPosition = startNode.position
    let scale: Float = 0.05

    ball.scale = .init(x: scale, y: scale, z: scale)
    ball.position = SCNVector3(
      ballPosition.x,
      0,
      ballPosition.z
    )
    ball.pivot = SCNMatrix4MakeTranslation(
      ball.boundingSphere.center.x / 2,
      ball.boundingSphere.center.y / 2,
      ball.boundingSphere.center.z / 2
    )

    let sphere = SCNSphere(radius: 0.02 * CGFloat(ball.boundingSphere.radius))
    let updatedSphere = SCNNode(geometry: sphere)
    let sphereShape = SCNPhysicsShape(geometry: updatedSphere.geometry!)

    let physicsBody = SCNPhysicsBody(type: .dynamic, shape: sphereShape)
    physicsBody.damping = 0.5
    physicsBody.mass = 3
    physicsBody.contactTestBitMask = 20
    physicsBody.categoryBitMask = 10
    ball.physicsBody = physicsBody
    ball.name = "givenBall"
    startNode.addChildNode(ball)
  }

  private func randomNumber(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
    CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum)
      + min(firstNum, secondNum)
  }

  private func addPortal(planeAnchor: ARPlaneAnchor) {
    guard let portalScene = SCNScene(named: "Portal.scn"),
      let portalNode = portalScene.rootNode.childNode(
        withName: "Portal",
        recursively: false
      ),
      let bowlingScene = SCNScene(named: "BowlingArena.scn"),
      let bowlingNode = bowlingScene.rootNode.childNode(
        withName: "BowlingArena",
        recursively: false
      )
    else { return }

    bowlingNode.eulerAngles.y = -.pi / 2
    bowlingNode.position = SCNVector3(0, 0.2, -3)
    portalNode.addChildNode(bowlingNode)

    let height = (portalNode.boundingBox.max.y - portalNode.boundingBox.min.y)

    portalNode.position = SCNVector3(
      planeAnchor.center.x,
      (-height / 2) - 0.2,
      planeAnchor.center.z - 3 // + 3
    )

    viewModel.gameFloor = portalNode
    sceneView.scene.rootNode.addChildNode(portalNode)
    addTexture(for: portalNode)
    viewModel.setupFloor()
  }

  private func addTexture(for portalNode: SCNNode) {
    addPlane(nodeName: "roof", portalNode: portalNode)
    addPlane(nodeName: "floor", portalNode: portalNode)
    addWalls(nodeName: "leftSideDoor", portalNode: portalNode)
    addWalls(nodeName: "rightSideDoor", portalNode: portalNode)
    addWalls(nodeName: "backWall", portalNode: portalNode)
    addWalls(nodeName: "leftWall", portalNode: portalNode)
    addWalls(nodeName: "rightWall", portalNode: portalNode)
  }

  private func addPlane(
    nodeName: String,
    portalNode: SCNNode,
    imageName: String = "WoodTexture"
  ) {
    let child = portalNode.childNode(withName: nodeName, recursively: true)
    child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: imageName)
    child?.geometry?.firstMaterial?.isDoubleSided = true
    child?.renderingOrder = 200
  }

  private func addWalls(
    nodeName: String,
    portalNode: SCNNode,
    imageName: String = "wall"
  ) {
    let child = portalNode.childNode(withName: nodeName, recursively: true)
    child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: imageName)
    child?.geometry?.firstMaterial?.isDoubleSided = true
    child?.renderingOrder = 200
    if let mask = child?.childNode(withName: "mask", recursively: false) {
      if nodeName == "leftSideDoor" || nodeName == "rightSideDoor" {
        mask.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "bowlingPhoto")
      } else {
        mask.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "wall")
      }
    }
  }

}

extension BowlingViewController: ARSCNViewDelegate {

  func renderer(
    _ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor
  ) {
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    print("Horizontal plane is detected...")

    if !viewModel.isPlaced {
      addPortal(planeAnchor: planeAnchor)
      viewModel.isPlaced = true
    }
  }

}

extension BowlingViewController: SCNPhysicsContactDelegate {
  
  func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
    let nodeA = contact.nodeA
    let nodeB = contact.nodeB
    
    if nodeA.physicsBody?.categoryBitMask == 10 {
      if nodeB.physicsBody?.categoryBitMask == 20 {
        print("NodeB is \(nodeB.name)")
        nodeA.physicsBody?.applyForce(.init(0, 0, 0.5), asImpulse: true)
      } else if nodeB.physicsBody?.categoryBitMask == 30 {
        print("NodeB is \(nodeB.name)")
        print("Collision detected...")
      }
    } else if nodeB.physicsBody?.categoryBitMask == 10 {
      if nodeA.physicsBody?.categoryBitMask == 20 {
        print("NodeA is \(nodeA.name)")
        nodeB.physicsBody?.applyForce(.init(0, 0, 0.5), asImpulse: true)
      } else if nodeA.physicsBody?.categoryBitMask == 30 {
        print("NodeA is \(nodeA.name)")
        print("Collision detected...")
      }
    }
    
  }
  
}
