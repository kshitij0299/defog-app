import Foundation

enum TaskSchedule: String, Codable, CaseIterable {
    case today
    case thisWeek
    case someday
}

enum InputSource: String, Codable, CaseIterable {
    case typed
    case voice
}

enum EntryType: String, Codable, CaseIterable {
    case quick
    case detailed
}

enum StorageMode: String, Codable, CaseIterable {
    case local
    case iCloud
}
