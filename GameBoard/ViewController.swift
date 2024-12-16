//
//  ViewController.swift
//  GameBoard
//
//  Created by Mekhak Ghapantsyan on 11/28/24.
//

import UIKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.backgroundColor = .clear
    view.addSubview(scrollView)
    
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(containerView)
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    
    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
    ])
    
    let buttons = [
      ("Plane", UIColor.systemGreen, #selector(planeButtonTapped)),
      ("Bowling", UIColor.systemPink, #selector(bowlingButtonTapped)),
      ("Emoji", UIColor.purple, #selector(emojiButtonTapped)),
      ("Mask", UIColor.systemYellow, #selector(maskButtonTapped)),
      ("Shooter", UIColor.systemBlue, #selector(shooterButtonTapped)),
      ("Body", UIColor.orange, #selector(bodyButtonTapped)),
      ("Number", UIColor.systemPink, #selector(numberButtonTapped)),
      ("Face", UIColor.systemMint, #selector(faceButtonTapped)),
      ("Obstacles", UIColor.magenta, #selector(obstaclesButtonTapped)),
      ("Table", UIColor.purple, #selector(tableButtonTapped)),
      ("Zoo", UIColor.red, #selector(zooButtonTapped)),
    ]
    
    var previousButton: UIButton?
    
    for (title, color, action) in buttons {
      let button = createButton(title: title, backgroundColor: color)
      button.addTarget(self, action: action, for: .touchUpInside)
      containerView.addSubview(button)
      button.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        button.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
        button.widthAnchor.constraint(equalToConstant: 200),
        button.heightAnchor.constraint(equalToConstant: 50),
        button.topAnchor.constraint(equalTo: previousButton?.bottomAnchor ?? containerView.topAnchor, constant: 20),
      ])
      
      previousButton = button
    }
    
    if let lastButton = previousButton {
      NSLayoutConstraint.activate([
        lastButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
      ])
    }
  }
  
  private func createButton(title: String, backgroundColor: UIColor) -> UIButton {
    let button = UIButton(type: .system)
    button.setTitle(title, for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
    button.tintColor = .white
    button.backgroundColor = backgroundColor
    button.layer.cornerRadius = 10
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
  
  @objc private func numberButtonTapped() {
    let numberVC = NumberViewController()
    navigationController?.pushViewController(numberVC, animated: false)
  }
  
  @objc private func faceButtonTapped() {
    let faceVC = FaceViewController()
    navigationController?.pushViewController(faceVC, animated: false)
  }
  
  @objc private func obstaclesButtonTapped() {
    let obstacleVC = ObstaclesViewController()
    navigationController?.pushViewController(obstacleVC, animated: false)
  }
  
  @objc private func tableButtonTapped() {
    let tableVC = TableViewController()
    navigationController?.pushViewController(tableVC, animated: false)
  }
  
  @objc private func zooButtonTapped() {
    let zooVC = ZooViewController()
    navigationController?.pushViewController(zooVC, animated: false)
  }
}
