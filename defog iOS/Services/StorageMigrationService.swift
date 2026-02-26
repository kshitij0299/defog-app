import SwiftData
import Foundation

struct MigrationProgress {
    let current: Int
    let total: Int
    let completed: Bool
    
    var percentage: Double {
        guard total > 0 else { return 0.0 }
        return Double(current) / Double(total)
    }
}

enum MigrationError: Error {
    case failedToInitializeCloudContainer
    case fetchFailed(Error)
    case insertionFailed(Error)
    case saveFailed(Error)
}

actor StorageMigrationService {
    
    /// Migrates all data from the local container to an iCloud-backed container.
    /// This is a one-way operation. Returns an AsyncStream to report progress.
    func migrate(from localContainer: ModelContainer, to cloudContainer: ModelContainer) -> AsyncStream<MigrationProgress> {
        AsyncStream { continuation in
            _Concurrency.Task {
                do {
                    let localContext = ModelContext(localContainer)
                    let cloudContext = ModelContext(cloudContainer)
                    
                    // Fetch all items from local
                    let tasks = try localContext.fetch(FetchDescriptor<Task>())
                    let goals = try localContext.fetch(FetchDescriptor<Goal>())
                    
                    // Note: Goal entries are fetched via goals, but we could fetch them independently if needed.
                    let totalItems = tasks.count + goals.count
                    
                    if totalItems == 0 {
                        continuation.yield(MigrationProgress(current: 0, total: 0, completed: true))
                        continuation.finish()
                        return
                    }
                    
                    var currentProgress = 0
                    
                    // Helper to yield progress
                    let updateProgress = {
                        currentProgress += 1
                        continuation.yield(MigrationProgress(current: currentProgress, total: totalItems, completed: currentProgress == totalItems))
                    }
                    
                    // 1. Copy Goals (and their entries)
                    var goalIdMap: [UUID: Goal] = [:]
                    
                    for localGoal in goals {
                        let newGoal = Goal(name: localGoal.name, color: localGoal.color)
                        newGoal.id = localGoal.id
                        newGoal.createdAt = localGoal.createdAt
                        newGoal.archivedAt = localGoal.archivedAt
                        
                        cloudContext.insert(newGoal)
                        goalIdMap[localGoal.id] = newGoal
                        
                        for localEntry in localGoal.entries {
                            let newEntry = GoalEntry(type: localEntry.type)
                            newEntry.id = localEntry.id
                            newEntry.text = localEntry.text
                            newEntry.createdAt = localEntry.createdAt
                            newEntry.goal = newGoal
                            
                            cloudContext.insert(newEntry)
                        }
                        
                        updateProgress()
                    }
                    
                    // 2. Copy Tasks
                    for localTask in tasks {
                        let newTask = Task(
                            text: localTask.text,
                            schedule: localTask.schedule,
                            source: localTask.source
                        )
                        newTask.id = localTask.id
                        newTask.completed = localTask.completed
                        newTask.createdAt = localTask.createdAt
                        newTask.completedAt = localTask.completedAt
                        
                        cloudContext.insert(newTask)
                        updateProgress()
                    }
                    
                    // Save cloud context
                    try cloudContext.save()
                    
                    // Final yield
                    continuation.yield(MigrationProgress(current: totalItems, total: totalItems, completed: true))
                    continuation.finish()
                    
                } catch {
                    print("Migration failed: \(error)")
                    continuation.finish()
                }
            }
        }
    }
}
