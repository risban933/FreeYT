//
//  LiquidGlassBackgroundView.swift
//  FreeYT
//
//  Created by Assistant on 10/30/25.
//

import SwiftUI

// HIG: Materials - proper blur, vibrancy, and blending for legibility and depth
struct LiquidGlassBackground<S: Shape>: ViewModifier {
    let shape: S
    
    func body(content: Content) -> some View {
        // SwiftUI: Liquid Glass (Modern iOS 18+ implementation)
        content
            .padding(12)
            .background {
                shape
                    .fill(.regularMaterial)
            }
            .glassEffect(in: shape)
            .compositingGroup()
    }
}

extension View {
    /// Applies Liquid Glass effect with iOS 18+ APIs and Material fallback
    func liquidGlass<S: Shape>(_ shape: S = RoundedRectangle(cornerRadius: 18, style: .continuous)) -> some View {
        modifier(LiquidGlassBackground(shape: shape))
    }
}

// GlassEffectContainer for grouping multiple glass elements
struct LiquidGlassContainer<Content: View>: View {
    let spacing: CGFloat
    let content: Content
    
    init(spacing: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        GlassEffectContainer(spacing: spacing) {
            content
        }
    }
}