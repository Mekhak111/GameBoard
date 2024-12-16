//
//  Int+Ext.swift
//  GameBoard
//
//  Created by Narek Aslanyan on 06.12.24.
//


extension Int {

  var degreesToRadians: Double { Double(self) * .pi / 180 }

}

extension Float {

  var radianToDegree: Double { Double(self * 180 / .pi) }

}
