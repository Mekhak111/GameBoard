//
//  UIImage+Ext.swift
//  GameBoard
//
//  Created by Narek Aslanyan on 16.12.24.
//

import UIKit

extension UIImage {
  
  func resizedImage(targetSize: CGSize) -> UIImage? {
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    let resizedImage = renderer.image { _ in
      self.draw(in: CGRect(origin: .zero, size: targetSize))
    }
    return resizedImage
  }
  
}
