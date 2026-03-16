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
                // Edit Mode
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Task description", text: $editText)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                        .onSubmit(saveChanges)
                    
                    HStack {
                        Picker("Schedule", selection: $editSchedule) {
                            Text("Today").tag(TaskSchedule.today)
                            Text("This Week").tag(TaskSchedule.thisWeek)
                            Text("Someday").tag(TaskSchedule.someday)
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .tint(.primary)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        
                        Spacer()
                        
                        Button("Cancel") {
                            isEditing = false
                        }
                        .font(.subheadline)
                        .foregroundColor(.red)
                        
                        Button("Save") {
                            saveChanges()
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.blue)
                        .disabled(editText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    HStack {
                        Text("Linked goal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Picker("Linked goal", selection: $editLinkedGoal) {
                            Text("No goal").tag(Goal?.none)
                            ForEach(activeGoals) { goal in
                                Text(goal.name).tag(Optional(goal))
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.primary)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }
            } else {
                // View Mode
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.text)
                        .font(.body)
                        .foregroundColor(task.completed ? .secondary : .primary)
                        .strikethrough(task.completed, color: .secondary)
                        .multilineTextAlignment(.leading)
                    
                    if !task.completed, let goal = task.linkedGoal {
                        HStack(spacing: 3) {
                            Circle()
                                .fill(Color(hex: goal.color) ?? .blue)
                                .frame(width: 6, height: 6)
                            Text(goal.name)
                                .font(.caption)
                                .foregroundColor(Color(hex: goal.color) ?? .blue)
                        }
                        .padding(.top, 1)
                        .padding(.bottom, 2)
                    }
                    
                    // Schedule Badge (only show if not completed, or maybe always)
                    if !task.completed {
                        scheduleBadge
                    }
                }
                
                Spacer(minLength: 8)
                
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
                        .padding(8)
                        .contentShape(Rectangle())
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(alignment: .leading) {
            if let goal = task.linkedGoal {
                Rectangle()
                    .fill(Color(hex: goal.color) ?? .blue)
                    .frame(width: 3)
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
    private var scheduleBadge: some View {
        let (title, color) = badgeDetails
        
        Text(title)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
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
