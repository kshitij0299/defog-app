import Foundation
import SwiftData

@Model
final class GoalEntry {
    var id: UUID
    var text: String?
    var type: EntryType
    var createdAt: Date
    var goal: Goal?
    
    init(id: UUID = UUID(), text: String? = nil, type: EntryType, createdAt: Date = Date(), goal: Goal? = nil) {
        self.id = id
        self.text = text
        self.type = type
        self.createdAt = createdAt
        self.goal = goal
    }
}
