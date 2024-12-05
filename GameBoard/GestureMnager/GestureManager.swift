//
//  GestureManager.swift
//  GameBoard
//
//  Created by Mekhak Ghapantsyan on 12/5/24.
//

import Foundation
import ARKit

class GestureManager {
  
  func detectPinchGesture(observation: VNHumanHandPoseObservation) -> Bool {
    guard let thumbTip = try? observation.recognizedPoints(.thumb)[.thumbTip],
          let indexTip = try? observation.recognizedPoints(.indexFinger)[.indexTip] else { return false }
    
    let distance = hypot(thumbTip.x - indexTip.x, thumbTip.y - indexTip.y)
    
    return distance < 0.05
  }
  
  func detectPinchWithMiddleGesture(observation: VNHumanHandPoseObservation) -> Bool {
    guard let thumbTip = try? observation.recognizedPoints(.thumb)[.thumbTip],
          let midTIp = try? observation.recognizedPoints(.middleFinger)[.middleTip] else { return false }
    
    let distance = hypot(thumbTip.x - midTIp.x, thumbTip.y - midTIp.y)
    
    return distance < 0.05
  }
  
  func detectPinchWithRingGesture(observation: VNHumanHandPoseObservation) -> Bool {
    guard let thumbTip = try? observation.recognizedPoints(.thumb)[.thumbTip],
          let ringTIp = try? observation.recognizedPoints(.ringFinger)[.ringTip] else { return false }
    
    let distance = hypot(thumbTip.x - ringTIp.x, thumbTip.y - ringTIp.y)
    
    return distance < 0.05
  }
  
  func detectPinchWithLittleGesture(observation: VNHumanHandPoseObservation) -> Bool {
    guard let thumbTip = try? observation.recognizedPoints(.thumb)[.thumbTip],
          let littleTip = try? observation.recognizedPoints(.littleFinger)[.littleTip] else { return false }
    
    let distance = hypot(thumbTip.x - littleTip.x, thumbTip.y - littleTip.y)
    
    return distance < 0.05
  }
  func detectVictoryGesture(from observation: VNHumanHandPoseObservation) -> Bool {
      do {
          // Get all recognized points for each finger
          let thumb = try observation.recognizedPoints(.thumb)
          let index = try observation.recognizedPoints(.indexFinger)
          let middle = try observation.recognizedPoints(.middleFinger)
          let ring = try observation.recognizedPoints(.ringFinger)
          let pinky = try observation.recognizedPoints(.littleFinger)
          
          // Ensure points are valid and have a confidence > 0.5
        guard let thumbTip = thumb[.thumbTip]?.location, thumb[.thumbTip]?.confidence ?? 0 > 0.5,
                let indexTip = index[.indexTip]?.location, index[.indexTip]?.confidence ?? 0 > 0.5,
                let middleTip = middle[.middleTip]?.location, middle[.middleTip]?.confidence ?? 0 > 0.5,
                let ringTip = ring[.ringTip]?.location, ring[.ringTip]?.confidence ?? 0 > 0.5,
              let pinkyTip = pinky[.littleTip]?.location, pinky[.littleTip]?.confidence ?? 0 > 0.5,
              let indexMCP = index[.indexMCP]?.location, index[.indexMCP]?.confidence ?? 0 > 0.5,
              let middleMCP = middle[.middleMCP]?.location, middle[.middleMCP]?.confidence ?? 0 > 0.5,
              let ringMCP = ring[.ringMCP]?.location, ring[.ringMCP]?.confidence ?? 0 > 0.5,
              let pinkyMCP = pinky[.littleMCP]?.location, pinky[.littleMCP]?.confidence ?? 0 > 0.5 else {
              return false
          }
          
          // Check if index and middle fingers are extended
          let indexExtended = distance(from: indexTip, to: indexMCP) > 0.3
          let middleExtended = distance(from: middleTip, to: middleMCP) > 0.3
          
          // Check if thumb, ring, and pinky fingers are curled
        let thumbCurled = distance(from: thumbTip, to: thumb[.thumbMP]!.location) < 0.2
          let ringCurled = distance(from: ringTip, to: ringMCP) < 0.2
          let pinkyCurled = distance(from: pinkyTip, to: pinkyMCP) < 0.2
          
          // Check if the index and middle tips are separated
          let fingersSeparated = distance(from: indexTip, to: middleTip) > 0.1
          
          // Victory gesture: index and middle fingers extended and separated, others curled
          return indexExtended && middleExtended && fingersSeparated && thumbCurled && ringCurled && pinkyCurled
      } catch {
          print("Error detecting hand pose: \(error)")
          return false
      }
  }
  
  func detectThumbsUpGesture(from observation: VNHumanHandPoseObservation) -> Bool {
      do {
          // Get recognized points for the thumb and all fingers
          let thumb = try observation.recognizedPoints(.thumb)
          let index = try observation.recognizedPoints(.indexFinger)
          let middle = try observation.recognizedPoints(.middleFinger)
          let ring = try observation.recognizedPoints(.ringFinger)
          let pinky = try observation.recognizedPoints(.littleFinger)
          
          // Ensure points are valid and have sufficient confidence
          guard let thumbTip = thumb[.thumbTip]?.location, thumb[.thumbTip]?.confidence ?? 0 > 0.5,
                let thumbMP = thumb[.thumbMP]?.location, thumb[.thumbMP]?.confidence ?? 0 > 0.5,
                let indexTip = index[.indexTip]?.location, index[.indexTip]?.confidence ?? 0 > 0.5,
                let middleTip = middle[.middleTip]?.location, middle[.middleTip]?.confidence ?? 0 > 0.5,
                let ringTip = ring[.ringTip]?.location, ring[.ringTip]?.confidence ?? 0 > 0.5,
                let pinkyTip = pinky[.ringTip]?.location, pinky[.ringTip]?.confidence ?? 0 > 0.5,
                let indexMCP = index[.indexMCP]?.location, index[.indexMCP]?.confidence ?? 0 > 0.5,
                let middleMCP = middle[.middleMCP]?.location, middle[.middleMCP]?.confidence ?? 0 > 0.5,
                let ringMCP = ring[.ringMCP]?.location, ring[.ringMCP]?.confidence ?? 0 > 0.5,
                let pinkyMCP = pinky[.littleMCP]?.location, pinky[.littleMCP]?.confidence ?? 0 > 0.5 else {
              return false
          }
          
          // Check if thumb is extended
          let thumbExtended = distance(from: thumbTip, to: thumbMP) > 0.03
          
          // Check if other fingers are curled
          let indexCurled = distance(from: indexTip, to: indexMCP) < 0.2
          let middleCurled = distance(from: middleTip, to: middleMCP) < 0.2
          let ringCurled = distance(from: ringTip, to: ringMCP) < 0.2
          let pinkyCurled = distance(from: pinkyTip, to: pinkyMCP) < 0.2
          
          // Optional: Check thumb is higher than the other fingers
          let thumbAboveOthers = thumbTip.y < min(indexTip.y, middleTip.y, ringTip.y, pinkyTip.y)
          
          // Thumbs up: thumb extended and above others, other fingers curled
          return thumbExtended && thumbAboveOthers && indexCurled && middleCurled && ringCurled && pinkyCurled
      } catch {
          print("Error detecting hand pose: \(error)")
          return false
      }
  }
  
  func detectOpenHandGesture(from observation: VNHumanHandPoseObservation) -> Bool {
      do {
          // Get recognized points for each finger
          let thumb = try observation.recognizedPoints(.thumb)
          let index = try observation.recognizedPoints(.indexFinger)
          let middle = try observation.recognizedPoints(.middleFinger)
          let ring = try observation.recognizedPoints(.ringFinger)
          let pinky = try observation.recognizedPoints(.littleFinger)
          
          // Ensure points are valid and have sufficient confidence
          guard let thumbTip = thumb[.thumbTip]?.location, thumb[.thumbTip]?.confidence ?? 0 > 0.5,
                let indexTip = index[.indexTip]?.location, index[.indexTip]?.confidence ?? 0 > 0.5,
                let middleTip = middle[.middleTip]?.location, middle[.middleTip]?.confidence ?? 0 > 0.5,
                let ringTip = ring[.ringTip]?.location, ring[.ringTip]?.confidence ?? 0 > 0.5,
                let pinkyTip = pinky[.littleTip]?.location, pinky[.littleTip]?.confidence ?? 0 > 0.5,
                let thumbMP = thumb[.thumbMP]?.location,
                let indexMCP = index[.indexMCP]?.location,
                let middleMCP = middle[.middleMCP]?.location,
                let ringMCP = ring[.ringMCP]?.location,
                let pinkyMCP = pinky[.littleMCP]?.location else {
              return false
          }
          
          // Check if all fingers are extended
          let thumbExtended = distance(from: thumbTip, to: thumbMP) > 0.05
          let indexExtended = distance(from: indexTip, to: indexMCP) > 0.05
          let middleExtended = distance(from: middleTip, to: middleMCP) > 0.05
          let ringExtended = distance(from: ringTip, to: ringMCP) > 0.05
          let pinkyExtended = distance(from: pinkyTip, to: pinkyMCP) > 0.05
          
          // Check if fingers are spread apart
          let thumbToIndex = distance(from: thumbTip, to: indexTip)
          let indexToMiddle = distance(from: indexTip, to: middleTip)
          let middleToRing = distance(from: middleTip, to: ringTip)
          let ringToPinky = distance(from: ringTip, to: pinkyTip)
          
          let fingersSpread = thumbToIndex > 0.05 &&
                              indexToMiddle > 0.05 &&
                              middleToRing > 0.05 &&
                              ringToPinky > 0.05
          
          // Open hand gesture: all fingers extended and spread
          return thumbExtended && indexExtended && middleExtended && ringExtended && pinkyExtended && fingersSpread
      } catch {
          print("Error detecting hand pose: \(error)")
          return false
      }
  }
  
  func detectClosedHandGesture(from observation: VNHumanHandPoseObservation) -> Bool {
      do {
          // Get recognized points for each finger
          let thumb = try observation.recognizedPoints(.thumb)
          let index = try observation.recognizedPoints(.indexFinger)
          let middle = try observation.recognizedPoints(.middleFinger)
          let ring = try observation.recognizedPoints(.ringFinger)
          let pinky = try observation.recognizedPoints(.littleFinger)
          
          // Ensure points are valid and have sufficient confidence
          guard let thumbTip = thumb[.thumbTip]?.location, thumb[.thumbTip]?.confidence ?? 0 > 0.5,
                let indexTip = index[.indexTip]?.location, index[.indexTip]?.confidence ?? 0 > 0.5,
                let middleTip = middle[.middleTip]?.location, middle[.middleTip]?.confidence ?? 0 > 0.5,
                let ringTip = ring[.ringTip]?.location, ring[.ringTip]?.confidence ?? 0 > 0.5,
                let pinkyTip = pinky[.littleTip]?.location, pinky[.littleTip]?.confidence ?? 0 > 0.5,
                let thumbMP = thumb[.thumbMP]?.location,
                let indexMCP = index[.indexMCP]?.location,
                let middleMCP = middle[.middleMCP]?.location,
                let ringMCP = ring[.ringMCP]?.location,
                let pinkyMCP = pinky[.littleMCP]?.location else {
              return false
          }
          
          // Check if all fingers are curled
          let indexCurled = distance(from: indexTip, to: indexMCP) < 0.02
          let middleCurled = distance(from: middleTip, to: middleMCP) < 0.02
          let ringCurled = distance(from: ringTip, to: ringMCP) < 0.02
          let pinkyCurled = distance(from: pinkyTip, to: pinkyMCP) < 0.02
          
          // Check if the thumb is curled or extended (optional)
          let thumbExtended = distance(from: thumbTip, to: thumbMP) > 0.03
          
          // A closed hand gesture: index, middle, ring, and pinky fingers curled, and thumb could be extended or curled
          return indexCurled && middleCurled && ringCurled && pinkyCurled && (thumbExtended || !indexCurled)
      } catch {
          print("Error detecting hand pose: \(error)")
          return false
      }
  }
  
  func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
      return hypot(point1.x - point2.x, point1.y - point2.y)
  }

}
