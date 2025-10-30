//
//  SearchDemoView.swift
//  FreeYT
//
//  Created by Assistant on 10/30/25.
//

import SwiftUI

struct SearchDemoView: View {
    @State private var searchQuery: String = ""
    @State private var searchResults: [SearchResult] = []
    @State private var isSearching: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Demo explanation header
                VStack(spacing: 12) {
                    Text("🔍 Search Demo")
                        .font(.title2.weight(.bold))
                    
                    Text("This demonstrates how FreeYT can enhance your YouTube search experience with privacy-focused features.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 16)
                .padding(.bottom, 24)
                
                // Search bar
                LiquidGlassSearchBar(
                    query: $searchQuery,
                    placeholder: "Search YouTube videos...",
                    scopes: [.all, .videos, .channels],
                    onSubmit: performSearch
                )
                .padding(.horizontal)
                
                // Search results
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(searchResults) { result in
                            SearchResultCard(result: result)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Search Demo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Load some demo results
            loadDemoResults()
        }
    }
    
    private func performSearch(_ query: String) async {
        guard !query.isEmpty else {
            searchResults = demoResults
            return
        }
        
        isSearching = true
        
        // Simulate search delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Filter demo results based on query
        searchResults = demoResults.filter { result in
            result.title.localizedCaseInsensitiveContains(query) ||
            result.channel.localizedCaseInsensitiveContains(query)
        }
        
        isSearching = false
    }
    
    private func loadDemoResults() {
        searchResults = demoResults
    }
}

struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let channel: String
    let duration: String
    let views: String
    let thumbnailColor: Color
    let isPrivacyEnhanced: Bool
}

struct SearchResultCard: View {
    let result: SearchResult
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(result.thumbnailColor)
                .frame(width: 120, height: 68)
                .overlay {
                    Image(systemName: "play.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)
                
                Text(result.channel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text(result.views)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text(result.duration)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    if result.isPrivacyEnhanced {
                        HStack(spacing: 2) {
                            Image(systemName: "shield.fill")
                                .font(.caption2)
                                .foregroundStyle(.green)
                            Text("Privacy+")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.green)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// Demo data
private let demoResults: [SearchResult] = [
    SearchResult(
        title: "How to Build iOS Apps with SwiftUI",
        channel: "Apple Developer",
        duration: "12:45",
        views: "1.2M views",
        thumbnailColor: .blue,
        isPrivacyEnhanced: true
    ),
    SearchResult(
        title: "Privacy on the Web: Best Practices",
        channel: "Web Security Channel",
        duration: "8:30",
        views: "450K views",
        thumbnailColor: .green,
        isPrivacyEnhanced: true
    ),
    SearchResult(
        title: "JavaScript Fundamentals Tutorial",
        channel: "Code Academy",
        duration: "25:15",
        views: "3.4M views",
        thumbnailColor: .orange,
        isPrivacyEnhanced: false
    ),
    SearchResult(
        title: "Safari Extensions Development Guide",
        channel: "Developer Tutorials",
        duration: "18:22",
        views: "89K views",
        thumbnailColor: .purple,
        isPrivacyEnhanced: true
    ),
    SearchResult(
        title: "Understanding Web Privacy",
        channel: "Privacy Matters",
        duration: "15:45",
        views: "670K views",
        thumbnailColor: .red,
        isPrivacyEnhanced: true
    )
]