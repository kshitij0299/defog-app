import SwiftUI
import SwiftData

struct BrainDumpView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(TranscriptionService.self) private var transcriptionService
    
    @State private var viewModel = BrainDumpViewModel()
    
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
                            Text("Finalizing transcription...").font(.caption).foregroundColor(.secondary)
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
                            viewModel.startProcessing(modelContext: modelContext)
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
            .navigationDestination(isPresented: $viewModel.isProcessing) {
                ProcessingView(
                    result: $viewModel.categorizationResult,
                    isProcessing: $viewModel.isProcessing,
                    processingPathLabel: $viewModel.processingPathLabel,
                    onConfirmed: {
                        viewModel.isProcessing = false
                        dismiss()
                    },
                    onCancel: {
                        viewModel.cancelProcessing()
                    }
                )
            }
        }
        .onChange(of: transcriptionService.aggregatedText) { _, newText in
            viewModel.text = newText
        }
    }
    
    private func toggleRecording() {
        if transcriptionService.isRecording {
            _Concurrency.Task {
                await transcriptionService.stopRecording()
            }
        } else {
            if transcriptionService.isSpeechAuthorized && transcriptionService.isMicrophoneAuthorized {
                var baseText = viewModel.text
                if !baseText.isEmpty && !baseText.hasSuffix(" ") {
                    baseText += " "
                }
                transcriptionService.startRecording(baseText: baseText)
            } else {
                transcriptionService.requestPermissionsIfNeeded()
            }
        }
    }
}

// MARK: - Processing View

struct ProcessingView: View {
    @Binding var result: CategorizationResult?
    @Binding var isProcessing: Bool
    @Binding var processingPathLabel: String
    let onConfirmed: () -> Void
    let onCancel: () -> Void
    
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
                    onCancel()
                }
            }
        }
        .onDisappear {
            if !isProcessing {
                result = nil
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
               lhs.goalUpdates.count == rhs.goalUpdates.count &&
               lhs.taskCompletions.count == rhs.taskCompletions.count
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(tasks.count)
        hasher.combine(newGoals.count)
        hasher.combine(goalUpdates.count)
        hasher.combine(taskCompletions.count)
    }
}
