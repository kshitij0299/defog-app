import SwiftUI

struct TimelineTabView: View {
    let goal: Goal
    
    var sortedEntries: [GoalEntry] {
        goal.entries.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        ScrollView {
            if sortedEntries.isEmpty {
                VStack(spacing: 12) {
                    Spacer().frame(height: 40)
                    Image(systemName: "clock")
                        .font(.largeTitle)
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No entries yet.")
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(sortedEntries.enumerated()), id: \.element.id) { index, entry in
                        HStack(alignment: .top, spacing: 16) {
                            // Timeline line & dot
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(Color(hex: goal.color) ?? .blue)
                                    .frame(width: 12, height: 12)
                                    .padding(.top, 4)
                                
                                if index != sortedEntries.count - 1 {
                                    Rectangle()
                                        .fill(Color.secondary.opacity(0.2))
                                        .frame(width: 2)
                                }
                            }
                            
                            // Entry Content
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.createdAt, format: .dateTime.month().day().hour().minute())
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                if entry.type == .quick {
                                    Text("✓ Did something")
                                        .italic()
                                        .foregroundColor(.secondary)
                                } else {
                                    if let text = entry.text, !text.isEmpty {
                                        Text(text)
                                            .padding(12)
                                            .background(Color(UIColor.secondarySystemGroupedBackground))
                                            .cornerRadius(8)
                                    } else {
                                        Text("Logged progress")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.bottom, 24)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
        }
    }
}
