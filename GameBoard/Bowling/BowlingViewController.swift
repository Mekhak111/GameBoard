//
//  BowlingViewController.swift
//  GameBoard
//
//  Created by Narek Aslanyan on 29.11.24.
//

import ARKit
import UIKit

enum Bitmask: Int {

  case ball = 10
  case floor = 20
  case pin = 30
  case finishFloor = 40

}

class BowlingViewController: UIViewController {

  private let viewModel = BowlingViewModel()
  let gestureManager: GestureManager = GestureManager()

  private lazy var sceneView: ARSCNView = {
    let sceneView = ARSCNView()
    sceneView.translatesAutoresizingMaskIntoConstraints = false
//    sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints, .showPhysicsShapes]
    sceneView.delegate = self
    sceneView.session.delegate = self
    sceneView.scene.physicsWorld.contactDelegate = self
    return sceneView
  }()

  private lazy var rightBarButtonItem: UIBarButtonItem = {
    let barButtonItem = UIBarButtonItem()
    let hStack = UIStackView(arrangedSubviews: [addPinsButton, resetButton])
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

  private lazy var resetButton: UIButton = {
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
    button.addTarget(self, action: #selector(reset), for: .touchUpInside)
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
    button.addTarget(self, action: #selector(throwBall), for: .touchUpInside)
    return button
  }()

  private lazy var infoLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .blue
    label.backgroundColor = .white
    return label
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    setupSubViews()
    setupHandPoseDetection()
    viewModel.isBallMovingDidChange = { [weak self] isBallMoving in
      guard let self else { return }
      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        throwBallButton.isEnabled = !isBallMoving
        viewModel.hideShowLaser()
      }
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    viewModel.configuration.frameSemantics = .sceneDepth
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

    sceneView.addSubview(infoLabel)
    infoLabel.bottomAnchor.constraint(equalTo: throwBallButton.topAnchor, constant: 8).isActive =
      true
    infoLabel.leftAnchor.constraint(equalTo: sceneView.leftAnchor).isActive = true
    infoLabel.rightAnchor.constraint(equalTo: sceneView.rightAnchor).isActive = true
  }

  @objc private func reset() {
    viewModel.resetPins()
    viewModel.resetBalls()
  }

  @objc private func createPins() {
    viewModel.createPins()
  }

  @objc private func throwBall() {
    viewModel.throwBall()
  }

  @objc private func giveBall() {
    viewModel.giveBall()
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
      planeAnchor.center.z - 3
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

  private func setupHandPoseDetection() {
    viewModel.handPoseRequest = VNDetectHumanHandPoseRequest()
    viewModel.handPoseRequest.maximumHandCount = 1
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

    if nodeA.physicsBody?.categoryBitMask == Bitmask.ball.rawValue {
      detectBallCollision(first: nodeA, second: nodeB)
    } else if nodeB.physicsBody?.categoryBitMask == Bitmask.ball.rawValue {
      detectBallCollision(first: nodeB, second: nodeA)
    }
  }
  
  func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      viewModel.checkFallenPins()
    }
  }

  private func detectBallCollision(first: SCNNode, second: SCNNode) {
    if second.physicsBody?.categoryBitMask == Bitmask.floor.rawValue {
      first.physicsBody?.applyForce(.init(0, 0, 0.5), asImpulse: true)
    } else if second.physicsBody?.categoryBitMask == Bitmask.pin.rawValue {
      print("\(second.name ?? "") Pin Collision detected...")
    } else if second.physicsBody?.categoryBitMask == Bitmask.finishFloor.rawValue {
      print("Finish floor....")
      viewModel.ballFallingDetected(first)
    }
  }

}

extension BowlingViewController: ARSessionDelegate {

  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    let pixelBuffer = frame.capturedImage
    detectHands(pixelBuffer: pixelBuffer)
  }

  func detectHands(pixelBuffer: CVPixelBuffer) {
    let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])

    do {
      try handler.perform([viewModel.handPoseRequest])
      guard let results = viewModel.handPoseRequest.results else { return }
      for observation in results {
        processHandPose(observation)
      }
    } catch {
      print("Failed to detect hands: \(error)")
    }
  }

  func processHandPose(_ observation: VNHumanHandPoseObservation) {
    handleGesture(observation: observation)
  }

  func handleGesture(observation: VNHumanHandPoseObservation) {
    if gestureManager.detectOpenHandGesture(from: observation) {
      viewModel.canThrowBall = true
      if !viewModel.isBallMoving && viewModel.canThrowBall {
        throwBall()
        viewModel.canThrowBall = false
      }
    } else {
      print("Unknown gesture Detected...")
    }

    // gestureDidUpdate(observation)
  }

  private func gestureDidUpdate(_ observation: VNHumanHandPoseObservation) {
    let gesture = gestureManager.detectGesture(observation: observation)

    switch gesture {
    case .closedHand: print("✊")
    case .openedHand: print("✋")
    case .like: print("👍")
    case .unlike: print("👎")
    case .unknown: print("❓")
    }
    
  }

}
