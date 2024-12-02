//
//  ViewController.swift
//  GameBoard
//
//  Created by Mekhak Ghapantsyan on 11/28/24.
//

import ARKit
import UIKit

class ViewController: UIViewController {

  private let configuration = ARWorldTrackingConfiguration()

  private lazy var sceneView: ARSCNView = {
    let sceneView = ARSCNView()
    sceneView.translatesAutoresizingMaskIntoConstraints = false
    sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
    return sceneView
  }()

  private lazy var bowlingGameButton: UIBarButtonItem = {
    var config = UIButton.Configuration.filled()
    config.title = "Play Bowling"
    config.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
    config.baseBackgroundColor = .white
    config.baseForegroundColor = .black
    config.cornerStyle = .capsule

    let barButtonItem = UIBarButtonItem()
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.configuration = config
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    button.heightAnchor.constraint(equalToConstant: 40).isActive = true
    button.addTarget(self, action: #selector(playBowlingAction), for: .touchUpInside)
    barButtonItem.customView = button
    return barButtonItem
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    setupSubViews()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    sceneView.session.run(configuration)
  }

  private func setupSubViews() {
    view.addSubview(sceneView)
    
    sceneView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

    navigationItem.rightBarButtonItem = bowlingGameButton
  }

  @objc private func playBowlingAction() {
    sceneView.session.pause()
    let bowlingVC = BowlingViewController()
    navigationController?.pushViewController(bowlingVC, animated: false)
  }

}
