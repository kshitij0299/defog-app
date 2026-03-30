import SwiftUI
import SwiftData

struct ConfirmationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Goal> { $0.archivedAt == nil }, sort: \Goal.createdAt)
    private var activeGoals: [Goal]
    
    @Query(sort: \Task.createdAt, order: .reverse)
    private var storedTasks: [Task]
    
    @Binding var rootIsActive: Bool
    let onConfirmed: () -> Void
    
    @State var viewModel: ConfirmationViewModel
    
    @State private var isTasksTargeted = false
    @State private var isNewGoalsTargeted = false
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Review & Confirm")
                        .font(.title2.weight(.bold))
                    
                    Text("Tap × to remove · tap tag to reschedule · tap goal chip to reassign · completions mark existing tasks done")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Empty State
                        if viewModel.isEmpty {
                            VStack(spacing: 8) {
                                Text("Hmm, I couldn't find any tasks or goals.")
                                    .font(.headline)
                                Text("Try rephrasing?")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)
                        } else {
                            
                            if !viewModel.result.taskCompletions.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    SectionHeader(icon: "checkmark.circle.fill", title: "Marking complete")
                                    
                                    ForEach(Array(viewModel.result.taskCompletions.enumerated()), id: \.element.id) { index, completion in
                                        let title = storedTasks.first(where: { $0.id == completion.matchedTaskId })?.text
                                            ?? "Open task"
                                        TaskCompletionRow(
                                            taskTitle: title,
                                            onRemove: { viewModel.removeTaskCompletion(at: index) }
                                        )
                                    }
                                }
                                .padding(12)
                                .padding(.horizontal, -12)
                            }
                            
                            // Tasks Section
                            VStack(alignment: .leading, spacing: 16) {
                                SectionHeader(icon: "checkmark.square", title: "These look like tasks")
                                
                                if viewModel.result.tasks.isEmpty {
                                    Text("Drop items here to create tasks")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                        .background(Color(uiColor: .systemBackground))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                                                .foregroundColor(Color(uiColor: .systemGray4))
                                        )
                                } else {
                                    ForEach(Array(viewModel.result.tasks.enumerated()), id: \.element.id) { index, task in
                                        let linkedGoal = activeGoals.first(where: { $0.name == task.linkedGoalName })
                                        let row = ConfirmationItemRow(text: task.text,
                                                            tagLabel: task.schedule.scheduleTagLabel(includeMenuChevron: true),
                                                            tagColor: task.schedule.scheduleTagBackground,
                                                            linkedGoalName: task.linkedGoalName,
                                                            goalColorHex: linkedGoal?.color,
                                                            onRemove: { viewModel.removeTask(at: index) },
                                                            activeGoals: activeGoals,
                                                            onGoalChange: { newName in
                                                                viewModel.updateTaskGoal(at: index, newGoalName: newName)
                                                            })
                                        
                                        row.draggable("task:\(task.id.uuidString)") {
                                            row
                                                .frame(width: UIScreen.main.bounds.width - 64)
                                                .scaleEffect(1.03)
                                                .opacity(0.85)
                                        }
                                    }
                                }
                            }
                            .padding(12)
                            .background(isTasksTargeted ? Color.blue.opacity(0.05) : Color.clear)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isTasksTargeted ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 2)
                            )
                            .padding(.horizontal, -12)
                            .dropDestination(for: String.self) { items, _ in
                                handleDrop(items: items, destination: .tasks)
                            } isTargeted: { targeted in
                                withAnimation { isTasksTargeted = targeted }
                            }
                            
                            // New Goals Section
                            VStack(alignment: .leading, spacing: 16) {
                                SectionHeader(icon: "target", title: "New goals")
                                
                                if viewModel.result.newGoals.isEmpty {
                                    Text("Drop items here to create new goals")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                        .background(Color(uiColor: .systemBackground))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                                                .foregroundColor(Color(uiColor: .systemGray4))
                                        )
                                } else {
                                    ForEach(Array(viewModel.result.newGoals.enumerated()), id: \.element.id) { index, goal in
                                        let row = ConfirmationItemRow(text: goal.name,
                                                            tagLabel: nil,
                                                            tagColor: .clear,
                                                            onRemove: { viewModel.removeNewGoal(at: index) })
                                        
                                        row.draggable("newGoal:\(goal.id.uuidString)") {
                                            row
                                                .frame(width: UIScreen.main.bounds.width - 64)
                                                .scaleEffect(1.03)
                                                .opacity(0.85)
                                        }
                                    }
                                }
                            }
                            .padding(12)
                            .background(isNewGoalsTargeted ? Color.blue.opacity(0.05) : Color.clear)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isNewGoalsTargeted ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 2)
                            )
                            .padding(.horizontal, -12)
                            .dropDestination(for: String.self) { items, _ in
                                handleDrop(items: items, destination: .newGoals)
                            } isTargeted: { targeted in
                                withAnimation { isNewGoalsTargeted = targeted }
                            }
                            
                            // Goal Updates Section
                            if !viewModel.result.goalUpdates.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    SectionHeader(icon: "pencil.line", title: "Goal updates")
                                    
                                    ForEach(Array(viewModel.result.goalUpdates.enumerated()), id: \.element.id) { index, update in
                                        let row = ConfirmationItemRow(text: update.text,
                                                            tagLabel: "\(update.matchedGoal.name) ▾",
                                                            tagColor: .blue.opacity(0.1),
                                                            onRemove: { viewModel.removeGoalUpdate(at: index) })
                                        
                                        row.draggable("goalUpdate:\(update.id.uuidString)") {
                                            row
                                                .frame(width: UIScreen.main.bounds.width - 64)
                                                .scaleEffect(1.03)
                                                .opacity(0.85)
                                        }
                                    }
                                }
                                .padding(12)
                                // We don't drop items onto Goal Updates, so no dropDestination needed here.
                                .padding(.horizontal, -12)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
            
            // Floating Action Button for Confirm
            if !viewModel.isEmpty {
                VStack {
                    Spacer()
                    Button {
                        viewModel.save(modelContext: modelContext)
                        NotificationService.shared.recordActivity()
                        rootIsActive = false
                        onConfirmed()
                    } label: {
                        Text("Looks Good!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(Color.blue)
                            .cornerRadius(16)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    // Return directly to Brain Dump text editor.
                    rootIsActive = false
                } label: {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    private enum DropDestinationSection {
        case tasks
        case newGoals
    }
    
    private func handleDrop(items: [String], destination: DropDestinationSection) -> Bool {
        var handled = false
        for item in items {
            let parts = item.split(separator: ":").map(String.init)
            guard parts.count == 2 else { continue }
            let type = parts[0]
            guard let id = UUID(uuidString: parts[1]) else { continue }
            
            withAnimation(.spring) {
                if destination == .tasks {
                    if type == "newGoal" {
                        viewModel.moveToTasks(id)
                        handled = true
                    } else if type == "goalUpdate" {
                        viewModel.moveGoalUpdateToTasks(id)
                        handled = true
                    }
                } else if destination == .newGoals {
                    if type == "task" {
                        viewModel.moveToGoals(id)
                        handled = true
                    }
                }
            }
        }
        return handled
    }
    
}

struct TaskCompletionRow: View {
    let taskTitle: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.body)
                .foregroundStyle(.green)
            Text(taskTitle)
                .font(.subheadline)
                .strikethrough(true)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.35), lineWidth: 1)
        )
    }
}

struct SectionHeader: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.subheadline)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .fontDesign(.rounded)
        }
        .foregroundColor(.primary)
        .padding(.top, 8)
    }
}

struct ConfirmationItemRow: View {
    let text: String
    let tagLabel: String?
    let tagColor: Color
    var linkedGoalName: String? = nil
    var goalColorHex: String? = nil
    let onRemove: () -> Void
    var activeGoals: [Goal] = []
    var onGoalChange: ((String?) -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let tagLabel = tagLabel {
                    Text(tagLabel)
                        .font(.caption2.weight(.semibold))
                        .fontDesign(.rounded)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(tagColor)
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
                
                Button {
                    onRemove()
                } label: {
                    Image(systemName: "xmark")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
                }
            }
            
            if onGoalChange != nil {
                Menu {
                    Button("No goal") {
                        onGoalChange?(nil)
                    }
                    ForEach(activeGoals) { goal in
                        Button(goal.name) {
                            onGoalChange?(goal.name)
                        }
                    }
                } label: {
                    if let goalName = linkedGoalName {
                        TaskPillView(
                            title: "\(goalName) ▾",
                            style: .linkedGoal(color: Color(hex: goalColorHex ?? "#A78BFA") ?? .blue)
                        )
                    } else {
                        TaskPillView(
                            title: "+ Link to goal",
                            style: .unlinkedGoal
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(uiColor: .systemGray5), lineWidth: 1)
        )
        .overlay(alignment: .leading) {
            if linkedGoalName != nil {
                Rectangle()
                    .fill(Color(hex: goalColorHex ?? "#A78BFA") ?? .blue)
                    .frame(width: 3)
            }
        }
    }
}
