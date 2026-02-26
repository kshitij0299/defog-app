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
    
    init(id: UUID = UUID(), text: String, completed: Bool = false, schedule: TaskSchedule, source: InputSource, createdAt: Date = Date(), completedAt: Date? = nil) {
        self.id = id
        self.text = text
        self.completed = completed
        self.schedule = schedule
        self.source = source
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
}
