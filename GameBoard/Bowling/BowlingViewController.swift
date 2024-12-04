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

  enum BitMaskCategory: Int {

    case ball = 2
    case figure = 3

  }

  var target: SCNNode?
  private var gameFloor = SCNNode()
  private var isPlaced: Bool = false
  private var figures = [SCNNode()]
  private var isArenaAdded: Bool = false
  private let configuration = ARWorldTrackingConfiguration()

  private lazy var sceneView: ARSCNView = {
    let sceneView = ARSCNView()
    sceneView.translatesAutoresizingMaskIntoConstraints = false
    sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints, .showPhysicsShapes]
    sceneView.delegate = self
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
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
    //    button.addTarget(self, action: #selector(createCube), for: .touchUpInside)
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
    sceneView.autoenablesDefaultLighting = true
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

    floorNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
    floorNode.geometry?.firstMaterial?.isDoubleSided = true
    floorNode.position = SCNVector3(
      planeAnchor.center.x,
      planeAnchor.center.y - 0.005,
      planeAnchor.center.z
    )

    let shape = SCNPhysicsShape(geometry: floorNode.geometry!)
    floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
    floorNode.physicsBody?.isAffectedByGravity = false
    return floorNode
  }

  @objc private func createFigures() {
//  private func createFigures(in node: SCNNode) {
//    createPlaneForGameFloor()
    setupFigures()
    let scene = SCNScene(named: "BowlingPin.scn")
    guard let figure = scene?.rootNode.childNode(withName: "figure", recursively: false)
    else { return }
    figures.removeAll()
    for index in 1...10 {
      let pin = figure.clone()
      let scale: Float = 0.001
      let position = getBowlingPinPosition(index: index)
      let relativePosition = SCNVector3(x: 0, y: 0, z: 3)
      pin.scale = .init(x: scale, y: scale, z: scale)

      let width = (pin.boundingBox.max.x - pin.boundingBox.min.x) * scale
      let height = (pin.boundingBox.max.y - pin.boundingBox.min.y) * scale
      pin.position = .init(
        x: Float(position.x) + relativePosition.x,
        y: height + 0.5,
        z: Float(position.z) + relativePosition.z
      )

      let (minBound, maxBound) = pin.boundingBox
      let centerOffset = SCNVector3(
        (minBound.x + maxBound.x) / 2.0,
        (minBound.y + maxBound.y) / 2.0,
        (minBound.z + maxBound.z) / 2.0
      )
      pin.pivot = SCNMatrix4MakeTranslation(centerOffset.x, centerOffset.y, centerOffset.z)

      let cone = SCNCone(
        topRadius: CGFloat(width / 2),
        bottomRadius: CGFloat(width / 2),
        height: CGFloat(height)
      )
      
      let updatedPin = SCNNode(geometry: cone)
      let coneShape = SCNPhysicsShape(geometry: updatedPin.geometry!)
      let physicsBody = SCNPhysicsBody(type: .dynamic, shape: coneShape)
            physicsBody.damping = 0.5
      pin.physicsBody = physicsBody
      
      figures.append(pin)
//      node.addChildNode(pin)
//      gameFloor.addChildNode(pin)
    }
    
    figures.forEach { pin in
      gameFloor.addChildNode(pin)
    }
  }
  
  private func createPlaneForGameFloor() {
    let floorNode = SCNNode(
      geometry: SCNBox(
        width: 2.0,
        height: 0.01,
        length: 6.0,
        chamferRadius: 0
      )
    )

    floorNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
    floorNode.geometry?.firstMaterial?.isDoubleSided = true
    floorNode.position = SCNVector3(0, 0.005, 3)

    let shape = SCNPhysicsShape(geometry: floorNode.geometry!)
    floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
    floorNode.physicsBody?.isAffectedByGravity = false
    gameFloor.addChildNode(floorNode)
  }

  @objc private func addBall() {
    let scene = SCNScene(named: "Ball.scn")
    guard let ball = scene?.rootNode.childNode(withName: "Ball", recursively: false) else { return }
    var gameFloorPosition = self.gameFloor.position
    if !figures.isEmpty {
      gameFloorPosition = figures.randomElement()?.position ?? gameFloorPosition
      for figure in figures {
        print("Figure Position: \(figure.position)")
      }
    }
    ball.scale = .init(x: 0.002, y: 0.002, z: 0.002)
    ball.position = SCNVector3(
      gameFloorPosition.x,
      0.5,
      gameFloorPosition.z
    )

    let radius = (ball.boundingBox.max.y - ball.boundingBox.min.y) * 0.001
    let updatedSphere = SCNNode(geometry: SCNSphere(radius: CGFloat(radius)))
    let shape = SCNPhysicsShape(geometry: updatedSphere.geometry!)

    let physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
    physicsBody.damping = 0.5
    ball.physicsBody = physicsBody
    ball.physicsBody = physicsBody
    gameFloor.addChildNode(ball)
  }

  private func getBowlingPinPosition(
    index: Int,
    spacing: Double = 0.1
  ) -> (
    x: Double, y: Double, z: Double
  ) {
    var row = 1
    var currentPinCount = 0
    while currentPinCount + row < index {
      currentPinCount += row
      row += 1
    }
    let positionInRow = index - currentPinCount - 1
    let x = Double(positionInRow) * spacing - Double(row - 1) * spacing / 2
    let z = -Double(row - 1) * spacing
    return (x, 0.0, z)
  }

  private func randomNumber(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
    CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum)
      + min(firstNum, secondNum)
  }

  @objc private func handleTap(_ sender: UITapGestureRecognizer) {
    guard let sceneView = sender.view as? ARSCNView else { return }

    let touchLocation = sender.location(in: sceneView)
    guard
      let query = sceneView.raycastQuery(
        from: touchLocation,
        allowing: .existingPlaneInfinite,
        alignment: .horizontal
      )
    else {
      return
    }

    let results = sceneView.session.raycast(query)
    guard let hitTestResult = results.first else {
      print("No surface found")
      return
    }

    if !isArenaAdded {
      addArena(hitResult: hitTestResult)
      isArenaAdded = true
    }
  }

  private func addArena(hitResult: ARRaycastResult) {
    guard let portalScene = SCNScene(named: "Portal.scn"),
      let portalNode = portalScene.rootNode.childNode(
        withName: "Portal",
        recursively: false
      )
    else { return }

    guard let bowlingScene = SCNScene(named: "BowlingScene.scn"),
      let bowlingNode = bowlingScene.rootNode.childNode(
        withName: "BowlingArena", recursively: false)
    else { return }

    bowlingNode.physicsBody = SCNPhysicsBody(
      type: .static,
      shape: SCNPhysicsShape(node: bowlingNode)
    )
    
    portalNode.addChildNode(bowlingNode)

    let transform = hitResult.worldTransform
    let planeXPosition = transform.columns.3.x
    let planeYPosition = transform.columns.3.y
    let planeZPosition = transform.columns.3.z
    portalNode.position = SCNVector3(
      planeXPosition,
      planeYPosition,
      planeZPosition + 3
    )
    sceneView.scene.rootNode.addChildNode(portalNode)
    addPlane(nodeName: "roof", portalNode: portalNode)
    addPlane(nodeName: "floor", portalNode: portalNode)
    addWalls(nodeName: "leftSideDoor", portalNode: portalNode)
    addWalls(nodeName: "rightSideDoor", portalNode: portalNode)
    addWalls(nodeName: "backWall", portalNode: portalNode)
    addWalls(nodeName: "leftWall", portalNode: portalNode)
    addWalls(nodeName: "rightWall", portalNode: portalNode)
    setupFigures()
  }

  private func addPlane(nodeName: String, portalNode: SCNNode, imageName: String = "WoodTexture") {
    let child = portalNode.childNode(withName: nodeName, recursively: true)
    child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "WoodTexture")
    child?.renderingOrder = 200
  }

  private func addWalls(nodeName: String, portalNode: SCNNode, imageName: String = "WoodTexture") {
    let child = portalNode.childNode(withName: nodeName, recursively: true)
    child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: imageName)
    child?.renderingOrder = 200
    if let mask = child?.childNode(withName: "mask", recursively: false) {
      mask.geometry?.firstMaterial?.transparency = 0.000001
    }
  }

  private func setupFigures() {
    guard let portalScene = SCNScene(named: "BowlingScene.scn"),
      let portalNode = portalScene.rootNode.childNode(withName: "BowlingArena", recursively: false),
      let lane = portalNode.childNode(withName: "lane", recursively: true)
    else { return }
    
//    let width = (lane.boundingBox.max.x - lane.boundingBox.min.x)
//    let height = (lane.boundingBox.max.y - lane.boundingBox.min.y)
//    let length = (lane.boundingBox.max.z - lane.boundingBox.min.z)
//
//    let box = SCNBox(width: CGFloat(width), height: CGFloat(height), length: CGFloat(length), chamferRadius: 0)
//
//    let shape = SCNPhysicsShape(geometry: portalNode)
//    lane.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
//    lane.physicsBody?.isAffectedByGravity = false
    
    let shape = SCNPhysicsShape(
      node: portalNode,
      options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox]
    )
    let physicsBody = SCNPhysicsBody(type: .static, shape: shape)
    physicsBody.isAffectedByGravity = false
    portalNode.physicsBody = physicsBody
    
    gameFloor = portalNode
    
    sceneView.scene.rootNode.addChildNode(gameFloor)
  }

  private func createCube() {
    let cube = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0.05)
    let cubeNode = SCNNode(geometry: cube)
    let cubeShape = SCNPhysicsShape(geometry: cubeNode.geometry!)
    let physicsBody = SCNPhysicsBody(type: .static, shape: cubeShape)
    //    physicsBody.damping = 0.5
    cubeNode.physicsBody = physicsBody
    cubeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
//    cubeNode.position = .init(x: -1, y: 0, z: -1)
    gameFloor.addChildNode(cubeNode)
  }

}

extension BowlingViewController: ARSCNViewDelegate {

  func renderer(
    _ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor
  ) {
    //    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    //    print("Horizontal plane is detected...")
    //
    //    if !isPlaced {
    //      let gameFloor = createFloor(planeAnchor: planeAnchor)
    //      self.gameFloor = gameFloor
    //      sceneView.scene.rootNode.addChildNode(gameFloor)
    //      isPlaced = true
    //    }
  }

}

extension Int {

  var degreesToRadians: Double { Double(self) * .pi / 180 }

}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
  SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
