import SwiftUI
import SwiftData

struct SettingsView: View {
    private let defaultOpenRouterEndpoint = "https://openrouter.ai/api/v1/chat/completions"
    private let defaultOpenRouterModel = "openai/gpt-4o-mini"

    @State private var showingOnboarding = false
    @State private var showingMigrationAlert = false
    @State private var isMigrating = false
    @State private var migrationProgress: MigrationProgress?
    
    // Default system local container reference for the service
    @Environment(\.modelContext) private var modelContext
    @Environment(TranscriptionService.self) private var transcriptionService
    
    @AppStorage("darkMode") private var isDarkMode = false
    @AppStorage("remindersEnabled") private var remindersEnabled = false
    @AppStorage("aiAPIKey") private var aiAPIKey = ""
    @AppStorage("aiModel") private var aiModel = "openai/gpt-4o-mini"
    @AppStorage("aiEndpoint") private var aiEndpoint = "https://openrouter.ai/api/v1/chat/completions"
    @AppStorage("byomCollapsed") private var byomCollapsed = false
    
    @State private var showNotificationDeniedMsg = false
    @State private var isTestingBYOM = false
    @State private var byomTestPassed: Bool?
    @State private var byomTestMessage = "Not tested yet"
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("APP TOUR")) {
                    Button(action: {
                        showingOnboarding = true
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("What's the difference?")
                            Spacer()
                        }
                    }
                    .foregroundColor(.primary)
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                            Text(version)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("APPEARANCE")) {
                    Toggle("Dark Mode", isOn: bindingForDarkMode)
                }

                Section(
                    header: Text("BYOM"),
                    footer: Text("Bring your own model via an OpenAI-compatible endpoint. Defaults are set for OpenRouter. If API key is empty, app falls back to legacy local rules.")
                ) {
                    if shouldShowCollapsedBYOM {
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                Text("BYOM is connected and responding.")
                                    .foregroundColor(.green)
                                    .font(.subheadline.weight(.semibold))
                            }
                            Spacer()
                            Button {
                                withAnimation {
                                    byomCollapsed = false
                                }
                            } label: {
                                Image(systemName: "pencil")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        TextField("Endpoint URL", text: $aiEndpoint)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        SecureField("API Key", text: $aiAPIKey)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        TextField("Model ID", text: $aiModel)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        Button {
                            _Concurrency.Task {
                                await testBYOMConnection()
                            }
                        } label: {
                            HStack {
                                if isTestingBYOM {
                                    ProgressView()
                                        .controlSize(.small)
                                    Text("Testing BYOM...")
                                } else if byomTestPassed == true {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(byomTestMessage)
                                } else if byomTestPassed == false {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text(byomTestMessage)
                                        .lineLimit(nil)
                                        .multilineTextAlignment(.leading)
                                } else {
                                    Image(systemName: "bolt.horizontal.circle")
                                        .foregroundColor(.secondary)
                                    Text("Test BYOM Connection")
                                }
                            }
                        }
                        .disabled(isTestingBYOM || !canTestBYOM)
                    }
                }
                
                Section(header: Text("REMINDERS"), footer: Text(showNotificationDeniedMsg ? "Enable notifications in Settings to use reminders." : "")) {
                    Toggle("Inactivity reminder", isOn: bindingForReminders)
                    
                    if showNotificationDeniedMsg {
                        Button("Open Settings") {
                            NotificationService.openSettings()
                        }
                        .font(.caption)
                    }
                }

                Section(
                    header: Text("VOICE INPUT"),
                    footer: Text("Voice transcription uses Apple Speech (SFSpeech) only. WhisperKit has been removed from this build.")
                ) {
                    Text("High-accuracy voice is not available in this build.")
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("STORAGE & SYNC")) {
                    HStack {
                        Text("Current Mode")
                        Spacer()
                        Text(UserPreferences.storageMode == .iCloud ? "iCloud Sync" : "This device only")
                            .foregroundColor(.secondary)
                    }
                    
                    if UserPreferences.storageMode == .local {
                        Button(action: {
                            showingMigrationAlert = true
                        }) {
                            HStack {
                                Image(systemName: "icloud.and.arrow.up")
                                Text("Upgrade to iCloud")
                                Spacer()
                             }
                            .foregroundColor(.accentColor)
                        }
                    }
                }
                
                Section(header: Text("DATA MANAGEMENT")) {
                    NavigationLink {
                        ArchivedGoalsView()
                    } label: {
                        HStack {
                            Image(systemName: "archivebox")
                            Text("Archived Goals")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                syncAISettingsIfNeeded()
            }
            .onChange(of: aiEndpoint) { _, _ in resetBYOMTestState() }
            .onChange(of: aiAPIKey) { _, _ in resetBYOMTestState() }
            .onChange(of: aiModel) { _, _ in resetBYOMTestState() }
            .sheet(isPresented: $showingOnboarding) {
                OnboardingView(readOnly: true)
            }
            .alert("Upgrade to iCloud", isPresented: $showingMigrationAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Start Upgrade") {
                    startMigration()
                }
            } message: {
                Text("This will move all your data to iCloud, allowing you to sync across all your devices.")
            }
            .overlay {
                if isMigrating {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        VStack(spacing: 16) {
                            ProgressView()
                            Text("Migrating to iCloud...")
                                .font(.headline)
                            if let progress = migrationProgress {
                                Text("\(progress.current) / \(progress.total) items")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(30)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 10)
                    }
                }
            }
        }
    }
    
    private func startMigration() {
        guard UserPreferences.storageMode == .local else { return }
        
        // Ensure iCloud is available
        guard FileManager.default.ubiquityIdentityToken != nil else { return }
        
        isMigrating = true
        
        _Concurrency.Task {
            // Keep a reference to the primary local container
            let localContainer = modelContext.container
            
            // Create a temporary cloud configuration manually to orchestrate migration
            let schema = Schema([Task.self, Goal.self, GoalEntry.self])
            let cloudConfig = ModelConfiguration("CloudMigration", schema: schema, cloudKitDatabase: .automatic)
            
            do {
                let cloudContainer = try ModelContainer(for: schema, configurations: cloudConfig)
                let migrationService = StorageMigrationService()
                
                let stream = await migrationService.migrate(from: localContainer, to: cloudContainer)
                
                for await progress in stream {
                    await MainActor.run {
                        self.migrationProgress = progress
                    }
                }
                
                // Complete
                await MainActor.run {
                    self.isMigrating = false
                    
                    // Switch underlying mode -> This forces App to recreate the primary Container as Cloud-based
                    UserPreferences.storageMode = .iCloud
                }
                
            } catch {
                await MainActor.run {
                    self.isMigrating = false
                    print("Could not start migration: \(error)")
                }
            }
        }
    }
    
    private var bindingForDarkMode: Binding<Bool> {
        Binding(
            get: { isDarkMode },
            set: { newValue in
                isDarkMode = newValue
                UserPreferences.darkMode = newValue
            }
        )
    }
    
    private var bindingForReminders: Binding<Bool> {
        Binding(
            get: { remindersEnabled },
            set: { newValue in
                if newValue {
                    NotificationService.shared.requestPermission { granted in
                        if granted {
                            remindersEnabled = true
                            UserPreferences.remindersEnabled = true
                            NotificationService.shared.scheduleInactivityNudge()
                            showNotificationDeniedMsg = false
                        } else {
                            remindersEnabled = false
                            UserPreferences.remindersEnabled = false
                            showNotificationDeniedMsg = true
                        }
                    }
                } else {
                    remindersEnabled = false
                    UserPreferences.remindersEnabled = false
                    NotificationService.shared.cancelInactivityNudge()
                    showNotificationDeniedMsg = false
                }
            }
        )
    }

    private func syncAISettingsIfNeeded() {
        aiAPIKey = UserPreferences.aiAPIKey
        if aiModel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            aiModel = defaultOpenRouterModel
        }
        if aiEndpoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            aiEndpoint = defaultOpenRouterEndpoint
        }
    }

    private var canTestBYOM: Bool {
        !aiEndpoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !aiAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !aiModel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var shouldShowCollapsedBYOM: Bool {
        byomCollapsed && !aiAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func resetBYOMTestState() {
        byomTestPassed = nil
        byomTestMessage = "Not tested yet"
        byomCollapsed = false
    }

    @MainActor
    private func testBYOMConnection() async {
        let endpoint = aiEndpoint.trimmingCharacters(in: .whitespacesAndNewlines)
        let apiKey = aiAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let model = aiModel.trimmingCharacters(in: .whitespacesAndNewlines)

        guard canTestBYOM else {
            byomTestPassed = false
            byomTestMessage = "Enter endpoint, API key, and model first."
            return
        }

        guard let url = URL(string: endpoint) else {
            byomTestPassed = false
            byomTestMessage = "Endpoint URL is invalid."
            return
        }

        isTestingBYOM = true
        byomTestPassed = nil
        byomTestMessage = "Checking connection..."

        defer { isTestingBYOM = false }

        do {
            let body = BYOMConnectionTestRequest(
                model: model,
                temperature: 0,
                max_tokens: 8,
                messages: [
                    BYOMConnectionTestMessage(role: "system", content: "Reply with OK."),
                    BYOMConnectionTestMessage(role: "user", content: "Health check")
                ]
            )

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.timeoutInterval = 30
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            if (url.host ?? "").contains("openrouter.ai") {
                request.setValue("https://defog.app", forHTTPHeaderField: "HTTP-Referer")
                request.setValue("Defog iOS", forHTTPHeaderField: "X-Title")
            }
            request.httpBody = try JSONEncoder().encode(body)

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                byomTestPassed = false
                byomTestMessage = "Invalid response from BYOM endpoint."
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let responseBody = String(data: data, encoding: .utf8) ?? ""
                let compactBody = responseBody
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .prefix(140)
                byomTestPassed = false
                byomTestMessage = "Failed (\(httpResponse.statusCode)): \(compactBody)"
                return
            }

            let responseText = String(data: data, encoding: .utf8) ?? ""
            guard responseText.contains("\"choices\"") else {
                byomTestPassed = false
                byomTestMessage = "Connected, but response format is not chat-completions."
                return
            }

            byomTestPassed = true
            byomTestMessage = "BYOM is connected and responding."
            withAnimation {
                byomCollapsed = true
            }
        } catch {
            byomTestPassed = false
            byomTestMessage = "Connection error: \(error.localizedDescription)"
            byomCollapsed = false
        }
    }
}

private struct BYOMConnectionTestRequest: Encodable {
    let model: String
    let temperature: Double
    let max_tokens: Int
    let messages: [BYOMConnectionTestMessage]
}

private struct BYOMConnectionTestMessage: Encodable {
    let role: String
    let content: String
}

#Preview {
    SettingsView()
}
