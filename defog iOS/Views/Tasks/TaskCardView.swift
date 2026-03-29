import SwiftUI
import SwiftData

struct TaskCardView: View {
    @Bindable var task: Task
    @Environment(\.modelContext) private var modelContext
    
    @Query(filter: #Predicate<Goal> { $0.archivedAt == nil }, sort: \Goal.createdAt)
    private var activeGoals: [Goal]
    
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    
    @FocusState private var isTaskTextFocused: Bool
    @State private var lastCommittedTaskText: String = ""
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Checkbox
            Button(action: toggleCompletion) {
                Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(task.completed ? .blue : .gray)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .background {
                Rectangle()
                    .fill(.clear)
                    .frame(width: 44, height: 44)
            }
            .padding(.top, 2)
            .accessibilityLabel(task.completed ? "Mark task incomplete" : "Mark task complete")
            .accessibilityValue(task.completed ? "Completed" : "Not completed")
            .accessibilityHint("Double-tap to toggle completion")
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top, spacing: 8) {
                    TextField("Task description", text: $task.text)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .foregroundColor(task.completed ? .secondary : .primary)
                        .strikethrough(task.completed, color: .secondary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                        .focused($isTaskTextFocused)
                        .submitLabel(.done)
                        .onSubmit(saveChanges)
                    .accessibilityLabel("Task text")
                    .accessibilityHint("Double-tap to edit task text")
                    .onChange(of: isTaskTextFocused) { _, isFocused in
                        if isFocused {
                            lastCommittedTaskText = task.text
                        } else {
                            saveChanges()
                        }
                    }

                    Spacer(minLength: 2)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            dismissInlineEditing()
                        }

                    // Menu
                    Menu {
                        Button(role: .destructive, action: {
                            dismissInlineEditing()
                            showDeleteConfirmation = true
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.secondary)
                            .padding(4)
                            .contentShape(Rectangle())
                            .background {
                                Rectangle()
                                    .fill(.clear)
                                    .frame(width: 44, height: 44)
                            }
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        dismissInlineEditing()
                    })
                    .accessibilityLabel("More actions")
                    .accessibilityHint("Contains task actions")
                }
                
                // Schedule and goal pills
                if !task.completed {
                    taskPills
                        .padding(.top, 6)
                }
            }
        }
        .padding(.leading, 0)
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(alignment: .leading) {
            if let goal = task.linkedGoal {
                Rectangle()
                    .fill(Color(hex: goal.color) ?? .blue)
                    .frame(width: 4)
                    .clipShape(Capsule())
                    .padding(.vertical, 6)
                    .padding(.leading, 4)
            }
        }
        // Light shadow for depth
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        .alert("Delete Task?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteTask()
            }
        } message: {
            Text("Are you sure you want to delete this task?")
        }
        .onAppear {
            lastCommittedTaskText = task.text
        }
    }
    
    @ViewBuilder
    private var taskPills: some View {
        HStack(spacing: 8) {
            scheduleBadge
            goalBadge
        }
    }
    
    @ViewBuilder
    private var scheduleBadge: some View {
        let (title, color) = badgeDetails

        Menu {
            Button("Today") {
                updateSchedule(.today)
            }

            Button("This Week") {
                updateSchedule(.thisWeek)
            }

            Button("Someday") {
                updateSchedule(.someday)
            }
        } label: {
            TaskPillView(
                title: "\(title) ▾",
                style: .schedule(color: color)
            )
        }
        .accessibilityLabel("Schedule")
        .accessibilityValue(title)
        .accessibilityHint("Double-tap to change task schedule")
    }
    
    @ViewBuilder
    private var goalBadge: some View {
        Menu {
            Button("No goal") {
                updateLinkedGoal(nil)
            }
            
            ForEach(activeGoals) { goal in
                Button(goal.name) {
                    updateLinkedGoal(goal)
                }
            }
        } label: {
            if let goal = task.linkedGoal {
                TaskPillView(
                    title: "\(goal.name) ▾",
                    style: .linkedGoal(color: Color(hex: goal.color) ?? .blue)
                )
            } else {
                TaskPillView(
                    title: "+ Link to goal",
                    style: .unlinkedGoal
                )
            }
        }
        .accessibilityLabel("Linked goal")
        .accessibilityValue(task.linkedGoal?.name ?? "No goal")
        .accessibilityHint("Double-tap to choose a goal")
    }
    
    private var badgeDetails: (String, Color) {
        switch task.schedule {
        case .today:
            return ("Today", .orange)
        case .thisWeek:
            return ("This Week", .blue)
        case .someday:
            return ("Someday", .purple)
        }
    }
    
    private func toggleCompletion() {
        dismissInlineEditing()
        withAnimation {
            task.completed.toggle()
            if task.completed {
                task.completedAt = Date()
                if let goal = task.linkedGoal {
                    let entry = GoalEntry(text: task.text, type: .detailed, goal: goal)
                    modelContext.insert(entry)
                    showToastMessage("Task done · logged to \(goal.name)")
                } else {
                    showToastMessage("Task completed!")
                }
                NotificationService.shared.recordActivity()
            } else {
                task.completedAt = nil
                showToastMessage("Task reopened")
            }
            try? modelContext.save()
        }
    }
    
    private func saveChanges() {
        let trimmedText = task.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            task.text = lastCommittedTaskText
            return
        }
        
        guard trimmedText != lastCommittedTaskText else {
            task.text = trimmedText
            return
        }

        task.text = trimmedText
        try? modelContext.save()
        lastCommittedTaskText = trimmedText
        showToastMessage("Task updated")
    }
    
    private func updateLinkedGoal(_ goal: Goal?) {
        dismissInlineEditing()
        let previousGoalName = task.linkedGoal?.name
        
        withAnimation {
            task.linkedGoal = goal
            try? modelContext.save()
            
            if let goal {
                if previousGoalName == nil {
                    showToastMessage("Task linked to \(goal.name)")
                } else if previousGoalName != goal.name {
                    showToastMessage("Task moved to \(goal.name)")
                } else {
                    showToastMessage("Already linked to \(goal.name)")
                }
            } else {
                if previousGoalName != nil {
                    showToastMessage("Goal removed")
                } else {
                    showToastMessage("No goal linked")
                }
            }
        }
    }

    private func updateSchedule(_ schedule: TaskSchedule) {
        dismissInlineEditing()
        let previousSchedule = task.schedule

        withAnimation {
            task.schedule = schedule
            try? modelContext.save()

            if previousSchedule == schedule {
                showToastMessage("Already set to \(badgeTitle(for: schedule))")
            } else {
                showToastMessage("Moved to \(badgeTitle(for: schedule))")
            }
        }
    }

    private func badgeTitle(for schedule: TaskSchedule) -> String {
        switch schedule {
        case .today:
            return "Today"
        case .thisWeek:
            return "This Week"
        case .someday:
            return "Someday"
        }
    }
    
    private func deleteTask() {
        withAnimation {
            modelContext.delete(task)
            try? modelContext.save()
            showToastMessage("Task deleted")
        }
    }
    
    private func showToastMessage(_ message: String) {
        toastMessage = message
        withAnimation {
            showToast = true
        }
    }

    private func dismissInlineEditing() {
        isTaskTextFocused = false
    }
}
