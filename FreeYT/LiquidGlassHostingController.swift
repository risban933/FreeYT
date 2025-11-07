//
//  LiquidGlassHostingController.swift
//  FreeYT
//
//  Created by Claude Code
//  SwiftUI Hosting Controller for Liquid Glass View
//

import UIKit
import SwiftUI

/// UIHostingController to bridge SwiftUI LiquidGlassView with UIKit app lifecycle
final class LiquidGlassHostingController: UIHostingController<LiquidGlassView> {

    init() {
        super.init(rootView: LiquidGlassView())
        setupAppearance()
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupAppearance() {
        // Transparent navigation bar for seamless glass effect
        navigationController?.navigationBar.isHidden = true

        // Ensure dark mode for optimal glass effect visibility
        overrideUserInterfaceStyle = .dark

        // Transparent background
        view.backgroundColor = .clear
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Hide navigation bar if present
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
