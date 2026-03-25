import Foundation

/// Snapshot of an incomplete task for categorization (matches SwiftData `Task` by id).
struct ExistingOpenTaskSummary: Identifiable, Sendable, Equatable {
    let id: UUID
    let text: String
}

struct CategorizationResult {
    var tasks: [CategorizedTask]
    var newGoals: [CategorizedNewGoal]
    var goalUpdates: [CategorizedGoalUpdate]
    /// User reported finishing these existing open tasks; confirm to mark complete in SwiftData.
    var taskCompletions: [CategorizedTaskCompletion]
    var source: CategorizationSource
}

enum CategorizationSource: Equatable, Hashable {
    case byom(model: String)
    case legacyLocal(reason: String)

    var processingLabel: String {
        switch self {
        case .byom(let model):
            return "Using \(model) via OpenRouter"
        case .legacyLocal(let reason):
            return "Using local rules (\(reason))"
        }
    }
}

struct CategorizedTask: Identifiable {
    var id = UUID()
    var text: String
    var schedule: TaskSchedule
    var confidence: Double
    var linkedGoalName: String?
}

struct CategorizedNewGoal: Identifiable {
    var id = UUID()
    var name: String
    var confidence: Double
}

struct CategorizedGoalUpdate: Identifiable {
    var id = UUID()
    var text: String
    var matchedGoal: Goal
    var confidence: Double
}

struct CategorizedTaskCompletion: Identifiable {
    var id = UUID()
    var matchedTaskId: UUID
    var confidence: Double
}

protocol CategorizationEngine {
    func categorize(text: String, existingGoals: [Goal], openTasks: [ExistingOpenTaskSummary]) async -> CategorizationResult
}

protocol TranscriptionEngine {
    var isAvailable: Bool { get }
    func transcribe() async throws -> String
}
