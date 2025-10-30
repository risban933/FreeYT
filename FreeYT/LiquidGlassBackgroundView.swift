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
        // SwiftUI: Liquid Glass (glassBackgroundEffect, Glass, GlassEffectContainer)
        if #available(iOS 18.0, *) {
            content
                .padding(12)
                .background {
                    shape
                        .fill(.regularMaterial)
                        .glassEffect(.regular, in: shape)
                }
                .overlay(
                    shape.stroke(.white.opacity(0.15), lineWidth: 0.5)
                )
                .compositingGroup()
        } else {
            // SwiftUI: Material / ultraThinMaterial - fallback with proper vibrancy
            content
                .padding(12)
                .background {
                    ZStack {
                        // Base material for blur
                        shape.fill(.ultraThinMaterial)
                        
                        // Hairline stroke for thickness perception
                        shape.stroke(.white.opacity(0.12), lineWidth: 1)
                        
                        // Subtle inner shadow for depth
                        shape
                            .fill(.black.opacity(0.08))
                            .blur(radius: 1)
                            .offset(y: 0.5)
                            .blendMode(.multiply)
                    }
                }
                // Maintain foreground vibrancy per Material docs
                .foregroundStyle(.primary)
        }
    }
}

extension View {
    /// Applies Liquid Glass effect with iOS 18+ APIs and Material fallback
    func liquidGlass<S: Shape>(_ shape: S = RoundedRectangle(cornerRadius: 18, style: .continuous)) -> some View {
        modifier(LiquidGlassBackground(shape: shape))
    }
}

// GlassEffectContainer equivalent for grouping multiple glass elements
struct LiquidGlassContainer<Content: View>: View {
    let spacing: CGFloat
    let content: Content
    
    init(spacing: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        if #available(iOS 18.0, *) {
            GlassEffectContainer(spacing: spacing) {
                content
            }
        } else {
            // Fallback: simple container with proper spacing
            content
        }
    }
}