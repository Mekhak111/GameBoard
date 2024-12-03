//
//  EmojiViewController.swift
//  GameBoard
//
//  Created by Mekhak Ghapantsyan on 12/3/24.
//

import UIKit
import ARKit
import Vision

class EmojiViewController: UIViewController, ARSessionDelegate {
  
  private var arView: ARSCNView!
  private var emojiLabel: UILabel!
  private var emojiStackView: UIStackView!
  private var emojiArray = ["😊", "😲", "😢", "😘", "🤔", "😉"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupARView()
  }
  
  private func setupUI() {
    emojiLabel = UILabel()
    emojiLabel.text = ""
    emojiLabel.font = UIFont.systemFont(ofSize: 100)
    emojiLabel.textAlignment = .center
    emojiLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(emojiLabel)
    
    NSLayoutConstraint.activate([
      emojiLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      emojiLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
    
    emojiStackView = UIStackView()
    emojiStackView.axis = .horizontal
    emojiStackView.spacing = 10
    emojiStackView.distribution = .equalSpacing
    emojiStackView.alignment = .center
    emojiStackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(emojiStackView)
    
    NSLayoutConstraint.activate([
      emojiStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      emojiStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      emojiStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
    ])
    
    updateEmojiStackView()
  }
  
  private func updateEmojiStackView() {
    emojiStackView.arrangedSubviews.forEach { $0.removeFromSuperview() } // Clear existing views
    for emoji in emojiArray {
      let emojiLabel = UILabel()
      emojiLabel.text = emoji
      emojiLabel.font = UIFont.systemFont(ofSize: 40)
      emojiStackView.addArrangedSubview(emojiLabel)
    }
  }
  
  
  private func setupARView() {
    arView = ARSCNView(frame: view.bounds)
    view.insertSubview(arView, at: 0)
    
    guard ARFaceTrackingConfiguration.isSupported else {
      fatalError("Face tracking is not supported on this device.")
    }
    
    let configuration = ARFaceTrackingConfiguration()
    arView.session.run(configuration)
    arView.session.delegate = self
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    arView.session.pause()
  }
  
  func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    for anchor in anchors {
      guard let faceAnchor = anchor as? ARFaceAnchor else { continue }
      detectFacialExpression(from: faceAnchor)
    }
  }
  
  private func detectFacialExpression(from faceAnchor: ARFaceAnchor) {
    let blendShapes = faceAnchor.blendShapes
    
    let smile = blendShapes[.mouthSmileLeft]?.floatValue ?? 0.0 + (blendShapes[.mouthSmileRight]?.floatValue ?? 0)
    let surprise = blendShapes[.jawOpen]?.floatValue ?? 0.0
    let sadness = blendShapes[.mouthFrownLeft]?.floatValue ?? 0.0 + (blendShapes[.mouthFrownRight]?.floatValue ?? 0)
    let puckerLips = blendShapes[.mouthPucker]?.floatValue ?? 0.0
    let squint = blendShapes[.eyeSquintLeft]?.floatValue ?? 0.0 + (blendShapes[.eyeSquintRight]?.floatValue ?? 0)
    let blink = blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0 + (blendShapes[.eyeBlinkRight]?.floatValue ?? 0)
    
    DispatchQueue.main.async {
      if smile > 0.5 {
        self.updateEmoji(to: "😊")
      } else if surprise > 0.5 {
        self.updateEmoji(to: "😲")
      } else if sadness > 0.5 {
        self.updateEmoji(to: "😢")
      } else if puckerLips > 0.5 {
        self.updateEmoji(to: "😘")
      } else if squint > 0.5 {
        self.updateEmoji(to: "🤔")
      } else if blink > 0.8 {
        self.updateEmoji(to: "😉")
      } else {
        self.updateEmoji(to: "")
      }
    }
  }
  
  private func updateEmoji(to emoji: String) {
    if let index = emojiArray.firstIndex(of: emoji) {
      emojiArray.remove(at: index)
      updateEmojiStackView()
      emojiLabel.text = emoji
    }
  }
  
}

