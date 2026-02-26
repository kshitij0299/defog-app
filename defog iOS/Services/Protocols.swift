import Foundation

struct CategorizationResult {
    var tasks: [CategorizedTask]
    var newGoals: [CategorizedNewGoal]
    var goalUpdates: [CategorizedGoalUpdate]
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

struct CategorizedTask {
    var text: String
    var schedule: TaskSchedule
    var confidence: Double
}

struct CategorizedNewGoal {
    var name: String
    var confidence: Double
}

struct CategorizedGoalUpdate {
    var text: String
    var matchedGoal: Goal
    var confidence: Double
}

@MainActor
protocol CategorizationEngine {
    func categorize(text: String, existingGoals: [Goal]) async -> CategorizationResult
}

protocol TranscriptionEngine {
    var isAvailable: Bool { get }
    func transcribe() async throws -> String
}
