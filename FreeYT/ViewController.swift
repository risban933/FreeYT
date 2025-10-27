//
//  ViewController.swift
//  FreeYT
//
//  Created by Rishabh Bansal on 10/19/25.
//

import UIKit
import SafariServices

final class FreeYTViewController: UIViewController {

    // MARK: - UI Components

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let iconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 32
        imageView.layer.masksToBounds = true
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 8)
        imageView.layer.shadowOpacity = 0.25
        imageView.layer.shadowRadius = 16
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "FreeYT"
        label.font = UIFont.systemFont(ofSize: 42, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Privacy YouTube Extension"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 12
        return view
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Automatically redirects YouTube links to privacy-enhanced no-cookie versions for safer browsing."
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let instructionsCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 12
        return view
    }()

    private let instructionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let instructionsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "How to Enable"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let openSettingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        var config = UIButton.Configuration.filled()
        config.title = "Open Safari Settings"
        config.baseBackgroundColor = .systemRed
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        config.buttonSize = .large

        if #available(iOS 15.0, *) {
            config.image = UIImage(systemName: "safari")
            config.imagePadding = 8
            config.imagePlacement = .leading
        }

        button.configuration = config
        return button
    }()

    private let statusIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 8
        view.isHidden = true
        return view
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGradientBackground()
        animateEntrance()

        #if targetEnvironment(macCatalyst)
        checkExtensionState()
        #endif
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Add scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        // Load icon
        if let iconImage = UIImage(named: "LargeIcon") {
            iconImageView.image = iconImage
        }

        // Build icon container
        iconContainerView.addSubview(iconImageView)

        // Build description card
        descriptionCard.addSubview(descriptionLabel)

        // Build instructions card
        instructionsCard.addSubview(instructionsTitleLabel)
        instructionsCard.addSubview(instructionsStackView)

        // Add instruction steps with SF Symbols
        addInstructionStep(number: 1, icon: "1.circle.fill", text: "Open Safari on your device")
        addInstructionStep(number: 2, icon: "2.circle.fill", text: "Go to Settings → Extensions")
        addInstructionStep(number: 3, icon: "3.circle.fill", text: "Enable 'FreeYT Extension'")
        addInstructionStep(number: 4, icon: "4.circle.fill", text: "Grant necessary permissions")

        // Build status indicator
        statusIndicator.addSubview(statusLabel)

        // Add all to stack
        contentStackView.addArrangedSubview(iconContainerView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(subtitleLabel)
        contentStackView.addArrangedSubview(descriptionCard)
        contentStackView.addArrangedSubview(instructionsCard)
        contentStackView.addArrangedSubview(openSettingsButton)
        contentStackView.addArrangedSubview(statusIndicator)

        // Spacing customization
        contentStackView.setCustomSpacing(12, after: titleLabel)
        contentStackView.setCustomSpacing(32, after: subtitleLabel)
        contentStackView.setCustomSpacing(28, after: descriptionCard)
        contentStackView.setCustomSpacing(24, after: instructionsCard)

        setupConstraints()
        openSettingsButton.addTarget(self, action: #selector(openSafariSettings), for: .touchUpInside)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content stack
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 60),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48),

            // Icon
            iconImageView.topAnchor.constraint(equalTo: iconContainerView.topAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: iconContainerView.leadingAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: iconContainerView.trailingAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: iconContainerView.bottomAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 140),
            iconImageView.heightAnchor.constraint(equalToConstant: 140),

            // Description card
            descriptionCard.widthAnchor.constraint(equalTo: contentStackView.widthAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: descriptionCard.topAnchor, constant: 24),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionCard.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionCard.trailingAnchor, constant: -24),
            descriptionLabel.bottomAnchor.constraint(equalTo: descriptionCard.bottomAnchor, constant: -24),

            // Instructions card
            instructionsCard.widthAnchor.constraint(equalTo: contentStackView.widthAnchor),
            instructionsTitleLabel.topAnchor.constraint(equalTo: instructionsCard.topAnchor, constant: 24),
            instructionsTitleLabel.centerXAnchor.constraint(equalTo: instructionsCard.centerXAnchor),

            instructionsStackView.topAnchor.constraint(equalTo: instructionsTitleLabel.bottomAnchor, constant: 20),
            instructionsStackView.leadingAnchor.constraint(equalTo: instructionsCard.leadingAnchor, constant: 24),
            instructionsStackView.trailingAnchor.constraint(equalTo: instructionsCard.trailingAnchor, constant: -24),
            instructionsStackView.bottomAnchor.constraint(equalTo: instructionsCard.bottomAnchor, constant: -24),

            // Button
            openSettingsButton.widthAnchor.constraint(equalTo: contentStackView.widthAnchor),
            openSettingsButton.heightAnchor.constraint(equalToConstant: 56),

            // Status indicator
            statusIndicator.widthAnchor.constraint(equalTo: contentStackView.widthAnchor),
            statusLabel.topAnchor.constraint(equalTo: statusIndicator.topAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: statusIndicator.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: statusIndicator.trailingAnchor, constant: -20),
            statusLabel.bottomAnchor.constraint(equalTo: statusIndicator.bottomAnchor, constant: -16)
        ])
    }

    private func addInstructionStep(number: Int, icon: String, text: String) {
        let stepContainer = UIStackView()
        stepContainer.axis = .horizontal
        stepContainer.spacing = 12
        stepContainer.alignment = .center

        let iconImageView = UIImageView()
        if #available(iOS 13.0, *) {
            iconImageView.image = UIImage(systemName: icon)
            iconImageView.tintColor = .systemRed
        }
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel.textColor = .label
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        stepContainer.addArrangedSubview(iconImageView)
        stepContainer.addArrangedSubview(textLabel)

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28)
        ])

        instructionsStackView.addArrangedSubview(stepContainer)
    }

    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds

        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                gradientLayer.colors = [
                    UIColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 1.0).cgColor,
                    UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1.0).cgColor
                ]
            } else {
                gradientLayer.colors = [
                    UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0).cgColor,
                    UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
                ]
            }
        } else {
            gradientLayer.colors = [
                UIColor.white.cgColor,
                UIColor(white: 0.98, alpha: 1.0).cgColor
            ]
        }

        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func animateEntrance() {
        // Initial state
        iconImageView.alpha = 0
        iconImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        titleLabel.alpha = 0
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        subtitleLabel.alpha = 0
        subtitleLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        descriptionCard.alpha = 0
        descriptionCard.transform = CGAffineTransform(translationX: 0, y: 30)
        instructionsCard.alpha = 0
        instructionsCard.transform = CGAffineTransform(translationX: 0, y: 30)
        openSettingsButton.alpha = 0
        openSettingsButton.transform = CGAffineTransform(translationX: 0, y: 30)

        // Animate in sequence
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.iconImageView.alpha = 1
            self.iconImageView.transform = .identity
        }

        UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
        }

        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut) {
            self.subtitleLabel.alpha = 1
            self.subtitleLabel.transform = .identity
        }

        UIView.animate(withDuration: 0.5, delay: 0.4, options: .curveEaseOut) {
            self.descriptionCard.alpha = 1
            self.descriptionCard.transform = .identity
        }

        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut) {
            self.instructionsCard.alpha = 1
            self.instructionsCard.transform = .identity
        }

        UIView.animate(withDuration: 0.5, delay: 0.6, options: .curveEaseOut) {
            self.openSettingsButton.alpha = 1
            self.openSettingsButton.transform = .identity
        }
    }

    // MARK: - Actions

    @objc private func openSafariSettings() {
        // Add button press animation
        UIView.animate(withDuration: 0.1, animations: {
            self.openSettingsButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.openSettingsButton.transform = .identity
            }
        }

        if let url = URL(string: "App-prefs:SAFARI") {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Extension State

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
        instructionsTitleLabel.text = "✓ Extension Enabled!"
        instructionsTitleLabel.textColor = .systemGreen

        // Update button
        if #available(iOS 15.0, *) {
            var config = openSettingsButton.configuration
            config?.title = "Extension Active"
            config?.baseBackgroundColor = .systemGreen
            config?.image = UIImage(systemName: "checkmark.circle.fill")
            openSettingsButton.configuration = config
            openSettingsButton.isEnabled = false
        }

        // Show status
        statusLabel.text = "✓ Your extension is active and protecting your privacy on YouTube."
        statusLabel.textColor = .systemGreen
        statusIndicator.isHidden = false
        statusIndicator.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)

        // Animate status appearance
        statusIndicator.alpha = 0
        statusIndicator.transform = CGAffineTransform(translationX: 0, y: 20)
        UIView.animate(withDuration: 0.5, delay: 0.7, options: .curveEaseOut) {
            self.statusIndicator.alpha = 1
            self.statusIndicator.transform = .identity
        }
    }
    #endif

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Update gradient on theme change
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                view.layer.sublayers?.first?.removeFromSuperlayer()
                setupGradientBackground()
            }
        }
    }
}
