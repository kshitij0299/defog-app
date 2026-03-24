import SwiftUI
import SwiftData

struct TaskCardView: View {
    @Bindable var task: Task
    @Environment(\.modelContext) private var modelContext
    
    @Query(filter: #Predicate<Goal> { $0.archivedAt == nil }, sort: \Goal.createdAt)
    private var activeGoals: [Goal]
    
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    
    @State private var isEditing = false
    @State private var editText: String = ""
    @State private var editSchedule: TaskSchedule = .today
    @State private var editLinkedGoal: Goal? = nil
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
            .padding(.top, 2)
            
            if isEditing {
                // Inline edit mode with reduced visual density.
                VStack(alignment: .leading, spacing: 10) {
                    TextField("Task description", text: $editText)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                        .onSubmit(saveChanges)
                    
                    HStack(spacing: 8) {
                        Picker("Schedule", selection: $editSchedule) {
                            Text("Today").tag(TaskSchedule.today)
                            Text("This Week").tag(TaskSchedule.thisWeek)
                            Text("Someday").tag(TaskSchedule.someday)
                        }
                        .pickerStyle(.menu)
                        .tint(.primary)
                        .accessibilityLabel("Schedule")
                        .padding(.horizontal, 10)
                        .frame(height: 36)
                        .background(Color(UIColor.tertiarySystemFill))
                        .clipShape(Capsule())
                        
                        Picker("Goal", selection: $editLinkedGoal) {
                            Text("No Goal").tag(Goal?.none)
                            ForEach(activeGoals) { goal in
                                Text(goal.name).tag(Optional(goal))
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.primary)
                        .accessibilityLabel("Linked goal")
                        .padding(.horizontal, 10)
                        .frame(height: 36)
                        .background(Color(UIColor.tertiarySystemFill))
                        .clipShape(Capsule())
                        
                        Spacer(minLength: 0)
                        
                        Button("Cancel") {
                            isEditing = false
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(minHeight: 44)
                        
                        Button("Save") {
                            saveChanges()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .font(.subheadline.weight(.semibold))
                        .frame(minHeight: 44)
                        .disabled(editText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            } else {
                // View Mode
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 8) {
                        Text(task.text)
                            .font(.body)
                            .foregroundColor(task.completed ? .secondary : .primary)
                            .strikethrough(task.completed, color: .secondary)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .multilineTextAlignment(.leading)

                        Spacer(minLength: 2)

                        // Menu
                        Menu {
                            Button(action: {
                                editText = task.text
                                editSchedule = task.schedule
                                editLinkedGoal = task.linkedGoal
                                isEditing = true
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }

                            Button(role: .destructive, action: {
                                showDeleteConfirmation = true
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.secondary)
                                .padding(4)
                                .padding(.top, 5)
                                .contentShape(Rectangle())
                        }
                    }
                    
                    // Schedule and goal pills
                    if !task.completed {
                        taskPills
                            .padding(.top, 6)
                    }
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
            Text("\(title) ▾")
                .font(.caption2.weight(.medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(color.opacity(0.15))
                .foregroundColor(color)
                .clipShape(Capsule())
        }
        .accessibilityLabel("Schedule")
        .accessibilityHint("Change task schedule")
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
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(hex: goal.color) ?? .blue)
                        .frame(width: 6, height: 6)
                    Text("\(goal.name) ▾")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(Color(hex: goal.color) ?? .blue)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background((Color(hex: goal.color) ?? .blue).opacity(0.1))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke((Color(hex: goal.color) ?? .blue).opacity(0.3), lineWidth: 1)
                )
            } else {
                Text("+ Link to goal")
                    .font(.caption2.weight(.medium))
                    .foregroundColor(Color(uiColor: .systemGray2))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .overlay(
                        Capsule()
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3]))
                            .foregroundColor(Color(uiColor: .systemGray3))
                    )
            }
        }
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
        let trimmedText = editText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        withAnimation {
            task.text = trimmedText
            task.schedule = editSchedule
            task.linkedGoal = editLinkedGoal
            isEditing = false
            try? modelContext.save()
            showToastMessage("Task updated")
        }
    }
    
    private func updateLinkedGoal(_ goal: Goal?) {
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
}
