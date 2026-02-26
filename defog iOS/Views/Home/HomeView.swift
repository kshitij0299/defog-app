import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(
        filter: #Predicate<Goal> { goal in
            goal.archivedAt == nil
        },
        sort: \Goal.createdAt,
        order: .forward
    ) private var activeGoals: [Goal]
    
    @Query(
        filter: #Predicate<Task> { task in
            task.completed == false
        },
        sort: \Task.createdAt,
        order: .reverse
    ) private var incompleteTasks: [Task]
    
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var showSummary = false

    private var todayTasks: [Task] {
        incompleteTasks.filter { $0.schedule == .today }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Section for Goals
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Active Goals")
                            .font(.title2.weight(.bold))
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if activeGoals.isEmpty {
                        Text("No active goals. Add some via brain dump.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(activeGoals) { goal in
                                    NavigationLink(value: goal) {
                                        CompactGoalCard(goal: goal)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top)
                
                // Section for Tasks
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Today's Tasks")
                            .font(.title2.weight(.bold))
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if todayTasks.isEmpty {
                        Text("Nothing for today. Add something?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(todayTasks.prefix(3)) { task in
                                TaskCardView(
                                    task: task,
                                    showToast: $showToast,
                                    toastMessage: $toastMessage
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        if todayTasks.count > 3 {
                            NavigationLink(value: "MoreTasks") {
                                HStack {
                                    Text("+\(todayTasks.count - 3) more tasks")
                                    Image(systemName: "arrow.right")
                                }
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.blue)
                                .padding(.horizontal)
                                .padding(.top, 4)
                            }
                        }
                    }
                }
                .padding(.top)
                
                // (Other Home sections like Timeline / Summary will go here eventually)
                Spacer()
            }
        }
        .navigationTitle("Home")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSummary = true
                } label: {
                    Image(systemName: "sun.max")
                        .foregroundColor(.primary)
                }
            }
        }
        .fullScreenCover(isPresented: $showSummary) {
            NavigationStack {
                DailySummaryView()
            }
        }
        .navigationDestination(for: Goal.self) { goal in
            GoalDetailView(goal: goal)
        }
        .navigationDestination(for: String.self) { value in
            if value == "MoreTasks" {
                TasksView()
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .toast(isShowing: $showToast, message: toastMessage)
    }
}

struct CompactGoalCard: View {
    let goal: Goal
    
    var lastEntryDateString: String {
        let sortedEntries = goal.entries.sorted { $0.createdAt > $1.createdAt }
        if let latest = sortedEntries.first {
            if Calendar.current.isDateInToday(latest.createdAt) {
                return "Updated today"
            } else if Calendar.current.isDateInYesterday(latest.createdAt) {
                return "Updated yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                return "Updated \(formatter.string(from: latest.createdAt))"
            }
        }
        return "No entries yet"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: goal.color) ?? .blue)
                    .frame(width: 10, height: 10)
                
                Text(goal.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
            }
            
            Text(lastEntryDateString)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(width: 140, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        // Light shadow for depth
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}
