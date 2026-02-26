import SwiftUI
import SwiftData

struct ConfirmationView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var rootIsActive: Bool
    
    @State var viewModel: ConfirmationViewModel
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Review & Confirm")
                        .font(.title2.weight(.bold))
                    
                    Text("Tap × to remove · tap tag to reschedule · tap goal chip to reassign")
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
                            
                            // Tasks Section
                            if !viewModel.result.tasks.isEmpty {
                                SectionHeader(icon: "checkmark.square", title: "These look like tasks")
                                
                                ForEach(Array(viewModel.result.tasks.enumerated()), id: \.offset) { index, task in
                                    ConfirmationItemRow(text: task.text,
                                                        tagLabel: scheduleString(task.schedule),
                                                        tagColor: scheduleColor(task.schedule),
                                                        onRemove: { viewModel.removeTask(at: index) })
                                }
                            }
                            
                            // New Goals Section
                            if !viewModel.result.newGoals.isEmpty {
                                SectionHeader(icon: "target", title: "New goals")
                                
                                ForEach(Array(viewModel.result.newGoals.enumerated()), id: \.offset) { index, goal in
                                    ConfirmationItemRow(text: goal.name,
                                                        tagLabel: nil,
                                                        tagColor: .clear,
                                                        onRemove: { viewModel.removeNewGoal(at: index) })
                                }
                            }
                            
                            // Goal Updates Section
                            if !viewModel.result.goalUpdates.isEmpty {
                                SectionHeader(icon: "pencil.line", title: "Goal updates")
                                
                                ForEach(Array(viewModel.result.goalUpdates.enumerated()), id: \.offset) { index, update in
                                    ConfirmationItemRow(text: update.text,
                                                        tagLabel: "\(update.matchedGoal.name) ▾",
                                                        tagColor: .blue.opacity(0.1),
                                                        onRemove: { viewModel.removeGoalUpdate(at: index) })
                                }
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
                        rootIsActive = false // Pop to root (Home)
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
    
    private func scheduleString(_ schedule: TaskSchedule) -> String {
        switch schedule {
        case .today: return "Today ▾"
        case .thisWeek: return "This Week ▾"
        case .someday: return "Someday ▾"
        }
    }
    
    private func scheduleColor(_ schedule: TaskSchedule) -> Color {
        switch schedule {
        case .today: return Color.orange.opacity(0.2)
        case .thisWeek: return Color.indigo.opacity(0.2)
        case .someday: return Color.gray.opacity(0.2)
        }
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
        }
        .foregroundColor(.primary)
        .padding(.top, 8)
    }
}

struct ConfirmationItemRow: View {
    let text: String
    let tagLabel: String?
    let tagColor: Color
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let tagLabel = tagLabel {
                Text(tagLabel)
                    .font(.caption2.weight(.semibold))
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
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(uiColor: .systemGray5), lineWidth: 1)
        )
    }
}
