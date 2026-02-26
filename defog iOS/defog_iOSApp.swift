import SwiftUI
import SwiftData

@main
struct defog_iOSApp: App {
    @AppStorage("storageMode") private var rawStorageMode: String = StorageMode.local.rawValue
    @AppStorage("storageChoiceMade") private var storageChoiceMade: Bool = false
    @AppStorage("darkMode") private var isDarkMode: Bool = false
    
    @State private var container: ModelContainer? = nil
    @State private var transcriptionService = TranscriptionService()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let container {
                    ContentView()
                        .modelContainer(container)
                        .environment(transcriptionService)
                        .preferredColorScheme(isDarkMode ? .dark : .light)
                } else {
                    ProgressView("Initializing...")
                }
            }
            .task {
                setupContainer()
            }
            .onChange(of: rawStorageMode) { _, _ in
                setupContainer()
            }
            .onChange(of: storageChoiceMade) { _, _ in
                setupContainer()
            }
        }
    }
    
    private func setupContainer() {
        do {
            let config: ModelConfiguration
            let mode = StorageMode(rawValue: rawStorageMode) ?? .local
            let schema = Schema([Task.self, Goal.self, GoalEntry.self])
            
            if !storageChoiceMade || mode == .local {
                config = ModelConfiguration(isStoredInMemoryOnly: false)
            } else {
                config = ModelConfiguration("Cloud", schema: schema, cloudKitDatabase: .automatic)
            }
            
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            print("Failed to initialize SwiftData container: \(error)")
            // Fall back to in-memory container
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let schema = Schema([Task.self, Goal.self, GoalEntry.self])
            container = try! ModelContainer(for: schema, configurations: config)
        }
    }
}
