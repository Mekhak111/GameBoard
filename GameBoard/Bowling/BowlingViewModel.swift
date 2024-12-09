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
  var pins = [SCNNode()]
  var isArenaAdded: Bool = false
  let configuration = ARWorldTrackingConfiguration()
  
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
  
  func createPins(from scene: SCNScene?) {
    guard let pinNode = scene?.rootNode.childNode(withName: "pin", recursively: false)
    else { return }
    resetPins()
    let pinParentNode = SCNNode()
    pinParentNode.name = "PinParent"
    for index in 1...10 {
      let pin = createPin(from: pinNode, index: index)
      pins.append(pin)
    }

    pins.forEach { pin in
      guard let floorNode = gameFloor.childNode(withName: "BowlingFloor", recursively: true) else {
        return
      }
      pinParentNode.addChildNode(pin)
      pinParentNode.eulerAngles.y = .pi / 2
      floorNode.addChildNode(pinParentNode)
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

  private func addHalfCylinderLeftWall(for node: SCNNode, cylinderSide: SideType, floorSide: SideType) {
    guard let plane, let sideWallPlane else { return }
    let distance = floorHeight / 2
    let floorOffset = floorSide == .left ? Float(plane.width / 2) : 0
    let offset = cylinderSide == .left ? distance : -distance
    node.createStaticChild(
      position: .init(0, -planeNodeYPosition, offset + floorOffset),
      plane: sideWallPlane,
      rotationAngles: .init(0, 0, 0),
      color: .yellow
    )
  }

  private func addHalfCylinderRightWall(for node: SCNNode, cylinderSide: SideType, floorSide: SideType) {
    guard let plane, let sideWallPlane else { return }
    let distance = floorHeight / 2 + rightPlaneHeight
    let floorOffset = floorSide == .left ? Float(plane.width / 2) : 0
    let offset = cylinderSide == .left ? distance : -distance
    node.createStaticChild(
      position: .init(0, -planeNodeYPosition, offset + floorOffset),
      plane: sideWallPlane,
      rotationAngles: .init(0, 0, 0),
      color: .yellow
    )
  }

  private func addHalfCylinderFloor(for node: SCNNode, cylinderSide: SideType, floorSide: SideType) {
    guard let plane, let sideFloorPlane else { return }
    let distance = (floorHeight + rightPlaneHeight) / 2
    let offset = cylinderSide == .left ? distance : -distance
    let floorOffset = floorSide == .left ? Float(plane.width / 2) : 0
    node.createStaticChild(
      position: .init(0, -halfCylinderHeight, offset + floorOffset),
      plane: sideFloorPlane,
      rotationAngles: .init(-90.degreesToRadians, 0, 0),
      color: .blue
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
  
  func resetPins() {
    pins.removeAll()
    gameFloor.enumerateChildNodes { node, _ in
      if let name = node.name, name == "PinParent" {
        node.removeFromParentNode()
      }
    }
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
    physicsBody.contactTestBitMask = 10
    physicsBody.categoryBitMask = 30
    pin.physicsBody = physicsBody
    pin.name = "pin\(index)"
    return pin
  }
  
}
