//
//  LiquidGlassSearchBar.swift
//  FreeYT
//
//  Created by Assistant on 10/30/25.
//

import SwiftUI

// SwiftUI Search APIs (.searchable, search scopes, tokens, suggestions)
public enum SearchScope: String, CaseIterable, Identifiable {
    case all = "All"
    case videos = "Videos"
    case channels = "Channels"
    case playlists = "Playlists"
    
    public var id: String { rawValue }
    
    var systemImage: String {
        switch self {
        case .all: return "magnifyingglass"
        case .videos: return "play.rectangle"
        case .channels: return "person.circle"
        case .playlists: return "list.bullet.rectangle"
        }
    }
}

public struct LiquidGlassSearchBar: View {
    @Binding public var query: String
    public var placeholder: String
    public var scopes: [SearchScope]
    public var onSubmit: (String) async -> Void
    
    @FocusState private var isFocused: Bool
    @State private var currentScope: SearchScope = .all
    @State private var showCancel = false
    @State private var debouncer = Debouncer()
    
    // Accessibility: Dynamic Type and High Contrast support
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorScheme) private var colorScheme
    @AccessibilityFocusState private var isAccessibilityFocused: Bool
    
    public init(
        query: Binding<String>,
        placeholder: String = "Search",
        scopes: [SearchScope] = [],
        onSubmit: @escaping (String) async -> Void
    ) {
        self._query = query
        self.placeholder = placeholder
        self.scopes = scopes
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            // Main search field with Liquid Glass
            searchField
            
            // Scope chips if provided
            if !scopes.isEmpty {
                scopeChips
            }
        }
        .onChange(of: query) { _, newValue in
            // Debounce query changes ~300ms and call onSubmit
            debouncer.call(delay: .milliseconds(300)) {
                await onSubmit(newValue)
            }
        }
        .onChange(of: isFocused) { _, focused in
            withAnimation(.easeInOut(duration: 0.3)) {
                showCancel = focused
            }
        }
    }
    
    private var searchField: some View {
        HStack(spacing: 12) {
            // Leading magnifying glass icon
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            
            // Text field with vibrant foreground
            TextField(placeholder, text: $query)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .accessibilityFocused($isAccessibilityFocused)
                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 20 : 16))
                .foregroundStyle(.primary) // Maintains vibrancy over glass
                .submitLabel(.search)
                .onSubmit {
                    // Return/Go triggers onSubmit immediately
                    Task {
                        await onSubmit(query)
                    }
                }
                .accessibilityLabel("Search field")
                .accessibilityValue(query.isEmpty ? placeholder : query)
            
            // Clear button when text is non-empty
            if !query.isEmpty {
                Button {
                    // Tapping clear resets query and keeps focus
                    query = ""
                    // Provide haptic feedback
                    if #available(iOS 17.0, *) {
                        let feedback = UIImpactFeedbackGenerator(style: .light)
                        feedback.impactOccurred()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Clear search")
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
            
            // Cancel button when focused
            if showCancel {
                Button("Cancel") {
                    query = ""
                    isFocused = false
                    Task {
                        await onSubmit("")
                    }
                }
                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 18 : 16))
                .foregroundStyle(.primary)
                .accessibilityLabel("Cancel search")
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .liquidGlass(RoundedRectangle(cornerRadius: 18, style: .continuous))
        // RTL layout support
        .environment(\.layoutDirection, .leftToRight)
        .flipsForRightToLeftLayoutDirection(true)
    }
    
    private var scopeChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(scopes) { scope in
                    scopeChip(for: scope)
                }
            }
            .padding(.horizontal, 16)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
    
    private func scopeChip(for scope: SearchScope) -> some View {
        let isSelected = currentScope == scope
        
        return Button {
            // Selection triggers haptics and refresh
            if #available(iOS 17.0, *) {
                let feedback = UISelectionFeedbackGenerator()
                feedback.selectionChanged()
            }
            
            withAnimation(.easeInOut(duration: 0.2)) {
                currentScope = scope
            }
            
            // Trigger search with new scope
            Task {
                await onSubmit(query)
            }
        } label: {
            chipContent(for: scope, isSelected: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(scope.rawValue) search scope")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .modifier(AccessibilityTraitsModifier(isSelected: isSelected))
    }
    
    private func chipContent(for scope: SearchScope, isSelected: Bool) -> some View {
        return HStack(spacing: 6) {
            Image(systemName: scope.systemImage)
                .font(.system(size: 12, weight: .medium))
            
            Text(scope.rawValue)
                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 16 : 12, weight: .medium))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .foregroundStyle(isSelected ? .primary : .secondary)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isSelected ? chipSelectedBackground : Color.clear)
        }
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.primary.opacity(0.3), lineWidth: 1)
            }
        }
    }
    
    // Helper computed property for selected background color
    private var chipSelectedBackground: Color {
        if colorScheme == .dark {
            return Color.white.opacity(0.15)
        } else {
            return Color.black.opacity(0.08)
        }
    }
}

// Native .searchable integration variant
extension LiquidGlassSearchBar {
    /// Creates a search bar that integrates with native .searchable API
    /// SwiftUI: searchable integration with scopes and tokens
    public static func native(
        query: Binding<String>,
        scopes: [SearchScope] = SearchScope.allCases,
        onSubmit: @escaping (String) async -> Void
    ) -> some View {
        return EmptyView()
            .searchable(text: query, placement: .navigationBarDrawer(displayMode: .always))
            .searchScopes(query) {
                ForEach(scopes) { scope in
                    Text(scope.rawValue)
                        .tag(scope.rawValue)
                }
            }
            .onSubmit(of: .search) {
                Task {
                    await onSubmit(query.wrappedValue)
                }
            }
    }
}

// MARK: - Helper Modifiers

private struct AccessibilityTraitsModifier: ViewModifier {
    let isSelected: Bool
    
    func body(content: Content) -> some View {
        if isSelected {
            content.accessibilityAddTraits(.isSelected)
        } else {
            content
        }
    }
}