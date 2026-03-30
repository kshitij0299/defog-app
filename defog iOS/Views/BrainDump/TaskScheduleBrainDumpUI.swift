import SwiftUI

extension TaskSchedule {
    /// Schedule chip label; set `includeMenuChevron` for review rows that wrap a schedule `Menu`.
    func scheduleTagLabel(includeMenuChevron: Bool) -> String {
        let base: String
        switch self {
        case .today: base = "Today"
        case .thisWeek: base = "This Week"
        case .someday: base = "Someday"
        }
        return includeMenuChevron ? "\(base) ▾" : base
    }

    var scheduleTagBackground: Color {
        switch self {
        case .today: Color.orange.opacity(0.2)
        case .thisWeek: Color.indigo.opacity(0.2)
        case .someday: Color.gray.opacity(0.2)
        }
    }
}
