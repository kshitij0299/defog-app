import SwiftUI

struct MainTabView: View {
    private enum TabItem: Hashable {
        case home
        case tasks
        case goals
        case add
    }

    @State private var homePath = NavigationPath()
    @State private var tasksPath = NavigationPath()
    @State private var goalsPath = NavigationPath()
    @State private var showBrainDump = false
    @State private var selectedTab: TabItem? = .home
    @State private var previousTab: TabItem = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: .home) {
                NavigationStack(path: $homePath) {
                    HomeView()
                }
            }

            Tab("Tasks", systemImage: "checkmark.square", value: .tasks) {
                NavigationStack(path: $tasksPath) {
                    TasksView()
                }
            }

            Tab("Goals", systemImage: "target", value: .goals) {
                NavigationStack(path: $goalsPath) {
                    GoalsView()
                }
            }

            Tab("Add", systemImage: "plus", value: .add, role: .search) {
                Color.clear
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .onChange(of: selectedTab) { _, newValue in
            if newValue == .add {
                selectedTab = previousTab
                showBrainDump = true
            } else if let newValue {
                previousTab = newValue
            }
        }
        .fullScreenCover(isPresented: $showBrainDump) {
            BrainDumpView()
        }
    }
}

#Preview {
    MainTabView()
}
