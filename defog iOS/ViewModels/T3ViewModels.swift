import Foundation
import SwiftData

@MainActor
@Observable
class BrainDumpViewModel {
    var text: String = ""
    var isMicrophoneEnabled: Bool = false
    var showPermissionAlert: Bool = false
    
    var engine: CategorizationEngine
    var isProcessing: Bool = false
    var categorizationResult: CategorizationResult? = nil
    var processingPathLabel: String = ""
    var processingTask: _Concurrency.Task<Void, Never>? = nil
    
    init(engine: CategorizationEngine = OpenRouterCategorizationEngine()) {
        self.engine = engine
    }
    
    // Optional integration for T4 future
    func checkMicrophonePermission() {
        // Mock permission check
        // showPermissionAlert = true / false 
    }
    
    func startProcessing(modelContext: ModelContext) {
        cancelProcessing()
        isProcessing = true
        processingPathLabel = initialProcessingPathLabel()
        
        let existingGoals = (try? modelContext.fetch(
            FetchDescriptor<Goal>(predicate: #Predicate { $0.archivedAt == nil })
        )) ?? []
        
        let openTasksRaw = (try? modelContext.fetch(
            FetchDescriptor<Task>(predicate: #Predicate { $0.completed == false }, sortBy: [SortDescriptor(\.createdAt)])
        )) ?? []
        let openTaskSummaries = openTasksRaw.map { ExistingOpenTaskSummary(id: $0.id, text: $0.text) }
        
        processingTask = _Concurrency.Task {
            let result = await engine.categorize(text: text, existingGoals: existingGoals, openTasks: openTaskSummaries)
            guard !_Concurrency.Task.isCancelled else { return }
            
            try? await _Concurrency.Task.sleep(for: .seconds(1))
            guard !_Concurrency.Task.isCancelled else { return }
            
            guard self.isProcessing else { return }
            self.processingPathLabel = result.source.processingLabel
            self.categorizationResult = result
        }
    }
    
    func cancelProcessing() {
        processingTask?.cancel()
        processingTask = nil
        isProcessing = false
        categorizationResult = nil
    }
    
    func initialProcessingPathLabel() -> String {
        let trimmedAPIKey = UserPreferences.aiAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAPIKey.isEmpty else {
            return CategorizationSource.legacyLocal(reason: "no API key").processingLabel
        }
        return CategorizationSource.byom(model: UserPreferences.aiModel).processingLabel
    }
}

@Observable
class ConfirmationViewModel {
    var result: CategorizationResult
    
    init(result: CategorizationResult) {
        self.result = result
    }
    
    // MARK: - Actions
    
    func removeTask(at index: Int) {
        guard result.tasks.indices.contains(index) else { return }
        result.tasks.remove(at: index)
    }
    
    func removeNewGoal(at index: Int) {
        guard result.newGoals.indices.contains(index) else { return }
        result.newGoals.remove(at: index)
    }
    
    func removeGoalUpdate(at index: Int) {
        guard result.goalUpdates.indices.contains(index) else { return }
        result.goalUpdates.remove(at: index)
    }
    
    func removeTaskCompletion(at index: Int) {
        guard result.taskCompletions.indices.contains(index) else { return }
        result.taskCompletions.remove(at: index)
    }
    
    func updateTaskSchedule(at index: Int, schedule: TaskSchedule) {
        guard result.tasks.indices.contains(index) else { return }
        result.tasks[index].schedule = schedule
    }
    
    func updateTaskGoal(at index: Int, newGoalName: String?) {
        guard result.tasks.indices.contains(index) else { return }
        result.tasks[index].linkedGoalName = newGoalName
    }
    
    func updateGoalUpdateDestination(at index: Int, newGoal: Goal?, createNewName: String?) {
        guard result.goalUpdates.indices.contains(index) else { return }
        
        if let newGoal = newGoal {
            result.goalUpdates[index].matchedGoal = newGoal
        } else if let createNewName = createNewName {
            // Remove from updates, add to new goals
            let removed = result.goalUpdates.remove(at: index)
            result.newGoals.append(CategorizedNewGoal(name: createNewName, confidence: 1.0))
        }
    }
    
    // MARK: - Drag and Drop Actions
    
    func moveToTasks(_ newGoalId: UUID) {
        guard let index = result.newGoals.firstIndex(where: { $0.id == newGoalId }) else { return }
        let goal = result.newGoals.remove(at: index)
        // Ensure new tasks appear at the bottom
        result.tasks.append(CategorizedTask(text: goal.name, schedule: .someday, confidence: goal.confidence, linkedGoalName: nil))
    }
    
    func moveToGoals(_ taskId: UUID) {
        guard let index = result.tasks.firstIndex(where: { $0.id == taskId }) else { return }
        let task = result.tasks.remove(at: index)
        result.newGoals.append(CategorizedNewGoal(name: task.text, confidence: task.confidence))
    }
    
    func moveGoalUpdateToTasks(_ updateId: UUID) {
        guard let index = result.goalUpdates.firstIndex(where: { $0.id == updateId }) else { return }
        let update = result.goalUpdates.remove(at: index)
        result.tasks.append(CategorizedTask(text: update.text, schedule: .someday, confidence: update.confidence, linkedGoalName: nil))
    }
    
    var isEmpty: Bool {
        return result.tasks.isEmpty && result.newGoals.isEmpty && result.goalUpdates.isEmpty && result.taskCompletions.isEmpty
    }
    
    // MARK: - Save
    
    private func pickGoalColor(existingGoals: [Goal]) -> String {
        let palette = [
            "#A78BFA", "#34D399", "#F87171", "#60A5FA", "#FBBF24",
            "#FB923C", "#38BDF8", "#F472B6", "#A3E635", "#E879F9"
        ]
        
        var colorUsage: [String: Int] = [:]
        for color in palette {
            colorUsage[color.uppercased()] = 0
        }
        
        for goal in existingGoals where goal.archivedAt == nil {
            let color = goal.color.uppercased()
            if colorUsage.keys.contains(color) {
                colorUsage[color, default: 0] += 1
            }
        }
        
        return palette.min { a, b in
            let countA = colorUsage[a.uppercased()] ?? 0
            let countB = colorUsage[b.uppercased()] ?? 0
            if countA != countB {
                return countA < countB
            }
            let indexA = palette.firstIndex(of: a) ?? 0
            let indexB = palette.firstIndex(of: b) ?? 0
            return indexA < indexB
        } ?? palette[0]
    }
    
    func save(modelContext: ModelContext) {
        // Fetch existing goals to link tasks
        let existingGoals = (try? modelContext.fetch(FetchDescriptor<Goal>())) ?? []
        var activeGoalsTracker = existingGoals

        let persistedTasks = (try? modelContext.fetch(FetchDescriptor<Task>())) ?? []
        
        for completion in result.taskCompletions {
            guard let match = persistedTasks.first(where: { $0.id == completion.matchedTaskId && !$0.completed }) else { continue }
            match.completed = true
            match.completedAt = Date()
            if let goal = match.linkedGoal {
                let entry = GoalEntry(text: match.text, type: .detailed, goal: goal)
                modelContext.insert(entry)
            }
        }
        
        // Save Tasks
        for catTask in result.tasks {
            let task = Task(text: catTask.text, schedule: catTask.schedule, source: .typed)
            if let linkedName = catTask.linkedGoalName, let goal = existingGoals.first(where: { $0.name == linkedName }) {
                task.linkedGoal = goal
            }
            modelContext.insert(task)
        }
        
        // Save New Goals
        for catNewGoal in result.newGoals {
            let color = pickGoalColor(existingGoals: activeGoalsTracker)
            let goal = Goal(name: catNewGoal.name, color: color)
            modelContext.insert(goal)
            activeGoalsTracker.append(goal)
            
            // Also need to create a GoalEntry? For MVP logic we just create the goal, 
            // but the text that drove this new goal isn't captured in a GoalEntry.
            // If we needed to capture the text, we'd add an entry here.
        }
        
        // Save Goal Updates
        for update in result.goalUpdates {
            let entry = GoalEntry(text: update.text, type: .detailed, goal: update.matchedGoal)
            modelContext.insert(entry)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save categorization result: \(error)")
        }
    }
}
