import Foundation
import NaturalLanguage

final class OpenRouterCategorizationEngine: CategorizationEngine {
    private let legacyFallback = LegacyRuleBasedCategorizationEngine()
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func categorize(text: String, existingGoals: [Goal]) async -> CategorizationResult {
        let apiKey = UserPreferences.aiAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !apiKey.isEmpty else {
            var fallback = await legacyFallback.categorize(text: text, existingGoals: existingGoals)
            fallback.source = .legacyLocal(reason: "no API key")
            return fallback
        }

        do {
            let llmOutput = try await requestCategorization(text: text, existingGoals: existingGoals, apiKey: apiKey)
            return mapOutput(llmOutput, existingGoals: existingGoals, source: .byom(model: UserPreferences.aiModel))
        } catch {
            print("OpenRouter categorization failed, using legacy fallback: \(error)")
            var fallback = await legacyFallback.categorize(text: text, existingGoals: existingGoals)
            fallback.source = .legacyLocal(reason: "connection failed")
            return fallback
        }
    }

    private func requestCategorization(text: String, existingGoals: [Goal], apiKey: String) async throws -> OpenRouterCategorizationOutput {
        let endpoint = UserPreferences.aiEndpoint.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: endpoint) else {
            throw OpenRouterError.invalidURL
        }

        let goalNames = existingGoals.map(\.name)
        let systemPrompt = """
        You classify a brain dump into tasks, new goals, and goal updates.
        Return JSON only. No markdown.
        Rules:
        - Tasks are one-off actionable items.
        - New goals are longer-term pursuits.
        - Goal updates are progress notes for an existing goal.
        - Split multi-action prompts into separate items.
        - Keep task/goal text concise and natural.
        - Schedules: today, thisWeek, someday.
        - If user says "today/tonight/now" => today.
        - If user says "tomorrow/this week/soon" => thisWeek.
        - Otherwise schedule = someday.
        - Only set matchedGoalName if it clearly maps to one of the provided existing goals.
        - For tasks, if it clearly relates to an existing goal, set linkedGoalName to that goal's name.
        - Goals must be broad, ongoing pursuits that a person works toward over weeks or months — e.g., 'Learn Music', 'Motion Design', 'Fitness', 'Read More'. Specific one-time activities like 'learn a new chord progression', 'do 10 pushups', or 'read one chapter' are tasks, not goals — even if they sound aspirational. When in doubt, classify as a task.
        - If a specific activity clearly belongs under a broader existing goal (e.g., "learn a new chord progression" -> existing "Guitar" goal), classify it as a task linked to that goal, not a new goal.
        """

        let userPrompt = """
        Existing goals: \(goalNames)
        User input: \(text)

        Return this JSON shape exactly:
        {
          "tasks": [{"text":"string","schedule":"today|thisWeek|someday","linkedGoalName":"string|null","confidence":0.0}],
          "newGoals": [{"name":"string","confidence":0.0}],
          "goalUpdates": [{"text":"string","matchedGoalName":"string","confidence":0.0}]
        }
        """

        do {
            let rawContent = try await performRequest(
                url: url,
                apiKey: apiKey,
                systemPrompt: systemPrompt,
                userPrompt: userPrompt,
                includeResponseFormat: true
            )
            return try decodeCategorizationOutput(from: rawContent)
        } catch let OpenRouterError.httpFailure(statusCode, _) where statusCode == 400 || statusCode == 422 {
            let rawContent = try await performRequest(
                url: url,
                apiKey: apiKey,
                systemPrompt: systemPrompt,
                userPrompt: userPrompt,
                includeResponseFormat: false
            )
            return try decodeCategorizationOutput(from: rawContent)
        } catch {
            let rawContent = try await performRequest(
                url: url,
                apiKey: apiKey,
                systemPrompt: systemPrompt,
                userPrompt: userPrompt,
                includeResponseFormat: false
            )
            return try decodeCategorizationOutput(from: rawContent)
        }
    }

    private func performRequest(
        url: URL,
        apiKey: String,
        systemPrompt: String,
        userPrompt: String,
        includeResponseFormat: Bool
    ) async throws -> String {
        let requestBody = OpenRouterRequest(
            model: UserPreferences.aiModel,
            temperature: 0.1,
            response_format: includeResponseFormat ? OpenRouterResponseFormat(type: "json_object") : nil,
            messages: [
                OpenRouterMessage(role: "system", content: systemPrompt),
                OpenRouterMessage(role: "user", content: userPrompt)
            ]
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 45
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        if (url.host ?? "").contains("openrouter.ai") {
            request.setValue("https://defog.app", forHTTPHeaderField: "HTTP-Referer")
            request.setValue("Defog iOS", forHTTPHeaderField: "X-Title")
        }
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenRouterError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            throw OpenRouterError.httpFailure(statusCode: httpResponse.statusCode, body: body)
        }

        let completion = try JSONDecoder().decode(OpenRouterCompletionResponse.self, from: data)
        guard let content = completion.choices.first?.message.contentText, !content.isEmpty else {
            throw OpenRouterError.emptyContent
        }
        return content
    }

    private func decodeCategorizationOutput(from content: String) throws -> OpenRouterCategorizationOutput {
        let cleaned = stripCodeFences(from: content)
        let jsonString = firstJSONObjectString(in: cleaned) ?? cleaned
        guard let cleanedData = jsonString.data(using: .utf8) else {
            throw OpenRouterError.invalidJSON
        }

        do {
            return try JSONDecoder().decode(OpenRouterCategorizationOutput.self, from: cleanedData)
        } catch {
            if let repaired = repairLooselyFormattedJSON(jsonString),
               let repairedData = repaired.data(using: .utf8) {
                return try JSONDecoder().decode(OpenRouterCategorizationOutput.self, from: repairedData)
            }
            throw OpenRouterError.invalidJSON
        }
    }

    private func firstJSONObjectString(in raw: String) -> String? {
        var startIndex: String.Index?
        var depth = 0
        var isInString = false
        var previousWasEscape = false

        for index in raw.indices {
            let char = raw[index]

            if isInString {
                if previousWasEscape {
                    previousWasEscape = false
                } else if char == "\\" {
                    previousWasEscape = true
                } else if char == "\"" {
                    isInString = false
                }
                continue
            }

            if char == "\"" {
                isInString = true
                continue
            }

            if char == "{" {
                if depth == 0 {
                    startIndex = index
                }
                depth += 1
                continue
            }

            if char == "}" {
                guard depth > 0 else { continue }
                depth -= 1
                if depth == 0, let start = startIndex {
                    return String(raw[start...index])
                }
            }
        }

        return nil
    }

    private func repairLooselyFormattedJSON(_ content: String) -> String? {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        var candidate = trimmed
        candidate = candidate.replacingOccurrences(of: "\n", with: " ")
        candidate = candidate.replacingOccurrences(of: "\t", with: " ")
        candidate = candidate.replacingOccurrences(of: "'", with: "\"")
        return candidate
    }

    private func mapOutput(_ output: OpenRouterCategorizationOutput, existingGoals: [Goal], source: CategorizationSource) -> CategorizationResult {
        let tasks: [CategorizedTask] = output.tasks.compactMap { item in
            let text = item.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return nil }
            let linkedName = (item.linkedGoalName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let matchedLinkedGoalName = linkedName.isEmpty ? nil : matchExistingGoalName(linkedName, existingGoals: existingGoals)?.name
            return CategorizedTask(
                text: text,
                schedule: TaskSchedule(rawValue: item.schedule) ?? .someday,
                confidence: item.confidence ?? 0.9,
                linkedGoalName: matchedLinkedGoalName
            )
        }

        let newGoals: [CategorizedNewGoal] = output.newGoals.compactMap { item in
            let name = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { return nil }
            return CategorizedNewGoal(name: name, confidence: item.confidence ?? 0.85)
        }

        let goalUpdates: [CategorizedGoalUpdate] = output.goalUpdates.compactMap { item in
            let text = item.text.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchedName = (item.matchedGoalName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty, !matchedName.isEmpty else { return nil }
            guard let goal = matchExistingGoalName(matchedName, existingGoals: existingGoals) else { return nil }
            return CategorizedGoalUpdate(text: text, matchedGoal: goal, confidence: item.confidence ?? 0.85)
        }

        return CategorizationResult(tasks: tasks, newGoals: newGoals, goalUpdates: goalUpdates, source: source)
    }

    private func matchExistingGoalName(_ targetName: String, existingGoals: [Goal]) -> Goal? {
        let normalizedTarget = normalize(targetName)
        guard !normalizedTarget.isEmpty else { return nil }

        if let exact = existingGoals.first(where: { normalize($0.name) == normalizedTarget }) {
            return exact
        }
        if let contained = existingGoals.first(where: { normalize($0.name).contains(normalizedTarget) || normalizedTarget.contains(normalize($0.name)) }) {
            return contained
        }

        return existingGoals
            .map { (goal: $0, score: similarity(normalize($0.name), normalizedTarget)) }
            .filter { $0.score >= 0.78 }
            .max(by: { $0.score < $1.score })?
            .goal
    }

    private func normalize(_ text: String) -> String {
        text
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .punctuationCharacters)
    }

    private func similarity(_ a: String, _ b: String) -> Double {
        guard !a.isEmpty, !b.isEmpty else { return 0 }
        let distance = levenshtein(a, b)
        let maxLen = max(a.count, b.count)
        guard maxLen > 0 else { return 1 }
        return 1.0 - (Double(distance) / Double(maxLen))
    }

    private func levenshtein(_ aStr: String, _ bStr: String) -> Int {
        let a = Array(aStr)
        let b = Array(bStr)

        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }

        var dist = [[Int]](repeating: [Int](repeating: 0, count: b.count + 1), count: a.count + 1)

        for i in 0...a.count { dist[i][0] = i }
        for j in 0...b.count { dist[0][j] = j }

        for i in 1...a.count {
            for j in 1...b.count {
                if a[i - 1] == b[j - 1] {
                    dist[i][j] = dist[i - 1][j - 1]
                } else {
                    dist[i][j] = min(
                        dist[i - 1][j] + 1,
                        dist[i][j - 1] + 1,
                        dist[i - 1][j - 1] + 1
                    )
                }
            }
        }

        return dist[a.count][b.count]
    }

    private func stripCodeFences(from content: String) -> String {
        var text = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("```") {
            text = text.replacingOccurrences(of: "```json", with: "")
            text = text.replacingOccurrences(of: "```", with: "")
            text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return text
    }
}

private struct OpenRouterRequest: Encodable {
    let model: String
    let temperature: Double
    let response_format: OpenRouterResponseFormat?
    let messages: [OpenRouterMessage]
}

private struct OpenRouterResponseFormat: Encodable {
    let type: String
}

private struct OpenRouterMessage: Encodable {
    let role: String
    let content: String
}

private struct OpenRouterCompletionResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            struct ContentPart: Decodable {
                let type: String?
                let text: String?
            }

            let content: String?
            let contentParts: [ContentPart]?

            var contentText: String? {
                if let content, !content.isEmpty { return content }
                guard let contentParts else { return nil }
                let joined = contentParts
                    .compactMap(\.text)
                    .joined(separator: " ")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                return joined.isEmpty ? nil : joined
            }

            private enum CodingKeys: String, CodingKey {
                case content
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                if let text = try? container.decode(String.self, forKey: .content) {
                    content = text
                    contentParts = nil
                    return
                }
                if let parts = try? container.decode([ContentPart].self, forKey: .content) {
                    content = nil
                    contentParts = parts
                    return
                }
                content = nil
                contentParts = nil
            }
        }
        let message: Message
    }
    let choices: [Choice]
}

private struct OpenRouterCategorizationOutput: Decodable {
    struct TaskItem: Decodable {
        let text: String
        let schedule: String
        let linkedGoalName: String?
        let confidence: Double?

        private enum CodingKeys: String, CodingKey {
            case text
            case schedule
            case linkedGoalName
            case linked_goal_name
            case confidence
        }

        init(from decoder: Decoder) throws {
            if let single = try? decoder.singleValueContainer(),
               let rawText = try? single.decode(String.self) {
                text = rawText
                schedule = "someday"
                linkedGoalName = nil
                confidence = nil
                return
            }

            let container = try decoder.container(keyedBy: CodingKeys.self)
            text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
            schedule = try container.decodeIfPresent(String.self, forKey: .schedule) ?? "someday"
            let camelLinked = try container.decodeIfPresent(String.self, forKey: .linkedGoalName)
            let snakeLinked = try container.decodeIfPresent(String.self, forKey: .linked_goal_name)
            linkedGoalName = camelLinked ?? snakeLinked
            confidence = try container.decodeIfPresent(Double.self, forKey: .confidence)
        }
    }

    struct NewGoalItem: Decodable {
        let name: String
        let confidence: Double?

        private enum CodingKeys: String, CodingKey {
            case name
            case confidence
        }

        init(from decoder: Decoder) throws {
            if let single = try? decoder.singleValueContainer(),
               let rawName = try? single.decode(String.self) {
                name = rawName
                confidence = nil
                return
            }

            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
            confidence = try container.decodeIfPresent(Double.self, forKey: .confidence)
        }
    }

    struct GoalUpdateItem: Decodable {
        let text: String
        let matchedGoalName: String?
        let confidence: Double?

        private enum CodingKeys: String, CodingKey {
            case text
            case matchedGoalName
            case matched_goal_name
            case confidence
        }

        init(from decoder: Decoder) throws {
            if let single = try? decoder.singleValueContainer(),
               let rawText = try? single.decode(String.self) {
                text = rawText
                matchedGoalName = nil
                confidence = nil
                return
            }

            let container = try decoder.container(keyedBy: CodingKeys.self)
            text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
            let camelMatchedGoal = try container.decodeIfPresent(String.self, forKey: .matchedGoalName)
            let snakeMatchedGoal = try container.decodeIfPresent(String.self, forKey: .matched_goal_name)
            matchedGoalName = camelMatchedGoal ?? snakeMatchedGoal
            confidence = try container.decodeIfPresent(Double.self, forKey: .confidence)
        }
    }

    let tasks: [TaskItem]
    let newGoals: [NewGoalItem]
    let goalUpdates: [GoalUpdateItem]

    private enum CodingKeys: String, CodingKey {
        case tasks
        case newGoals
        case new_goals
        case goalUpdates
        case goal_updates
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tasks = try container.decodeIfPresent([TaskItem].self, forKey: .tasks) ?? []
        let camelNewGoals = try container.decodeIfPresent([NewGoalItem].self, forKey: .newGoals)
        let snakeNewGoals = try container.decodeIfPresent([NewGoalItem].self, forKey: .new_goals)
        newGoals = camelNewGoals ?? snakeNewGoals ?? []

        let camelGoalUpdates = try container.decodeIfPresent([GoalUpdateItem].self, forKey: .goalUpdates)
        let snakeGoalUpdates = try container.decodeIfPresent([GoalUpdateItem].self, forKey: .goal_updates)
        goalUpdates = camelGoalUpdates ?? snakeGoalUpdates ?? []
    }
}

private enum OpenRouterError: Error {
    case invalidURL
    case invalidResponse
    case httpFailure(statusCode: Int, body: String)
    case emptyContent
    case invalidJSON
}

final class LegacyRuleBasedCategorizationEngine: CategorizationEngine {
    
    // Finite action verbs mapping to tasks
    private let finiteActionVerbs: Set<String> = [
        "buy", "call", "send", "fix", "reply", "book", "pay", "submit", "get", "pick", "drop", "email", "text", "message", "order", "schedule", "clean"
    ]
    
    // Ongoing pursuit verbs mapping to goals
    private let ongoingPursuitVerbs: Set<String> = [
        "learn", "practice", "improve", "work", "build", "study", "read", "write", "train", "exercise", "develop", "research", "explore"
    ]
    
    // Schedule keywords
    private let todayKeywords: Set<String> = ["today", "tonight", "now"]
    private let thisWeekKeywords: Set<String> = ["week", "tomorrow", "soon"]
    
    func categorize(text: String, existingGoals: [Goal]) async -> CategorizationResult {
        var resultTasks: [CategorizedTask] = []
        var resultNewGoals: [CategorizedNewGoal] = []
        var resultGoalUpdates: [CategorizedGoalUpdate] = []
        
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            let sentence = String(text[tokenRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !sentence.isEmpty else { return true }

            let clauses = self.splitIntoClauses(sentence)
            for clause in clauses {
                self.processSentence(clause, existingGoals: existingGoals, resultTasks: &resultTasks, resultNewGoals: &resultNewGoals, resultGoalUpdates: &resultGoalUpdates)
            }
            return true
        }
        
        return CategorizationResult(
            tasks: resultTasks,
            newGoals: resultNewGoals,
            goalUpdates: resultGoalUpdates,
            source: .legacyLocal(reason: "default path")
        )
    }
    
    private func processSentence(_ sentence: String, existingGoals: [Goal], resultTasks: inout [CategorizedTask], resultNewGoals: inout [CategorizedNewGoal], resultGoalUpdates: inout [CategorizedGoalUpdate]) {
        let normalizedSentence = cleanupClause(sentence)
        guard !normalizedSentence.isEmpty else { return }

        let tagger = NLTagger(tagSchemes: [.lemma, .lexicalClass])
        tagger.string = normalizedSentence
        
        var isTask = false
        var isGoal = false
        var nounPhrases: [String] = []
        var schedule: TaskSchedule = .someday
        
        let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation]
        
        // Quick pass to infer schedule
        let lowercasedSentence = normalizedSentence.lowercased()
        if todayKeywords.contains(where: { lowercasedSentence.contains($0) }) {
            schedule = .today
        } else if thisWeekKeywords.contains(where: { lowercasedSentence.contains($0) }) {
            schedule = .thisWeek
        }

        // Imperative fast-path: first token often encodes intent for short prompts ("call dentist", "learn guitar")
        if let firstWord = lowercasedSentence.split(separator: " ").first.map(String.init) {
            if finiteActionVerbs.contains(firstWord) {
                isTask = true
            }
            if ongoingPursuitVerbs.contains(firstWord) {
                isGoal = true
            }
        }
        
        tagger.enumerateTags(in: normalizedSentence.startIndex..<normalizedSentence.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            guard let tag = tag else { return true }
            let word = String(normalizedSentence[tokenRange]).lowercased()
            
            if tag == .verb {
                let lemmaTagger = NLTagger(tagSchemes: [.lemma])
                lemmaTagger.string = word
                if let lemmaPos = lemmaTagger.tag(at: word.startIndex, unit: .word, scheme: .lemma).0 {
                    let lemma = lemmaPos.rawValue.lowercased()
                    if finiteActionVerbs.contains(lemma) || finiteActionVerbs.contains(word) {
                        isTask = true
                    } else if ongoingPursuitVerbs.contains(lemma) || ongoingPursuitVerbs.contains(word) {
                        isGoal = true
                    }
                } else {
                    // Fallback to word
                    if finiteActionVerbs.contains(word) { isTask = true }
                    if ongoingPursuitVerbs.contains(word) { isGoal = true }
                }
            } else if tag == .noun {
                nounPhrases.append(word)
            }
            
            return true
        }
        
        // If neither was matched but we have a sentence, try a heuristic or default to Task
        if !isTask && !isGoal {
            // Defaulting shorter actionable lines to tasks
            isTask = true
        }
        
        // Add specificity check for goals
        if isGoal {
            let words = normalizedSentence.lowercased().split(separator: " ").map(String.init)
            let hasQuantifier = words.contains(where: { ["a", "an", "one", "some"].contains($0) || Int($0) != nil }) || normalizedSentence.lowercased().contains("a new")
            let hasSpecificObject = self.hasSpecificObjectPattern(normalizedSentence)
            
            if hasQuantifier || hasSpecificObject {
                isGoal = false
                isTask = true
            }
        }
        
        // We prioritize explicit goal verbs over task verbs if both exist, for the purpose of the prototype
        if isGoal {
            // Extract the target of the goal (heuristic: text after the verb)
            // For now, use the full sentence to represent the goal intent
            let extractedTarget = extractGoalName(from: normalizedSentence, nounPhrases: nounPhrases)
            
            if let matchedGoal = matchExistingGoal(extractedTarget, existingGoals: existingGoals) {
                resultGoalUpdates.append(CategorizedGoalUpdate(text: normalizedSentence, matchedGoal: matchedGoal, confidence: 0.9))
            } else {
                resultNewGoals.append(CategorizedNewGoal(name: extractedTarget, confidence: 0.8))
            }
        } else if isTask {
            var matchedLinkedGoalName: String? = nil
            if !nounPhrases.isEmpty {
                var candidates = nounPhrases
                if nounPhrases.count > 1 {
                    for i in 0..<(nounPhrases.count - 1) {
                        candidates.append("\(nounPhrases[i]) \(nounPhrases[i+1])")
                    }
                }
                
                var bestGoal: Goal? = nil
                var bestScore = 0.0
                
                for candidate in candidates {
                    let normalizedCandidate = candidate.lowercased().trimmingCharacters(in: .punctuationCharacters)
                    guard !normalizedCandidate.isEmpty else { continue }
                    
                    for goal in existingGoals {
                        let normalizedGoalName = goal.name.lowercased().trimmingCharacters(in: .punctuationCharacters)
                        guard !normalizedGoalName.isEmpty else { continue }
                        
                        var score = 0.0
                        if normalizedCandidate == normalizedGoalName {
                            score = 1.0
                        } else if normalizedCandidate.contains(normalizedGoalName) || normalizedGoalName.contains(normalizedCandidate) {
                            score = 0.9
                        } else {
                            let distance = levenshtein(normalizedCandidate, normalizedGoalName)
                            let maxLength = max(normalizedCandidate.count, normalizedGoalName.count)
                            score = 1.0 - (Double(distance) / Double(maxLength))
                        }
                        
                        if score >= 0.75 && score > bestScore {
                            bestScore = score
                            bestGoal = goal
                        }
                    }
                }
                matchedLinkedGoalName = bestGoal?.name
            }
            resultTasks.append(CategorizedTask(text: normalizedSentence, schedule: schedule, confidence: 0.85, linkedGoalName: matchedLinkedGoalName))
        }
    }

    private func hasSpecificObjectPattern(_ text: String) -> Bool {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation]
        
        var foundDeterminer = false
        var hasPattern = false
        let specificDeterminers: Set<String> = ["the", "this", "that", "these", "those", "my", "your", "his", "her", "our", "their"]
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            guard let tag = tag else { return true }
            let word = String(text[tokenRange]).lowercased()
            
            if specificDeterminers.contains(word) {
                foundDeterminer = true
            } else if tag == .noun {
                if foundDeterminer {
                    hasPattern = true
                    return false
                }
            } else if tag != .adjective && tag != .adverb {
                foundDeterminer = false
            }
            
            return true
        }
        
        return hasPattern
    }

    private func splitIntoClauses(_ sentence: String) -> [String] {
        let baseParts = sentence
            .replacingOccurrences(of: "\n", with: ",")
            .split(whereSeparator: { $0 == "," || $0 == ";" })
            .map { String($0) }

        var clauses: [String] = []
        for part in baseParts {
            clauses.append(contentsOf: splitOnVerbBoundaries(part))
        }

        return clauses
            .map { cleanupClause($0) }
            .filter { !$0.isEmpty }
    }

    private func splitOnVerbBoundaries(_ text: String) -> [String] {
        let triggerVerbs = finiteActionVerbs.union(ongoingPursuitVerbs)
        let words = text.split(whereSeparator: \.isWhitespace).map(String.init)

        var chunks: [[String]] = []
        var current: [String] = []
        var seenVerbInChunk = false

        for word in words {
            let normalizedWord = normalizeToken(word)
            let isTrigger = triggerVerbs.contains(normalizedWord)

            if isTrigger && seenVerbInChunk {
                if !current.isEmpty {
                    chunks.append(current)
                }
                current = [word]
                seenVerbInChunk = true
            } else {
                current.append(word)
                if isTrigger {
                    seenVerbInChunk = true
                }
            }
        }

        if !current.isEmpty {
            chunks.append(current)
        }

        return chunks.map { $0.joined(separator: " ") }
    }

    private func cleanupClause(_ text: String) -> String {
        var result = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Strip conversational lead-ins for cleaner task/goal text.
        let preambles = [
            "i wanna ",
            "i want to ",
            "i need to ",
            "please ",
            "can you ",
            "could you ",
            "let me "
        ]
        let lowercased = result.lowercased()
        if let prefix = preambles.first(where: { lowercased.hasPrefix($0) }) {
            result = String(result.dropFirst(prefix.count))
        }

        let leadingConjunctions = ["and ", "then "]
        let lowered = result.lowercased()
        if let prefix = leadingConjunctions.first(where: { lowered.hasPrefix($0) }) {
            result = String(result.dropFirst(prefix.count))
        }

        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        let loweredTrailing = result.lowercased()
        if loweredTrailing.hasSuffix(" and") {
            result = String(result.dropLast(4)).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return result
    }

    private func normalizeToken(_ word: String) -> String {
        word
            .lowercased()
            .trimmingCharacters(in: .punctuationCharacters)
    }
    
    private func extractGoalName(from sentence: String, nounPhrases: [String]) -> String {
        guard !nounPhrases.isEmpty else { return "New Goal" }
        // Simple heuristic: combine nouns. In a real app we'd use noun phrase extraction
        return nounPhrases.map { $0.capitalized }.joined(separator: " ")
    }
    
    private func matchExistingGoal(_ target: String, existingGoals: [Goal]) -> Goal? {
        let normalizedTarget = target.lowercased().trimmingCharacters(in: .punctuationCharacters)
        
        for goal in existingGoals {
            let normalizedGoalName = goal.name.lowercased().trimmingCharacters(in: .punctuationCharacters)
            // Exact match auto-merge requirement
            if normalizedTarget == normalizedGoalName {
                return goal
            }
            // Basic fuzzy match (e.g. substring or high overlap for MVP)
            if normalizedTarget.contains(normalizedGoalName) || normalizedGoalName.contains(normalizedTarget) {
                 return goal
            }
            
            // Levenshtein distance >= 0.75 would be implemented here for real
            let distance = levenshtein(normalizedTarget, normalizedGoalName)
            let maxLength = max(normalizedTarget.count, normalizedGoalName.count)
            let similarity = 1.0 - (Double(distance) / Double(maxLength))
            if similarity >= 0.75 {
                return goal
            }
        }
        return nil
    }
    
    // Helper for fuzzy string matching
    private func levenshtein(_ aStr: String, _ bStr: String) -> Int {
        let a = Array(aStr)
        let b = Array(bStr)

        if a.count == 0 { return b.count }
        if b.count == 0 { return a.count }

        var dist = [[Int]](repeating: [Int](repeating: 0, count: b.count + 1), count: a.count + 1)

        for i in 0...a.count { dist[i][0] = i }
        for j in 0...b.count { dist[0][j] = j }

        for i in 1...a.count {
            for j in 1...b.count {
                if a[i - 1] == b[j - 1] {
                    dist[i][j] = dist[i - 1][j - 1]
                } else {
                    dist[i][j] = min(
                        dist[i - 1][j] + 1,
                        dist[i][j - 1] + 1,
                        dist[i - 1][j - 1] + 1
                    )
                }
            }
        }

        return dist[a.count][b.count]
    }
}
