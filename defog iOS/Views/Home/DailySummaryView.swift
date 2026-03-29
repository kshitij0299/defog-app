import SwiftUI
import SwiftData

struct DailySummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.setTabBarHidden) private var setTabBarHidden
    
    // We fetch all tasks and goals, then filter them by date in memory
    // because dynamic date predicates in @Query can be tricky.
    
    @Query private var tasks: [Task]
    @Query private var goals: [Goal]
    
    private var tasksCompletedToday: [Task] {
        tasks.filter { task in
            guard let completedAt = task.completedAt else { return false }
            return Calendar.current.isDateInToday(completedAt)
        }
        .sorted(by: { $0.completedAt! > $1.completedAt! })
    }
    
    private var goalsUpdatedToday: [(goal: Goal, todayEntries: [GoalEntry])] {
        let result: [(goal: Goal, todayEntries: [GoalEntry])] = goals.compactMap { goal in
            let todayEntries = goal.entries.filter { Calendar.current.isDateInToday($0.createdAt) }
            if todayEntries.isEmpty { return nil }
            return (goal, todayEntries.sorted(by: { $0.createdAt > $1.createdAt }))
        }
        return result.sorted(by: { ($0.todayEntries.first?.createdAt ?? Date()) > ($1.todayEntries.first?.createdAt ?? Date()) })
    }
    
    private var totalActivityCount: Int {
        tasksCompletedToday.count + goalsUpdatedToday.count // One point per task + one point per updated goal
    }
    
    private var encouragingLine: String {
        switch totalActivityCount {
        case 0:
            return "Nothing logged yet today — that's okay. The day's still yours."
        case 1...2:
            return "A little goes a long way."
        default:
            return "You showed up today."
        }
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            if totalActivityCount == 0 {
                // Empty State
                VStack(spacing: 24) {
                    Spacer()
                    Image(systemName: "sun.haze")
                        .font(.system(size: 64, weight: .light))
                        .foregroundColor(.secondary)
                    
                    Text("Nothing logged yet today — that's okay. The day's still yours.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // Tasks Section
                        if !tasksCompletedToday.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Tasks completed today")
                                    .font(.headline)
                                    .fontDesign(.rounded)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 1) {
                                    ForEach(tasksCompletedToday) { task in
                                        HStack(alignment: .top, spacing: 12) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                                .font(.body.weight(.semibold))
                                                .padding(.top, 2)
                                            
                                            Text(task.text)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color(UIColor.secondarySystemGroupedBackground))
                                    }
                                }
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                        
                        // Goals Section
                        if !goalsUpdatedToday.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Goal progress today")
                                    .font(.headline)
                                    .fontDesign(.rounded)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 12) {
                                    ForEach(goalsUpdatedToday, id: \.goal.id) { item in
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Circle()
                                                    .fill(Color(hex: item.goal.color) ?? .blue)
                                                    .frame(width: 12, height: 12)
                                                
                                                Text(item.goal.name)
                                                    .font(.subheadline.weight(.semibold))
                                                    .fontDesign(.rounded)
                                                
                                                Spacer()
                                                
                                                Text("\(item.todayEntries.count) entr\(item.todayEntries.count == 1 ? "y" : "ies")")
                                                    .font(.caption)
                                                    .fontDesign(.rounded)
                                                    .foregroundColor(.secondary)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color(UIColor.tertiarySystemFill))
                                                    .cornerRadius(8)
                                            }
                                            
                                            if let recentText = item.todayEntries.first?.text, !recentText.isEmpty {
                                                Text(recentText)
                                                    .font(.body)
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(2)
                                            }
                                        }
                                        .padding()
                                        .background(Color(UIColor.secondarySystemGroupedBackground))
                                        .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Encouraging Line Footer
                        VStack {
                            Divider()
                                .padding(.vertical, 24)
                            
                            Text(encouragingLine)
                                .font(.body.italic())
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.top, 24)
                }
            }
        }
        .navigationTitle("Daily Summary")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.primary)
                }
            }
        }
        .onAppear {
            setTabBarHidden(true)
        }
        .onDisappear {
            setTabBarHidden(false)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        DailySummaryView()
    }
}
