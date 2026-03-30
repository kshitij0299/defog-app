import Foundation

/// Locale-aware display normalization for goal names from extraction / voice (preview + review),
/// without rewriting mixed-case user strings (e.g. "iOS").
enum GoalDisplayNameFormatting {
    /// Uses `String.capitalized(with: Locale.current)` only when the trimmed string is uniformly
    /// lower- or uppercased, so typical LLM outputs like `music` / `MUSIC` become `Music`.
    static func formatGoalDisplayName(_ raw: String) -> String {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return t }
        let locale = Locale.current
        let lower = t.lowercased(with: locale)
        let upper = t.uppercased(with: locale)
        if t == lower || t == upper {
            return t.capitalized(with: locale)
        }
        return t
    }
}
