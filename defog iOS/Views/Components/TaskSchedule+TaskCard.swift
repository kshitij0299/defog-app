import SwiftUI

extension TaskSchedule {
    /// Matches `TaskCardView` schedule badge title.
    var taskCardScheduleLabel: String {
        switch self {
        case .today: return "Today"
        case .thisWeek: return "This Week"
        case .someday: return "Someday"
        }
    }

    /// Matches `TaskCardView` schedule pill accent color.
    var taskCardSchedulePillColor: Color {
        switch self {
        case .today: return .orange
        case .thisWeek: return .blue
        case .someday: return .purple
        }
    }
}
