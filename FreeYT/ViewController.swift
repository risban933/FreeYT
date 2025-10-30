//
//  ViewController.swift
//  FreeYT
//
//  Created by Rishabh Bansal on 10/19/25.
//

import UIKit
import SafariServices
import SwiftUI

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

    private let searchDemoButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        var config = UIButton.Configuration.tinted()
        config.title = "Try Search Demo"
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .systemBlue
        config.cornerStyle = .large
        config.buttonSize = .medium

        if #available(iOS 15.0, *) {
            config.image = UIImage(systemName: "magnifyingglass")
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
        
        // Check if this is first launch using OnboardingManager
        if OnboardingManager.shared.isFirstLaunch {
            showWelcomeAnimation()
        } else {
            animateEntrance()
        }

        #if targetEnvironment(macCatalyst)
        checkExtensionState()
        #endif
        
        // Add periodic extension state checking for better UX
        startPeriodicExtensionCheck()
        
        // Listen for onboarding completion notifications
        NotificationCenter.default.addObserver(
            self, 
            selector: #selector(onboardingCompleted), 
            name: OnboardingManager.Notification.onboardingCompleted, 
            object: nil
        )
        
        // Modern trait change registration
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { [weak self] (traitEnvironment: UITraitEnvironment, previousTraitCollection: UITraitCollection) in
            self?.updateGradientForTraitChanges()
        }
    }
    
    private func updateGradientForTraitChanges() {
        // Update gradient on theme change
        // Remove existing gradient layer safely
        if let gradientLayer = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradientLayer.removeFromSuperlayer()
        }
        setupGradientBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Mark that the app has been launched
        OnboardingManager.shared.markAppAsLaunched()
    }
    
    @objc private func onboardingCompleted() {
        // Handle any additional setup when onboarding is completed
        print("Onboarding completed! Analytics: \(OnboardingManager.shared.getOnboardingAnalytics())")
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
        contentStackView.addArrangedSubview(searchDemoButton)
        contentStackView.addArrangedSubview(statusIndicator)

        // Spacing customization
        contentStackView.setCustomSpacing(12, after: titleLabel)
        contentStackView.setCustomSpacing(32, after: subtitleLabel)
        contentStackView.setCustomSpacing(28, after: descriptionCard)
        contentStackView.setCustomSpacing(24, after: instructionsCard)

        setupConstraints()
        openSettingsButton.addTarget(self, action: #selector(openSafariSettings), for: .touchUpInside)
        searchDemoButton.addTarget(self, action: #selector(showSearchDemo), for: .touchUpInside)
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
            
            // Search Demo Button
            searchDemoButton.widthAnchor.constraint(equalTo: contentStackView.widthAnchor),
            searchDemoButton.heightAnchor.constraint(equalToConstant: 48),

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
        searchDemoButton.alpha = 0
        searchDemoButton.transform = CGAffineTransform(translationX: 0, y: 30)

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

        UIView.animate(withDuration: 0.5, delay: 0.7, options: .curveEaseOut) {
            self.searchDemoButton.alpha = 1
            self.searchDemoButton.transform = .identity
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

        // Show helpful feedback
        showSettingsGuidance()
        
        // Open settings with fallback options
        openSafariSettingsWithFallback()
    }
    
    private func showSettingsGuidance() {
        // Create a temporary guidance overlay
        let guidanceView = createGuidanceOverlay()
        view.addSubview(guidanceView)
        
        NSLayoutConstraint.activate([
            guidanceView.topAnchor.constraint(equalTo: openSettingsButton.bottomAnchor, constant: 16),
            guidanceView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            guidanceView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
        
        // Animate in
        guidanceView.alpha = 0
        guidanceView.transform = CGAffineTransform(translationX: 0, y: 10)
        UIView.animate(withDuration: 0.3) {
            guidanceView.alpha = 1
            guidanceView.transform = .identity
        }
        
        // Auto-remove after 8 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            UIView.animate(withDuration: 0.3) {
                guidanceView.alpha = 0
            } completion: { _ in
                guidanceView.removeFromSuperview()
            }
        }
    }
    
    private func createGuidanceOverlay() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "💡 Look for 'Extensions' in Safari Settings, then toggle FreeYT ON"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.numberOfLines = 0
        
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        return container
    }
    
    private func openSafariSettingsWithFallback() {
        // Try different URLs to open Safari settings
        let settingsURLs = [
            "App-prefs:SAFARI",
            "prefs:root=SAFARI",
            "App-prefs:root=SAFARI"
        ]
        
        var settingsOpened = false
        
        for urlString in settingsURLs {
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url) { success in
                    if success {
                        DispatchQueue.main.async {
                            // Check extension state after a delay to see if user enabled it
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                #if targetEnvironment(macCatalyst)
                                self.checkExtensionState()
                                #endif
                            }
                        }
                    }
                }
                settingsOpened = true
                break
            }
        }
        
        if !settingsOpened {
            // Fallback: show an alert with manual instructions
            showManualInstructionsAlert()
        }
    }
    
    private func showManualInstructionsAlert() {
        let alert = UIAlertController(
            title: "Open Safari Settings",
            message: "Please manually open Settings app → Safari → Extensions → Enable FreeYT",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Got it", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func showSearchDemo() {
        // Create and present the SwiftUI search demo
        let searchDemoView = SearchDemoView()
        let hostingController = UIHostingController(rootView: searchDemoView)
        hostingController.title = "Search Demo"
        
        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
        
        present(navigationController, animated: true)
    }

    // MARK: - Extension State

    #if targetEnvironment(macCatalyst)
    private func checkExtensionState() {
        if #available(iOS 15.0, *) {
            let extensionIdentifier = "com.freeyt.app.extension"
            SFSafariWebExtensionManager.getStateOfSafariWebExtension(withIdentifier: extensionIdentifier) { [weak self] state, error in
                DispatchQueue.main.async {
                    // Update last check time
                    OnboardingManager.shared.updateLastExtensionCheckDate()
                    
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
                        
                        // Mark onboarding as completed when extension is enabled
                        if !OnboardingManager.shared.hasCompletedOnboarding {
                            OnboardingManager.shared.markOnboardingAsCompleted()
                            OnboardingManager.shared.notifyOnboardingCompleted()
                        }
                        
                        // Notify about extension status change
                        OnboardingManager.shared.notifyExtensionStatusChanged(isEnabled: true)
                    }
                }
            }
        }
    }

    private func updateUIForEnabledState() {
        // Update instructions title with success state
        instructionsTitleLabel.text = "✅ Extension Enabled!"
        instructionsTitleLabel.textColor = .systemGreen
        
        // Hide individual instruction steps since they're complete
        instructionsStackView.arrangedSubviews.forEach { $0.alpha = 0.6 }
        
        // Add success message to instructions
        let successLabel = UILabel()
        successLabel.text = "🎉 Great! Your YouTube browsing is now privacy-protected."
        successLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        successLabel.textColor = .systemGreen
        successLabel.textAlignment = .center
        successLabel.numberOfLines = 0
        successLabel.alpha = 0
        successLabel.translatesAutoresizingMaskIntoConstraints = false
        
        instructionsStackView.addArrangedSubview(successLabel)
        
        // Update button to success state
        if #available(iOS 15.0, *) {
            var config = openSettingsButton.configuration
            config?.title = "✓ Extension Active & Working"
            config?.baseBackgroundColor = .systemGreen
            config?.image = UIImage(systemName: "checkmark.circle.fill")
            openSettingsButton.configuration = config
            openSettingsButton.isEnabled = false
        }

        // Show status with detailed information
        statusLabel.text = "🛡️ FreeYT is now redirecting YouTube links to privacy-enhanced versions automatically. Enjoy safer browsing!"
        statusLabel.textColor = .systemGreen
        statusIndicator.isHidden = false
        statusIndicator.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        statusIndicator.layer.borderWidth = 1
        statusIndicator.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.3).cgColor

        // Animate all success states
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseOut) {
            successLabel.alpha = 1
        }
        
        statusIndicator.alpha = 0
        statusIndicator.transform = CGAffineTransform(translationX: 0, y: 20)
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.statusIndicator.alpha = 1
            self.statusIndicator.transform = .identity
        }
        
        // Add a celebratory haptic feedback
        if #available(iOS 10.0, *) {
            let feedbackGenerator = UINotificationFeedbackGenerator()
            feedbackGenerator.notificationOccurred(.success)
        }
        
        // Show completion celebration
        showCompletionCelebration()
    }
    
    private func showCompletionCelebration() {
        // Create celebration emojis that animate across the screen
        let emojis = ["🎉", "🛡️", "✨", "🔒"]
        
        for (index, emoji) in emojis.enumerated() {
            let emojiLabel = UILabel()
            emojiLabel.text = emoji
            emojiLabel.font = UIFont.systemFont(ofSize: 30)
            emojiLabel.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(emojiLabel)
            
            // Position randomly along the top
            emojiLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
            emojiLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CGFloat(index * 80 + 40)).isActive = true
            
            // Initial state
            emojiLabel.alpha = 0
            emojiLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
            // Animate in with delay
            UIView.animate(withDuration: 0.8, delay: Double(index) * 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.3, options: .curveEaseOut) {
                emojiLabel.alpha = 1
                emojiLabel.transform = .identity
            } completion: { _ in
                // Animate out after a delay
                UIView.animate(withDuration: 0.5, delay: 2.0) {
                    emojiLabel.alpha = 0
                    emojiLabel.transform = CGAffineTransform(translationX: 0, y: -50)
                } completion: { _ in
                    emojiLabel.removeFromSuperview()
                }
            }
        }
    }
    #endif

    // MARK: - First Launch & Onboarding
    
    private func showWelcomeAnimation() {
        // Enhanced welcome animation for first-time users
        
        // Initial state - everything hidden and positioned
        let allAnimatableViews = [iconImageView, titleLabel, subtitleLabel, descriptionCard, instructionsCard, openSettingsButton]
        
        for view in allAnimatableViews {
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 50)
        }
        
        iconImageView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        
        // Show welcome message first
        showTemporaryWelcomeMessage()
        
        // Then animate main content after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.animateMainContent()
        }
    }
    
    private func showTemporaryWelcomeMessage() {
        let welcomeLabel = UILabel()
        welcomeLabel.text = "Welcome to FreeYT! 🎉"
        welcomeLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        welcomeLabel.textAlignment = .center
        welcomeLabel.alpha = 0
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(welcomeLabel)
        
        NSLayoutConstraint.activate([
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Animate welcome message
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: .curveEaseOut) {
            welcomeLabel.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0.5) {
                welcomeLabel.alpha = 0
            } completion: { _ in
                welcomeLabel.removeFromSuperview()
            }
        }
    }
    
    private func animateMainContent() {
        // Icon animation with bounce
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.3, options: .curveEaseOut) {
            self.iconImageView.alpha = 1
            self.iconImageView.transform = .identity
        }

        // Title with slide up
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
        }

        // Subtitle
        UIView.animate(withDuration: 0.6, delay: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.subtitleLabel.alpha = 1
            self.subtitleLabel.transform = .identity
        }

        // Description card
        UIView.animate(withDuration: 0.6, delay: 0.4, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.descriptionCard.alpha = 1
            self.descriptionCard.transform = .identity
        }

        // Instructions card
        UIView.animate(withDuration: 0.6, delay: 0.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.instructionsCard.alpha = 1
            self.instructionsCard.transform = .identity
        }

        // Settings button with special highlight animation
        UIView.animate(withDuration: 0.6, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.openSettingsButton.alpha = 1
            self.openSettingsButton.transform = .identity
        } completion: { _ in
            self.highlightSettingsButton()
        }
        
        // Search demo button
        UIView.animate(withDuration: 0.6, delay: 0.7, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.searchDemoButton.alpha = 1
            self.searchDemoButton.transform = .identity
        }
    }
    
    private func highlightSettingsButton() {
        // Subtle pulse animation to draw attention to the button
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction]) {
            self.openSettingsButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }
        
        // Stop the pulse after a few cycles
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            UIView.animate(withDuration: 0.3) {
                self.openSettingsButton.transform = .identity
            }
        }
    }
    
    // MARK: - Periodic Extension Checking
    
    private var extensionCheckTimer: Timer?
    
    private func startPeriodicExtensionCheck() {
        #if targetEnvironment(macCatalyst)
        // Check extension state periodically using OnboardingManager's smart timing
        extensionCheckTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            if OnboardingManager.shared.shouldCheckExtensionStatus {
                self?.checkExtensionState()
            }
        }
        #endif
    }
    
    private func stopPeriodicExtensionCheck() {
        extensionCheckTimer?.invalidate()
        extensionCheckTimer = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopPeriodicExtensionCheck()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopPeriodicExtensionCheck()
    }
}
