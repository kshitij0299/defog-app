import SwiftUI
import SwiftData

@Observable
final class RootViewModel {
    var showOnboarding: Bool
    var showStorageChoice: Bool
    var showDailyPrompt: Bool = false
    var staleTasks: [Task] = []
    
    init() {
        self.showOnboarding = !UserPreferences.onboardingCompleted
        self.showStorageChoice = !UserPreferences.storageChoiceMade
    }
    
    func checkDailyPrompt(context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 1. Check if we already prompted today
        if let lastPromptDate = UserPreferences.lastDailyPromptDate,
           calendar.isDateInToday(lastPromptDate) {
            return
        }
        
        do {
            let allTasks = try context.fetch(FetchDescriptor<Task>())
            
            // Filter in memory to avoid enum-comparison predicate limitations.
            staleTasks = allTasks.filter {
                $0.schedule == .today &&
                $0.completed == false &&
                $0.createdAt < today
            }
            
            if !staleTasks.isEmpty {
                showDailyPrompt = true
            }
        } catch {
            print("Error fetching tasks for daily prompt: \(error)")
        }
    }
    
    func markPromptShown() {
        UserPreferences.lastDailyPromptDate = Date()
        showDailyPrompt = false
        staleTasks = []
    }
}

struct RootView: View {
    @State private var viewModel = RootViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        if viewModel.showOnboarding {
            OnboardingView(onCompletion: {
                withAnimation {
                    viewModel.showOnboarding = false
                }
            })
            .transition(.opacity)
        } else if viewModel.showStorageChoice {
            StorageChoiceView(onChoiceMade: { _ in
                withAnimation {
                    viewModel.showStorageChoice = false
                }
            })
            .transition(.opacity)
        } else {
            ZStack {
                MainTabView()
                    .transition(.opacity)
                
                if viewModel.showDailyPrompt {
                    DailyPromptOverlay(
                        staleTasksCount: viewModel.staleTasks.count,
                        onMove: {
                            moveTasksToThisWeek()
                        },
                        onKeep: {
                            viewModel.markPromptShown()
                        },
                        onDismiss: {
                            viewModel.showDailyPrompt = false
                            // Note: intentionally NOT calling markPromptShown() here
                            // so it might appear again if they foreground the app later today.
                        }
                    )
                    .zIndex(100)
                }
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active, !viewModel.showOnboarding, !viewModel.showStorageChoice {
                    viewModel.checkDailyPrompt(context: modelContext)
                }
            }
        }
    }
    
    private func moveTasksToThisWeek() {
        for task in viewModel.staleTasks {
            task.schedule = .thisWeek
        }
        try? modelContext.save()
        viewModel.markPromptShown()
    }
}

#Preview {
    RootView()
}
