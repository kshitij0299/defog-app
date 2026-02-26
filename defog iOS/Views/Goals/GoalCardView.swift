import SwiftUI
import SwiftData

struct GoalCardView: View {
    let goal: Goal
    
    // We'll calculate a placeholder streak or actual streak here based on entries.
    // Spec: "momentum indicator ('X days in a row' - shown only when streak >= 2)"
    var currentStreak: Int {
        // Simple mock calculation for now, or real calculation from entries.
        // Assuming entries are sorted. Let's calculate a real streak based on days.
        calculateStreak(for: goal)
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: goal.color) ?? .blue)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.name)
                    .font(.headline)
                
                HStack(spacing: 12) {
                    Text("\(goal.entries.count) \((goal.entries.count == 1) ? "entry" : "entries")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if currentStreak >= 2 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("\(currentStreak) days")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    func calculateStreak(for goal: Goal) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let uniqueDays = Set(goal.entries.map { calendar.startOfDay(for: $0.createdAt) })
        let sortedDays = uniqueDays.sorted(by: >)
        
        if sortedDays.isEmpty { return 0 }
        
        var streak = 0
        var expectedDate = today
        
        // If the latest entry is neither today nor yesterday, streak is 0
        if !sortedDays.contains(today) && !sortedDays.contains(calendar.date(byAdding: .day, value: -1, to: today)!) {
            return 0
        }
        
        // Check backwards from today or yesterday
        let startDate = sortedDays.contains(today) ? today : calendar.date(byAdding: .day, value: -1, to: today)!
        expectedDate = startDate
        
        for date in sortedDays {
            if date > startDate { continue }
            if date == expectedDate {
                streak += 1
                expectedDate = calendar.date(byAdding: .day, value: -1, to: expectedDate)!
            } else {
                break
            }
        }
        
        return streak
    }
}

// Helper extension for Color initialization from hex string, if needed later
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
