import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let goal: Goal
    
    @State private var selectedTab: Int = 0 
    @State private var showRenameModal = false
    @State private var showArchiveAlert = false
    @State private var newGoalName = ""
    @State private var showDetailedEntryInput = false
    @State private var newEntryText = ""
    @State private var isAIOverviewPresented = false
    @State private var showDeleteAlert = false
    
    var currentStreak: Int {
        // Quick streak calculation for the current goal entries
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let uniqueDays = Set(goal.entries.map { calendar.startOfDay(for: $0.createdAt) })
        let sortedDays = uniqueDays.sorted(by: >)
        if sortedDays.isEmpty { return 0 }
        if !sortedDays.contains(today) && !sortedDays.contains(calendar.date(byAdding: .day, value: -1, to: today)!) { return 0 }
        
        var streak = 0
        var expectedDate = sortedDays.contains(today) ? today : calendar.date(byAdding: .day, value: -1, to: today)!
        for date in sortedDays {
            if date > expectedDate { continue }
            if date == expectedDate {
                streak += 1
                expectedDate = calendar.date(byAdding: .day, value: -1, to: expectedDate)!
            } else { break }
        }
        return streak
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Picker
            Picker("View Selection", selection: $selectedTab) {
                Text("Timeline").tag(0)
                Text("Calendar").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Tab Content
            if selectedTab == 0 {
                TimelineTabView(goal: goal)
            } else {
                CalendarTabView(goal: goal)
            }
            
            Spacer()
            
            // Sparkle FAB
            if !goal.entries.isEmpty {
                HStack {
                    Spacer()
                    Button(action: { isAIOverviewPresented = true }) {
                        Text("✦")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 16)
                }
            }
            
            // Bottom Action Bar
            VStack(spacing: 0) {
                Divider()
                
                if showDetailedEntryInput {
                    VStack(alignment: .leading) {
                        TextField("What did you do today?", text: $newEntryText)
                            .textFieldStyle(.roundedBorder)
                        
                        HStack {
                            Button("Cancel") {
                                withAnimation {
                                    showDetailedEntryInput = false
                                    newEntryText = ""
                                }
                            }
                            .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button("Save Entry") {
                                saveDetailedEntry()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(newEntryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                }
                
                HStack {
                    Button(action: saveQuickEntry) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Did something today")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        withAnimation {
                            showDetailedEntryInput.toggle()
                        }
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.title3)
                            .frame(width: 48, height: 48)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color(UIColor.systemGroupedBackground))
            }
        }
        .navigationTitle(goal.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isAIOverviewPresented) {
            AIOverviewSheet(goal: goal)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Rename Goal", systemImage: "pencil") {
                        newGoalName = goal.name
                        showRenameModal = true
                    }
                    Button("Archive Goal", systemImage: "archivebox") {
                        showArchiveAlert = true
                    }
                    Button("Delete Goal", systemImage: "trash", role: .destructive) {
                        showDeleteAlert = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: goal.color) ?? .blue)
                            .frame(width: 8, height: 8)
                        Text(goal.name).font(.headline)
                    }
                    if currentStreak >= 2 {
                        Text("\(currentStreak) days in a row")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .alert("Rename Goal", isPresented: $showRenameModal) {
            TextField("Goal Name", text: $newGoalName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                if !newGoalName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    goal.name = newGoalName
                    try? modelContext.save()
                    // Assuming a ToastManager handles "Goal renamed"
                }
            }
        }
        .alert("Archive Goal?", isPresented: $showArchiveAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Archive", role: .destructive) {
                goal.archivedAt = Date()
                
                let goalId = goal.id
                let descriptor = FetchDescriptor<Task>(predicate: #Predicate<Task> { task in
                    task.linkedGoal?.id == goalId
                })
                if let tasks = try? modelContext.fetch(descriptor) {
                    for task in tasks {
                        task.linkedGoal = nil
                    }
                }
                
                try? modelContext.save()
                dismiss() // Pop back to active goals view
            }
        } message: {
            Text("You can unarchive it from Settings.")
        }
        .alert("Delete Goal?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                modelContext.delete(goal)
                try? modelContext.save()
                dismiss() // Pop back to active goals view
            }
        } message: {
            Text("This action is permanent and will delete all progress entries for this goal.")
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private func saveQuickEntry() {
        let entry = GoalEntry(type: .quick)
        goal.entries.append(entry)
        try? modelContext.save()
        NotificationService.shared.recordActivity()
        // Toast "Marked as done!"
    }
    
    private func saveDetailedEntry() {
        let entry = GoalEntry(text: newEntryText.trimmingCharacters(in: .whitespacesAndNewlines), type: .detailed)
        goal.entries.append(entry)
        try? modelContext.save()
        NotificationService.shared.recordActivity()
        // Toast "Progress logged!"
        withAnimation {
            showDetailedEntryInput = false
            newEntryText = ""
        }
    }
}
