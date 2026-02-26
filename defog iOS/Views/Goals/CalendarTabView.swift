import SwiftUI

struct CalendarTabView: View {
    let goal: Goal
    
    // We want a 35-day rolling heatmap
    var days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var result: [Date] = []
        for i in (0..<35).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                result.append(date)
            }
        }
        return result
    }
    
    var entriesByDay: [Date: [GoalEntry]] {
        let calendar = Calendar.current
        return Dictionary(grouping: goal.entries) { entry in
            calendar.startOfDay(for: entry.createdAt)
        }
    }
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Last 35 Days")
                    .font(.headline)
                    .padding(.horizontal)
                
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(days, id: \.self) { day in
                        DayCell(
                            date: day,
                            hasEntries: entriesByDay[day] != nil && !entriesByDay[day]!.isEmpty,
                            colorHex: goal.color
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
    }
}

private struct DayCell: View {
    let date: Date
    let hasEntries: Bool
    let colorHex: String
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(hasEntries ? (Color(hex: colorHex) ?? .blue) : Color(UIColor.secondarySystemGroupedBackground))
                .aspectRatio(1, contentMode: .fill)
            
            if isToday {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.primary, lineWidth: 2)
            }
            
            Text(date.formatted(.dateTime.day()))
                .font(.system(size: 10))
                .foregroundColor(hasEntries ? .white : .primary)
        }
    }
}
