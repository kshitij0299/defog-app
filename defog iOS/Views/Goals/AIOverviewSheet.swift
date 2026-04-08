import SwiftUI
import SwiftData

struct AIOverviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    let goal: Goal
    
    private var calendar: Calendar { .current }
    
    // MARK: - Computed Properties
    
    private var sortedEntries: [GoalEntry] {
        goal.entries.sorted(by: { $0.createdAt > $1.createdAt })
    }
    
    private var last30DaysEntries: [GoalEntry] {
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return goal.entries.filter { $0.createdAt >= thirtyDaysAgo }
    }
    
    private var mostActiveWeekday: String? {
        guard !goal.entries.isEmpty else { return nil }
        
        let counts = goal.entries.reduce(into: [Int: Int]()) { result, entry in
            let weekday = calendar.component(.weekday, from: entry.createdAt)
            result[weekday, default: 0] += 1
        }
        
        guard let (weekday, _) = counts.max(by: { $0.value < $1.value }) else { return nil }
        return calendar.standaloneWeekdaySymbols[weekday - 1]
    }
    
    private var encouragementPhrase: String {
        guard let lastEntry = sortedEntries.first else { return "Ready when you are" }
        let days = calendar.dateComponents([.day], from: lastEntry.createdAt, to: Date()).day ?? 0
        
        if days < 3 {
            return "You're on a roll"
        } else if days <= 7 {
            return "Still going"
        } else {
            return "Ready when you are"
        }
    }
    
    private var suggestedFocus: String {
        guard let lastEntry = sortedEntries.first else { return "It's been a while — even a quick note counts." }
        let days = calendar.dateComponents([.day], from: lastEntry.createdAt, to: Date()).day ?? 0
        
        if days > 7 {
            return "It's been a while — even a quick note counts."
        } else {
            return "You're building momentum."
        }
    }
    
    private var recentHighlights: [GoalEntry] {
        sortedEntries.filter { $0.type == .detailed && $0.text != nil && !$0.text!.isEmpty }
            .prefix(3)
            .map { $0 }
    }
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    if goal.entries.isEmpty {
                        VStack(spacing: 16) {
                            Text("✦")
                                .font(.system(size: 48))
                                .foregroundColor(.accentColor)
                            Text("Start logging to see your patterns here.")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else {
                        // Encouragement & Focus
                        VStack(alignment: .leading, spacing: 8) {
                            Text(encouragementPhrase)
                                .font(.title3)
                                .fontWeight(.bold)
                            Text(suggestedFocus)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        // Summary Stats
                        HStack(spacing: 40) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Activity Pattern")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                    .fontDesign(.rounded)
                                if let weekday = mostActiveWeekday {
                                    Text("Most active on \(weekday)")
                                        .font(.body)
                                        .fontWeight(.medium)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Entry Count")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                    .fontDesign(.rounded)
                                Text("\(last30DaysEntries.count) in last 30 days")
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                        }
                        
                        if !recentHighlights.isEmpty {
                            Divider()
                            
                            // Recent Highlights
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent Highlights")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                    .fontDesign(.rounded)
                                
                                ForEach(recentHighlights) { entry in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\"\(entry.text ?? "")\"")
                                            .font(.body)
                                            .italic()
                                        Text(entry.createdAt, style: .date)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("AI Overview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}
