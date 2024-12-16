//
//  BowlingViewModel.swift
//  GameBoard
//
//  Created by Narek Aslanyan on 06.12.24.
//

import ARKit
import Foundation

class BowlingViewModel {

  enum SideType {

    case left
    case right

  }

  var planeNodeYPosition: Float = 0.1
  var plane: SCNPlane?
  var halfCylinderHeight: Float = 0.3
  var floorHeight: Float = 0
  var rightPlaneHeight: Float = 0
  var sideFloorPlane: SCNPlane?
  var sideWallPlane: SCNPlane?
  var gameFloor = SCNNode()
  var isPlaced: Bool = false
  var isImageDetected: Bool = false
  var isArenaAdded: Bool = false
  var canThrowBall: Bool = true
  var ballColor: UIColor = .red
  var ballTexture: UIImage? = UIImage(named: "texture1")
  var isBallMoving: Bool = false
  var handPoseRequest: VNDetectHumanHandPoseRequest!
  var initialRotations: [SCNNode: SCNVector4] = [:]
  var fallenPinsCount: Int = 0
  var isBallMovingDidChange: ((Bool) -> Void)?
  var fallenPins: Set<String> = []
  
  let configuration = ARWorldTrackingConfiguration()

  func checkFallenPins() {
    guard let pinParent = gameFloor.childNode(withName: "PinParent", recursively: true)
    else {
      return
    }
    guard !pinParent.childNodes.isEmpty else { return }

    for child in pinParent.childNodes {
      guard let initialRotation = initialRotations[child],
        child.presentation.rotation != initialRotation
      else { continue }
      let wRadian = child.presentation.rotation.w
      let degree = wRadian.radianToDegree
      let name = child.name ?? "UnNamed"
      print("Node \(name) has rotated to \(degree) degree")

      if abs(degree) > 45 && !fallenPins.contains(name) {
        print("\(name) is Fallllennnnn!")
        fallenPins.insert(name)
        fallenPinsCount += 1
        setScoreValue()
        removeFallenPin(named: name)
      }
      if fallenPins.count == 10 {
        repeatGame()
      }
    }
  }

  func ballFallingDetected(_ node: SCNNode) {
    canThrowBall = true
    isBallMoving = false
    isBallMovingDidChange?(isBallMoving)
    node.removeFromParentNode()
    if !isBallMoving && canThrowBall {
      giveBall()
      canThrowBall = false
    }
  }

  func getBowlingPinPosition(
    index: Int,
    spacing: Double = 0.1
  ) -> SCNVector3 {
    var row = 1
    var currentPinCount = 0
    while currentPinCount + row < index {
      currentPinCount += row
      row += 1
    }
    let positionInRow = index - currentPinCount - 1
    let x = Double(positionInRow) * spacing - Double(row - 1) * spacing / 2
    let z = -Double(row - 1) * spacing

    return SCNVector3(x, 0.0, z)
  }

  func setupFloor() {
    guard let lane = gameFloor.childNode(withName: "lane", recursively: true)
    else { return }
    let floorNode = setupFloorConfig(for: lane)

    setupFloor(for: floorNode, side: .left)
    setupFloor(for: floorNode, side: .right)
  }

  func throwBall() {
    removeGivenBallFromParent()
    let scene = SCNScene(named: "Ball.scn")
    guard let ball = scene?.rootNode.childNode(withName: "Ball", recursively: false),
      let pinParent = gameFloor.childNode(withName: "PinParent", recursively: true)
    else { return }
    
    guard pinParent.childNode(withName: "givenBall", recursively: true) == nil else {
      return
    }
    
    guard let laserNode = gameFloor.childNode(withName: "Laser", recursively: true)
    else { return }
    let ballThrowPositionX = laserNode.position.x

    isBallMoving = true
    isBallMovingDidChange?(isBallMoving)
    let gameFloorPosition = pinParent.position
    let scale: Float = 0.05

    ball.scale = .init(x: scale, y: scale, z: scale)
    ball.position = SCNVector3(
      gameFloorPosition.x + ballThrowPositionX,
      0.2,
      gameFloorPosition.z + 6
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
    physicsBody.contactTestBitMask = Bitmask.pin.rawValue
    physicsBody.contactTestBitMask = Bitmask.finishFloor.rawValue | Bitmask.pin.rawValue
    physicsBody.categoryBitMask = Bitmask.ball.rawValue
    ball.physicsBody = physicsBody
    ball.name = "givenBall"
    ball.geometry?.firstMaterial?.diffuse.contents = ballTexture // ballColor
    pinParent.addChildNode(ball)
  }

  func giveBall() {
    let scene = SCNScene(named: "Ball.scn")
    guard let ball = scene?.rootNode.childNode(withName: "Ball", recursively: false),
      let startNode = gameFloor.childNode(withName: "start", recursively: true)
    else { return }

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
    physicsBody.contactTestBitMask = Bitmask.floor.rawValue
    physicsBody.categoryBitMask = Bitmask.ball.rawValue
    ball.physicsBody = physicsBody
    ball.name = "givenBall"
    //    let randomColor = RandomColor.allCases.randomElement()?.color
    let randomTexture = RandomTexture.allCases.randomElement()?.textureImage
    ball.geometry?.firstMaterial?.diffuse.contents = randomTexture
    startNode.addChildNode(ball)
  }

  func createPins() {
    let scene = SCNScene(named: "BowlingPin.scn")
    createPins(from: scene)
    guard gameFloor.childNode(withName: "givenBall", recursively: true) != nil else {
      giveBall()
      return
    }
  }

  func resetPins() {
    fallenPins = []
    initialRotations = [:]
    canThrowBall = true
    isBallMoving = false
    isBallMovingDidChange?(isBallMoving)
    gameFloor.enumerateChildNodes { node, _ in
      if let name = node.name, name == "PinParent" {
        node.removeFromParentNode()
      }
    }
  }

  func resetBalls() {
    gameFloor.enumerateChildNodes { node, _ in
      if let name = node.name, name.contains("givenBall") {
        node.removeFromParentNode()
      }
    }
  }

  func removeGivenBallFromParent() {
    var isGivenBallFound: Bool = false
    gameFloor.enumerateChildNodes { node, stop in
      guard !isGivenBallFound else { return }
      if let name = node.name, name.contains("givenBall") {
        isGivenBallFound = true
        if let color = node.geometry?.firstMaterial?.diffuse.contents as? UIColor {
          ballColor = color
        }
        if let image = node.geometry?.firstMaterial?.diffuse.contents as? UIImage {
          ballTexture = image
        }
        node.removeFromParentNode()
      }
    }
  }
  
  func hideShowLaser() {
    guard let laserNode = gameFloor.childNode(withName: "Laser", recursively: true)
    else { return }
    
    laserNode.isHidden = isBallMoving
  }
  
  func recognizedImage(imageAnchor: ARImageAnchor) -> SCNNode? {
    let transform = imageAnchor.transform
    let position = SIMD3<Float>(
      transform.columns.3.x,
      transform.columns.3.y,
      transform.columns.3.z
    )

    let textScn = SCNText()
    textScn.extrusionDepth = 0.01
    textScn.firstMaterial?.diffuse.contents = UIColor.green
    textScn.firstMaterial?.isDoubleSided = true
    textScn.chamferRadius = CGFloat(0.01)
    
    let text = "Image \nwas \nrecognized"

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    paragraphStyle.lineSpacing = 0.12

    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont(name: "Futura", size: 0.15) ?? UIFont.systemFont(ofSize: 0.15),
      .foregroundColor: UIColor.green,
      .paragraphStyle: paragraphStyle
    ]

    let attributedText = NSAttributedString(string: text, attributes: attributes)
    textScn.string = attributedText

    let (minBound, maxBound) = textScn.boundingBox
    let textNode = SCNNode(geometry: textScn)
    textNode.pivot = SCNMatrix4MakeTranslation(
      (maxBound.x - minBound.x) / 2,
      minBound.y,
      0.01 / 2
    )
    textNode.scale = SCNVector3Make(0.2, 0.2, 0.2)

    let plane = SCNPlane(
      width: imageAnchor.referenceImage.physicalSize.width,
      height: imageAnchor.referenceImage.physicalSize.height
    )
    plane.firstMaterial?.diffuse.contents = UIColor.clear
    let planeNode = SCNNode(geometry: plane)
    planeNode.position = .init(position.x, position.y, position.z)
    planeNode.addChildNode(textNode)

    guard let detectedImage = imageAnchor.referenceImage.name else {
      print("I can't detect Image")
      return nil
    }
    print(" \(detectedImage) image was recognized")

    let scaleOutAction = SCNAction.scale(to: 0.3, duration: 1)
    let scaleInAction = SCNAction.scale(to: 0.2, duration: 1)
    let arrayOfActions = [scaleOutAction, scaleInAction]
    let repeatedArray = Array(repeating: arrayOfActions, count: 4).flatMap { $0 }
    let sequenceAction = SCNAction.sequence(repeatedArray)
    
    textNode.runAction(sequenceAction) { [weak self] in
      guard let self else { return }
      isImageDetected = true
    }
    planeNode.name = "detectedImage"
    return planeNode
  }
  
  func deleteDetectedImage(node: SCNNode) {
    guard let detectedImage = node.childNode(withName: "detectedImage", recursively: true) else { return }
    
    detectedImage.removeFromParentNode()
  }

  private func createPins(from scene: SCNScene?) {
    guard let pinNode = scene?.rootNode.childNode(withName: "pin", recursively: false)
    else { return }
    resetPins()
    var pins: [SCNNode] = []
    let pinParentNode = SCNNode()
    pinParentNode.eulerAngles.y = .pi / 2
    pinParentNode.name = "PinParent"
    for index in 1...10 {
      let pin = createPin(from: pinNode, index: index)
      pins.append(pin)
    }

    guard let floorNode = gameFloor.childNode(withName: "BowlingFloor", recursively: true) else {
      return
    }
    pins.forEach { pin in
      pinParentNode.addChildNode(pin)
    }
    storeInitialRotations(parentNode: pinParentNode)
    floorNode.addChildNode(pinParentNode)
    showLaser()
  }

  private func storeInitialRotations(parentNode: SCNNode) {
    for child in parentNode.childNodes {
      initialRotations[child] = child.presentation.rotation
    }
  }

  private func setupFloorConfig(for lane: SCNNode) -> SCNNode {
    let width = (lane.boundingBox.max.x - lane.boundingBox.min.x)
    let height = (lane.boundingBox.max.z - lane.boundingBox.min.z)

    let parentPlane = SCNPlane(width: CGFloat(width), height: CGFloat(height))
    let parentPlaneNode = SCNNode(geometry: parentPlane)
    parentPlaneNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
    parentPlaneNode.name = "BowlingFloor"

    // Setup plane properties

    planeNodeYPosition = 0.1
    plane = SCNPlane(width: CGFloat(width), height: CGFloat((height / 2) * 0.54))
    halfCylinderHeight = 0.3
    floorHeight = (height / 2) * 0.54
    rightPlaneHeight = floorHeight * 0.5
    sideFloorPlane = SCNPlane(width: CGFloat(width), height: CGFloat(rightPlaneHeight))
    sideWallPlane = SCNPlane(width: CGFloat(width), height: CGFloat(halfCylinderHeight))
    lane.addChildNode(parentPlaneNode)
    return parentPlaneNode
  }

  private func addHalfCylinderLeftWall(
    for node: SCNNode,
    cylinderSide: SideType,
    floorSide: SideType
  ) {
    guard let plane, let sideWallPlane else { return }
    let distance = floorHeight / 2
    let floorOffset = floorSide == .left ? Float(plane.width / 2) : 0
    let offset = cylinderSide == .left ? distance : -distance
    node.createStaticChild(
      position: .init(0, -planeNodeYPosition, offset + floorOffset),
      plane: sideWallPlane,
      rotationAngles: .init(0, 0, 0),
      color: .yellow,
      scale: 0.3
    )
  }

  private func addHalfCylinderRightWall(
    for node: SCNNode,
    cylinderSide: SideType,
    floorSide: SideType
  ) {
    guard let plane, let sideWallPlane else { return }
    let distance = floorHeight / 2 + rightPlaneHeight
    let floorOffset = floorSide == .left ? Float(plane.width / 2) : 0
    let offset = cylinderSide == .left ? distance : -distance
    node.createStaticChild(
      position: .init(0, -planeNodeYPosition, offset + floorOffset),
      plane: sideWallPlane,
      rotationAngles: .init(0, 0, 0),
      color: .yellow,
      scale: 0.3
    )
  }

  private func addHalfCylinderFloor(
    for node: SCNNode,
    cylinderSide: SideType,
    floorSide: SideType
  ) {
    guard let plane, let sideFloorPlane else { return }
    let distance = (floorHeight + rightPlaneHeight) / 2
    let offset = cylinderSide == .left ? distance : -distance
    let floorOffset = floorSide == .left ? Float(plane.width / 2) : 0
    node.createStaticChild(
      position: .init(0, -halfCylinderHeight, offset + floorOffset),
      plane: sideFloorPlane,
      rotationAngles: .init(-90.degreesToRadians, 0, 0),
      color: .blue,
      scale: 0.3
    )
  }

  private func addCenterFloor(for node: SCNNode, side: SideType) {
    guard let plane else { return }
    let distance = side == .left ? Float(plane.width / 2) : 0
    node.createStaticChild(
      position: .init(0, planeNodeYPosition, distance),
      plane: plane,
      rotationAngles: .init(-90.degreesToRadians, 0, 0),
      color: .green
    )
  }

  private func setupFloor(for node: SCNNode, side: SideType) {
    // Center Floor
    addCenterFloor(for: node, side: side)
    // Left Half Cylinder
    addHalfCylinderFloor(for: node, cylinderSide: .left, floorSide: side)
    addHalfCylinderLeftWall(for: node, cylinderSide: .left, floorSide: side)
    addHalfCylinderRightWall(for: node, cylinderSide: .left, floorSide: side)
    // Right Half Cylinder
    addHalfCylinderFloor(for: node, cylinderSide: .right, floorSide: side)
    addHalfCylinderLeftWall(for: node, cylinderSide: .right, floorSide: side)
    addHalfCylinderRightWall(for: node, cylinderSide: .right, floorSide: side)
  }

  private func createPin(from pinNode: SCNNode, index: Int) -> SCNNode {
    let pin = pinNode.clone()
    let scale: Float = 0.005
    let position = getBowlingPinPosition(index: index, spacing: 0.5)
    let relativePosition = SCNVector3(x: 0, y: 0, z: -4.5)
    pin.scale = .init(x: scale, y: scale, z: scale)

    let width = (pin.boundingBox.max.x - pin.boundingBox.min.x) * scale
    let height = (pin.boundingBox.max.y - pin.boundingBox.min.y) * scale
    pin.position = .init(
      x: Float(position.x) + relativePosition.x,
      y: height + 0.05,
      z: Float(position.z) + relativePosition.z
    )

    let (minBound, maxBound) = pin.boundingBox
    let centerOffset = SCNVector3(
      (minBound.x + maxBound.x) / 2.0,
      (minBound.y + maxBound.y) / 2.0,
      (minBound.z + maxBound.z) / 2.0
    )
    pin.pivot = SCNMatrix4MakeTranslation(
      centerOffset.x,
      centerOffset.y,
      centerOffset.z
    )

    let cone = SCNCone(
      topRadius: 0,
      bottomRadius: CGFloat((scale * 80 * width) / 2),
      height: CGFloat(scale * 80 * height)
    )

    let updatedPin = SCNNode(geometry: cone)
    let coneShape = SCNPhysicsShape(geometry: updatedPin.geometry!)

    let physicsBody = SCNPhysicsBody(type: .dynamic, shape: coneShape)
    physicsBody.damping = 0.5
    physicsBody.contactTestBitMask = Bitmask.ball.rawValue
    physicsBody.categoryBitMask = Bitmask.pin.rawValue
    pin.physicsBody = physicsBody
    pin.name = "pin\(index)"
    return pin
  }

  private func setScoreValue() {
    guard let scoreNode = gameFloor.childNode(withName: "scoreTextNode", recursively: true),
      let textGeometry = scoreNode.geometry as? SCNText
    else { return }
    textGeometry.string = "Score: \(fallenPinsCount)"
  }

  private func removeFallenPin(named: String) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      guard let pinNode = self.gameFloor.childNode(withName: named, recursively: true) else {
        return
      }
      pinNode.removeFromParentNode()
    }
  }

  private func repeatGame() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
      guard let self else { return }
      createPins()
    }
  }
  
  private func showLaser() {
    guard let pinParent = gameFloor.childNode(withName: "PinParent", recursively: true)
    else { return }
    
    let capsule = SCNCapsule(capRadius: 0.1, height: 18)
    let laserNode = SCNNode(geometry: capsule)
    laserNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
    laserNode.eulerAngles.x = .pi / 2
    laserNode.position = .init(0, 0.8, 0)
    laserNode.name = "Laser"
    pinParent.addChildNode(laserNode)
    animateLaser(node: laserNode)
  }
  
  private func animateLaser(node: SCNNode) {
    let nodePosition = SCNVector3(0, 0.8, 0)
    let leftPosition = SCNVector3(-3, 0.8, 0)
    let rightPosition = SCNVector3(3, 0.8, 0)

    // Create actions
    let leftPositionAction = SCNAction.move(to: leftPosition, duration: 1.0)
    let nodePositionAction = SCNAction.move(to: nodePosition, duration: 1.0)
    let rightPositionAction = SCNAction.move(to: rightPosition, duration: 1.0)

    // Create a sequence of actions
    let sequence = SCNAction.sequence([
      leftPositionAction, nodePositionAction, rightPositionAction, nodePositionAction
    ])

    // Repeat the sequence forever
    let repeatForever = SCNAction.repeatForever(sequence)
    
    node.runAction(repeatForever)
  }

}
