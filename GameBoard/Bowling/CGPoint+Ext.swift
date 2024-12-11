//
//  CGPoint+Ext.swift
//  GameBoard
//
//  Created by Narek Aslanyan on 11.12.24.
//

import UIKit

extension CGPoint {
  
  func distance(to point: CGPoint) -> CGFloat {
    sqrt(pow(self.x - point.x, 2) + pow(self.y - point.y, 2))
  }
  
}
