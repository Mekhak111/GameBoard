//
//  RandomColor.swift
//  GameBoard
//
//  Created by Narek Aslanyan on 10.12.24.
//

import UIKit

enum RandomColor: Int, CaseIterable {

  case red
  case green
  case blue
  case yellow
  case black

  var color: UIColor {
    switch self {
    case .red: .red
    case .green: .green
    case .blue: .blue
    case .yellow: .yellow
    case .black: .black
    }
  }

}
