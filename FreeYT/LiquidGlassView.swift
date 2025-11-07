//
//  LiquidGlassView.swift
//  FreeYT
//
//  Created by Claude Code
//  iOS 26 Liquid Glass Design Implementation
//

import SwiftUI
import SafariServices

/// Main view showcasing iOS 26 liquid glass design for FreeYT
struct LiquidGlassView: View {
    @State private var isExtensionEnabled = false
    @State private var checkingState = true

    var body: some View {
        ZStack {
            // Dynamic gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.2, green: 0.05, blue: 0.15),
                    Color(red: 0.15, green: 0.1, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    Spacer().frame(height: 20)

                    // App Icon with Glass Effect
                    AppIconSection()

                    // Title Section with Glass Effect
                    TitleSection()

                    // Status Card with Liquid Glass
                    StatusCard(isEnabled: isExtensionEnabled, isChecking: checkingState)

                    // Description Card with Glass Effect
                    DescriptionCard()

                    // Instructions Card with Glass Effect
                    InstructionsCard()

                    // Action Button with Glass Effect
                    ActionButton(isEnabled: isExtensionEnabled)

                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            checkExtensionStatus()
        }
    }

    private func checkExtensionStatus() {
        #if targetEnvironment(macCatalyst)
        if #available(iOS 15.0, *) {
            let extensionIdentifier = "com.freeyt.app.extension"
            SFSafariWebExtensionManager.getStateOfSafariWebExtension(withIdentifier: extensionIdentifier) { state, error in
                DispatchQueue.main.async {
                    checkingState = false
                    if let state = state {
                        isExtensionEnabled = state.isEnabled
                    }
                }
            }
        } else {
            checkingState = false
        }
        #else
        checkingState = false
        #endif
    }
}

// MARK: - App Icon Section
struct AppIconSection: View {
    var body: some View {
        ZStack {
            // Glass effect background
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 140, height: 140)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)

            // App icon
            Image("LargeIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 22))
        }
        .padding(.top, 20)
    }
}

// MARK: - Title Section
struct TitleSection: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("FreeYT")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color.white.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Privacy YouTube Extension")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - Status Card
struct StatusCard: View {
    let isEnabled: Bool
    let isChecking: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Status indicator with glass effect
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 50, height: 50)

                if isChecking {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: isEnabled ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(isEnabled ? .green : .orange)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(isChecking ? "Checking Status..." : (isEnabled ? "Extension Enabled" : "Extension Disabled"))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)

                Text(isEnabled ? "Your privacy is protected" : "Enable in Safari Settings")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
        )
    }
}

// MARK: - Description Card
struct DescriptionCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 20))
                    .foregroundColor(.blue.opacity(0.8))

                Text("Privacy Protection")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }

            Text("Automatically redirects YouTube links to privacy-enhanced no-cookie versions, protecting you from tracking.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Instructions Card
struct InstructionsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.number")
                    .font(.system(size: 20))
                    .foregroundColor(.purple.opacity(0.8))

                Text("How to Enable")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 12) {
                InstructionStep(number: "1", text: "Open Safari")
                InstructionStep(number: "2", text: "Go to Settings → Extensions")
                InstructionStep(number: "3", text: "Enable FreeYT Extension")
                InstructionStep(number: "4", text: "Grant necessary permissions")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }
}

struct InstructionStep: View {
    let number: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 28, height: 28)

                Text(number)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let isEnabled: Bool
    @State private var isPressed = false

    var body: some View {
        Button(action: openSafariSettings) {
            HStack(spacing: 8) {
                Image(systemName: isEnabled ? "checkmark.circle.fill" : "gear")
                    .font(.system(size: 18))

                Text(isEnabled ? "Extension Active" : "Open Safari Settings")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                ZStack {
                    // Gradient background
                    LinearGradient(
                        colors: isEnabled ? [
                            Color.green.opacity(0.6),
                            Color.green.opacity(0.4)
                        ] : [
                            Color.red.opacity(0.7),
                            Color.red.opacity(0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    // Glass overlay
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(isPressed ? 0.1 : 0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: (isEnabled ? Color.green : Color.red).opacity(0.3), radius: 15, x: 0, y: 8)
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .disabled(isEnabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }

    private func openSafariSettings() {
        if let url = URL(string: "App-prefs:SAFARI") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Preview
struct LiquidGlassView_Previews: PreviewProvider {
    static var previews: some View {
        LiquidGlassView()
            .preferredColorScheme(.dark)
    }
}
