import SwiftUI

/// Shared background, shadow, and leading goal accent for task rows (Tasks tab + Brain Dump live preview).
struct TaskCardChrome<Checkbox: View, MainContent: View>: View {
    var goalAccentColor: Color?
    @ViewBuilder var checkbox: () -> Checkbox
    @ViewBuilder var mainContent: () -> MainContent

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            checkbox()
            mainContent()
        }
        .padding(.leading, 0)
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(alignment: .leading) {
            if let goalAccentColor {
                Rectangle()
                    .fill(goalAccentColor)
                    .frame(width: 4)
                    .clipShape(Capsule())
                    .padding(.vertical, 6)
                    .padding(.leading, 4)
            }
        }
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

/// Same task-card surface without a checkbox column (Brain Dump live preview).
struct TaskCardChromeContentOnly<Content: View>: View {
    var goalAccentColor: Color?
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(alignment: .leading) {
                if let goalAccentColor {
                    Rectangle()
                        .fill(goalAccentColor)
                        .frame(width: 4)
                        .clipShape(Capsule())
                        .padding(.vertical, 6)
                        .padding(.leading, 4)
                }
            }
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}
