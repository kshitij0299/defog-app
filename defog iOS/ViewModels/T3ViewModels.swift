import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
class BrainDumpViewModel {
    var text: String = ""
    var isMicrophoneEnabled: Bool = false
    var showPermissionAlert: Bool = false
    
    var engine: CategorizationEngine
    var isProcessing: Bool = false
    var categorizationResult: CategorizationResult? = nil
    var processingPathLabel: String = ""
    var processingTask: _Concurrency.Task<Void, Never>? = nil

    // MARK: - Live preview (debounced)

    var liveTasks: [CategorizedTask] = []
    var liveNewGoals: [CategorizedNewGoal] = []
    var liveGoalUpdates: [LivePreviewGoalUpdate] = []
    var liveTaskCompletions: [CategorizedTaskCompletion] = []
    var liveExtractionLoading: Bool = false
    var liveExtractionError: String?

    /// Alternating slide-in edge for new task rows (by id).
    var taskInsertionFromLeading: [UUID: Bool] = [:]
    /// Alternating slide-in edge for new goal rows (by id).
    var goalInsertionFromLeading: [UUID: Bool] = [:]

    private var liveDebounceTask: _Concurrency.Task<Void, Never>?
    private var liveExtractionGeneration: UInt64 = 0
    private var nextTaskAnimFromLeading: Bool = true
    private var nextGoalAnimFromLeading: Bool = true

    private static let liveDebounceNanoseconds: UInt64 = 2_500_000_000

    init(engine: CategorizationEngine = OpenRouterCategorizationEngine()) {
        self.engine = engine
    }
    
    // Optional integration for T4 future
    func checkMicrophonePermission() {
        // Mock permission check
        // showPermissionAlert = true / false 
    }
    
    func startProcessing(modelContext: ModelContext) {
        cancelLiveDebouncing()
        cancelProcessing()
        isProcessing = true
        processingPathLabel = initialProcessingPathLabel()
        
        let existingGoals = (try? modelContext.fetch(
            FetchDescriptor<Goal>(predicate: #Predicate { $0.archivedAt == nil })
        )) ?? []
        
        let openTasksRaw = (try? modelContext.fetch(
            FetchDescriptor<Task>(predicate: #Predicate { $0.completed == false }, sortBy: [SortDescriptor(\.createdAt)])
        )) ?? []
        let openTaskSummaries = openTasksRaw.map { ExistingOpenTaskSummary(id: $0.id, text: $0.text) }
        
        let livePreview = LivePreviewContext(
            pendingNewGoalNames: liveNewGoals.map(\.name),
            liveTasks: liveTasks.map {
                LivePreviewTaskLine(text: $0.text, schedule: $0.schedule, linkedGoalName: $0.linkedGoalName)
            }
        )

        processingTask = _Concurrency.Task {
            let result = await engine.categorize(
                text: text,
                existingGoals: existingGoals,
                openTasks: openTaskSummaries,
                livePreview: livePreview
            )
            guard !_Concurrency.Task.isCancelled else { return }
            
            try? await _Concurrency.Task.sleep(for: .seconds(1))
            guard !_Concurrency.Task.isCancelled else { return }
            
            guard self.isProcessing else { return }
            self.processingPathLabel = result.source.processingLabel
            self.categorizationResult = result
        }
    }
    
    func cancelProcessing() {
        processingTask?.cancel()
        processingTask = nil
        isProcessing = false
        categorizationResult = nil
    }

    /// Call when `text` changes (typing or transcription).
    func onTextChangedForLiveExtraction(modelContext: ModelContext) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            cancelLiveDebouncing()
            clearLivePreview()
            return
        }
        scheduleLiveExtraction(modelContext: modelContext)
    }

    func cancelLiveDebouncing() {
        liveDebounceTask?.cancel()
        liveDebounceTask = nil
    }

    func clearLivePreview() {
        liveTasks = []
        liveNewGoals = []
        liveGoalUpdates = []
        liveTaskCompletions = []
        taskInsertionFromLeading = [:]
        goalInsertionFromLeading = [:]
        liveExtractionLoading = false
        liveExtractionError = nil
    }

    private func scheduleLiveExtraction(modelContext: ModelContext) {
        cancelLiveDebouncing()
        liveExtractionGeneration &+= 1
        let generation = liveExtractionGeneration

        liveDebounceTask = _Concurrency.Task { [weak self] in
            try? await _Concurrency.Task.sleep(nanoseconds: Self.liveDebounceNanoseconds)
            guard let self, !_Concurrency.Task.isCancelled else { return }
            guard generation == self.liveExtractionGeneration else { return }
            await self.runLiveExtraction(modelContext: modelContext, generation: generation)
        }
    }

    private func runLiveExtraction(modelContext: ModelContext, generation: UInt64) async {
        guard generation == liveExtractionGeneration else { return }

        let existingGoals = (try? modelContext.fetch(
            FetchDescriptor<Goal>(predicate: #Predicate { $0.archivedAt == nil })
        )) ?? []

        let openTasksRaw = (try? modelContext.fetch(
            FetchDescriptor<Task>(predicate: #Predicate { $0.completed == false }, sortBy: [SortDescriptor(\.createdAt)])
        )) ?? []
        let openTaskSummaries = openTasksRaw.map { ExistingOpenTaskSummary(id: $0.id, text: $0.text) }

        liveExtractionLoading = true
        liveExtractionError = nil

        let livePreview = LivePreviewContext(
            pendingNewGoalNames: liveNewGoals.map(\.name),
            liveTasks: liveTasks.map {
                LivePreviewTaskLine(text: $0.text, schedule: $0.schedule, linkedGoalName: $0.linkedGoalName)
            }
        )
        let response = await engine.categorizeLive(
            text: text,
            existingGoals: existingGoals,
            openTasks: openTaskSummaries,
            livePreview: livePreview
        )

        guard generation == liveExtractionGeneration else { return }

        liveExtractionLoading = false

        let oldTaskIds = Set(liveTasks.map(\.id))
        let oldGoalIds = Set(liveNewGoals.map(\.id))

        var commands = response.commands
        let syntheticDeletes = Self.syntheticGoalDeleteCommandsIfNeeded(
            text: text,
            pendingGoalNames: liveNewGoals.map(\.name),
            existingCommands: commands
        )
        commands.append(contentsOf: syntheticDeletes)

        let taskSnapshot: [CategorizedTask]
        let goalSnapshot: [CategorizedNewGoal]
        if Self.shouldRecoverEmptySnapshot(
            response: response,
            liveTasks: liveTasks,
            liveNewGoals: liveNewGoals,
            commands: commands
        ) {
            taskSnapshot = liveTasks
            goalSnapshot = liveNewGoals
        } else {
            taskSnapshot = response.tasks
            goalSnapshot = response.newGoals
        }

        var mergedTasks = Self.mergeTasksPreservingIds(existing: liveTasks, snapshot: taskSnapshot)
        mergedTasks = Self.mergeTasksPreservingIdsWithGoalDeleteGuard(
            existing: liveTasks,
            merged: mergedTasks,
            commands: commands
        )
        var mergedGoals = Self.mergeNewGoalsPreservingIds(existing: liveNewGoals, snapshot: goalSnapshot)
        var mergedUpdates = Self.mergeGoalUpdatesPreservingIds(existing: liveGoalUpdates, snapshot: response.goalUpdates)
        let mergedCompletions = response.taskCompletions

        let existingNames = existingGoals.map(\.name)
        mergedTasks = mergedTasks.map { t in
            var t = t
            t.linkedGoalName = Self.resolveLiveLinkedGoalName(t.linkedGoalName, newGoals: mergedGoals, existingGoalNames: existingNames)
            return t
        }

        Self.applyVoiceCommands(
            commands: commands,
            tasks: &mergedTasks,
            newGoals: &mergedGoals,
            existingGoalNames: existingNames
        )

        Self.recordNewInsertionEdges(
            oldTaskIds: oldTaskIds,
            newTasks: mergedTasks,
            map: &taskInsertionFromLeading,
            nextLeading: &nextTaskAnimFromLeading
        )
        Self.recordNewInsertionEdgesGoals(
            oldGoalIds: oldGoalIds,
            newGoals: mergedGoals,
            map: &goalInsertionFromLeading,
            nextLeading: &nextGoalAnimFromLeading
        )

        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
            liveTasks = mergedTasks
            liveNewGoals = mergedGoals
            liveGoalUpdates = mergedUpdates
            liveTaskCompletions = mergedCompletions
        }
    }

    func insertionFromLeadingForTask(id: UUID) -> Bool {
        taskInsertionFromLeading[id] ?? true
    }

    func insertionFromLeadingForGoal(id: UUID) -> Bool {
        goalInsertionFromLeading[id] ?? true
    }

    // MARK: - Merge + commands (static helpers)

    private static func normalizeKey(_ s: String) -> String {
        s.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .punctuationCharacters)
    }

    private static func mergeTasksPreservingIds(existing: [CategorizedTask], snapshot: [CategorizedTask]) -> [CategorizedTask] {
        var used = Set<UUID>()
        var result: [CategorizedTask] = []
        for item in snapshot {
            let key = normalizeKey(item.text)
            if let match = existing.first(where: { !used.contains($0.id) && normalizeKey($0.text) == key }) {
                used.insert(match.id)
                var t = item
                t.id = match.id
                result.append(t)
            } else if let fuzzy = existing.first(where: { !used.contains($0.id) && (normalizeKey($0.text).contains(key) || key.contains(normalizeKey($0.text))) && !key.isEmpty }) {
                used.insert(fuzzy.id)
                var t = item
                t.id = fuzzy.id
                result.append(t)
            } else {
                result.append(item)
            }
        }
        return result
    }

    private static func mergeNewGoalsPreservingIds(existing: [CategorizedNewGoal], snapshot: [CategorizedNewGoal]) -> [CategorizedNewGoal] {
        var used = Set<UUID>()
        var result: [CategorizedNewGoal] = []
        for item in snapshot {
            let key = normalizeKey(item.name)
            if let match = existing.first(where: { !used.contains($0.id) && normalizeKey($0.name) == key }) {
                used.insert(match.id)
                var g = item
                g.id = match.id
                g.name = match.name
                result.append(g)
            } else if let fuzzy = existing.first(where: { !used.contains($0.id) && (normalizeKey($0.name).contains(key) || key.contains(normalizeKey($0.name))) && !key.isEmpty }) {
                used.insert(fuzzy.id)
                var g = item
                g.id = fuzzy.id
                g.name = fuzzy.name
                result.append(g)
            } else {
                var g = item
                g.name = GoalDisplayNameFormatting.formatGoalDisplayName(item.name)
                result.append(g)
            }
        }
        return result
    }

    private static func mergeGoalUpdatesPreservingIds(existing: [LivePreviewGoalUpdate], snapshot: [LivePreviewGoalUpdate]) -> [LivePreviewGoalUpdate] {
        var used = Set<UUID>()
        var result: [LivePreviewGoalUpdate] = []
        for item in snapshot {
            let tk = normalizeKey(item.text)
            let gk = normalizeKey(item.matchedGoalName)
            if let match = existing.first(where: { !used.contains($0.id) && normalizeKey($0.text) == tk && normalizeKey($0.matchedGoalName) == gk }) {
                used.insert(match.id)
                var u = item
                u.id = match.id
                result.append(u)
            } else {
                result.append(item)
            }
        }
        return result
    }

    private static func normalizeCommandOp(_ op: String) -> String {
        op.lowercased().replacingOccurrences(of: "-", with: "_")
    }

    private static func shouldRecoverEmptySnapshot(
        response: LiveExtractionResponse,
        liveTasks: [CategorizedTask],
        liveNewGoals: [CategorizedNewGoal],
        commands: [LiveVoiceCommand]
    ) -> Bool {
        guard response.tasks.isEmpty && response.newGoals.isEmpty else { return false }
        guard !liveTasks.isEmpty || !liveNewGoals.isEmpty else { return false }
        return commands.contains(where: { normalizeCommandOp($0.op) == "delete_goal" })
    }

    private static func textImpliesGoalRemovalSentence(_ text: String) -> Bool {
        let t = text.lowercased()
        let phrases = [
            "don't want", "dont want", "do not want",
            "delete the", "remove the", "drop the",
            "without the", "no longer want", "don't need", "don't need the",
            "i don't want", "i dont want"
        ]
        return phrases.contains(where: { t.contains($0) })
    }

    private static func pendingGoalMentioned(_ name: String, textLowercased t: String) -> Bool {
        t.contains(name.lowercased())
    }

    private static func syntheticGoalDeleteCommandsIfNeeded(
        text: String,
        pendingGoalNames: [String],
        existingCommands: [LiveVoiceCommand]
    ) -> [LiveVoiceCommand] {
        guard !pendingGoalNames.isEmpty else { return [] }
        if existingCommands.contains(where: { normalizeCommandOp($0.op) == "delete_goal" }) { return [] }
        let t = text.lowercased()
        guard textImpliesGoalRemovalSentence(text) else { return [] }
        for name in pendingGoalNames where pendingGoalMentioned(name, textLowercased: t) {
            return [LiveVoiceCommand(op: "delete_goal", goalName: name)]
        }
        return []
    }

    private static func mergeTasksPreservingIdsWithGoalDeleteGuard(
        existing: [CategorizedTask],
        merged: [CategorizedTask],
        commands: [LiveVoiceCommand]
    ) -> [CategorizedTask] {
        guard commands.contains(where: { normalizeCommandOp($0.op) == "delete_goal" }) else { return merged }
        var result = merged
        let mergedIds = Set(merged.map(\.id))
        for prev in existing where !mergedIds.contains(prev.id) {
            if taskMatchedByDeleteCommand(prev, commands: commands) { continue }
            result.append(prev)
        }
        return result
    }

    private static func taskMatchedByDeleteCommand(_ task: CategorizedTask, commands: [LiveVoiceCommand]) -> Bool {
        for cmd in commands {
            guard normalizeCommandOp(cmd.op) == "delete_task" else { continue }
            guard let needle = firstNonEmptyField([cmd.taskText, cmd.fromText]) else { continue }
            let n = normalizeKey(needle)
            let tk = normalizeKey(task.text)
            if tk == n || tk.contains(n) || n.contains(tk) { return true }
        }
        return false
    }

    private static func recordNewInsertionEdges(
        oldTaskIds: Set<UUID>,
        newTasks: [CategorizedTask],
        map: inout [UUID: Bool],
        nextLeading: inout Bool
    ) {
        for t in newTasks where !oldTaskIds.contains(t.id) {
            map[t.id] = nextLeading
            nextLeading.toggle()
        }
    }

    private static func recordNewInsertionEdgesGoals(
        oldGoalIds: Set<UUID>,
        newGoals: [CategorizedNewGoal],
        map: inout [UUID: Bool],
        nextLeading: inout Bool
    ) {
        for g in newGoals where !oldGoalIds.contains(g.id) {
            map[g.id] = nextLeading
            nextLeading.toggle()
        }
    }

    private static func findTaskIndex(tasks: [CategorizedTask], needle: String?) -> Int? {
        guard let needle, !needle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        let n = normalizeKey(needle)
        return tasks.firstIndex { normalizeKey($0.text) == n || normalizeKey($0.text).contains(n) || n.contains(normalizeKey($0.text)) }
    }

    private static func findGoalIndex(goals: [CategorizedNewGoal], needle: String?) -> Int? {
        guard let needle, !needle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        let n = normalizeKey(needle)
        return goals.firstIndex { normalizeKey($0.name) == n || normalizeKey($0.name).contains(n) || n.contains(normalizeKey($0.name)) }
    }

    private static func firstNonEmptyField(_ fields: [String?]) -> String? {
        for s in fields {
            if let t = s?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty { return t }
        }
        return nil
    }

    private static func goalCommandNeedle(_ cmd: LiveVoiceCommand) -> String? {
        firstNonEmptyField([cmd.goalName, cmd.fromText, cmd.taskText])
    }

    private static func renameGoalOldNeedle(_ cmd: LiveVoiceCommand) -> String? {
        firstNonEmptyField([cmd.fromText, cmd.goalName, cmd.taskText])
    }

    private static func unlinkTasksFromExistingGoal(
        canonicalName: String,
        tasks: inout [CategorizedTask]
    ) {
        let n = normalizeKey(canonicalName)
        for j in tasks.indices {
            guard let link = tasks[j].linkedGoalName else { continue }
            if normalizeKey(link) == n {
                tasks[j].linkedGoalName = nil
            }
        }
    }

    private static func resolveLiveLinkedGoalName(
        _ raw: String?,
        newGoals: [CategorizedNewGoal],
        existingGoalNames: [String]
    ) -> String? {
        guard let raw = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return nil }
        if let canon = existingGoalDisplayName(matching: raw, existingGoalNames: existingGoalNames) { return canon }
        let n = normalizeKey(raw)
        if let g = newGoals.first(where: {
            normalizeKey($0.name) == n
                || normalizeKey($0.name).contains(n)
                || n.contains(normalizeKey($0.name))
        }) {
            return g.name
        }
        return GoalDisplayNameFormatting.formatGoalDisplayName(raw)
    }

    private static func ensureLiveNewGoal(
        named raw: String,
        confidence: Double,
        newGoals: inout [CategorizedNewGoal],
        existingGoalNames: [String]
    ) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }
        if let canon = existingGoalDisplayName(matching: trimmed, existingGoalNames: existingGoalNames) {
            return canon
        }
        if let i = findGoalIndex(goals: newGoals, needle: trimmed) {
            return newGoals[i].name
        }
        let display = GoalDisplayNameFormatting.formatGoalDisplayName(trimmed)
        newGoals.append(CategorizedNewGoal(name: display, confidence: confidence))
        return display
    }

    private static func existingGoalDisplayName(matching needle: String, existingGoalNames: [String]) -> String? {
        let n = normalizeKey(needle)
        if let ex = existingGoalNames.first(where: { normalizeKey($0) == n }) { return ex }
        return existingGoalNames.first(where: { normalizeKey($0).contains(n) || n.contains(normalizeKey($0)) })
    }

    private static func applyVoiceCommands(
        commands: [LiveVoiceCommand],
        tasks: inout [CategorizedTask],
        newGoals: inout [CategorizedNewGoal],
        existingGoalNames: [String]
    ) {
        for cmd in commands {
            let op = normalizeCommandOp(cmd.op)
            switch op {
            case "delete_task":
                if let i = findTaskIndex(tasks: tasks, needle: cmd.taskText ?? cmd.fromText) {
                    tasks.remove(at: i)
                }
            case "rename_task":
                guard let to = cmd.toText?.trimmingCharacters(in: .whitespacesAndNewlines), !to.isEmpty else { continue }
                if let i = findTaskIndex(tasks: tasks, needle: cmd.fromText ?? cmd.taskText) {
                    tasks[i].text = to
                }
            case "set_schedule":
                guard let raw = cmd.schedule?.lowercased() else { continue }
                let sched = TaskSchedule(rawValue: raw) ?? .someday
                if let i = findTaskIndex(tasks: tasks, needle: cmd.taskText) {
                    tasks[i].schedule = sched
                }
            case "link_goal":
                let gName = (cmd.goalName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                guard !gName.isEmpty else { continue }
                guard let i = findTaskIndex(tasks: tasks, needle: cmd.taskText) else { continue }
                let conf = tasks[i].confidence
                let canon = ensureLiveNewGoal(
                    named: gName,
                    confidence: conf,
                    newGoals: &newGoals,
                    existingGoalNames: existingGoalNames
                )
                tasks[i].linkedGoalName = canon.isEmpty ? nil : canon
            case "delete_goal":
                guard let rawNeedle = goalCommandNeedle(cmd) else { continue }
                let needle = GoalDisplayNameFormatting.formatGoalDisplayName(rawNeedle)
                let goalIdx = findGoalIndex(goals: newGoals, needle: rawNeedle)
                    ?? findGoalIndex(goals: newGoals, needle: needle)
                if let i = goalIdx {
                    let removedName = newGoals[i].name
                    newGoals.remove(at: i)
                    let rn = normalizeKey(removedName)
                    for j in tasks.indices {
                        guard let link = tasks[j].linkedGoalName else { continue }
                        if normalizeKey(link) == rn || link == removedName {
                            tasks[j].linkedGoalName = nil
                        }
                    }
                } else if let canon = existingGoalDisplayName(matching: rawNeedle, existingGoalNames: existingGoalNames)
                    ?? existingGoalDisplayName(matching: needle, existingGoalNames: existingGoalNames)
                {
                    unlinkTasksFromExistingGoal(canonicalName: canon, tasks: &tasks)
                }
            case "rename_goal":
                guard let toRaw = cmd.toText?.trimmingCharacters(in: .whitespacesAndNewlines), !toRaw.isEmpty else { continue }
                let to = GoalDisplayNameFormatting.formatGoalDisplayName(toRaw)
                guard let oldRaw = renameGoalOldNeedle(cmd) else { continue }
                let oldFormatted = GoalDisplayNameFormatting.formatGoalDisplayName(oldRaw)
                if let i = findGoalIndex(goals: newGoals, needle: oldRaw)
                    ?? findGoalIndex(goals: newGoals, needle: oldFormatted)
                {
                    let previousName = newGoals[i].name
                    newGoals[i].name = to
                    let prevKey = normalizeKey(previousName)
                    for j in tasks.indices {
                        guard let link = tasks[j].linkedGoalName else { continue }
                        if normalizeKey(link) == prevKey || link == previousName {
                            tasks[j].linkedGoalName = to
                        }
                    }
                }
            case "move_task_to_goal":
                let gNameRaw = (cmd.goalName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                guard !gNameRaw.isEmpty else { continue }
                guard let ti = findTaskIndex(tasks: tasks, needle: cmd.taskText) else { continue }
                let conf = tasks[ti].confidence
                let canonical = ensureLiveNewGoal(
                    named: gNameRaw,
                    confidence: conf,
                    newGoals: &newGoals,
                    existingGoalNames: existingGoalNames
                )
                tasks[ti].linkedGoalName = canonical.isEmpty ? nil : canonical
            case "move_goal_to_task":
                guard let gNeedle = goalCommandNeedle(cmd) else { continue }
                if let gi = findGoalIndex(goals: newGoals, needle: gNeedle)
                    ?? findGoalIndex(goals: newGoals, needle: GoalDisplayNameFormatting.formatGoalDisplayName(gNeedle))
                {
                    let g = newGoals.remove(at: gi)
                    tasks.append(CategorizedTask(text: g.name, schedule: .someday, confidence: g.confidence, linkedGoalName: nil))
                }
            default:
                break
            }
        }
    }
    
    func initialProcessingPathLabel() -> String {
        let trimmedAPIKey = UserPreferences.aiAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAPIKey.isEmpty else {
            return CategorizationSource.legacyLocal(reason: "no API key").processingLabel
        }
        return CategorizationSource.byom(model: UserPreferences.aiModel).processingLabel
    }
}

@Observable
class ConfirmationViewModel {
    var result: CategorizationResult
    
    init(result: CategorizationResult) {
        self.result = result
    }
    
    // MARK: - Actions
    
    func removeTask(at index: Int) {
        guard result.tasks.indices.contains(index) else { return }
        result.tasks.remove(at: index)
    }
    
    func removeNewGoal(at index: Int) {
        guard result.newGoals.indices.contains(index) else { return }
        result.newGoals.remove(at: index)
    }
    
    func removeGoalUpdate(at index: Int) {
        guard result.goalUpdates.indices.contains(index) else { return }
        result.goalUpdates.remove(at: index)
    }
    
    func removeTaskCompletion(at index: Int) {
        guard result.taskCompletions.indices.contains(index) else { return }
        result.taskCompletions.remove(at: index)
    }
    
    func updateTaskSchedule(at index: Int, schedule: TaskSchedule) {
        guard result.tasks.indices.contains(index) else { return }
        result.tasks[index].schedule = schedule
    }
    
    func updateTaskGoal(at index: Int, newGoalName: String?) {
        guard result.tasks.indices.contains(index) else { return }
        result.tasks[index].linkedGoalName = newGoalName
    }
    
    func updateGoalUpdateDestination(at index: Int, newGoal: Goal?, createNewName: String?) {
        guard result.goalUpdates.indices.contains(index) else { return }
        
        if let newGoal = newGoal {
            result.goalUpdates[index].matchedGoal = newGoal
        } else if let createNewName = createNewName {
            result.goalUpdates.remove(at: index)
            let name = GoalDisplayNameFormatting.formatGoalDisplayName(createNewName)
            result.newGoals.append(CategorizedNewGoal(name: name, confidence: 1.0))
        }
    }
    
    // MARK: - Drag and Drop Actions
    
    func moveToTasks(_ newGoalId: UUID) {
        guard let index = result.newGoals.firstIndex(where: { $0.id == newGoalId }) else { return }
        let goal = result.newGoals.remove(at: index)
        // Ensure new tasks appear at the bottom
        result.tasks.append(CategorizedTask(text: goal.name, schedule: .someday, confidence: goal.confidence, linkedGoalName: nil))
    }
    
    func moveToGoals(_ taskId: UUID) {
        guard let index = result.tasks.firstIndex(where: { $0.id == taskId }) else { return }
        let task = result.tasks.remove(at: index)
        let goalName = GoalDisplayNameFormatting.formatGoalDisplayName(task.text)
        result.newGoals.append(CategorizedNewGoal(name: goalName, confidence: task.confidence))
    }
    
    func moveGoalUpdateToTasks(_ updateId: UUID) {
        guard let index = result.goalUpdates.firstIndex(where: { $0.id == updateId }) else { return }
        let update = result.goalUpdates.remove(at: index)
        result.tasks.append(CategorizedTask(text: update.text, schedule: .someday, confidence: update.confidence, linkedGoalName: nil))
    }
    
    var isEmpty: Bool {
        return result.tasks.isEmpty && result.newGoals.isEmpty && result.goalUpdates.isEmpty && result.taskCompletions.isEmpty
    }
    
    // MARK: - Save
    
    private func pickGoalColor(existingGoals: [Goal]) -> String {
        let palette = [
            "#A78BFA", "#34D399", "#F87171", "#60A5FA", "#FBBF24",
            "#FB923C", "#38BDF8", "#F472B6", "#A3E635", "#E879F9"
        ]
        
        var colorUsage: [String: Int] = [:]
        for color in palette {
            colorUsage[color.uppercased()] = 0
        }
        
        for goal in existingGoals where goal.archivedAt == nil {
            let color = goal.color.uppercased()
            if colorUsage.keys.contains(color) {
                colorUsage[color, default: 0] += 1
            }
        }
        
        return palette.min { a, b in
            let countA = colorUsage[a.uppercased()] ?? 0
            let countB = colorUsage[b.uppercased()] ?? 0
            if countA != countB {
                return countA < countB
            }
            let indexA = palette.firstIndex(of: a) ?? 0
            let indexB = palette.firstIndex(of: b) ?? 0
            return indexA < indexB
        } ?? palette[0]
    }
    
    func save(modelContext: ModelContext) {
        // Fetch existing goals to link tasks
        let existingGoals = (try? modelContext.fetch(FetchDescriptor<Goal>())) ?? []
        var activeGoalsTracker = existingGoals

        let persistedTasks = (try? modelContext.fetch(FetchDescriptor<Task>())) ?? []
        
        for completion in result.taskCompletions {
            guard let match = persistedTasks.first(where: { $0.id == completion.matchedTaskId && !$0.completed }) else { continue }
            match.completed = true
            match.completedAt = Date()
            if let goal = match.linkedGoal {
                let entry = GoalEntry(text: match.text, type: .detailed, goal: goal)
                modelContext.insert(entry)
            }
        }

        // Save new goals first so tasks can link to freshly inserted goals by name.
        for catNewGoal in result.newGoals {
            let color = pickGoalColor(existingGoals: activeGoalsTracker)
            let goal = Goal(name: catNewGoal.name, color: color)
            modelContext.insert(goal)
            activeGoalsTracker.append(goal)
        }

        func resolveGoalForLink(named linkedName: String) -> Goal? {
            if let g = activeGoalsTracker.first(where: { $0.name == linkedName }) {
                return g
            }
            return activeGoalsTracker.first(where: { $0.name.caseInsensitiveCompare(linkedName) == .orderedSame })
        }

        for catTask in result.tasks {
            let task = Task(text: catTask.text, schedule: catTask.schedule, source: .typed)
            if let linkedName = catTask.linkedGoalName, let goal = resolveGoalForLink(named: linkedName) {
                task.linkedGoal = goal
            }
            modelContext.insert(task)
        }
        
        // Save Goal Updates
        for update in result.goalUpdates {
            let entry = GoalEntry(text: update.text, type: .detailed, goal: update.matchedGoal)
            modelContext.insert(entry)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save categorization result: \(error)")
        }
    }
}
