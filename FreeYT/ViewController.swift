//
//  ViewController.swift
//  FreeYT
//
//  Created by Rishabh Bansal on 10/19/25.
//

import UIKit
import SafariServices

final class FreeYTViewController: UIViewController {

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "FreeYT"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Privacy YouTube Extension"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Automatically redirects YouTube links to privacy-enhanced no-cookie versions."
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.text = "To enable FreeYT:"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let stepsLabel: UILabel = {
        let label = UILabel()
        label.text = "1. Open Safari\n2. Go to Settings → Extensions\n3. Enable FreeYT Extension\n4. Grant necessary permissions"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let openSettingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open Safari Settings", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        #if targetEnvironment(macCatalyst)
        checkExtensionState()
        #endif
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Load icon
        if let iconImage = UIImage(named: "LargeIcon") {
            iconImageView.image = iconImage
        }

        // Add subviews
        view.addSubview(iconImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(instructionsLabel)
        view.addSubview(stepsLabel)
        view.addSubview(openSettingsButton)

        // Setup constraints
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 120),
            iconImageView.heightAnchor.constraint(equalToConstant: 120),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            descriptionLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            instructionsLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            instructionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            instructionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            stepsLabel.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 16),
            stepsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stepsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            openSettingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            openSettingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            openSettingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            openSettingsButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        openSettingsButton.addTarget(self, action: #selector(openSafariSettings), for: .touchUpInside)
    }

    @objc private func openSafariSettings() {
        if let url = URL(string: "App-prefs:SAFARI") {
            UIApplication.shared.open(url)
        }
    }

    #if targetEnvironment(macCatalyst)
    private func checkExtensionState() {
        if #available(iOS 15.0, *) {
            let extensionIdentifier = "com.freeyt.app.extension"
            SFSafariWebExtensionManager.getStateOfSafariWebExtension(withIdentifier: extensionIdentifier) { [weak self] state, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("[FreeYT] Extension state error:", error.localizedDescription)
                        return
                    }

                    guard let state = state else {
                        print("[FreeYT] Extension state unavailable")
                        return
                    }

                    if state.isEnabled {
                        self?.updateUIForEnabledState()
                    }
                }
            }
        }
    }

    private func updateUIForEnabledState() {
        instructionsLabel.text = "✓ Extension is enabled!"
        instructionsLabel.textColor = .systemGreen
        stepsLabel.text = "Your extension is active and protecting your privacy on YouTube."
        openSettingsButton.setTitle("Extension Enabled", for: .normal)
        openSettingsButton.backgroundColor = .systemGreen
        openSettingsButton.isEnabled = false
    }
    #endif

}
