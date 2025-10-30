//
//  SearchDemoView.swift
//  FreeYT
//
//  Created by Assistant on 10/30/25.
//

import SwiftUI

struct SearchDemoView: View {
    @State private var customSearchQuery = ""
    @State private var nativeSearchQuery = ""
    @State private var searchResults: [SearchResult] = []
    @State private var isLoading = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Custom Liquid Glass Search Bar Demo
            customSearchDemo
                .tabItem {
                    Label("Custom", systemImage: "magnifyingglass.circle")
                }
                .tag(0)
            
            // Native .searchable Demo
            nativeSearchDemo
                .tabItem {
                    Label("Native", systemImage: "list.bullet")
                }
                .tag(1)
        }
    }
    
    // Demo a: Custom LiquidGlassSearchBar driving results with debounced async filtering
    private var customSearchDemo: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Pinned search bar at top
                VStack(spacing: 16) {
                    LiquidGlassSearchBar(
                        query: $customSearchQuery,
                        placeholder: "Search YouTube content...",
                        scopes: SearchScope.allCases,
                        onSubmit: performCustomSearch
                    )
                    .padding(.horizontal, 16)
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                .padding(.vertical, 12)
                .background(.regularMaterial, ignoresSafeAreaEdges: .top)
                
                // Results list
                List {
                    if searchResults.isEmpty && !customSearchQuery.isEmpty && !isLoading {
                        ContentUnavailableView(
                            "No Results",
                            systemImage: "magnifyingglass",
                            description: Text("Try searching for something else")
                        )
                    } else {
                        ForEach(searchResults) { result in
                            SearchResultRow(result: result)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("FreeYT Search")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                // Load initial sample data
                loadSampleData()
            }
        }
    }
    
    // Demo b: Native .searchable example with search scopes and token suggestions
    private var nativeSearchDemo: some View {
        NavigationStack {
            List {
                ForEach(filteredNativeResults) { result in
                    SearchResultRow(result: result)
                        .listRowSeparator(.hidden)
                }
            }
            .navigationTitle("Native Search")
            .searchable(text: $nativeSearchQuery, placement: .navigationBarDrawer(displayMode: .always))
            .searchScopes($nativeSearchQuery) {
                ForEach(SearchScope.allCases) { scope in
                    Text(scope.rawValue).tag(scope.rawValue)
                }
            }
            .onSubmit(of: .search) {
                Task {
                    await performNativeSearch(nativeSearchQuery)
                }
            }
            .onChange(of: nativeSearchQuery) { _, newValue in
                // Real-time filtering for native search
                if !newValue.isEmpty {
                    Task {
                        await performNativeSearch(newValue)
                    }
                }
            }
            .onAppear {
                loadSampleData()
            }
        }
    }
    
    private var filteredNativeResults: [SearchResult] {
        if nativeSearchQuery.isEmpty {
            return searchResults
        }
        return searchResults.filter { result in
            result.title.localizedCaseInsensitiveContains(nativeSearchQuery) ||
            result.description.localizedCaseInsensitiveContains(nativeSearchQuery)
        }
    }
    
    @MainActor
    private func performCustomSearch(_ query: String) async {
        guard !query.isEmpty else {
            searchResults = sampleResults
            return
        }
        
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(for: .milliseconds(500))
        
        // Filter results based on query
        let filtered = sampleResults.filter { result in
            result.title.localizedCaseInsensitiveContains(query) ||
            result.description.localizedCaseInsensitiveContains(query) ||
            result.channel.localizedCaseInsensitiveContains(query)
        }
        
        searchResults = filtered
        isLoading = false
    }
    
    @MainActor
    private func performNativeSearch(_ query: String) async {
        // Simulate async search for native implementation
        try? await Task.sleep(for: .milliseconds(200))
        
        if query.isEmpty {
            searchResults = sampleResults
        } else {
            searchResults = sampleResults.filter { result in
                result.title.localizedCaseInsensitiveContains(query) ||
                result.description.localizedCaseInsensitiveContains(query) ||
                result.channel.localizedCaseInsensitiveContains(query)
            }
        }
    }
    
    private func loadSampleData() {
        searchResults = sampleResults
    }
}

// MARK: - Search Result Model and Sample Data

struct SearchResult: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let channel: String
    let thumbnailName: String
    let duration: String
    let views: String
    let uploadTime: String
    let type: SearchScope
}

private let sampleResults: [SearchResult] = [
    SearchResult(
        title: "Privacy-First YouTube Browsing",
        description: "Learn how to browse YouTube safely with privacy-enhanced features and no tracking cookies.",
        channel: "Tech Privacy Guide",
        thumbnailName: "video1",
        duration: "10:34",
        views: "125K views",
        uploadTime: "2 days ago",
        type: .videos
    ),
    SearchResult(
        title: "Understanding Browser Extensions",
        description: "A comprehensive guide to how browser extensions work and how they protect your privacy.",
        channel: "Code Academy",
        thumbnailName: "video2",
        duration: "15:22",
        views: "89K views",
        uploadTime: "1 week ago",
        type: .videos
    ),
    SearchResult(
        title: "Privacy Tech Channel",
        description: "Channel dedicated to privacy tools, browser security, and safe internet browsing practices.",
        channel: "Privacy Tech",
        thumbnailName: "channel1",
        duration: "",
        views: "45K subscribers",
        uploadTime: "",
        type: .channels
    ),
    SearchResult(
        title: "Safari Extension Development",
        description: "Complete tutorial series on building Safari extensions for enhanced web browsing.",
        channel: "iOS Dev Weekly",
        thumbnailName: "playlist1",
        duration: "8 videos",
        views: "Updated last week",
        uploadTime: "",
        type: .playlists
    ),
    SearchResult(
        title: "YouTube Without Ads: Privacy Methods",
        description: "Explore different ways to watch YouTube content while maintaining your privacy and avoiding unwanted tracking.",
        channel: "Digital Freedom",
        thumbnailName: "video3",
        duration: "12:45",
        views: "67K views",
        uploadTime: "3 days ago",
        type: .videos
    ),
    SearchResult(
        title: "Web Privacy Essentials Playlist",
        description: "Essential videos covering web privacy, tracking protection, and safe browsing habits.",
        channel: "Security First",
        thumbnailName: "playlist2",
        duration: "12 videos",
        views: "Updated 2 days ago",
        uploadTime: "",
        type: .playlists
    )
]

// MARK: - Search Result Row View

struct SearchResultRow: View {
    let result: SearchResult
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail placeholder with glass effect
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.tertiary)
                .frame(width: 80, height: 60)
                .overlay {
                    VStack {
                        Image(systemName: result.type.systemImage)
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        
                        if !result.duration.isEmpty {
                            Text(result.duration)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.black.opacity(0.8), in: RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
                .liquidGlass(RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(result.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(result.channel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if !result.views.isEmpty {
                        Text("•")
                            .foregroundStyle(.secondary)
                        
                        Text(result.views)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if !result.uploadTime.isEmpty {
                        Text("•")
                            .foregroundStyle(.secondary)
                        
                        Text(result.uploadTime)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

#Preview("Custom Search") {
    SearchDemoView()
}

#Preview("Search Result Row") {
    List {
        SearchResultRow(result: sampleResults[0])
        SearchResultRow(result: sampleResults[1])
        SearchResultRow(result: sampleResults[2])
    }
    .listStyle(.plain)
}