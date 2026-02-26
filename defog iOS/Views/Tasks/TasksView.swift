import SwiftUI
import SwiftData

struct TasksView: View {
    @Query(sort: \Task.createdAt, order: .reverse) private var tasks: [Task]
    
    @State private var showCompleted = false
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var todayTasks: [Task] {
        tasks.filter { !$0.completed && $0.schedule == .today }
    }
    
    var thisWeekTasks: [Task] {
        tasks.filter { !$0.completed && $0.schedule == .thisWeek }
    }
    
    var somedayTasks: [Task] {
        tasks.filter { !$0.completed && $0.schedule == .someday }
    }
    
    var completedTasks: [Task] {
        tasks.filter { $0.completed }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24, pinnedViews: []) {
                taskSection(title: "Today", tasks: todayTasks, emptyMessage: "No tasks for today. Feeling organized!")
                taskSection(title: "This Week", tasks: thisWeekTasks, emptyMessage: "Nothing planned for this week.")
                taskSection(title: "Someday", tasks: somedayTasks, emptyMessage: "No tasks waiting for someday.")
                
                // Completed Section
                if !completedTasks.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        DisclosureGroup(isExpanded: $showCompleted) {
                            LazyVStack(spacing: 12) {
                                ForEach(completedTasks) { task in
                                    TaskCardView(
                                        task: task,
                                        showToast: $showToast,
                                        toastMessage: $toastMessage
                                    )
                                }
                            }
                            .padding(.top, 8)
                        } label: {
                            HStack {
                                Text("Completed")
                                    .font(.title3.weight(.bold))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(completedTasks.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            // Removing default padding from default DisclosureGroup
                        }
                        .accentColor(.primary) // Chevron color
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Tasks")
        .background(Color(UIColor.systemGroupedBackground))
        .toast(isShowing: $showToast, message: toastMessage)
    }
    
    @ViewBuilder
    private func taskSection(title: String, tasks: [Task], emptyMessage: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.title3.weight(.bold))
                Spacer()
                Text("\(tasks.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            if tasks.isEmpty {
                Text(emptyMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 4)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(tasks) { task in
                        TaskCardView(
                            task: task,
                            showToast: $showToast,
                            toastMessage: $toastMessage
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    TasksView()
        .modelContainer(for: Task.self, inMemory: true)
}
