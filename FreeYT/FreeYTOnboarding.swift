//
//  FreeYTOnboarding.swift
//  FreeYT
//
//  Modern Liquid Glass Onboarding Experience
//

import SwiftUI
import Combine
import SafariServices

// MARK: - Main Onboarding View
struct FreeYTOnboardingView: View {
    @StateObject private var onboardingVM = OnboardingViewModel()
    @State private var currentPage = 0
    @State private var showingMainApp = false
    @Namespace private var namespace
    
    var body: some View {
        ZStack {
            // Dynamic gradient background
            DynamicGradientBackground()
            
            // Floating particles effect
            ParticleFieldView()
            
            if !showingMainApp {
                OnboardingPagerView(
                    currentPage: $currentPage,
                    showingMainApp: $showingMainApp,
                    namespace: namespace
                )
                .environmentObject(onboardingVM)
            } else {
                MainAppView()
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(!showingMainApp)
    }
}

// MARK: - Liquid Glass Modifier
struct LiquidGlassModifier: ViewModifier {
    let cornerRadius: CGFloat
    let blurRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
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
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat = 20, blurRadius: CGFloat = 10) -> some View {
        modifier(LiquidGlassModifier(cornerRadius: cornerRadius, blurRadius: blurRadius))
    }
}

// MARK: - Onboarding Pager
struct OnboardingPagerView: View {
    @Binding var currentPage: Int
    @Binding var showingMainApp: Bool
    let namespace: Namespace.ID
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Page content
                TabView(selection: $currentPage) {
                    WelcomePage(namespace: namespace)
                        .tag(0)
                    
                    PrivacyPage()
                        .tag(1)
                    
                    FeaturePage()
                        .tag(2)
                    
                    SetupPage(showingMainApp: $showingMainApp)
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)
                
                // Custom page indicator
                VStack {
                    Spacer()
                    
                    CustomPageIndicator(currentPage: $currentPage, totalPages: 4)
                        .padding(.bottom, 50)
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Welcome Page
struct WelcomePage: View {
    let namespace: Namespace.ID
    @State private var logoScale: CGFloat = 0.5
    @State private var titleOpacity: Double = 0
    @State private var subtitleOffset: CGFloat = 50
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated logo with glass effect
            ZStack {
                // Pulse effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.red.opacity(0.3),
                                Color.red.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 50,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .scaleEffect(pulseAnimation ? 1.2 : 0.8)
                    .opacity(pulseAnimation ? 0 : 0.8)
                    .animation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: false),
                        value: pulseAnimation
                    )
                
                // Logo container
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: 180, height: 180)
                    .overlay(
                        Image(systemName: "play.shield.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.red, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .red.opacity(0.5), radius: 20)
                    )
                    .liquidGlass(cornerRadius: 40)
                    .scaleEffect(logoScale)
                    .matchedGeometryEffect(id: "logo", in: namespace)
            }
            
            VStack(spacing: 20) {
                Text("FreeYT")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(titleOpacity)
                
                Text("Privacy-First YouTube Experience")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .offset(y: subtitleOffset)
                    .opacity(titleOpacity)
            }
            
            Spacer()
            
            // Swipe indicator
            HStack(spacing: 5) {
                Image(systemName: "chevron.left")
                Text("Swipe to begin")
                Image(systemName: "chevron.left")
            }
            .font(.caption)
            .foregroundColor(.white.opacity(0.5))
            .padding(.bottom, 30)
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.7)) {
                logoScale = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                titleOpacity = 1.0
            }
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5)) {
                subtitleOffset = 0
            }
            
            pulseAnimation = true
            
            // Haptic feedback
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
}

// MARK: - Privacy Page
struct PrivacyPage: View {
    @State private var features: [PrivacyFeature] = []
    @State private var animateFeatures = false
    
    struct PrivacyFeature: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let description: String
        let color: Color
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 15) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .blue.opacity(0.5), radius: 20)
                
                Text("Your Privacy Matters")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Text("We protect your YouTube browsing")
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.top, 60)
            
            // Privacy features grid
            VStack(spacing: 20) {
                ForEach(Array(features.enumerated()), id: \.element.id) { index, feature in
                    PrivacyFeatureCard(feature: feature)
                        .scaleEffect(animateFeatures ? 1 : 0.8)
                        .opacity(animateFeatures ? 1 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8)
                            .delay(Double(index) * 0.1),
                            value: animateFeatures
                        )
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .onAppear {
            features = [
                PrivacyFeature(
                    icon: "eye.slash.fill",
                    title: "No Tracking",
                    description: "Blocks YouTube tracking cookies",
                    color: .blue
                ),
                PrivacyFeature(
                    icon: "shield.lefthalf.filled",
                    title: "Enhanced Privacy",
                    description: "Routes through privacy-safe domains",
                    color: .green
                ),
                PrivacyFeature(
                    icon: "lock.icloud.fill",
                    title: "Secure Browsing",
                    description: "Your data stays on your device",
                    color: .purple
                ),
                PrivacyFeature(
                    icon: "hand.raised.fill",
                    title: "Ad Protection",
                    description: "Reduces targeted advertising",
                    color: .orange
                )
            ]
            
            withAnimation {
                animateFeatures = true
            }
            
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}

struct PrivacyFeatureCard: View {
    let feature: PrivacyPage.PrivacyFeature
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(feature.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: feature.icon)
                    .font(.title2)
                    .foregroundColor(feature.color)
            }
            
            // Text
            VStack(alignment: .leading, spacing: 5) {
                Text(feature.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(feature.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding()
        .liquidGlass(cornerRadius: 16)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
        }
    }
}

// MARK: - Feature Page
struct FeaturePage: View {
    @State private var selectedFeature = 0
    @State private var autoScroll = true
    
    let features = [
        ("Instant Redirect", "play.rectangle.fill", "Automatically converts YouTube links", Color.red),
        ("Smart Search", "magnifyingglass", "Privacy-enhanced search experience", Color.blue),
        ("Background Play", "play.circle.fill", "Continue listening with screen off", Color.green),
        ("Download Later", "arrow.down.circle.fill", "Save videos for offline viewing", Color.purple)
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Powerful Features")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
                .padding(.top, 60)
            
            // Interactive feature carousel
            GeometryReader { geometry in
                ZStack {
                    ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                        FeatureCard(
                            title: feature.0,
                            icon: feature.1,
                            description: feature.2,
                            color: feature.3,
                            isSelected: index == selectedFeature
                        )
                        .offset(x: CGFloat(index - selectedFeature) * (geometry.size.width * 0.8))
                        .scaleEffect(index == selectedFeature ? 1.0 : 0.85)
                        .opacity(abs(index - selectedFeature) <= 1 ? 1.0 : 0.3)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedFeature)
                        .onTapGesture {
                            withAnimation {
                                selectedFeature = index
                                autoScroll = false
                            }
                            UISelectionFeedbackGenerator().selectionChanged()
                        }
                    }
                }
            }
            .frame(height: 400)
            
            // Feature dots
            HStack(spacing: 10) {
                ForEach(0..<features.count, id: \.self) { index in
                    Circle()
                        .fill(index == selectedFeature ? Color.white : Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: selectedFeature)
                }
            }
            
            Spacer()
        }
        .onAppear {
            startAutoScroll()
        }
    }
    
    func startAutoScroll() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            if autoScroll {
                withAnimation {
                    selectedFeature = (selectedFeature + 1) % features.count
                }
            } else {
                timer.invalidate()
            }
        }
    }
}

struct FeatureCard: View {
    let title: String
    let icon: String
    let description: String
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 25) {
            // Icon with animation
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color.opacity(0.3), color.opacity(0.1)],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundColor(color)
                    .rotationEffect(.degrees(isSelected ? 10 : 0))
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isSelected)
            }
            
            VStack(spacing: 10) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if isSelected {
                Text("Available Now")
                    .font(.caption)
                    .foregroundColor(color)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(color.opacity(0.2))
                            .overlay(
                                Capsule()
                                    .strokeBorder(color.opacity(0.5), lineWidth: 1)
                            )
                    )
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(30)
        .frame(width: 280, height: 380)
        .liquidGlass(cornerRadius: 30)
    }
}

// MARK: - Setup Page
struct SetupPage: View {
    @Binding var showingMainApp: Bool
    @State private var isSettingUp = false
    @State private var setupProgress: CGFloat = 0
    @State private var setupSteps: [SetupStep] = []
    @State private var currentStep = 0
    
    struct SetupStep: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
        var completed: Bool = false
    }
    
    var body: some View {
        VStack(spacing: 40) {
            // Header
            VStack(spacing: 15) {
                Image(systemName: "gear.badge.checkmark")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.pulse, value: isSettingUp)
                
                Text("Quick Setup")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Text("Enable the extension in Safari")
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.top, 60)
            
            // Setup steps
            VStack(spacing: 20) {
                ForEach(Array(setupSteps.enumerated()), id: \.element.id) { index, step in
                    SetupStepView(
                        step: step,
                        isActive: index == currentStep,
                        stepNumber: index + 1
                    )
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 15) {
                Button(action: startSetup) {
                    HStack {
                        if isSettingUp {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "safari")
                        }
                        
                        Text(isSettingUp ? "Opening Safari..." : "Open Safari Settings")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .disabled(isSettingUp)
                
                Button(action: skipSetup) {
                    Text("Skip for now")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.callout)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 50)
        }
        .onAppear {
            setupSteps = [
                SetupStep(title: "Open Safari Settings", icon: "safari"),
                SetupStep(title: "Go to Extensions", icon: "puzzlepiece.extension"),
                SetupStep(title: "Enable FreeYT", icon: "checkmark.circle"),
                SetupStep(title: "Grant Permissions", icon: "hand.raised")
            ]
        }
    }
    
    func startSetup() {
        withAnimation {
            isSettingUp = true
        }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // Simulate opening Safari settings
        if let url = URL(string: "App-prefs:SAFARI") {
            UIApplication.shared.open(url)
        }
        
        // Simulate progress
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            withAnimation {
                currentStep = min(currentStep + 1, setupSteps.count - 1)
                setupProgress = CGFloat(currentStep + 1) / CGFloat(setupSteps.count)
            }
            
            if currentStep >= setupSteps.count - 1 {
                timer.invalidate()
                completeSetup()
            }
        }
    }
    
    func skipSetup() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showingMainApp = true
        }
    }
    
    func completeSetup() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showingMainApp = true
            }
        }
    }
}

struct SetupStepView: View {
    let step: SetupPage.SetupStep
    let isActive: Bool
    let stepNumber: Int
    
    var body: some View {
        HStack(spacing: 20) {
            // Step number
            ZStack {
                Circle()
                    .fill(isActive ? Color.green : Color.white.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                if step.completed {
                    Image(systemName: "checkmark")
                        .font(.body.bold())
                        .foregroundColor(.white)
                } else {
                    Text("\(stepNumber)")
                        .font(.body.bold())
                        .foregroundColor(isActive ? .white : .white.opacity(0.5))
                }
            }
            
            // Step content
            VStack(alignment: .leading, spacing: 5) {
                Text(step.title)
                    .font(.headline)
                    .foregroundColor(isActive ? .white : .white.opacity(0.7))
                
                if isActive {
                    Text("In progress...")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            // Icon
            Image(systemName: step.icon)
                .font(.title2)
                .foregroundColor(isActive ? .green : .white.opacity(0.3))
                .scaleEffect(isActive ? 1.1 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isActive)
        }
        .padding()
        .liquidGlass(cornerRadius: 16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    isActive ? Color.green.opacity(0.5) : Color.clear,
                    lineWidth: 2
                )
        )
    }
}

// MARK: - Supporting Views
struct CustomPageIndicator: View {
    @Binding var currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(0..<totalPages, id: \.self) { page in
                Capsule()
                    .fill(currentPage == page ? Color.white : Color.white.opacity(0.3))
                    .frame(width: currentPage == page ? 30 : 10, height: 10)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentPage)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .liquidGlass(cornerRadius: 25, blurRadius: 5)
    }
}

struct DynamicGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.1, blue: 0.2),
                Color(red: 0.15, green: 0.05, blue: 0.25),
                Color(red: 0.05, green: 0.05, blue: 0.15)
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

struct ParticleFieldView: View {
    @State private var particles: [Particle] = []
    @State private var screenSize: CGSize = .zero
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
    }
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.white.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(x: particle.x, y: particle.y)
                    .blur(radius: 1)
            }
            .onAppear {
                screenSize = geometry.size
                generateParticles()
            }
            .onChange(of: geometry.size) { _, newSize in
                screenSize = newSize
            }
        }
        .ignoresSafeArea()
    }
    
    func generateParticles() {
        guard screenSize != .zero else { return }
        
        for _ in 0..<30 {
            particles.append(
                Particle(
                    x: CGFloat.random(in: 0...screenSize.width),
                    y: CGFloat.random(in: 0...screenSize.height),
                    size: CGFloat.random(in: 2...6),
                    opacity: Double.random(in: 0.1...0.3)
                )
            )
        }
        
        animateParticles()
    }
    
    func animateParticles() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            withAnimation(.linear(duration: 0.05)) {
                for index in particles.indices {
                    particles[index].y -= 1
                    
                    if particles[index].y < -10 {
                        particles[index].y = screenSize.height + 10
                        particles[index].x = CGFloat.random(in: 0...screenSize.width)
                    }
                }
            }
        }
    }
    }


// MARK: - Main App View
struct MainAppView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "rectangle.stack.fill")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
    }
}

// Placeholder views for main app tabs
struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<5) { _ in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .frame(height: 200)
                            .liquidGlass(cornerRadius: 16)
                    }
                }
                .padding()
            }
            .navigationTitle("FreeYT")
            .background(DynamicGradientBackground())
        }
    }
}

struct SearchView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Search")
            .background(DynamicGradientBackground())
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.6))
            
            TextField("Search YouTube", text: $text)
                .foregroundColor(.white)
        }
        .padding()
        .liquidGlass(cornerRadius: 16)
    }
}

struct LibraryView: View {
    var body: some View {
        NavigationView {
            Text("Library")
                .navigationTitle("Library")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Extension") {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Extension Active")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - View Model
class OnboardingViewModel: ObservableObject {
    @Published var hasCompletedOnboarding = false
    @Published var extensionEnabled = false
    
    init() {
        checkOnboardingStatus()
    }
    
    func checkOnboardingStatus() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "HasCompletedOnboarding")
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "HasCompletedOnboarding")
        hasCompletedOnboarding = true
    }
}

// MARK: - App Entry Point
struct FreeYTApp: App {
    var body: some Scene {
        WindowGroup {
            FreeYTOnboardingView()
        }
    }
}
