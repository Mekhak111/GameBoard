//
//  RandomTexture.swift
//  GameBoard
//
//  Created by Narek Aslanyan on 10.12.24.
//

import UIKit

enum RandomTexture: Int, CaseIterable {
  
  case texture1
  case texture2
  case texture3
  case texture4
  case texture5
  case texture6
  case texture7
  
  var textureImage: UIImage? {
    switch self {
    case .texture1: UIImage(named: "texture1")
    case .texture2: UIImage(named: "texture2")
    case .texture3: UIImage(named: "texture3")
    case .texture4: UIImage(named: "texture4")
    case .texture5: UIImage(named: "texture5")
    case .texture6: UIImage(named: "texture6")
    case .texture7: UIImage(named: "texture7")
    }
  }
  
}
