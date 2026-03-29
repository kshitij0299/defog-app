import SwiftUI

struct TaskPillView: View {
    private let pillHorizontalPadding: CGFloat = 10
    private let pillVerticalPadding: CGFloat = 7
    private let pillMinTapTarget: CGFloat = 44

    let title: String
    let style: Style

    enum Style {
        case schedule(color: Color)
        case linkedGoal(color: Color)
        case unlinkedGoal
    }

    var body: some View {
        switch style {
        case .schedule(let color):
            Text(title)
                .font(.caption2.weight(.medium))
                .fontDesign(.rounded)
                .padding(.horizontal, pillHorizontalPadding)
                .padding(.vertical, pillVerticalPadding)
                .background(color.opacity(0.15))
                .foregroundColor(color)
                .clipShape(Capsule())
                .frame(minHeight: pillMinTapTarget)
                .contentShape(Rectangle())

        case .linkedGoal(let color):
            HStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                Text(title)
                    .font(.caption2.weight(.medium))
                    .fontDesign(.rounded)
                    .foregroundColor(color)
            }
            .padding(.horizontal, pillHorizontalPadding)
            .padding(.vertical, pillVerticalPadding)
            .background(color.opacity(0.1))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
            .frame(minHeight: pillMinTapTarget)
            .contentShape(Rectangle())

        case .unlinkedGoal:
            Text(title)
                .font(.caption2.weight(.medium))
                .fontDesign(.rounded)
                .foregroundColor(Color(uiColor: .systemGray2))
                .padding(.horizontal, pillHorizontalPadding)
                .padding(.vertical, pillVerticalPadding)
                .overlay(
                    Capsule()
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3]))
                        .foregroundColor(Color(uiColor: .systemGray3))
                )
                .frame(minHeight: pillMinTapTarget)
                .contentShape(Rectangle())
        }
    }
}
