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
      backgroundColor: .systemBlue
    )
    planeButton.addTarget(self, action: #selector(planeButtonTapped), for: .touchUpInside)

    let bowlingButton = createButton(
      title: "Bowling",
      backgroundColor: .systemGreen
    )
    bowlingButton.addTarget(self, action: #selector(bowlingButtonTapped), for: .touchUpInside)

    let emojiButton = createButton(
      title: "Emoji",
      backgroundColor: .systemYellow
    )
    emojiButton.addTarget(self, action: #selector(emojiButtonTapped), for: .touchUpInside)

    view.addSubview(planeButton)
    view.addSubview(bowlingButton)
    view.addSubview(emojiButton)

    planeButton.translatesAutoresizingMaskIntoConstraints = false
    bowlingButton.translatesAutoresizingMaskIntoConstraints = false
    emojiButton.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      planeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      planeButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
      planeButton.widthAnchor.constraint(equalToConstant: 200),
      planeButton.heightAnchor.constraint(equalToConstant: 50),

      // Bowling Button Constraints
      bowlingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      bowlingButton.topAnchor.constraint(equalTo: planeButton.bottomAnchor, constant: 20),
      bowlingButton.widthAnchor.constraint(equalToConstant: 200),
      bowlingButton.heightAnchor.constraint(equalToConstant: 50),

      emojiButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      emojiButton.topAnchor.constraint(equalTo: bowlingButton.bottomAnchor, constant: 20),
      emojiButton.widthAnchor.constraint(equalToConstant: 200),
      emojiButton.heightAnchor.constraint(equalToConstant: 50),
    ])
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

}
