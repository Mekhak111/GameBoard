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
    
    let planeButton = createButton(
      title: "Plane",
      backgroundColor: .systemGreen
    )
    planeButton.addTarget(self, action: #selector(planeButtonTapped), for: .touchUpInside)
    
    let bowlingButton = createButton(
      title: "Bowling",
      backgroundColor: .systemPink
    )
    bowlingButton.addTarget(self, action: #selector(bowlingButtonTapped), for: .touchUpInside)
    
    let emojiButton = createButton(
      title: "Emoji",
      backgroundColor: .purple
    )
    emojiButton.addTarget(self, action: #selector(emojiButtonTapped), for: .touchUpInside)
    
    let maskButton = createButton(
      title: "Mask",
      backgroundColor: .systemYellow
    )
    maskButton.addTarget(self, action: #selector(maskButtonTapped), for: .touchUpInside)
    
    let shooterButton = createButton(
      title: "Shooter",
      backgroundColor: .systemBlue
    )
    shooterButton.addTarget(self, action: #selector(shooterButtonTapped), for: .touchUpInside)
    
    let bodyButton = createButton(
      title: "Body",
      backgroundColor: .orange
    )
    bodyButton.addTarget(self, action: #selector(bodyButtonTapped), for: .touchUpInside)

    
    view.addSubview(planeButton)
    view.addSubview(bowlingButton)
    view.addSubview(emojiButton)
    view.addSubview(maskButton)
    view.addSubview(shooterButton)
    view.addSubview(bodyButton)
    
    planeButton.translatesAutoresizingMaskIntoConstraints = false
    bowlingButton.translatesAutoresizingMaskIntoConstraints = false
    emojiButton.translatesAutoresizingMaskIntoConstraints = false
    maskButton.translatesAutoresizingMaskIntoConstraints = false
    shooterButton.translatesAutoresizingMaskIntoConstraints = false
    bodyButton.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      planeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      planeButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
      planeButton.widthAnchor.constraint(equalToConstant: 200),
      planeButton.heightAnchor.constraint(equalToConstant: 50),
      
      bowlingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      bowlingButton.topAnchor.constraint(equalTo: planeButton.bottomAnchor, constant: 20),
      bowlingButton.widthAnchor.constraint(equalToConstant: 200),
      bowlingButton.heightAnchor.constraint(equalToConstant: 50),
      
      emojiButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      emojiButton.topAnchor.constraint(equalTo: bowlingButton.bottomAnchor, constant:20),
      emojiButton.widthAnchor.constraint(equalToConstant: 200),
      emojiButton.heightAnchor.constraint(equalToConstant: 50),
      
      maskButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      maskButton.topAnchor.constraint(equalTo: emojiButton.bottomAnchor, constant:20),
      maskButton.widthAnchor.constraint(equalToConstant: 200),
      maskButton.heightAnchor.constraint(equalToConstant: 50),
      
      shooterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      shooterButton.topAnchor.constraint(equalTo: maskButton.bottomAnchor, constant:20),
      shooterButton.widthAnchor.constraint(equalToConstant: 200),
      shooterButton.heightAnchor.constraint(equalToConstant: 50),
      
      bodyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      bodyButton.topAnchor.constraint(equalTo: shooterButton.bottomAnchor, constant:20),
      bodyButton.widthAnchor.constraint(equalToConstant: 200),
      bodyButton.heightAnchor.constraint(equalToConstant: 50),
    ])
  }
  
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
  
  @objc private func planeButtonTapped() {
    let planeVC = PlaneViewController()
    navigationController?.pushViewController(planeVC, animated: false)
  }
  
  @objc private func bowlingButtonTapped() {
    let bowlingVC = BowlingViewController()
    navigationController?.pushViewController(bowlingVC, animated: false)
  }
  
  @objc private func emojiButtonTapped() {
    let emojiVC = EmojiViewController()
    navigationController?.pushViewController(emojiVC, animated: false)
  }
  
  @objc private func maskButtonTapped() {
    let maskVC = MaskViewController()
    navigationController?.pushViewController(maskVC, animated: false)
  }
  
  @objc private func shooterButtonTapped() {
    let shooterVC = ShooterViewController()
    navigationController?.pushViewController(shooterVC, animated: false)
  }
  
  @objc private func bodyButtonTapped() {
    let bodyVC = BodyViewController()
    navigationController?.pushViewController(bodyVC, animated: false)
  }
  
}
