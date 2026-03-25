import SwiftUI

private struct TabBarHiddenSetterKey: EnvironmentKey {
    static let defaultValue: (Bool) -> Void = { _ in }
}

extension EnvironmentValues {
    var setTabBarHidden: (Bool) -> Void {
        get { self[TabBarHiddenSetterKey.self] }
        set { self[TabBarHiddenSetterKey.self] = newValue }
    }
}

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
    @State private var isTabBarHidden = false
    
    var body: some View {
        let shouldHideTabBar = isTabBarHidden || showBrainDump

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
        .toolbarVisibility(shouldHideTabBar ? .hidden : .visible, for: .tabBar)
        .onChange(of: selectedTab) { _, newValue in
            isTabBarHidden = false
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
        .environment(\.setTabBarHidden, { hidden in
            isTabBarHidden = hidden
        })
    }
}

#Preview {
    MainTabView()
}
