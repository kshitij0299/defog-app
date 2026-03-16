import Foundation
import SwiftData

@Model
final class Task {
    var id: UUID
    var text: String
    var completed: Bool
    var schedule: TaskSchedule
    var source: InputSource
    var createdAt: Date
    var completedAt: Date?
    
    @Relationship(deleteRule: .nullify)
    var linkedGoal: Goal?
    
    init(id: UUID = UUID(), text: String, completed: Bool = false, schedule: TaskSchedule, source: InputSource, createdAt: Date = Date(), completedAt: Date? = nil, linkedGoal: Goal? = nil) {
        self.id = id
        self.text = text
        self.completed = completed
        self.schedule = schedule
        self.source = source
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.linkedGoal = linkedGoal
    }
}
