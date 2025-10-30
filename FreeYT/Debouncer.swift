//
//  Debouncer.swift
//  FreeYT
//
//  Created by Assistant on 10/30/25.
//

import Foundation

/// Minimal, testable debouncer utility for search and other delayed operations
final class Debouncer: @unchecked Sendable {
    private var task: Task<Void, Never>?
    
    /// Debounces the given action with specified delay
    /// - Parameters:
    ///   - delay: The delay duration (default 300ms)
    ///   - action: The action to perform after the delay
    func call(delay: Duration = .milliseconds(300), _ action: @escaping @Sendable () async -> Void) {
        task?.cancel()
        task = Task {
            do {
                try await Task.sleep(for: delay)
                await action()
            } catch {
                // Task was cancelled, ignore
            }
        }
    }
    
    /// Cancels any pending debounced action
    func cancel() {
        task?.cancel()
        task = nil
    }
    
    deinit {
        cancel()
    }
}