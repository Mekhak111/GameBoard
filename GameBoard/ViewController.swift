//
//  ViewController.swift
//  GameBoard
//
//  Created by Mekhak Ghapantsyan on 11/28/24.
//

import ARKit
import UIKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    // Create Plane Button
    let planeButton = createButton(
      title: "Plane",
      backgroundColor: .systemBlue
    )
    planeButton.addTarget(self, action: #selector(planeButtonTapped), for: .touchUpInside)
    
    // Create Bowling Button
    let bowlingButton = createButton(
      title: "Bowling",
      backgroundColor: .systemGreen
    )
    bowlingButton.addTarget(self, action: #selector(bowlingButtonTapped), for: .touchUpInside)
    
    // Add buttons to the view
    view.addSubview(planeButton)
    view.addSubview(bowlingButton)
    
    // Set button constraints
    planeButton.translatesAutoresizingMaskIntoConstraints = false
    bowlingButton.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      // Plane Button Constraints
      planeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      planeButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
      planeButton.widthAnchor.constraint(equalToConstant: 200),
      planeButton.heightAnchor.constraint(equalToConstant: 50),
      
      // Bowling Button Constraints
      bowlingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      bowlingButton.topAnchor.constraint(equalTo: planeButton.bottomAnchor, constant: 20),
      bowlingButton.widthAnchor.constraint(equalToConstant: 200),
      bowlingButton.heightAnchor.constraint(equalToConstant: 50),
    ])
  }
  
  // Helper to create a button
  private func createButton(title: String, backgroundColor: UIColor) -> UIButton {
      let button = UIButton(type: .system)
      button.setTitle(title, for: .normal)
      button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
      button.tintColor = .white
      button.backgroundColor = backgroundColor
      button.layer.cornerRadius = 10
      button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      
      return button
  }
  // Button Actions
  @objc private func planeButtonTapped() {
    let planeVC = PlaneViewController()
    navigationController?.pushViewController(planeVC, animated: false)
  }
  
  @objc private func bowlingButtonTapped() {
    let bowlingVC = BowlingViewController()
    navigationController?.pushViewController(bowlingVC, animated: false)
  }
  
}
