//
//  SCNNode+Ext.swift
//  GameBoard
//
//  Created by Narek Aslanyan on 06.12.24.
//

import ARKit

extension SCNNode {

  func createStaticChild(
    position: SCNVector3,
    plane: SCNPlane,
    rotationAngles: SCNVector3 = .init(0, 0, 0),
    color: UIColor = .red,
    scale: Float = 0.4
  ) {
    let planeNode = SCNNode(geometry: plane)
    planeNode.setupStaticPlane(color: color, scale: scale)
    planeNode.position = position
    planeNode.eulerAngles = rotationAngles
    self.addChildNode(planeNode)
  }

  func setupStaticPlane(color: UIColor = .red, scale: Float = 0.4) {
    let width = (self.boundingBox.max.x - self.boundingBox.min.x)
    let length = (self.boundingBox.max.y - self.boundingBox.min.y)

    let (minBound, maxBound) = self.boundingBox
    let centerOffset = SCNVector3(
      ((minBound.x + maxBound.x) / 2.0),
      ((minBound.y + maxBound.y) / 2.0),
      ((minBound.z + maxBound.z) / 2.0)
    )
    self.pivot = SCNMatrix4MakeTranslation(
      centerOffset.x,
      centerOffset.y,
      centerOffset.z
    )

    let plane = SCNPlane(width: CGFloat(width * scale), height: CGFloat(length * scale))
    let updatedPlane = SCNNode(geometry: plane)
    let planeShape = SCNPhysicsShape(geometry: updatedPlane.geometry!)

    let physicsBody = SCNPhysicsBody(type: .static, shape: planeShape)
    physicsBody.isAffectedByGravity = false
    self.physicsBody = physicsBody
    self.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
    self.geometry?.firstMaterial?.isDoubleSided = true
  }

}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
  SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func == (left: SCNVector3, right: SCNVector3) -> Bool {
  left.x == right.x && left.y == right.y && left.z == right.z
}

func != (left: SCNVector3, right: SCNVector3) -> Bool {
  left.x != right.x || left.y != right.y || left.z != right.z
}

func != (left: SCNVector4, right: SCNVector4) -> Bool {
  left.x != right.x || left.y != right.y || left.z != right.z || left.w != right.w
}

func randomNumber(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
  CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum)
    + min(firstNum, secondNum)
}
