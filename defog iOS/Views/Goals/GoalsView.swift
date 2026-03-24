import SwiftUI
import SwiftData

struct GoalsView: View {
    @Query(
        filter: #Predicate<Goal> { goal in
            goal.archivedAt == nil
        },
        sort: \Goal.createdAt,
        order: .forward
    ) private var activeGoals: [Goal]
    
    // For navigation injection if relying on NavigationStack. 
    // Assuming this view is embedded in MainTabView's NavigationStack.
    
    var body: some View {
        ScrollView {
            if activeGoals.isEmpty {
                VStack(spacing: 16) {
                    Spacer().frame(height: 60)
                    Image(systemName: "target")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No goals yet.")
                        .font(.headline)
                    Text("Add one via brain dump.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(activeGoals) { goal in
                        NavigationLink(value: goal) {
                            GoalCardView(goal: goal)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Goals")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundColor(.primary)
                }
            }
        }
        .navigationDestination(for: Goal.self) { goal in
            GoalDetailView(goal: goal)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}
