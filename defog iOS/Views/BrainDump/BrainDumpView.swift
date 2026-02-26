import SwiftUI
import SwiftData

struct BrainDumpView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(TranscriptionService.self) private var transcriptionService
    
    @State private var viewModel = BrainDumpViewModel()
    @State private var engine = OpenRouterCategorizationEngine()
    
    @State private var isProcessing = false
    @State private var categorizationResult: CategorizationResult?
    @State private var processingPathLabel = ""
    @State private var textBeforeRecording = ""
    @State private var processingTask: _Concurrency.Task<Void, Never>?
    
    // For querying existing goals
    @Query(filter: #Predicate<Goal> { goal in
        goal.archivedAt == nil
    }) private var existingGoals: [Goal]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Brain Dump")
                        .font(.title2.weight(.bold))
                        .padding(.horizontal)
                    
                    Text("Tell me everything on your mind")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    TextEditor(text: $viewModel.text)
                        .font(.body)
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(uiColor: .systemGray5), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        .frame(maxHeight: .infinity)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Example")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                        Text("\"Buy groceries, call dentist, learn motion design...\"")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    if transcriptionService.permissionDenied {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
                            Text("Voice input needs microphone access.").font(.caption)
                            Spacer()
                            Button("Enable in Settings") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .font(.caption.weight(.semibold))
                        }
                        .padding(.horizontal)
                    } else if transcriptionService.isProcessing {
                        HStack {
                            ProgressView().scaleEffect(0.7)
                            Text("Enhancing transcription with WhisperKit...").font(.caption).foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                    
                    HStack(spacing: 12) {
                        Button {
                            toggleRecording()
                        } label: {
                            Image(systemName: transcriptionService.isRecording ? "square.fill" : "mic.fill")
                                .font(.title2)
                                .foregroundColor(transcriptionService.isRecording ? .white : .primary)
                                .frame(width: 56, height: 56)
                                .background(transcriptionService.isRecording ? Color.red : Color(uiColor: .systemGray6))
                                .cornerRadius(16)
                                .scaleEffect(transcriptionService.isRecording ? 1.05 : 1.0)
                                .animation(transcriptionService.isRecording ? Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: transcriptionService.isRecording)
                        }
                        
                        Button {
                            startProcessing()
                        } label: {
                            Text("Process")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, maxHeight: 56)
                                .background(viewModel.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.primary)
                                .cornerRadius(16)
                        }
                        .disabled(viewModel.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || transcriptionService.isRecording)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.secondary)
                    }
                }
            }
            // Navigate to Processing / Confirmation
            .navigationDestination(isPresented: $isProcessing) {
                ProcessingView(
                    result: $categorizationResult,
                    isProcessing: $isProcessing,
                    processingPathLabel: $processingPathLabel,
                    onConfirmed: {
                        isProcessing = false
                        dismiss()
                    }
                )
            }
        }
        .onChange(of: categorizationResult?.tasks.count) {
            // Once we have a result from the Processing view, it will handle navigating further
            // Alternatively, ProcessingView handles the AI Task directly and pushes ConfirmationView
        }
        .onChange(of: isProcessing) { _, newValue in
            if !newValue {
                processingTask?.cancel()
                processingTask = nil
            }
        }
        .onChange(of: transcriptionService.partialTranscript) { _, newPart in
            if transcriptionService.isRecording {
                viewModel.text = textBeforeRecording + newPart
            }
        }
        .onChange(of: transcriptionService.finalTranscript) { _, newFinal in
            if !newFinal.isEmpty {
                viewModel.text = textBeforeRecording + newFinal
            }
        }
    }
    
    private func toggleRecording() {
        if transcriptionService.isRecording {
            _Concurrency.Task {
                await transcriptionService.stopRecording()
            }
        } else {
            if transcriptionService.isSpeechAuthorized && transcriptionService.isMicrophoneAuthorized {
                textBeforeRecording = viewModel.text
                if !textBeforeRecording.isEmpty && !textBeforeRecording.hasSuffix(" ") {
                    textBeforeRecording += " "
                }
                transcriptionService.startRecording()
            } else {
                transcriptionService.requestPermissionsIfNeeded()
            }
        }
    }
    
    private func startProcessing() {
        processingTask?.cancel()
        categorizationResult = nil
        isProcessing = true
        processingPathLabel = initialProcessingPathLabel()
        
        // Simulate a small delay for "Making sense..." feeling
        processingTask = _Concurrency.Task {
            // Processing logic that hands off to the engine
            let result = await engine.categorize(text: viewModel.text, existingGoals: existingGoals)
            guard !_Concurrency.Task.isCancelled else { return }
            
            try? await _Concurrency.Task.sleep(nanoseconds: 1_000_000_000) // 1s delay
            guard !_Concurrency.Task.isCancelled else { return }
            
            await MainActor.run {
                guard self.isProcessing else { return }
                self.processingPathLabel = result.source.processingLabel
                self.categorizationResult = result
            }
        }
    }

    private func initialProcessingPathLabel() -> String {
        let trimmedAPIKey = UserPreferences.aiAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAPIKey.isEmpty else {
            return CategorizationSource.legacyLocal(reason: "no API key").processingLabel
        }
        return CategorizationSource.byom(model: UserPreferences.aiModel).processingLabel
    }
}

// MARK: - Processing View

struct ProcessingView: View {
    @Binding var result: CategorizationResult?
    @Binding var isProcessing: Bool
    @Binding var processingPathLabel: String
    let onConfirmed: () -> Void
    
    @State private var path = NavigationPath()
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            
            VStack {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
                Text("Making sense...")
                    .font(.headline)
                    .foregroundColor(.secondary)
                if !processingPathLabel.isEmpty {
                    Text(processingPathLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .navigationTitle("Processing")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    result = nil
                    isProcessing = false
                }
            }
        }
        .onDisappear {
            if !isProcessing {
                result = nil
            }
        }
        .onChange(of: result?.tasks.count) {
            // Hacky trigger for Swift 5.9 observation
            if result != nil {
                 // The parent will handle the destination, or we can use a navigationDestination here
            }
        }
        .navigationDestination(item: $result) { catResult in
            ConfirmationView(
                rootIsActive: $isProcessing,
                onConfirmed: onConfirmed,
                viewModel: ConfirmationViewModel(result: catResult)
            )
        }
    }
}

// Helper to make CategorizationResult equatable/hashable for navigation
extension CategorizationResult: Hashable {
    static func == (lhs: CategorizationResult, rhs: CategorizationResult) -> Bool {
        return lhs.tasks.count == rhs.tasks.count &&
               lhs.newGoals.count == rhs.newGoals.count &&
               lhs.goalUpdates.count == rhs.goalUpdates.count
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(tasks.count)
        hasher.combine(newGoals.count)
        hasher.combine(goalUpdates.count)
    }
}
