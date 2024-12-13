//
//  AccelerometrManager.swift
//  GameBoard
//
//  Created by Mekhak Ghapantsyan on 12/13/24.
//

import Foundation
import CoreMotion

class AccelerometerManager {
  
  private let motionManager = CMMotionManager()
  private let queue = OperationQueue()
  
  var onRotationChange: ((String) -> Void)?
  
  init() {
    guard motionManager.isAccelerometerAvailable else {
      print("Accelerometer is not available on this device.")
      return
    }
    motionManager.accelerometerUpdateInterval = 0.1
  }
  
  func startMonitoring() {
    motionManager.startAccelerometerUpdates(to: queue) { [weak self] data, error in
      guard let self = self, let accelerometerData = data, error == nil else {
        if let error = error {
          print("Error while updating accelerometer: \(error.localizedDescription)")
        }
        return
      }
      
      let x = accelerometerData.acceleration.x
      let z = accelerometerData.acceleration.z
      
      var rotation = "Unknown"
      
      if x < -0.5 {
        rotation = "Rotating Left"
      } else if x > 0.5 {
        rotation = "Rotating Right"
      } else if z > 0.3 {
        rotation = "Rotating back"
      } else if z < -0.3 {
        rotation = "Rotating forward"
      }
      
      DispatchQueue.main.async {
        self.onRotationChange?(rotation)
      }
    }
  }
  
  func stopMonitoring() {
    motionManager.stopAccelerometerUpdates()
  }
  
}
