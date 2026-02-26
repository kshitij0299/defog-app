import Foundation
import SwiftData

@Observable
class BrainDumpViewModel {
    var text: String = ""
    var isMicrophoneEnabled: Bool = false
    var showPermissionAlert: Bool = false
    
    // Optional integration for T4 future
    func checkMicrophonePermission() {
        // Mock permission check
        // showPermissionAlert = true / false 
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
    
    func updateTaskSchedule(at index: Int, schedule: TaskSchedule) {
        guard result.tasks.indices.contains(index) else { return }
        result.tasks[index].schedule = schedule
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
    
    var isEmpty: Bool {
        return result.tasks.isEmpty && result.newGoals.isEmpty && result.goalUpdates.isEmpty
    }
    
    // MARK: - Save
    
    func save(modelContext: ModelContext) {
        // Save Tasks
        for catTask in result.tasks {
            let task = Task(text: catTask.text, schedule: catTask.schedule, source: .typed)
            modelContext.insert(task)
        }
        
        // Save New Goals
        for catNewGoal in result.newGoals {
            let color = ["#A78BFA", "#34D399", "#F87171", "#60A5FA", "#FBBF24"].randomElement() ?? "#A78BFA"
            let goal = Goal(name: catNewGoal.name, color: color)
            modelContext.insert(goal)
            
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
