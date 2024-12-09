//
//  PhysicsHelper.swift
//  GameBoard
//
//  Created by Narek Aslanyan on 06.12.24.
//

import SceneKit

func printPhysicsBodies(of node: SCNNode) {
  for child in node.childNodes {
    guard let physicsBody = child.physicsBody else {
      print("Node hasn't physics body:")
      continue
    }
    print("Node: \(child.name ?? "Unnamed")")
    print(" - Type: \(physicsBody.type)")
    print(" - Mass: \(physicsBody.mass)")
    print(" - Friction: \(physicsBody.friction)")
    print(" - Restitution: \(physicsBody.restitution)")
    print(" - Shape: \(physicsBody.physicsShape?.debugDescription ?? "None")")
    print(" - Is Affected By Gravity: \(physicsBody.isAffectedByGravity)")
  }
}
