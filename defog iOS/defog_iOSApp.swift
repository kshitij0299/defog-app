import SwiftUI
import SwiftData
import UIKit

@main
struct defog_iOSApp: App {
    @AppStorage("storageMode") private var rawStorageMode: String = StorageMode.local.rawValue
    @AppStorage("storageChoiceMade") private var storageChoiceMade: Bool = false
    @AppStorage("darkMode") private var isDarkMode: Bool = false
    
    @State private var container: ModelContainer? = nil
    @State private var transcriptionService = TranscriptionService()

    init() {
        let navBarAppearance = UINavigationBar.appearance()
        let inlineBase = UIFont.systemFont(ofSize: 17, weight: .semibold)
        if let descriptor = inlineBase.fontDescriptor.withDesign(.rounded) {
            let inlineRounded = UIFont(descriptor: descriptor, size: inlineBase.pointSize)
            navBarAppearance.titleTextAttributes = [.font: inlineRounded]
        }
        let largeBase = UIFont.systemFont(ofSize: 34, weight: .bold)
        if let descriptor = largeBase.fontDescriptor.withDesign(.rounded) {
            let largeRounded = UIFont(descriptor: descriptor, size: largeBase.pointSize)
            navBarAppearance.largeTitleTextAttributes = [.font: largeRounded]
        }
    }
    
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
