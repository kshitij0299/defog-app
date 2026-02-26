import SwiftUI

struct MainTabView: View {
    @State private var homePath = NavigationPath()
    @State private var tasksPath = NavigationPath()
    @State private var goalsPath = NavigationPath()
    @State private var settingsPath = NavigationPath()
    @State private var showBrainDump = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView {
                NavigationStack(path: $homePath) {
                    HomeView()
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                
                NavigationStack(path: $tasksPath) {
                    TasksView()
                }
                .tabItem {
                    Label("Tasks", systemImage: "checkmark.square")
                }
                
                NavigationStack(path: $goalsPath) {
                    GoalsView()
                }
                .tabItem {
                    Label("Goals", systemImage: "target")
                }

                NavigationStack(path: $settingsPath) {
                    SettingsView()
                }
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
            }
            
            Button(action: {
                showBrainDump = true
            }) {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .padding(.bottom, 80)
            .padding(.trailing, 24)
        }
        .fullScreenCover(isPresented: $showBrainDump) {
            BrainDumpView()
        }
    }
}

#Preview {
    MainTabView()
}
