import Foundation
import SwiftData

@Model
final class Goal {
    var id: UUID
    var name: String
    var color: String
    var createdAt: Date
    var archivedAt: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \GoalEntry.goal)
    var entries: [GoalEntry]
    
    init(id: UUID = UUID(), name: String, color: String, createdAt: Date = Date(), archivedAt: Date? = nil, entries: [GoalEntry] = []) {
        self.id = id
        self.name = name
        self.color = color
        self.createdAt = createdAt
        self.archivedAt = archivedAt
        self.entries = entries
    }
}
