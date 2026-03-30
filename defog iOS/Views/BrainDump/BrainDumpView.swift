import SwiftUI
import SwiftData

struct BrainDumpView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(TranscriptionService.self) private var transcriptionService

    @Query(filter: #Predicate<Goal> { $0.archivedAt == nil }, sort: \Goal.createdAt)
    private var activeGoals: [Goal]

    @Query(sort: \Task.createdAt, order: .reverse)
    private var storedTasks: [Task]

    @State private var viewModel = BrainDumpViewModel()

    @FocusState private var isComposerFocused: Bool

    private let placeholderExample = "Buy groceries, call dentist, learn motion design…"

    private static let livePendingGoalPalette: [String] = [
        "#A78BFA", "#34D399", "#F87171", "#60A5FA", "#FBBF24",
        "#FB923C", "#38BDF8", "#F472B6", "#A3E635", "#E879F9"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    Text("Brain Dump")
                        .font(.title2.weight(.bold))
                        .fontDesign(.rounded)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    Text("Tell me everything on your mind")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.bottom, 8)

                    livePreviewScroll

                    composerSection
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isComposerFocused = false
                    }
                    .fontWeight(.semibold)
                }
            }
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
            viewModel.onTextChangedForLiveExtraction(modelContext: modelContext)
        }
        .onChange(of: viewModel.text) { _, _ in
            viewModel.onTextChangedForLiveExtraction(modelContext: modelContext)
        }
    }

    private var livePreviewScroll: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if viewModel.liveExtractionLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Understanding…")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                }

                let hasAnyLive = !viewModel.liveTaskCompletions.isEmpty
                    || !viewModel.liveTasks.isEmpty
                    || !viewModel.liveNewGoals.isEmpty
                    || !viewModel.liveGoalUpdates.isEmpty

                if !viewModel.liveTaskCompletions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(icon: "checkmark.circle.fill", title: "Marking complete")
                        ForEach(viewModel.liveTaskCompletions) { completion in
                            let title = storedTasks.first(where: { $0.id == completion.matchedTaskId })?.text ?? "Open task"
                            BrainDumpLiveCompletionRow(taskTitle: title)
                        }
                    }
                    .padding(.horizontal)
                }

                if !viewModel.liveTasks.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(icon: "checkmark.square", title: "Tasks")
                        ForEach(viewModel.liveTasks) { task in
                            let linkedName = task.linkedGoalName
                            let linkedExisting = linkedName.flatMap { name in
                                activeGoals.first { $0.name.caseInsensitiveCompare(name) == .orderedSame }
                            }
                            let goalHex: String? = {
                                guard let name = linkedName, !name.isEmpty else { return nil }
                                if let g = linkedExisting { return g.color }
                                return Self.hexForPendingGoalLabel(name)
                            }()
                            BrainDumpLiveTaskRow(
                                text: task.text,
                                schedule: task.schedule,
                                linkedGoalName: task.linkedGoalName,
                                goalColorHex: goalHex
                            )
                            .transition(liveCardTransition(fromLeading: viewModel.insertionFromLeadingForTask(id: task.id)))
                        }
                    }
                    .padding(.horizontal)
                }

                if !viewModel.liveNewGoals.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(icon: "target", title: "Goals")
                        ForEach(viewModel.liveNewGoals) { goal in
                            BrainDumpLiveGoalRow(
                                name: goal.name,
                                goalColorHex: Self.hexForPendingGoalLabel(goal.name)
                            )
                                .transition(liveCardTransition(fromLeading: viewModel.insertionFromLeadingForGoal(id: goal.id)))
                        }
                    }
                    .padding(.horizontal)
                }

                if !viewModel.liveGoalUpdates.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(icon: "pencil.line", title: "Goal updates")
                        ForEach(viewModel.liveGoalUpdates) { update in
                            BrainDumpLiveGoalUpdateRow(text: update.text, goalName: update.matchedGoalName)
                        }
                    }
                    .padding(.horizontal)
                }

                if !hasAnyLive,
                   !viewModel.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                   !viewModel.liveExtractionLoading {
                    Text("Keep going — recognized tasks and goals show up here.")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 24)
                        .padding(.horizontal)
                }
            }
            .padding(.bottom, 12)
        }
        .scrollDismissesKeyboard(.interactively)
        .frame(maxHeight: .infinity)
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: viewModel.liveTasks.map(\.id))
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: viewModel.liveNewGoals.map(\.id))
    }

    private var composerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if transcriptionService.permissionDenied {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                    Text("Voice input needs microphone access.").font(.caption)
                    Spacer()
                    Button("Enable in Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .font(.caption.weight(.semibold))
                }
            } else if transcriptionService.isProcessing {
                HStack {
                    ProgressView().scaleEffect(0.7)
                    Text("Finalizing transcription…").font(.caption).foregroundStyle(.secondary)
                }
            }

            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.text)
                    .font(.body)
                    .focused($isComposerFocused)
                    .frame(minHeight: 88, maxHeight: 120)
                    .padding(10)
                    .scrollContentBackground(.hidden)
                    .background(Color(uiColor: .systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(uiColor: .systemGray5), lineWidth: 1)
                    )

                if viewModel.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(placeholderExample)
                        .font(.body)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 18)
                        .padding(.leading, 16)
                        .allowsHitTesting(false)
                }
            }

            HStack(spacing: 12) {
                Button {
                    toggleRecording()
                } label: {
                    Image(systemName: transcriptionService.isRecording ? "square.fill" : "mic.fill")
                        .font(.title2)
                        .foregroundStyle(transcriptionService.isRecording ? .white : .primary)
                        .frame(width: 56, height: 56)
                        .background(transcriptionService.isRecording ? Color.red : Color(uiColor: .systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .scaleEffect(transcriptionService.isRecording ? 1.05 : 1.0)
                        .animation(transcriptionService.isRecording ? Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: transcriptionService.isRecording)
                }

                Button {
                    isComposerFocused = false
                    _Concurrency.Task { @MainActor in
                        if transcriptionService.isRecording {
                            await transcriptionService.stopRecording()
                            viewModel.text = transcriptionService.aggregatedText
                        }
                        let trimmed = viewModel.text.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        viewModel.startProcessing(modelContext: modelContext)
                    }
                } label: {
                    Text("Process")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: 56)
                        .background(canProcess ? Color.primary : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(!canProcess)
            }
        }
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private var canProcess: Bool {
        !viewModel.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private static func hexForPendingGoalLabel(_ name: String) -> String {
        var h = 0
        for byte in name.utf8 {
            h = (h &* 31) &+ Int(byte)
        }
        let idx = abs(h) % livePendingGoalPalette.count
        return livePendingGoalPalette[idx]
    }

    private func liveCardTransition(fromLeading: Bool) -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: fromLeading ? .leading : .trailing).combined(with: .opacity),
            removal: .opacity
        )
    }

    private func toggleRecording() {
        if transcriptionService.isRecording {
            _Concurrency.Task {
                await transcriptionService.stopRecording()
            }
        } else {
            if transcriptionService.isSpeechAuthorized && transcriptionService.isMicrophoneAuthorized {
                isComposerFocused = false
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

// MARK: - Live preview rows

private struct BrainDumpLiveCompletionRow: View {
    let taskTitle: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(taskTitle)
                .font(.subheadline)
                .strikethrough(true)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.35), lineWidth: 1)
        )
    }
}

private struct BrainDumpLiveTaskRow: View {
    let text: String
    let schedule: TaskSchedule
    var linkedGoalName: String?
    var goalColorHex: String?

    private var goalAccentColor: Color? {
        guard let linkedGoalName, !linkedGoalName.isEmpty else { return nil }
        return Color(hex: goalColorHex ?? "#A78BFA") ?? .blue
    }

    var body: some View {
        TaskCardChromeContentOnly(goalAccentColor: goalAccentColor) {
            VStack(alignment: .leading, spacing: 4) {
                Text(text)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 8) {
                    TaskPillView(
                        title: schedule.taskCardScheduleLabel,
                        style: .schedule(color: schedule.taskCardSchedulePillColor)
                    )
                    if let name = linkedGoalName, !name.isEmpty {
                        TaskPillView(
                            title: name,
                            style: .linkedGoal(color: Color(hex: goalColorHex ?? "#A78BFA") ?? .blue)
                        )
                    }
                }
                .padding(.top, 6)
            }
            // Match BrainDumpLiveGoalRow: 8pt dot + 8pt spacing before title.
            .padding(.leading, goalAccentColor == nil ? 0 : 16)
        }
    }
}

private struct BrainDumpLiveGoalRow: View {
    let name: String
    let goalColorHex: String

    private var goalTint: Color {
        Color(hex: goalColorHex) ?? Color(hex: "#A78BFA") ?? .blue
    }

    var body: some View {
        TaskCardChromeContentOnly(goalAccentColor: nil) {
            HStack(alignment: .center, spacing: 8) {
                Circle()
                    .fill(goalTint)
                    .frame(width: 8, height: 8)
                Text(GoalDisplayNameFormatting.formatGoalDisplayName(name))
                    .font(.body)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

private struct BrainDumpLiveGoalUpdateRow: View {
    let text: String
    let goalName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(text)
                .font(.subheadline)
            Text(goalName)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Processing View

struct ProcessingView: View {
    @Binding var result: CategorizationResult?
    @Binding var isProcessing: Bool
    @Binding var processingPathLabel: String
    let onConfirmed: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()

            VStack {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
                Text("Making sense...")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                if !processingPathLabel.isEmpty {
                    Text(processingPathLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
        lhs.tasks.count == rhs.tasks.count &&
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
