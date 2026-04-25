//  TokenRefreshCoordinator.swift
//  Created by Sebastian Burrieza on 25/04/2026.

/// Serializes concurrent token refresh calls so only one refresh runs at a time.
///
/// When multiple requests receive a 401 simultaneously, the first one triggers
/// a real refresh. All subsequent calls wait for that same `Task` to complete
/// and reuse its result — no double-refresh, no token invalidation race.
///
/// ```
/// Request A → 401 → starts refresh Task ─────────────┐
/// Request B → 401 → sees ongoingRefresh → awaits ─────┤→ both get same new token
/// Request C → 401 → sees ongoingRefresh → awaits ─────┘
/// ```
actor TokenRefreshCoordinator {

    private var ongoingRefresh: Task<String?, Error>?

    /// Returns a valid token, starting a refresh only if one isn't already in progress.
    /// Concurrent callers automatically coalesce onto the same refresh `Task`.
    func refresh(using refresher: @escaping (@Sendable () async throws -> String?)) async throws -> String? {
        if let ongoing = ongoingRefresh {
            // A refresh is already running — wait for it and reuse the result.
            return try await ongoing.value
        }

        let task = Task { try await refresher() }
        ongoingRefresh = task
        defer { ongoingRefresh = nil }
        return try await task.value
    }
}
