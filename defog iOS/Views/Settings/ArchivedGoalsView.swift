import SwiftUI
import SwiftData

struct ArchivedGoalsView: View {
    @Query(
        filter: #Predicate<Goal> { goal in
            goal.archivedAt != nil
        },
        sort: \Goal.archivedAt,
        order: .reverse
    ) private var archivedGoals: [Goal]
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List {
            if archivedGoals.isEmpty {
                Text("No archived goals.")
                    .foregroundColor(.secondary)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(archivedGoals) { goal in
                    HStack {
                        Circle()
                            .fill(Color(hex: goal.color) ?? .blue)
                            .frame(width: 10, height: 10)
                        
                        VStack(alignment: .leading) {
                            Text(goal.name)
                                .font(.headline)
                            if let archivedDate = goal.archivedAt {
                                Text("Archived \(archivedDate, format: .dateTime.year().month().day())")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button("Unarchive") {
                            withAnimation {
                                goal.archivedAt = nil
                                try? modelContext.save()
                                // Toast "Goal restored" handled externally
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                }
                .onDelete(perform: deleteArchivedGoals)
            }
        }
        .navigationTitle("Archived Goals")
        // Just in case there is no NavigationView wrapping this currently
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func deleteArchivedGoals(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let goal = archivedGoals[index]
                modelContext.delete(goal)
            }
            try? modelContext.save()
        }
    }
}
