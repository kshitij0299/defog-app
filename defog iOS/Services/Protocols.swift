import Foundation

// MARK: - Live brain dump (debounced preview + voice commands)

/// One row of the current live task list (shown to the live LLM for edit commands).
struct LivePreviewTaskLine: Sendable, Equatable {
    var text: String
    var schedule: TaskSchedule
    var linkedGoalName: String?
}

/// Snapshot of in-memory preview state passed to `categorizeLive` so the model can emit delete/rename commands.
struct LivePreviewContext: Sendable, Equatable {
    var pendingNewGoalNames: [String]
    var liveTasks: [LivePreviewTaskLine]

    static let empty = LivePreviewContext(pendingNewGoalNames: [], liveTasks: [])
}

/// Goal update row for live preview (string goal name; resolved to `Goal` on final `Process`).
struct LivePreviewGoalUpdate: Identifiable, Equatable, Sendable {
    var id: UUID
    var text: String
    var matchedGoalName: String
    var confidence: Double
}

/// Parsed voice / explicit edit operations from the live LLM pass.
struct LiveVoiceCommand: Equatable, Sendable, Decodable {
    var op: String
    var taskText: String?
    var goalName: String?
    var fromText: String?
    var toText: String?
    var schedule: String?

    private enum CodingKeys: String, CodingKey {
        case op
        case taskText
        case task_text
        case goalName
        case goal_name
        case fromText
        case from_text
        case toText
        case to_text
        case toKey = "to"
        case schedule
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        op = try c.decode(String.self, forKey: .op)
        taskText = try c.decodeIfPresent(String.self, forKey: .taskText)
            ?? c.decodeIfPresent(String.self, forKey: .task_text)
        goalName = try c.decodeIfPresent(String.self, forKey: .goalName)
            ?? c.decodeIfPresent(String.self, forKey: .goal_name)
        fromText = try c.decodeIfPresent(String.self, forKey: .fromText)
            ?? c.decodeIfPresent(String.self, forKey: .from_text)
        toText = try c.decodeIfPresent(String.self, forKey: .toText)
            ?? c.decodeIfPresent(String.self, forKey: .to_text)
            ?? c.decodeIfPresent(String.self, forKey: .toKey)
        schedule = try c.decodeIfPresent(String.self, forKey: .schedule)
    }

    init(
        op: String,
        taskText: String? = nil,
        goalName: String? = nil,
        fromText: String? = nil,
        toText: String? = nil,
        schedule: String? = nil
    ) {
        self.op = op
        self.taskText = taskText
        self.goalName = goalName
        self.fromText = fromText
        self.toText = toText
        self.schedule = schedule
    }
}

/// Result of a single live categorization call (snapshot + optional edit commands).
struct LiveExtractionResponse: Sendable {
    var tasks: [CategorizedTask]
    var newGoals: [CategorizedNewGoal]
    var goalUpdates: [LivePreviewGoalUpdate]
    var taskCompletions: [CategorizedTaskCompletion]
    var commands: [LiveVoiceCommand]
    var source: CategorizationSource

    static func from(result: CategorizationResult, commands: [LiveVoiceCommand] = []) -> LiveExtractionResponse {
        LiveExtractionResponse(
            tasks: result.tasks,
            newGoals: result.newGoals,
            goalUpdates: result.goalUpdates.map {
                LivePreviewGoalUpdate(id: $0.id, text: $0.text, matchedGoalName: $0.matchedGoal.name, confidence: $0.confidence)
            },
            taskCompletions: result.taskCompletions,
            commands: commands,
            source: result.source
        )
    }

    static func empty(source: CategorizationSource) -> LiveExtractionResponse {
        LiveExtractionResponse(tasks: [], newGoals: [], goalUpdates: [], taskCompletions: [], commands: [], source: source)
    }
}

extension CategorizationEngine {
    /// Convenience: full categorization without a live preview snapshot (uses `.empty`).
    func categorize(text: String, existingGoals: [Goal], openTasks: [ExistingOpenTaskSummary]) async -> CategorizationResult {
        await categorize(text: text, existingGoals: existingGoals, openTasks: openTasks, livePreview: .empty)
    }

    /// Default: full `categorize` with no extra commands (used by rule-based engine).
    func categorizeLive(
        text: String,
        existingGoals: [Goal],
        openTasks: [ExistingOpenTaskSummary],
        livePreview: LivePreviewContext = .empty
    ) async -> LiveExtractionResponse {
        let result = await categorize(text: text, existingGoals: existingGoals, openTasks: openTasks, livePreview: livePreview)
        return LiveExtractionResponse.from(result: result, commands: [])
    }
}

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
    func categorize(
        text: String,
        existingGoals: [Goal],
        openTasks: [ExistingOpenTaskSummary],
        livePreview: LivePreviewContext
    ) async -> CategorizationResult
}

protocol TranscriptionEngine {
    var isAvailable: Bool { get }
    func transcribe() async throws -> String
}
